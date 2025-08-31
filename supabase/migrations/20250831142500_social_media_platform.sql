-- Location: supabase/migrations/20250831142500_social_media_platform.sql
-- Schema Analysis: Existing tables: messages, profiles
-- Integration Type: extension/enhancement
-- Dependencies: profiles (id), messages (profile_id)

-- 1. Create enum types for social media functionality
CREATE TYPE public.platform_type AS ENUM ('facebook', 'instagram', 'twitter', 'linkedin', 'tiktok', 'youtube');
CREATE TYPE public.post_status AS ENUM ('draft', 'scheduled', 'published', 'failed');
CREATE TYPE public.message_status AS ENUM ('unread', 'read', 'replied', 'archived');
CREATE TYPE public.account_status AS ENUM ('connected', 'disconnected', 'error', 'pending');

-- 2. Extend existing profiles table with social media fields
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- 3. Create connected accounts table
CREATE TABLE public.connected_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    platform public.platform_type NOT NULL,
    account_name TEXT NOT NULL,
    account_id TEXT NOT NULL,
    access_token TEXT,
    status public.account_status DEFAULT 'connected'::public.account_status,
    follower_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    last_sync_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create posts table for social media content
CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    connected_account_id UUID REFERENCES public.connected_accounts(id) ON DELETE CASCADE,
    title TEXT,
    content TEXT NOT NULL,
    media_urls TEXT[] DEFAULT '{}',
    hashtags TEXT[] DEFAULT '{}',
    status public.post_status DEFAULT 'draft'::public.post_status,
    scheduled_for TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    engagement_count INTEGER DEFAULT 0,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Enhance existing messages table
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS platform public.platform_type;
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS sender_name TEXT;
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS sender_avatar TEXT;
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS status public.message_status DEFAULT 'unread'::public.message_status;
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS thread_id TEXT;
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS reply_to_id UUID REFERENCES public.messages(id);
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

-- 6. Create analytics table for dashboard metrics
CREATE TABLE public.analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    connected_account_id UUID REFERENCES public.connected_accounts(id) ON DELETE CASCADE,
    metric_type TEXT NOT NULL, -- 'followers', 'engagement', 'reach', etc.
    metric_value INTEGER NOT NULL,
    date_recorded DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. Create essential indexes
CREATE INDEX idx_connected_accounts_profile_id ON public.connected_accounts(profile_id);
CREATE INDEX idx_connected_accounts_platform ON public.connected_accounts(platform);
CREATE INDEX idx_posts_profile_id ON public.posts(profile_id);
CREATE INDEX idx_posts_status ON public.posts(status);
CREATE INDEX idx_posts_scheduled_for ON public.posts(scheduled_for);
CREATE INDEX idx_messages_profile_id ON public.messages(profile_id);
CREATE INDEX idx_messages_status ON public.messages(status);
CREATE INDEX idx_messages_platform ON public.messages(platform);
CREATE INDEX idx_analytics_profile_id ON public.analytics(profile_id);
CREATE INDEX idx_analytics_date_recorded ON public.analytics(date_recorded);

-- 8. Enable RLS on new tables
ALTER TABLE public.connected_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;

-- 9. Create RLS policies using safe patterns
-- Pattern 2: Simple user ownership for connected_accounts
CREATE POLICY "users_manage_own_connected_accounts"
ON public.connected_accounts
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

-- Pattern 2: Simple user ownership for posts
CREATE POLICY "users_manage_own_posts"
ON public.posts
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

-- Pattern 2: Simple user ownership for analytics
CREATE POLICY "users_manage_own_analytics"
ON public.analytics
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

-- Pattern 1: Core user table - keep existing RLS or create simple one for profiles
CREATE POLICY "users_manage_own_profiles"
ON public.profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for messages (enhanced)
DROP POLICY IF EXISTS "users_manage_own_messages" ON public.messages;
CREATE POLICY "users_manage_own_messages"
ON public.messages
FOR ALL
TO authenticated
USING (profile_id = auth.uid())
WITH CHECK (profile_id = auth.uid());

