import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class QuickActionsSection extends StatelessWidget {
  final VoidCallback onCreatePost;
  final VoidCallback onViewCalendar;
  final VoidCallback onViewMessages;

  const QuickActionsSection({
    Key? key,
    required this.onCreatePost,
    required this.onViewCalendar,
    required this.onViewMessages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'การดำเนินการด่วน',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'สร้างโพสต์',
                subtitle: 'เขียนเนื้อหาใหม่',
                icon: Icons.add_circle_outline,
                color: AppTheme.primary,
                onTap: onCreatePost,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                title: 'ดูปฏิทิน',
                subtitle: 'จัดการตารางเวลา',
                icon: Icons.calendar_today_outlined,
                color: const Color(0xFF2E7D32),
                onTap: onViewCalendar,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            title: 'ข้อความ',
            subtitle: 'ตอบกลับและจัดการข้อความ',
            icon: Icons.message_outlined,
            color: const Color(0xFFFF6B35),
            onTap: onViewMessages,
            isWide: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isWide = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(3.w),
        onTap: onTap,
        child: Container(
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
            border: Border.all(
              color: color.withAlpha(26),
              width: 1,
            ),
          ),
          child: isWide
              ? Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Icon(
                        icon,
                        size: 6.w,
                        color: color,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 4.w,
                      color: Colors.grey[400],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: color.withAlpha(26),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Icon(
                        icon,
                        size: 6.w,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}