import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PlatformMetricsCard extends StatelessWidget {
  final String platform;
  final String accountName;
  final int followerCount;
  final int followingCount;
  final String status;

  const PlatformMetricsCard({
    Key? key,
    required this.platform,
    required this.accountName,
    required this.followerCount,
    required this.followingCount,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45.w,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with platform icon and status
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _getPlatformColor().withAlpha(26),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3.w),
                topRight: Radius.circular(3.w),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getPlatformColor(),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Icon(
                    _getPlatformIcon(),
                    size: 5.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    _getPlatformDisplayName(),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: status == 'connected' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  child: Text(
                    status == 'connected' ? 'เชื่อมต่อแล้ว' : 'ขาดการเชื่อมต่อ',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Account name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Text(
              accountName,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Metrics
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricItem(
                    'ผู้ติดตาม',
                    _formatNumber(followerCount),
                    Icons.people_outline,
                  ),
                  _buildMetricItem(
                    'กำลังติดตาม',
                    _formatNumber(followingCount),
                    Icons.person_add_outlined,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 1.h),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 4.w,
          color: Colors.grey[600],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
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

  Color _getPlatformColor() {
    switch (platform.toLowerCase()) {
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
      case 'youtube':
        return const Color(0xFFFF0000);
      default:
        return AppTheme.primary;
    }
  }

  IconData _getPlatformIcon() {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'linkedin':
        return Icons.work;
      case 'tiktok':
        return Icons.music_note;
      case 'youtube':
        return Icons.play_arrow;
      default:
        return Icons.public;
    }
  }

  String _getPlatformDisplayName() {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'Facebook';
      case 'instagram':
        return 'Instagram';
      case 'twitter':
        return 'Twitter';
      case 'linkedin':
        return 'LinkedIn';
      case 'tiktok':
        return 'TikTok';
      case 'youtube':
        return 'YouTube';
      default:
        return platform.toUpperCase();
    }
  }
}