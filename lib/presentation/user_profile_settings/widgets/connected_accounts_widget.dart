import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectedAccountsWidget extends StatelessWidget {
  final List<ConnectedAccount> accounts;
  final VoidCallback onViewAllPressed;

  const ConnectedAccountsWidget({
    Key? key,
    required this.accounts,
    required this.onViewAllPressed,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'บัญชีที่เชื่อมต่อ',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: onViewAllPressed,
                  child: Text(
                    'ดูทั้งหมด',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (accounts.isEmpty)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.border.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'link_off',
                      color: AppTheme.textSecondary,
                      size: 32,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'ยังไม่มีบัญชีที่เชื่อมต่อ',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'เชื่อมต่อบัญชีโซเชียลมีเดียเพื่อเริ่มใช้งาน',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...accounts
                .take(3)
                .map((account) => Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color:
                                  account.platformColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: account.iconName,
                              color: account.platformColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            account.platformName,
                            style: AppTheme.darkTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            account.accountName,
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: account.isActive
                                  ? AppTheme.success.withValues(alpha: 0.2)
                                  : AppTheme.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              account.isActive
                                  ? 'เชื่อมต่อแล้ว'
                                  : 'ไม่ได้เชื่อมต่อ',
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: account.isActive
                                    ? AppTheme.success
                                    : AppTheme.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                        ),
                        if (account != accounts.take(3).last)
                          Divider(
                            color: AppTheme.border.withValues(alpha: 0.3),
                            height: 1,
                            indent: 4.w,
                            endIndent: 4.w,
                          ),
                      ],
                    ))
                .toList(),
        ],
      ),
    );
  }
}

class ConnectedAccount {
  final String platformName;
  final String accountName;
  final String iconName;
  final Color platformColor;
  final bool isActive;

  const ConnectedAccount({
    required this.platformName,
    required this.accountName,
    required this.iconName,
    required this.platformColor,
    required this.isActive,
  });
}
