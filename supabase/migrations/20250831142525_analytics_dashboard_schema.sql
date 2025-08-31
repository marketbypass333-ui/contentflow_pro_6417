-- Location: supabase/migrations/20250831142525_analytics_dashboard_schema.sql
-- Schema Analysis: Existing tables: messages, profiles
-- Integration Type: addition/extension
-- Dependencies: profiles table (existing)

-- Social media platforms and analytics schema
CREATE TYPE public.platform_type AS ENUM ('facebook', 'instagram', 'twitter', 'linkedin', 'tiktok', 'youtube');
CREATE TYPE public.post_status AS ENUM ('draft', 'scheduled', 'published', 'failed');
CREATE TYPE public.content_type AS ENUM ('image', 'video', 'text', 'carousel', 'story', 'reel');

-- Social media accounts connected to user profiles
CREATE TABLE public.social_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    platform public.platform_type NOT NULL,
    account_name TEXT NOT NULL,
    access_token TEXT,
    is_active BOOLEAN DEFAULT true,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    connected_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_sync_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Posts across all social platforms
CREATE TABLE public.social_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    account_id UUID REFERENCES public.social_accounts(id) ON DELETE CASCADE,
    platform public.platform_type NOT NULL,
    content_type public.content_type NOT NULL,
    title TEXT,
    content TEXT NOT NULL,
    media_url TEXT,
    status public.post_status DEFAULT 'draft',
    platform_post_id TEXT,
    scheduled_at TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Analytics data for posts
CREATE TABLE public.post_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES public.social_posts(id) ON DELETE CASCADE,
    views_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    reach INTEGER DEFAULT 0,
    impressions INTEGER DEFAULT 0,
    engagement_rate DECIMAL(5,2) DEFAULT 0.00,
    click_through_rate DECIMAL(5,2) DEFAULT 0.00,
    recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Daily analytics aggregation
CREATE TABLE public.daily_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    account_id UUID REFERENCES public.social_accounts(id) ON DELETE SET NULL,
    platform public.platform_type NOT NULL,
    analytics_date DATE NOT NULL,
    total_posts INTEGER DEFAULT 0,
    total_views INTEGER DEFAULT 0,
    total_likes INTEGER DEFAULT 0,
    total_comments INTEGER DEFAULT 0,
    total_shares INTEGER DEFAULT 0,
    total_reach INTEGER DEFAULT 0,
    total_impressions INTEGER DEFAULT 0,
    avg_engagement_rate DECIMAL(5,2) DEFAULT 0.00,
    follower_growth INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(profile_id, account_id, platform, analytics_date)
);

-- Audience insights and demographics
CREATE TABLE public.audience_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    account_id UUID REFERENCES public.social_accounts(id) ON DELETE CASCADE,
    platform public.platform_type NOT NULL,
    age_group TEXT NOT NULL, -- '18-24', '25-34', etc.
    gender TEXT NOT NULL, -- 'male', 'female', 'other'
    location TEXT NOT NULL, -- country or city
    percentage DECIMAL(5,2) NOT NULL,
    insight_type TEXT NOT NULL, -- 'age', 'gender', 'location'
    recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Peak activity times for audience
CREATE TABLE public.audience_activity (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    account_id UUID REFERENCES public.social_accounts(id) ON DELETE CASCADE,
    platform public.platform_type NOT NULL,
    hour_of_day INTEGER NOT NULL CHECK (hour_of_day >= 0 AND hour_of_day <= 23),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 1 AND day_of_week <= 7),
    activity_level DECIMAL(5,2) NOT NULL, -- percentage of audience active
    recorded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Essential indexes for performance
CREATE INDEX idx_social_accounts_profile_id ON public.social_accounts(profile_id);
CREATE INDEX idx_social_accounts_platform ON public.social_accounts(platform);
CREATE INDEX idx_social_posts_profile_id ON public.social_posts(profile_id);
CREATE INDEX idx_social_posts_account_id ON public.social_posts(account_id);
CREATE INDEX idx_social_posts_platform ON public.social_posts(platform);
CREATE INDEX idx_social_posts_status ON public.social_posts(status);
CREATE INDEX idx_post_analytics_post_id ON public.post_analytics(post_id);
CREATE INDEX idx_daily_analytics_profile_id ON public.daily_analytics(profile_id);
CREATE INDEX idx_daily_analytics_date ON public.daily_analytics(analytics_date);
CREATE INDEX idx_audience_insights_profile_id ON public.audience_insights(profile_id);
CREATE INDEX idx_audience_activity_profile_id ON public.audience_activity(profile_id);

-- Enable RLS for all analytics tables
ALTER TABLE public.social_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audience_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audience_activity ENABLE ROW LEVEL SECURITY;

