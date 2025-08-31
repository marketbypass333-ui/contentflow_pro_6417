import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;
  final int unreadCount;
  final VoidCallback? onNotificationTap;

  const DashboardHeader({
    Key? key,
    required this.userName,
    this.avatarUrl,
    required this.unreadCount,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int hour = now.hour;
    String greeting = 'สวัสดี';

    if (hour < 12) {
      greeting = 'สวัสดีตอนเช้า';
    } else if (hour < 17) {
      greeting = 'สวัสดีตอนบ่าย';
    } else {
      greeting = 'สวัสดีตอนเย็น';
    }

    return Row(
      children: [
        // User avatar
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withAlpha(51),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: 6.w,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[400],
                        size: 6.w,
                      ),
                    ),
                  )
                : Container(
                    color: AppTheme.primary.withAlpha(26),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.primary,
                      size: 6.w,
                    ),
                  ),
          ),
        ),

        SizedBox(width: 3.w),

        // Greeting and user name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                userName,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Notifications bell
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6.w),
            onTap: onNotificationTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 6.w,
                    color: AppTheme.textPrimary,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(1.w),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 4.w,
                          minHeight: 4.w,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: 2.w),

        // Account switcher (placeholder for now)
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6.w),
            onTap: () {
              // TODO: Implement account switcher
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account switcher coming soon!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 6.w,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}