import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PlatformFilterChips extends StatelessWidget {
  final String selectedPlatform;
  final Function(String) onPlatformChanged;

  const PlatformFilterChips({
    Key? key,
    required this.selectedPlatform,
    required this.onPlatformChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> platforms = [
      {
        'key': 'all',
        'name': 'ทั้งหมด',
        'icon': Icons.all_inbox,
        'color': AppTheme.primary
      },
      {
        'key': 'facebook',
        'name': 'Facebook',
        'icon': Icons.facebook,
        'color': const Color(0xFF1877F2)
      },
      {
        'key': 'instagram',
        'name': 'Instagram',
        'icon': Icons.camera_alt,
        'color': const Color(0xFFE4405F)
      },
      {
        'key': 'twitter',
        'name': 'Twitter',
        'icon': Icons.alternate_email,
        'color': const Color(0xFF1DA1F2)
      },
      {
        'key': 'linkedin',
        'name': 'LinkedIn',
        'icon': Icons.work,
        'color': const Color(0xFF0A66C2)
      },
    ];

    return Container(
      height: 6.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: platforms.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final platform = platforms[index];
          final bool isSelected = selectedPlatform == platform['key'];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6.w),
              onTap: () => onPlatformChanged(platform['key']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? platform['color'].withAlpha(26)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: isSelected ? platform['color'] : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: platform['color'].withAlpha(51),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withAlpha(26),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      platform['icon'],
                      size: 4.w,
                      color: isSelected ? platform['color'] : AppTheme.textPrimary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      platform['name'],
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected ? platform['color'] : AppTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}