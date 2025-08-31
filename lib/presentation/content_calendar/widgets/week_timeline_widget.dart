import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class WeekTimelineWidget extends StatelessWidget {
  final DateTime selectedWeek;
  final List<Map<String, dynamic>> scheduledPosts;
  final Function(Map<String, dynamic>) onPostTap;
  final Function(Map<String, dynamic>) onPostLongPress;

  const WeekTimelineWidget({
    super.key,
    required this.selectedWeek,
    required this.scheduledPosts,
    required this.onPostTap,
    required this.onPostLongPress,
  });

  List<DateTime> _getWeekDays() {
    final startOfWeek =
        selectedWeek.subtract(Duration(days: selectedWeek.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<Map<String, dynamic>> _getPostsForDay(DateTime day) {
    return scheduledPosts.where((post) {
      final postDate = post['scheduledDate'] as DateTime;
      return postDate.year == day.year &&
          postDate.month == day.month &&
          postDate.day == day.day;
    }).toList()
      ..sort((a, b) {
        final aTime = a['scheduledDate'] as DateTime;
        final bTime = b['scheduledDate'] as DateTime;
        return aTime.compareTo(bTime);
      });
  }

  String _getDayName(int weekday) {
    const dayNames = ['อา', 'จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส'];
    return dayNames[weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _getWeekDays();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w),
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
      child: Column(
        children: [
          _buildWeekHeader(weekDays),
          _buildTimelineGrid(weekDays),
        ],
      ),
    );
  }

  Widget _buildWeekHeader(List<DateTime> weekDays) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w), // Space for time column
          ...weekDays.map((day) {
            final isToday = DateTime.now().day == day.day &&
                DateTime.now().month == day.month &&
                DateTime.now().year == day.year;

            return Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Column(
                  children: [
                    Text(
                      _getDayName(day.weekday),
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppTheme.darkTheme.colorScheme.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: isToday
                            ? null
                            : Border.all(
                                color: AppTheme.darkTheme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                              ),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: isToday
                                ? AppTheme.darkTheme.colorScheme.onPrimary
                                : AppTheme.darkTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineGrid(List<DateTime> weekDays) {
    return Container(
      height: 40.h,
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(24, (hour) {
            return _buildHourRow(hour, weekDays);
          }),
        ),
      ),
    );
  }

  Widget _buildHourRow(int hour, List<DateTime> weekDays) {
    return Container(
      height: 8.h,
      child: Row(
        children: [
          _buildTimeLabel(hour),
          ...weekDays.map((day) {
            final postsInHour = _getPostsForDay(day).where((post) {
              final postTime = post['scheduledDate'] as DateTime;
              return postTime.hour == hour;
            }).toList();

            return Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: AppTheme.darkTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                    ),
                    bottom: BorderSide(
                      color: AppTheme.darkTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: _buildHourCell(postsInHour),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeLabel(int hour) {
    return Container(
      width: 12.w,
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          bottom: BorderSide(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Center(
        child: Text(
          '${hour.toString().padLeft(2, '0')}:00',
          style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
            color:
                AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildHourCell(List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return const SizedBox.expand();
    }

    return Container(
      padding: EdgeInsets.all(1.w),
      child: Column(
        children: posts.take(2).map((post) {
          return Expanded(
            child: GestureDetector(
              onTap: () => onPostTap(post),
              onLongPress: () => onPostLongPress(post),
              child: Container(
                margin: EdgeInsets.only(bottom: 0.5.h),
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getPlatformColor(post['platform'] as String)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getPlatformColor(post['platform'] as String)
                        .withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: _getPlatformColor(post['platform'] as String),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        post['content'] as String,
                        style:
                            AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.darkTheme.colorScheme.onSurface,
                          fontSize: 8.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'youtube':
        return const Color(0xFFFF0000);
      default:
        return AppTheme.darkTheme.colorScheme.tertiary;
    }
  }
}
