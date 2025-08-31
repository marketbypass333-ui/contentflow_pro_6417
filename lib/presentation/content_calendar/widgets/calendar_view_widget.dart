import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CalendarViewWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final bool isWeekView;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onDayLongPressed;
  final List<Map<String, dynamic>> scheduledPosts;

  const CalendarViewWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.isWeekView,
    required this.onDaySelected,
    required this.onDayLongPressed,
    required this.scheduledPosts,
  });

  List<Map<String, dynamic>> _getPostsForDay(DateTime day) {
    return scheduledPosts.where((post) {
      final postDate = post['scheduledDate'] as DateTime;
      return isSameDay(postDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
      child: TableCalendar<Map<String, dynamic>>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        calendarFormat: isWeekView ? CalendarFormat.week : CalendarFormat.month,
        eventLoader: _getPostsForDay,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        onDaySelected: onDaySelected,
        onDayLongPressed: (day, focusedDay) => onDayLongPressed(day),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurface,
          ) ?? const TextStyle(),
          holidayTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.tertiary,
          ) ?? const TextStyle(),
          defaultTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSurface,
          ) ?? const TextStyle(),
          selectedTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ) ?? const TextStyle(),
          todayTextStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onSecondary,
            fontWeight: FontWeight.w600,
          ) ?? const TextStyle(),
          selectedDecoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.tertiary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          canMarkersOverflow: true,
          markersOffset: const PositionedOffset(bottom: 4),
          markerSize: 6,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          leftChevronVisible: false,
          rightChevronVisible: false,
          headerPadding: EdgeInsets.zero,
          headerMargin: EdgeInsets.zero,
          titleTextStyle: TextStyle(fontSize: 0),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ) ??
              const TextStyle(),
          weekendStyle: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ) ??
              const TextStyle(),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;

            return Positioned(
              bottom: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events.take(3).map((event) {
                  final platform = event['platform'] as String;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getPlatformColor(platform),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
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