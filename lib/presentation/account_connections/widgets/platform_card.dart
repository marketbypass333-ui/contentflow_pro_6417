import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformCard extends StatelessWidget {
  final Map<String, dynamic> platform;
  final VoidCallback onTap;

  const PlatformCard({
    Key? key,
    required this.platform,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.border.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: AppTheme.getElevationShadow(1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _getPlatformColor().withValues(alpha: 0.1),
                  ),
                  child: CustomImageWidget(
                    imageUrl: platform['logoUrl'] as String,
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  platform['name'] as String,
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  platform['description'] as String,
                  style: AppTheme.darkTheme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getPlatformColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getPlatformColor(),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'เชื่อมต่อ',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: _getPlatformColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPlatformColor() {
    switch ((platform['name'] as String).toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'tiktok':
        return const Color(0xFF000000);
      default:
        return AppTheme.primary;
    }
  }
}
