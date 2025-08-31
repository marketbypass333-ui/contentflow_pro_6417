import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/app_export.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/calendar_view_widget.dart';
import './widgets/floating_create_button_widget.dart';
import './widgets/scheduled_posts_sheet_widget.dart';
import './widgets/week_timeline_widget.dart';

class ContentCalendar extends StatefulWidget {
  const ContentCalendar({super.key});

  @override
  State<ContentCalendar> createState() => _ContentCalendarState();
}

class _ContentCalendarState extends State<ContentCalendar>
    with TickerProviderStateMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  bool _isWeekView = false;
  bool _isLoading = false;

  // Mock scheduled posts data
  final List<Map<String, dynamic>> _scheduledPosts = [
    {
      "id": 1,
      "platform": "Facebook",
      "content":
          "เปิดตัวผลิตภัณฑ์ใหม่ของเรา! มาดูกันว่าจะมีอะไรน่าสนใจบ้าง #NewProduct #Innovation",
      "scheduledDate": DateTime.now().add(const Duration(days: 1, hours: 9)),
      "status": "scheduled",
      "imageUrl":
          "https://images.pexels.com/photos/267389/pexels-photo-267389.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#NewProduct", "#Innovation"],
    },
    {
      "id": 2,
      "platform": "Instagram",
      "content":
          "Behind the scenes ของการทำงานในออฟฟิศ ✨ #WorkLife #BehindTheScenes",
      "scheduledDate": DateTime.now().add(const Duration(days: 2, hours: 14)),
      "status": "scheduled",
      "imageUrl":
          "https://images.pexels.com/photos/3184291/pexels-photo-3184291.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#WorkLife", "#BehindTheScenes"],
    },
    {
      "id": 3,
      "platform": "Twitter",
      "content":
          "เทคโนโลยี AI กำลังเปลี่ยนแปลงโลกของเรา มาร่วมพูดคุยกันเรื่องอนาคตของ AI #AI #Technology #Future",
      "scheduledDate": DateTime.now().add(const Duration(days: 3, hours: 16)),
      "status": "scheduled",
      "imageUrl":
          "https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#AI", "#Technology", "#Future"],
    },
    {
      "id": 4,
      "platform": "LinkedIn",
      "content":
          "การพัฒนาทักษะในยุคดิจิทัล: 5 ทักษะที่จำเป็นสำหรับอนาคต #SkillDevelopment #DigitalAge #Career",
      "scheduledDate": DateTime.now().add(const Duration(days: 5, hours: 10)),
      "status": "scheduled",
      "imageUrl":
          "https://images.pexels.com/photos/3184338/pexels-photo-3184338.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#SkillDevelopment", "#DigitalAge", "#Career"],
    },
    {
      "id": 5,
      "platform": "YouTube",
      "content":
          "วิดีโอสอนใหม่: วิธีการใช้งาน ContentFlow Pro อย่างมืออาชีพ 🎥 #Tutorial #ContentFlow #SocialMedia",
      "scheduledDate": DateTime.now().add(const Duration(days: 7, hours: 18)),
      "status": "scheduled",
      "imageUrl":
          "https://images.pexels.com/photos/3153198/pexels-photo-3153198.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#Tutorial", "#ContentFlow", "#SocialMedia"],
    },
    {
      "id": 6,
      "platform": "Facebook",
      "content":
          "ขอบคุณลูกค้าทุกท่านที่ไว้วางใจในบริการของเรา 🙏 #ThankYou #CustomerAppreciation",
      "scheduledDate":
          DateTime.now().subtract(const Duration(days: 1, hours: 12)),
      "status": "published",
      "imageUrl":
          "https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#ThankYou", "#CustomerAppreciation"],
    },
    {
      "id": 7,
      "platform": "Instagram",
      "content":
          "เมื่อวานเป็นวันที่ยอดเยี่ยม! ขอบคุณทีมงานทุกคน 💪 #TeamWork #Success",
      "scheduledDate":
          DateTime.now().subtract(const Duration(days: 2, hours: 15)),
      "status": "published",
      "imageUrl":
          "https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#TeamWork", "#Success"],
    },
    {
      "id": 8,
      "platform": "Twitter",
      "content":
          "การอัปเดตระบบเสร็จสิ้นแล้ว ขอบคุณสำหรับความอดทน #SystemUpdate #Maintenance",
      "scheduledDate":
          DateTime.now().subtract(const Duration(days: 3, hours: 8)),
      "status": "failed",
      "imageUrl":
          "https://images.pexels.com/photos/3184317/pexels-photo-3184317.jpeg?auto=compress&cs=tinysrgb&w=800",
      "hashtags": ["#SystemUpdate", "#Maintenance"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingCreateButtonWidget(
        onPressed: _onCreatePost,
        selectedDate: _selectedDay,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.darkTheme.appBarTheme.backgroundColor,
      elevation: 0,
      title: Text(
        'ปฏิทินเนื้อหา',
        style: AppTheme.darkTheme.appBarTheme.titleTextStyle,
      ),
      actions: [
        IconButton(
          onPressed: _onRefresh,
          icon: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.darkTheme.colorScheme.onSurface,
                    ),
                  ),
                )
              : CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                  size: 24,
                ),
        ),
        IconButton(
          onPressed: _onSettings,
          icon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.darkTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.darkTheme.colorScheme.primary,
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      child: Column(
        children: [
          CalendarHeaderWidget(
            isWeekView: _isWeekView,
            onToggleView: _onToggleView,
            onTodayPressed: _onTodayPressed,
            selectedDate: _selectedDay,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  _isWeekView ? _buildWeekView() : _buildMonthView(),
                  SizedBox(height: 2.h),
                  _buildQuickStats(),
                  SizedBox(height: 10.h), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView() {
    return CalendarViewWidget(
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      isWeekView: false,
      onDaySelected: _onDaySelected,
      onDayLongPressed: _onDayLongPressed,
      scheduledPosts: _scheduledPosts,
    );
  }

  Widget _buildWeekView() {
    return WeekTimelineWidget(
      selectedWeek: _selectedDay,
      scheduledPosts: _scheduledPosts,
      onPostTap: _onPostTap,
      onPostLongPress: _onPostLongPress,
    );
  }

  Widget _buildQuickStats() {
    final todayPosts = _scheduledPosts.where((post) {
      final postDate = post['scheduledDate'] as DateTime;
      final today = DateTime.now();
      return postDate.year == today.year &&
          postDate.month == today.month &&
          postDate.day == today.day;
    }).length;

    final weekPosts = _scheduledPosts.where((post) {
      final postDate = post['scheduledDate'] as DateTime;
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday % 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return postDate.isAfter(weekStart) &&
          postDate.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'วันนี้',
              '$todayPosts',
              'โพสต์',
              AppTheme.darkTheme.colorScheme.primary,
              Icons.today,
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'สัปดาห์นี้',
              '$weekPosts',
              'โพสต์',
              AppTheme.darkTheme.colorScheme.secondary,
              Icons.date_range,
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          Expanded(
            child: _buildStatItem(
              'ทั้งหมด',
              '${_scheduledPosts.length}',
              'โพสต์',
              AppTheme.darkTheme.colorScheme.tertiary,
              Icons.analytics,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
            color:
                AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color:
                AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final postsForDay = _scheduledPosts.where((post) {
      final postDate = post['scheduledDate'] as DateTime;
      return isSameDay(postDate, selectedDay);
    }).toList();

    if (postsForDay.isNotEmpty) {
      _showScheduledPostsSheet(selectedDay, postsForDay);
    }
  }

  void _onDayLongPressed(DateTime day) {
    setState(() {
      _selectedDay = day;
      _focusedDay = day;
    });
    _onCreatePost();
  }

  void _onToggleView() {
    setState(() {
      _isWeekView = !_isWeekView;
    });
  }

  void _onTodayPressed() {
    final today = DateTime.now();
    setState(() {
      _selectedDay = today;
      _focusedDay = today;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ปฏิทินได้รับการอัปเดตแล้ว',
            style: AppTheme.darkTheme.snackBarTheme.contentTextStyle,
          ),
          backgroundColor: AppTheme.darkTheme.snackBarTheme.backgroundColor,
          behavior: AppTheme.darkTheme.snackBarTheme.behavior,
          shape: AppTheme.darkTheme.snackBarTheme.shape,
        ),
      );
    }
  }

  void _onSettings() {
    Navigator.pushNamed(context, '/user-profile-settings');
  }

  void _onCreatePost() {
    Navigator.pushNamed(context, '/post-creation');
  }

  void _onPostTap(Map<String, dynamic> post) {
    _showPostPreview(post);
  }

  void _onPostLongPress(Map<String, dynamic> post) {
    _showPostActions(post);
  }

  void _showScheduledPostsSheet(
      DateTime selectedDate, List<Map<String, dynamic>> posts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ScheduledPostsSheetWidget(
        selectedDate: selectedDate,
        posts: posts,
        onEditPost: _onEditPost,
        onDeletePost: _onDeletePost,
        onPreviewPost: _onPreviewPost,
      ),
    );
  }

  void _showPostPreview(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.dialogTheme.backgroundColor,
        shape: AppTheme.darkTheme.dialogTheme.shape,
        title: Text(
          'ตัวอย่างโพสต์',
          style: AppTheme.darkTheme.dialogTheme.titleTextStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'แพลตฟอร์ม: ${post['platform']}',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              post['content'] as String,
              style: AppTheme.darkTheme.dialogTheme.contentTextStyle,
            ),
            if (post['imageUrl'] != null) ...[
              SizedBox(height: 2.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: post['imageUrl'] as String,
                  width: double.infinity,
                  height: 20.h,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ปิด',
              style: TextStyle(
                color: AppTheme.darkTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostActions(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.bottomSheetTheme.backgroundColor,
      shape: AppTheme.darkTheme.bottomSheetTheme.shape,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.darkTheme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                'แก้ไขโพสต์',
                style: AppTheme.darkTheme.listTileTheme.titleTextStyle,
              ),
              onTap: () {
                Navigator.pop(context);
                _onEditPost(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.darkTheme.colorScheme.secondary,
                size: 24,
              ),
              title: Text(
                'ดูตัวอย่าง',
                style: AppTheme.darkTheme.listTileTheme.titleTextStyle,
              ),
              onTap: () {
                Navigator.pop(context);
                _onPreviewPost(post);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.darkTheme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'ลบโพสต์',
                style:
                    AppTheme.darkTheme.listTileTheme.titleTextStyle?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _onDeletePost(post);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onEditPost(Map<String, dynamic> post) {
    Navigator.pushNamed(context, '/post-creation');
  }

  void _onDeletePost(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkTheme.dialogTheme.backgroundColor,
        shape: AppTheme.darkTheme.dialogTheme.shape,
        title: Text(
          'ยืนยันการลบ',
          style: AppTheme.darkTheme.dialogTheme.titleTextStyle,
        ),
        content: Text(
          'คุณต้องการลบโพสต์นี้หรือไม่?',
          style: AppTheme.darkTheme.dialogTheme.contentTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                color: AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _scheduledPosts.removeWhere((p) => p['id'] == post['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'ลบโพสต์เรียบร้อยแล้ว',
                    style: AppTheme.darkTheme.snackBarTheme.contentTextStyle,
                  ),
                  backgroundColor: AppTheme.darkTheme.colorScheme.error,
                ),
              );
            },
            child: Text(
              'ลบ',
              style: TextStyle(
                color: AppTheme.darkTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPreviewPost(Map<String, dynamic> post) {
    _showPostPreview(post);
  }
}
