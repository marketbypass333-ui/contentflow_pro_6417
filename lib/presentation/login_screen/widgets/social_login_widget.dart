import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final bool isLoading;
  final Function(String provider) onSocialLogin;

  const SocialLoginWidget({
    Key? key,
    required this.isLoading,
    required this.onSocialLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "หรือ" text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.border.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'หรือ',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.border.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Social Login Buttons
        Row(
          children: [
            // Google Login Button
            Expanded(
              child: _buildSocialButton(
                context: context,
                provider: 'Google',
                icon: 'g_translate',
                backgroundColor: AppTheme.darkTheme.colorScheme.surface,
                borderColor: AppTheme.border.withValues(alpha: 0.3),
                textColor: AppTheme.textPrimary,
                onTap: () => onSocialLogin('google'),
              ),
            ),

            SizedBox(width: 3.w),

            // Facebook Login Button
            Expanded(
              child: _buildSocialButton(
                context: context,
                provider: 'Facebook',
                icon: 'facebook',
                backgroundColor: const Color(0xFF1877F2),
                borderColor: const Color(0xFF1877F2),
                textColor: Colors.white,
                onTap: () => onSocialLogin('facebook'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String provider,
    required String icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 6.h,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: textColor,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    provider,
                    style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
