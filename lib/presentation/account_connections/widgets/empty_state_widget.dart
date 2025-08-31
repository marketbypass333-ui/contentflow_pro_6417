import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onGetStarted;

  const EmptyStateWidget({
    Key? key,
    required this.onGetStarted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImageWidget(
            imageUrl:
                'https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=400&h=400&fit=crop',
            width: 40.w,
            height: 40.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 4.h),
          Text(
            'เชื่อมต่อบัญชีโซเชียลมีเดีย',
            style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            'เริ่มต้นการจัดการโซเชียลมีเดียของคุณโดยการเชื่อมต่อบัญชีแรก เราสนับสนุนแพลตฟอร์มหลักทั้งหมด',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          _buildStepGuide(),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'เริ่มต้นเชื่อมต่อ',
                style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepGuide() {
    final steps = [
      {
        'icon': 'link',
        'title': 'เลือกแพลตฟอร์ม',
        'description': 'เลือกโซเชียลมีเดียที่ต้องการเชื่อมต่อ',
      },
      {
        'icon': 'security',
        'title': 'ยืนยันตัวตน',
        'description': 'เข้าสู่ระบบด้วยบัญชีของคุณ',
      },
      {
        'icon': 'check_circle',
        'title': 'เริ่มใช้งาน',
        'description': 'จัดการเนื้อหาและกำหนดการโพสต์',
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: index < steps.length - 1 ? 2.h : 0),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: step['icon'] as String,
                  color: AppTheme.primary,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      step['description'] as String,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
