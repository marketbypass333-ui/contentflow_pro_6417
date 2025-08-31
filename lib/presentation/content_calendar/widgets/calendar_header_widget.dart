import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final bool isWeekView;
  final VoidCallback onToggleView;
  final VoidCallback onTodayPressed;
  final DateTime selectedDate;

  const CalendarHeaderWidget({
    super.key,
    required this.isWeekView,
    required this.onToggleView,
    required this.onTodayPressed,
    required this.selectedDate,
  });

  String _getMonthYearText() {
    final months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    return '${months[selectedDate.month - 1]} ${selectedDate.year + 543}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMonthYearText(),
                style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  _buildViewToggleButton(),
                  SizedBox(width: 3.w),
                  _buildTodayButton(),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('เดือน', !isWeekView),
          _buildToggleOption('สัปดาห์', isWeekView),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: onToggleView,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.darkTheme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? AppTheme.darkTheme.colorScheme.onPrimary
                : AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTodayButton() {
    return GestureDetector(
      onTap: onTodayPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color:
              AppTheme.darkTheme.colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                AppTheme.darkTheme.colorScheme.secondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          'วันนี้',
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.darkTheme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to previous month/week
          },
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: CustomIconWidget(
              iconName: 'chevron_left',
              color: AppTheme.darkTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to next month/week
          },
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.darkTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.darkTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.darkTheme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
