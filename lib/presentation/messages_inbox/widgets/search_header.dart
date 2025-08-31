import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;

  const SearchHeader({
    Key? key,
    required this.controller,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onSearchChanged,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'ค้นหาการสนทนา...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[500],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                onSearchChanged('');
              },
              icon: Icon(
                Icons.clear,
                color: Colors.grey[600],
                size: 5.w,
              ),
              constraints: BoxConstraints(
                minWidth: 8.w,
                minHeight: 8.w,
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}