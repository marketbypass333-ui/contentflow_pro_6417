import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectedAccountCard extends StatelessWidget {
  final Map<String, dynamic> account;
  final VoidCallback onManage;
  final VoidCallback onRefresh;
  final VoidCallback onDisconnect;

  const ConnectedAccountCard({
    Key? key,
    required this.account,
    required this.onManage,
    required this.onRefresh,
    required this.onDisconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(account['id'].toString()),
      background: _buildSwipeBackground(context, isLeft: true),
      secondaryBackground: _buildSwipeBackground(context, isLeft: false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onRefresh();
        } else {
          onDisconnect();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.getElevationShadow(2),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              _buildPlatformLogo(),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account['accountName'] as String,
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${account['platform']} • ${_formatFollowerCount(account['followers'])}',
                      style: AppTheme.darkTheme.textTheme.bodySmall,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        _buildStatusIndicator(),
                        SizedBox(width: 2.w),
                        Text(
                          _getStatusText(),
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildManageButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformLogo() {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.background,
      ),
      child: CustomImageWidget(
        imageUrl: account['logoUrl'] as String,
        width: 12.w,
        height: 12.w,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 2.w,
      height: 2.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(),
      ),
    );
  }

  Widget _buildManageButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.primary, width: 1),
      ),
      child: InkWell(
        onTap: onManage,
        child: Text(
          'จัดการ',
          style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? AppTheme.warning : AppTheme.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: isLeft ? 'refresh' : 'delete',
                color: Colors.white,
                size: 6.w,
              ),
              SizedBox(height: 0.5.h),
              Text(
                isLeft ? 'รีเฟรช' : 'ยกเลิก',
                style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (account['status'] as String) {
      case 'active':
        return AppTheme.success;
      case 'needs_refresh':
        return AppTheme.warning;
      case 'disconnected':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText() {
    switch (account['status'] as String) {
      case 'active':
        return 'เชื่อมต่อแล้ว';
      case 'needs_refresh':
        return 'ต้องรีเฟรช';
      case 'disconnected':
        return 'ขาดการเชื่อมต่อ';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  String _formatFollowerCount(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M ผู้ติดตาม';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K ผู้ติดตาม';
    } else {
      return '$followers ผู้ติดตาม';
    }
  }
}
