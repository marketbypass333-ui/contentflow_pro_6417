import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import './widgets/dashboard_header.dart';
import './widgets/platform_metrics_card.dart';
import './widgets/quick_actions_section.dart';
import './widgets/recent_posts_section.dart';
import './widgets/trending_hashtags_widget.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/platform_metrics_card.dart';
import 'widgets/quick_actions_section.dart';
import 'widgets/recent_posts_section.dart';
import 'widgets/trending_hashtags_widget.dart';

class SocialMediaDashboard extends StatefulWidget {
  const SocialMediaDashboard({Key? key}) : super(key: key);

  @override
  State<SocialMediaDashboard> createState() => _SocialMediaDashboardState();
}

class _SocialMediaDashboardState extends State<SocialMediaDashboard> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardMetrics = {};
  List<Map<String, dynamic>> _connectedAccounts = [];
  List<Map<String, dynamic>> _recentPosts = [];
  int _unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    _initializeTimeago();
    _loadDashboardData();
  }

  void _initializeTimeago() {
    timeago.setLocaleMessages('th', timeago.ThMessages());
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = _supabaseService.client.auth.currentUser;
      if (user == null) {
        _navigateToLogin();
        return;
      }

      // Load dashboard metrics
      final metricsResponse =
          await _supabaseService.client.from('profiles').select('''
            id,
            full_name,
            avatar_url,
            connected_accounts!inner(
              id,
              platform,
              account_name,
              follower_count,
              following_count,
              status
            )
          ''').eq('id', user.id).single();

      // Load recent posts
      final postsResponse = await _supabaseService.client
          .from('posts')
          .select('''
            id,
            title,
            content,
            created_at,
            published_at,
            status,
            likes_count,
            comments_count,
            shares_count,
            engagement_count,
            connected_accounts!inner(
              platform,
              account_name
            )
          ''')
          .eq('profile_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      // Load unread messages count
      final messagesResponse = await _supabaseService.client
          .from('messages')
          .select('id')
          .eq('profile_id', user.id)
          .eq('status', 'unread');

      setState(() {
        _dashboardMetrics = metricsResponse;
        _connectedAccounts = List<Map<String, dynamic>>.from(
            metricsResponse['connected_accounts'] ?? []);
        _recentPosts = List<Map<String, dynamic>>.from(postsResponse ?? []);
        _unreadMessages = messagesResponse.length;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Error loading dashboard data: $error');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar('ไม่สามารถโหลดข้อมูลได้ กรุณาลองใหม่อีกครั้ง');
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadDashboardData();
  }

  void _navigateToMessages() {
    Navigator.pushNamed(context, AppRoutes.messagesInbox);
  }

  void _navigateToCreatePost() {
    Navigator.pushNamed(context, AppRoutes.postCreation);
  }

  void _navigateToCalendar() {
    Navigator.pushNamed(context, AppRoutes.contentCalendar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        userName: _dashboardMetrics['full_name'] ?? 'User',
                        avatarUrl: _dashboardMetrics['avatar_url'],
                        unreadCount: _unreadMessages,
                        onNotificationTap: _navigateToMessages,
                      ),

                      SizedBox(height: 3.h),

                      // Platform metrics cards
                      _buildPlatformMetricsSection(),

                      SizedBox(height: 3.h),

                      // Quick actions
                      QuickActionsSection(
                        onCreatePost: _navigateToCreatePost,
                        onViewCalendar: _navigateToCalendar,
                        onViewMessages: _navigateToMessages,
                      ),

                      SizedBox(height: 3.h),

                      // Recent posts
                      RecentPostsSection(
                        posts: _recentPosts,
                        onRefresh: _refreshData,
                      ),

                      SizedBox(height: 3.h),

                      // Trending hashtags
                      const TrendingHashtagsWidget(),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildPlatformMetricsSection() {
    if (_connectedAccounts.isEmpty) {
      return _buildEmptyAccountsState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'แพลตฟอร์มที่เชื่อมต่อ',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 16.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _connectedAccounts.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final account = _connectedAccounts[index];
              return PlatformMetricsCard(
                platform: account['platform'] ?? '',
                accountName: account['account_name'] ?? '',
                followerCount: account['follower_count'] ?? 0,
                followingCount: account['following_count'] ?? 0,
                status: account['status'] ?? 'connected',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyAccountsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_circle_outlined,
            size: 15.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'ยังไม่มีบัญชีที่เชื่อมต่อ',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'เชื่อมต่อบัญชีโซเชียลมีเดียของคุณเพื่อเริ่มต้นการจัดการเนื้อหา',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.accountConnections);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            child: Text(
              'เชื่อมต่อบัญชี',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}