-- 10. Create helper functions for dashboard metrics
CREATE OR REPLACE FUNCTION public.get_dashboard_metrics(user_id UUID)
RETURNS TABLE(
    total_accounts INTEGER,
    total_posts INTEGER,
    total_followers BIGINT,
    unread_messages INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE((SELECT COUNT(*)::INTEGER FROM public.connected_accounts ca WHERE ca.profile_id = user_id AND ca.status = 'connected'), 0),
        COALESCE((SELECT COUNT(*)::INTEGER FROM public.posts p WHERE p.profile_id = user_id), 0),
        COALESCE((SELECT SUM(follower_count)::BIGINT FROM public.connected_accounts ca WHERE ca.profile_id = user_id AND ca.status = 'connected'), 0),
        COALESCE((SELECT COUNT(*)::INTEGER FROM public.messages m WHERE m.profile_id = user_id AND m.status = 'unread'), 0);
END;
$$;

-- 11. Create function to get platform metrics
CREATE OR REPLACE FUNCTION public.get_platform_metrics(user_id UUID, platform_name public.platform_type)
RETURNS TABLE(
    follower_count INTEGER,
    posts_count INTEGER,
    engagement_rate DECIMAL
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(ca.follower_count, 0),
        COALESCE((SELECT COUNT(*)::INTEGER FROM public.posts p WHERE p.profile_id = user_id AND p.connected_account_id = ca.id), 0),
        CASE 
            WHEN COALESCE(ca.follower_count, 0) > 0 
            THEN ROUND((COALESCE((SELECT AVG(engagement_count) FROM public.posts p WHERE p.profile_id = user_id AND p.connected_account_id = ca.id), 0) / ca.follower_count * 100), 2)
            ELSE 0.0
        END
    FROM public.connected_accounts ca
    WHERE ca.profile_id = user_id AND ca.platform = platform_name AND ca.status = 'connected'
    LIMIT 1;
END;
$$;

-- 12. Mock data for demonstration
DO $$
DECLARE
    demo_user_id UUID := gen_random_uuid();
    facebook_account_id UUID := gen_random_uuid();
    instagram_account_id UUID := gen_random_uuid();
    twitter_account_id UUID := gen_random_uuid();
    post1_id UUID := gen_random_uuid();
    post2_id UUID := gen_random_uuid();
BEGIN
    -- Create demo user profile
    INSERT INTO public.profiles (id, username, full_name, avatar_url, role)
    VALUES (demo_user_id, 'demo_user', 'ContentFlow Demo User', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face', 'user');

    -- Create connected social media accounts
    INSERT INTO public.connected_accounts (id, profile_id, platform, account_name, account_id, follower_count, following_count, status)
    VALUES 
        (facebook_account_id, demo_user_id, 'facebook', 'ContentFlow Business', 'fb_123456', 15420, 890, 'connected'),
        (instagram_account_id, demo_user_id, 'instagram', '@contentflow_pro', 'ig_789012', 8750, 1200, 'connected'),
        (twitter_account_id, demo_user_id, 'twitter', '@ContentFlowPro', 'tw_345678', 5230, 2100, 'connected');

    -- Create sample posts
    INSERT INTO public.posts (id, profile_id, connected_account_id, title, content, hashtags, status, published_at, likes_count, comments_count, shares_count, engagement_count)
    VALUES 
        (post1_id, demo_user_id, facebook_account_id, 'New Product Launch!', 'เปิดตัวฟีเจอร์ใหม่ที่จะเปลี่ยนวิธีการจัดการโซเชียลมีเดียของคุณ! 🚀✨ #ProductLaunch #SocialMedia #Innovation #ContentFlow', 
         ARRAY['ProductLaunch', 'SocialMedia', 'Innovation', 'ContentFlow'], 'published', NOW() - INTERVAL '2 hours', 245, 18, 32, 295),
        (post2_id, demo_user_id, instagram_account_id, 'Behind the Scenes', 'มาดูกันว่าทีมเราทำงานกันอย่างไร! 💪📱 #BehindTheScenes #TeamWork #ContentCreation #SocialMediaLife', 
         ARRAY['BehindTheScenes', 'TeamWork', 'ContentCreation', 'SocialMediaLife'], 'published', NOW() - INTERVAL '5 hours', 167, 23, 12, 202);

    -- Create sample messages
    INSERT INTO public.messages (profile_id, content, platform, sender_name, sender_avatar, status, thread_id)
    VALUES 
        (demo_user_id, 'สวัสดีครับ ผมสนใจบริการของคุณมากเลย สามารถขอข้อมูลเพิ่มเติมได้มั้ยครับ?', 'facebook', 'สมชาย ใจดี', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=50&h=50&fit=crop&crop=face', 'unread', 'fb_thread_001'),
        (demo_user_id, 'Hi! Love your recent post about social media management. Do you offer consultation services?', 'instagram', 'Sarah Johnson', 'https://images.unsplash.com/photo-1494790108755-2616b612e1c8?w=50&h=50&fit=crop&crop=face', 'unread', 'ig_thread_002'),
        (demo_user_id, 'Great insights on content planning! Could you share more tips for small businesses?', 'twitter', 'Mike Chen', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=50&h=50&fit=crop&crop=face', 'read', 'tw_thread_003');

    -- Create sample analytics data
    INSERT INTO public.analytics (profile_id, connected_account_id, metric_type, metric_value, date_recorded)
    VALUES 
        (demo_user_id, facebook_account_id, 'followers', 15420, CURRENT_DATE),
        (demo_user_id, facebook_account_id, 'engagement', 1245, CURRENT_DATE),
        (demo_user_id, instagram_account_id, 'followers', 8750, CURRENT_DATE),
        (demo_user_id, instagram_account_id, 'engagement', 987, CURRENT_DATE),
        (demo_user_id, twitter_account_id, 'followers', 5230, CURRENT_DATE),
        (demo_user_id, twitter_account_id, 'engagement', 432, CURRENT_DATE);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data creation error: %', SQLERRM;
END $$;

-- 13. Create cleanup function for development
CREATE OR REPLACE FUNCTION public.cleanup_demo_data()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Delete demo data in dependency order
    DELETE FROM public.analytics WHERE profile_id IN (SELECT id FROM public.profiles WHERE username = 'demo_user');
    DELETE FROM public.posts WHERE profile_id IN (SELECT id FROM public.profiles WHERE username = 'demo_user');
    DELETE FROM public.messages WHERE profile_id IN (SELECT id FROM public.profiles WHERE username = 'demo_user');
    DELETE FROM public.connected_accounts WHERE profile_id IN (SELECT id FROM public.profiles WHERE username = 'demo_user');
    DELETE FROM public.profiles WHERE username = 'demo_user';
    
    RAISE NOTICE 'Demo data cleaned up successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Cleanup failed: %', SQLERRM;
END;
$$;