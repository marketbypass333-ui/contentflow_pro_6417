import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/audience_insights_widget.dart';
import './widgets/engagement_chart_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/platform_comparison_widget.dart';
import './widgets/recommendations_widget.dart';
import './widgets/top_posts_widget.dart';
import 'widgets/audience_insights_widget.dart';
import 'widgets/engagement_chart_widget.dart';
import 'widgets/metrics_card_widget.dart';
import 'widgets/platform_comparison_widget.dart';
import 'widgets/recommendations_widget.dart';
import 'widgets/top_posts_widget.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({Key? key}) : super(key: key);

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedDateRange = '7 days';
  bool _isLoading = true;

  // Analytics data
  Map<String, dynamic> _analyticsData = {};
  List<Map<String, dynamic>> _dailyAnalytics = [];
  List<Map<String, dynamic>> _topPosts = [];
  List<Map<String, dynamic>> _platformData = [];
  Map<String, dynamic> _audienceInsights = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      final supabase = SupabaseService.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Get date range
      final endDate = DateTime.now();
      final startDate = _getStartDate(endDate);

      // Load main analytics summary
      final summaryResponse =
          await supabase.rpc('get_analytics_summary', params: {
        'user_profile_id': userId,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      });

      // Load daily analytics for charts
      final dailyResponse = await supabase
          .from('daily_analytics')
          .select('*')
          .eq('profile_id', userId)
          .gte('analytics_date', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('analytics_date', DateFormat('yyyy-MM-dd').format(endDate))
          .order('analytics_date');

      // Load top performing posts
      final postsResponse = await supabase
          .from('social_posts')
          .select('''
            *,
            post_analytics!inner(*)
          ''')
          .eq('profile_id', userId)
          .gte('published_at', startDate.toIso8601String())
          .lte('published_at', endDate.toIso8601String())
          .order('post_analytics.engagement_rate', ascending: false)
          .limit(5);

      // Load platform comparison data
      final platformResponse = await supabase
          .from('social_accounts')
          .select('*')
          .eq('profile_id', userId)
          .eq('is_active', true);

      // Load audience insights
      final audienceResponse = await supabase
          .from('audience_insights')
          .select('*')
          .eq('profile_id', userId)
          .order('percentage', ascending: false);

      setState(() {
        _analyticsData =
            summaryResponse?.isNotEmpty == true ? summaryResponse[0] : {};
        _dailyAnalytics = List<Map<String, dynamic>>.from(dailyResponse ?? []);
        _topPosts = List<Map<String, dynamic>>.from(postsResponse ?? []);
        _platformData = List<Map<String, dynamic>>.from(platformResponse ?? []);

        // Group audience insights by type
        final insights =
            List<Map<String, dynamic>>.from(audienceResponse ?? []);
        _audienceInsights = {
          'age': insights.where((i) => i['insight_type'] == 'age').toList(),
          'gender':
              insights.where((i) => i['insight_type'] == 'gender').toList(),
          'location':
              insights.where((i) => i['insight_type'] == 'location').toList(),
        };

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: ${e.toString()}')),
        );
      }
    }
  }

  DateTime _getStartDate(DateTime endDate) {
    switch (_selectedDateRange) {
      case '7 days':
        return endDate.subtract(const Duration(days: 7));
      case '30 days':
        return endDate.subtract(const Duration(days: 30));
      case '90 days':
        return endDate.subtract(const Duration(days: 90));
      default:
        return endDate.subtract(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildAnalyticsContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Analytics Dashboard',
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      actions: [
        _buildDateRangeSelector(),
        IconButton(
          icon: const Icon(Icons.file_download_outlined, color: Colors.black54),
          onPressed: _exportReport,
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      margin: EdgeInsets.only(right: 3.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDateRange,
          items: ['7 days', '30 days', '90 days', 'Custom'].map((range) {
            return DropdownMenuItem(
              value: range,
              child: Text(
                range,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && value != 'Custom') {
              setState(() => _selectedDateRange = value);
              _loadAnalyticsData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Key Metrics Cards
          _buildMetricsSection(),
          SizedBox(height: 3.h),

          // Engagement Trends Chart
          _buildSectionTitle('Engagement Trends'),
          SizedBox(height: 2.h),
          EngagementChartWidget(dailyAnalytics: _dailyAnalytics),
          SizedBox(height: 4.h),

          // Platform Comparison
          _buildSectionTitle('Platform Performance'),
          SizedBox(height: 2.h),
          PlatformComparisonWidget(platformData: _platformData),
          SizedBox(height: 4.h),

          // Top Performing Posts
          _buildSectionTitle('Top Performing Content'),
          SizedBox(height: 2.h),
          TopPostsWidget(topPosts: _topPosts),
          SizedBox(height: 4.h),

          // Audience Insights
          _buildSectionTitle('Audience Insights'),
          SizedBox(height: 2.h),
          AudienceInsightsWidget(insights: _audienceInsights),
          SizedBox(height: 4.h),

          // AI Recommendations
          _buildSectionTitle('AI-Powered Recommendations'),
          SizedBox(height: 2.h),
          RecommendationsWidget(analyticsData: _analyticsData),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildMetricsSection() {
    final totalReach = _analyticsData['total_reach']?.toString() ?? '0';
    final engagementRate =
        _analyticsData['avg_engagement_rate']?.toString() ?? '0.0';
    final followerGrowth = _analyticsData['follower_growth']?.toString() ?? '0';
    final totalPosts = _analyticsData['total_posts']?.toString() ?? '0';

    return Row(
      children: [
        Expanded(
          child: MetricsCardWidget(
            title: 'Total Reach',
            value: _formatNumber(int.tryParse(totalReach) ?? 0),
            change: '+12.5%',
            isPositive: true,
            icon: Icons.visibility_outlined,
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: MetricsCardWidget(
            title: 'Engagement Rate',
            value: '${engagementRate}%',
            change: '+2.1%',
            isPositive: true,
            icon: Icons.favorite_outlined,
            color: Colors.pink,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: MetricsCardWidget(
            title: 'Follower Growth',
            value: followerGrowth,
            change: '+5.8%',
            isPositive: (int.tryParse(followerGrowth) ?? 0) > 0,
            icon: Icons.trending_up_outlined,
            color: Colors.green,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: MetricsCardWidget(
            title: 'Posts Published',
            value: totalPosts,
            change: '+3',
            isPositive: true,
            icon: Icons.post_add_outlined,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Analytics report exported successfully!',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}