-- RLS Policies using Pattern 2 (Simple User Ownership)
CREATE POLICY "users_manage_own_social_accounts"
ON public.social_accounts
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

CREATE POLICY "users_manage_own_social_posts"
ON public.social_posts
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

CREATE POLICY "users_view_own_post_analytics"
ON public.post_analytics
FOR SELECT
TO authenticated
USING (EXISTS (
    SELECT 1 FROM public.social_posts sp
    WHERE sp.id = post_analytics.post_id
    AND sp.profile_id = auth.uid()
));

CREATE POLICY "users_manage_own_daily_analytics"
ON public.daily_analytics
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

CREATE POLICY "users_manage_own_audience_insights"
ON public.audience_insights
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

CREATE POLICY "users_manage_own_audience_activity"
ON public.audience_activity
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

-- Analytics calculation functions
CREATE OR REPLACE FUNCTION public.calculate_engagement_rate(
    post_uuid UUID
) RETURNS DECIMAL(5,2)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    total_engagement INTEGER;
    total_reach INTEGER;
    engagement_rate DECIMAL(5,2);
BEGIN
    SELECT 
        COALESCE(pa.likes_count, 0) + COALESCE(pa.comments_count, 0) + COALESCE(pa.shares_count, 0),
        COALESCE(pa.reach, 1)
    INTO total_engagement, total_reach
    FROM public.post_analytics pa
    WHERE pa.post_id = post_uuid;
    
    IF total_reach = 0 THEN
        total_reach := 1;
    END IF;
    
    engagement_rate := (total_engagement::DECIMAL / total_reach::DECIMAL) * 100;
    
    RETURN LEAST(engagement_rate, 100.00);
END;
$$;

