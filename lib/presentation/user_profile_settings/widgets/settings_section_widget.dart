import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<SettingsItem> items;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              title,
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                ListTile(
                  leading: item.iconName != null
                      ? CustomIconWidget(
                          iconName: item.iconName!,
                          color: item.iconColor ?? AppTheme.textSecondary,
                          size: 24,
                        )
                      : null,
                  title: Text(
                    item.title,
                    style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: item.subtitle != null
                      ? Text(
                          item.subtitle!,
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : null,
                  trailing: item.trailing ??
                      (item.onTap != null
                          ? CustomIconWidget(
                              iconName: 'chevron_right',
                              color: AppTheme.textSecondary,
                              size: 20,
                            )
                          : null),
                  onTap: item.onTap,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                ),
                if (!isLast)
                  Divider(
                    color: AppTheme.border.withValues(alpha: 0.3),
                    height: 1,
                    indent: 4.w,
                    endIndent: 4.w,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}

class SettingsItem {
  final String title;
  final String? subtitle;
  final String? iconName;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.title,
    this.subtitle,
    this.iconName,
    this.iconColor,
    this.trailing,
    this.onTap,
  });
}
