import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FloatingCreateButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final DateTime? selectedDate;

  const FloatingCreateButtonWidget({
    super.key,
    required this.onPressed,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: AppTheme.darkTheme.colorScheme.primary,
        foregroundColor: AppTheme.darkTheme.colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.darkTheme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'สร้างโพสต์',
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.darkTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