-- Function to get analytics summary for date range
CREATE OR REPLACE FUNCTION public.get_analytics_summary(
    user_profile_id UUID,
    start_date DATE,
    end_date DATE
) RETURNS TABLE(
    total_posts BIGINT,
    total_reach BIGINT,
    total_engagement BIGINT,
    avg_engagement_rate DECIMAL(5,2),
    follower_growth INTEGER,
    top_platform TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(sp.id) as total_posts,
        COALESCE(SUM(pa.reach), 0) as total_reach,
        COALESCE(SUM(pa.likes_count + pa.comments_count + pa.shares_count), 0) as total_engagement,
        COALESCE(AVG(pa.engagement_rate), 0.00)::DECIMAL(5,2) as avg_engagement_rate,
        COALESCE(SUM(da.follower_growth), 0)::INTEGER as follower_growth,
        COALESCE(
            (SELECT da2.platform::TEXT 
             FROM public.daily_analytics da2 
             WHERE da2.profile_id = user_profile_id 
             AND da2.analytics_date BETWEEN start_date AND end_date
             GROUP BY da2.platform 
             ORDER BY SUM(da2.total_reach) DESC 
             LIMIT 1), 
            'N/A'
        ) as top_platform
    FROM public.social_posts sp
    LEFT JOIN public.post_analytics pa ON sp.id = pa.post_id
    LEFT JOIN public.daily_analytics da ON sp.profile_id = da.profile_id 
        AND da.analytics_date BETWEEN start_date AND end_date
    WHERE sp.profile_id = user_profile_id
    AND sp.published_at BETWEEN start_date::TIMESTAMPTZ AND (end_date + INTERVAL '1 day')::TIMESTAMPTZ;
END;
$$;

-- Mock data for analytics dashboard
DO $$
DECLARE
    sample_profile_id UUID;
    facebook_account_id UUID := gen_random_uuid();
    instagram_account_id UUID := gen_random_uuid();
    twitter_account_id UUID := gen_random_uuid();
    post1_id UUID := gen_random_uuid();
    post2_id UUID := gen_random_uuid();
    post3_id UUID := gen_random_uuid();
    post4_id UUID := gen_random_uuid();
    post5_id UUID := gen_random_uuid();
BEGIN
    -- Get existing profile ID (from existing profiles table)
    SELECT id INTO sample_profile_id FROM public.profiles LIMIT 1;
    
    IF sample_profile_id IS NULL THEN
        -- Create a sample profile if none exists
        sample_profile_id := gen_random_uuid();
        INSERT INTO public.profiles (id, username, created_at)
        VALUES (sample_profile_id, 'analytics_user', CURRENT_TIMESTAMP);
    END IF;

    -- Insert sample social accounts
    INSERT INTO public.social_accounts (id, profile_id, platform, account_name, followers_count, following_count, posts_count) VALUES
        (facebook_account_id, sample_profile_id, 'facebook', 'ContentFlow Pro FB', 2850, 320, 45),
        (instagram_account_id, sample_profile_id, 'instagram', 'contentflow.pro', 4200, 180, 67),
        (twitter_account_id, sample_profile_id, 'twitter', '@contentflowpro', 1750, 890, 120);

    -- Insert sample posts
    INSERT INTO public.social_posts (id, profile_id, account_id, platform, content_type, title, content, status, published_at) VALUES
        (post1_id, sample_profile_id, facebook_account_id, 'facebook', 'image', '5 Social Media Tips', 'Here are the top 5 social media tips that will boost your engagement!', 'published', CURRENT_TIMESTAMP - INTERVAL '2 days'),
        (post2_id, sample_profile_id, instagram_account_id, 'instagram', 'video', 'Behind the Scenes', 'Take a look behind the scenes of our content creation process', 'published', CURRENT_TIMESTAMP - INTERVAL '1 day'),
        (post3_id, sample_profile_id, twitter_account_id, 'twitter', 'text', 'Weekly Update', 'This week we helped 50+ businesses optimize their social media strategy!', 'published', CURRENT_TIMESTAMP - INTERVAL '3 hours'),
        (post4_id, sample_profile_id, instagram_account_id, 'instagram', 'image', 'Infographic Friday', 'Weekly social media statistics that matter for your business', 'published', CURRENT_TIMESTAMP - INTERVAL '5 days'),
        (post5_id, sample_profile_id, facebook_account_id, 'facebook', 'carousel', 'Client Success Story', 'How we helped increase engagement by 300% in just 2 months', 'published', CURRENT_TIMESTAMP - INTERVAL '7 days');

    -- Insert analytics data for posts
    INSERT INTO public.post_analytics (post_id, views_count, likes_count, comments_count, shares_count, reach, impressions, engagement_rate) VALUES
        (post1_id, 1850, 145, 23, 12, 1650, 2200, 10.91),
        (post2_id, 2450, 320, 45, 28, 2100, 3100, 18.71),
        (post3_id, 890, 67, 8, 5, 780, 1200, 10.26),
        (post4_id, 1200, 98, 15, 7, 1100, 1500, 10.91),
        (post5_id, 1650, 128, 19, 9, 1400, 2000, 11.14);

    -- Insert daily analytics for the past 30 days
    FOR i IN 0..29 LOOP
        INSERT INTO public.daily_analytics (profile_id, account_id, platform, analytics_date, total_posts, total_views, total_likes, total_comments, total_shares, total_reach, total_impressions, avg_engagement_rate, follower_growth)
        VALUES 
            (sample_profile_id, facebook_account_id, 'facebook', CURRENT_DATE - INTERVAL '1 day' * i, 
             CASE WHEN i % 3 = 0 THEN 1 ELSE 0 END, -- Post every 3 days
             800 + (RANDOM() * 500)::INTEGER, 
             50 + (RANDOM() * 100)::INTEGER, 
             5 + (RANDOM() * 15)::INTEGER, 
             2 + (RANDOM() * 8)::INTEGER, 
             700 + (RANDOM() * 400)::INTEGER, 
             1000 + (RANDOM() * 600)::INTEGER, 
             8.5 + (RANDOM() * 5)::DECIMAL(5,2), 
             (RANDOM() * 20 - 10)::INTEGER), -- Growth between -10 and +10
            (sample_profile_id, instagram_account_id, 'instagram', CURRENT_DATE - INTERVAL '1 day' * i,
             CASE WHEN i % 2 = 0 THEN 1 ELSE 0 END, -- Post every 2 days
             1200 + (RANDOM() * 800)::INTEGER, 
             80 + (RANDOM() * 150)::INTEGER, 
             8 + (RANDOM() * 20)::INTEGER, 
             3 + (RANDOM() * 12)::INTEGER, 
             1000 + (RANDOM() * 600)::INTEGER, 
             1500 + (RANDOM() * 900)::INTEGER, 
             12.0 + (RANDOM() * 6)::DECIMAL(5,2), 
             (RANDOM() * 30 - 15)::INTEGER), -- Growth between -15 and +15
            (sample_profile_id, twitter_account_id, 'twitter', CURRENT_DATE - INTERVAL '1 day' * i,
             CASE WHEN i % 1 = 0 THEN CASE WHEN RANDOM() > 0.3 THEN 1 ELSE 0 END ELSE 0 END, -- More frequent posting
             400 + (RANDOM() * 300)::INTEGER, 
             25 + (RANDOM() * 50)::INTEGER, 
             3 + (RANDOM() * 10)::INTEGER, 
             1 + (RANDOM() * 5)::INTEGER, 
             350 + (RANDOM() * 200)::INTEGER, 
             600 + (RANDOM() * 400)::INTEGER, 
             6.5 + (RANDOM() * 4)::DECIMAL(5,2), 
             (RANDOM() * 25 - 12)::INTEGER); -- Growth between -12 and +13
    END LOOP;

    -- Insert audience insights
    INSERT INTO public.audience_insights (profile_id, account_id, platform, age_group, gender, location, percentage, insight_type) VALUES
        -- Age demographics
        (sample_profile_id, facebook_account_id, 'facebook', '18-24', 'all', 'all', 18.5, 'age'),
        (sample_profile_id, facebook_account_id, 'facebook', '25-34', 'all', 'all', 35.2, 'age'),
        (sample_profile_id, facebook_account_id, 'facebook', '35-44', 'all', 'all', 28.1, 'age'),
        (sample_profile_id, facebook_account_id, 'facebook', '45-54', 'all', 'all', 12.7, 'age'),
        (sample_profile_id, facebook_account_id, 'facebook', '55+', 'all', 'all', 5.5, 'age'),
        -- Gender demographics
        (sample_profile_id, instagram_account_id, 'instagram', 'all', 'female', 'all', 58.3, 'gender'),
        (sample_profile_id, instagram_account_id, 'instagram', 'all', 'male', 'all', 40.2, 'gender'),
        (sample_profile_id, instagram_account_id, 'instagram', 'all', 'other', 'all', 1.5, 'gender'),
        -- Location demographics (Thailand focused)
        (sample_profile_id, twitter_account_id, 'twitter', 'all', 'all', 'Bangkok', 42.1, 'location'),
        (sample_profile_id, twitter_account_id, 'twitter', 'all', 'all', 'Chiang Mai', 15.3, 'location'),
        (sample_profile_id, twitter_account_id, 'twitter', 'all', 'all', 'Phuket', 8.7, 'location'),
        (sample_profile_id, twitter_account_id, 'twitter', 'all', 'all', 'Other Thailand', 20.4, 'location'),
        (sample_profile_id, twitter_account_id, 'twitter', 'all', 'all', 'International', 13.5, 'location');

    -- Insert audience activity patterns
    FOR hour_val IN 0..23 LOOP
        FOR day_val IN 1..7 LOOP
            INSERT INTO public.audience_activity (profile_id, account_id, platform, hour_of_day, day_of_week, activity_level)
            VALUES 
                (sample_profile_id, facebook_account_id, 'facebook', hour_val, day_val, 
                 CASE 
                    WHEN hour_val BETWEEN 8 AND 10 OR hour_val BETWEEN 19 AND 22 THEN 70 + (RANDOM() * 25)::DECIMAL(5,2)  -- Peak times
                    WHEN hour_val BETWEEN 12 AND 14 THEN 60 + (RANDOM() * 20)::DECIMAL(5,2)  -- Lunch break
                    WHEN hour_val BETWEEN 0 AND 6 THEN 5 + (RANDOM() * 10)::DECIMAL(5,2)   -- Night time
                    ELSE 30 + (RANDOM() * 20)::DECIMAL(5,2)  -- Regular hours
                 END),
                (sample_profile_id, instagram_account_id, 'instagram', hour_val, day_val,
                 CASE 
                    WHEN hour_val BETWEEN 11 AND 13 OR hour_val BETWEEN 20 AND 23 THEN 75 + (RANDOM() * 20)::DECIMAL(5,2)  -- Peak times  
                    WHEN hour_val BETWEEN 8 AND 10 THEN 55 + (RANDOM() * 25)::DECIMAL(5,2)  -- Morning
                    WHEN hour_val BETWEEN 0 AND 7 THEN 8 + (RANDOM() * 12)::DECIMAL(5,2)   -- Night time
                    ELSE 35 + (RANDOM() * 15)::DECIMAL(5,2)  -- Regular hours
                 END),
                (sample_profile_id, twitter_account_id, 'twitter', hour_val, day_val,
                 CASE 
                    WHEN hour_val BETWEEN 7 AND 9 OR hour_val BETWEEN 18 AND 20 THEN 65 + (RANDOM() * 30)::DECIMAL(5,2)  -- Commute times
                    WHEN hour_val BETWEEN 12 AND 14 THEN 50 + (RANDOM() * 20)::DECIMAL(5,2)  -- Lunch
                    WHEN hour_val BETWEEN 0 AND 6 THEN 3 + (RANDOM() * 8)::DECIMAL(5,2)   -- Night time
                    ELSE 25 + (RANDOM() * 25)::DECIMAL(5,2)  -- Regular hours
                 END);
        END LOOP;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data insertion failed: %', SQLERRM;
END $$;