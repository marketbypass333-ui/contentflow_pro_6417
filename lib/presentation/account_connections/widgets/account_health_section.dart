import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccountHealthSection extends StatelessWidget {
  final Map<String, dynamic> healthData;

  const AccountHealthSection({
    Key? key,
    required this.healthData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'health_and_safety',
                color: AppTheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'สถานะสุขภาพบัญชี',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildHealthMetric(
            'การใช้งาน API',
            '${healthData['apiUsage']}/${healthData['apiLimit']}',
            (healthData['apiUsage'] as int) / (healthData['apiLimit'] as int),
            AppTheme.primary,
          ),
          SizedBox(height: 2.h),
          _buildHealthMetric(
            'อัตราการส่งข้อมูล',
            '${healthData['rateUsage']}/${healthData['rateLimit']} ต่อชั่วโมง',
            (healthData['rateUsage'] as int) / (healthData['rateLimit'] as int),
            AppTheme.warning,
          ),
          SizedBox(height: 3.h),
          _buildLastSyncInfo(),
        ],
      ),
    );
  }

  Widget _buildHealthMetric(
      String title, String subtitle, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: AppTheme.darkTheme.textTheme.bodySmall,
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.border.withValues(alpha: 0.3),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 0.8.h,
        ),
      ],
    );
  }

  Widget _buildLastSyncInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'sync',
            color: AppTheme.success,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ซิงค์ล่าสุด',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  healthData['lastSync'] as String,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'ปกติ',
              style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
