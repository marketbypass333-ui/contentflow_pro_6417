import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ScheduledPostsSheetWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> posts;
  final Function(Map<String, dynamic>) onEditPost;
  final Function(Map<String, dynamic>) onDeletePost;
  final Function(Map<String, dynamic>) onPreviewPost;

  const ScheduledPostsSheetWidget({
    super.key,
    required this.selectedDate,
    required this.posts,
    required this.onEditPost,
    required this.onDeletePost,
    required this.onPreviewPost,
  });

  String _formatDate() {
    final months = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    return '${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year + 543}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          _buildPostsList(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      width: 10.w,
      height: 0.5.h,
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'calendar_today',
            color: AppTheme.darkTheme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'โพสต์ที่กำหนดไว้',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                _formatDate(),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkTheme.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${posts.length} โพสต์',
            style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.darkTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    if (posts.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'event_note',
              color: AppTheme.darkTheme.colorScheme.onSurface
                  .withValues(alpha: 0.3),
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'ไม่มีโพสต์ที่กำหนดไว้',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'แตะเพื่อเพิ่มโพสต์ใหม่',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.darkTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: 50.h),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        itemCount: posts.length,
        separatorBuilder: (context, index) => SizedBox(height: 1.h),
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostItem(post);
        },
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    final platform = post['platform'] as String;
    final content = post['content'] as String;
    final scheduledTime = post['scheduledDate'] as DateTime;
    final status = post['status'] as String;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.darkTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.darkTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPlatformIcon(platform),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      platform,
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getPlatformColor(platform),
                      ),
                    ),
                    Text(
                      _formatTime(scheduledTime),
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            content,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkTheme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                'ดูตัวอย่าง',
                Icons.visibility_outlined,
                () => onPreviewPost(post),
              ),
              SizedBox(width: 2.w),
              _buildActionButton(
                'แก้ไข',
                Icons.edit_outlined,
                () => onEditPost(post),
              ),
              SizedBox(width: 2.w),
              _buildActionButton(
                'ลบ',
                Icons.delete_outline,
                () => onDeletePost(post),
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformIcon(String platform) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: _getPlatformColor(platform).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomIconWidget(
        iconName: _getPlatformIconName(platform),
        color: _getPlatformColor(platform),
        size: 20,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'scheduled':
        statusColor = AppTheme.darkTheme.colorScheme.tertiary;
        statusText = 'กำหนดไว้';
        break;
      case 'published':
        statusColor = AppTheme.darkTheme.colorScheme.tertiary;
        statusText = 'เผยแพร่แล้ว';
        break;
      case 'failed':
        statusColor = AppTheme.darkTheme.colorScheme.error;
        statusText = 'ล้มเหลว';
        break;
      default:
        statusColor =
            AppTheme.darkTheme.colorScheme.onSurface.withValues(alpha: 0.5);
        statusText = 'ร่าง';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        statusText,
        style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.1)
              : AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDestructive
                ? AppTheme.darkTheme.colorScheme.error.withValues(alpha: 0.3)
                : AppTheme.darkTheme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDestructive
                  ? AppTheme.darkTheme.colorScheme.error
                  : AppTheme.darkTheme.colorScheme.primary,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                color: isDestructive
                    ? AppTheme.darkTheme.colorScheme.error
                    : AppTheme.darkTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'linkedin':
        return const Color(0xFF0A66C2);
      case 'youtube':
        return const Color(0xFFFF0000);
      default:
        return AppTheme.darkTheme.colorScheme.tertiary;
    }
  }

  String _getPlatformIconName(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return 'facebook';
      case 'instagram':
        return 'camera_alt';
      case 'twitter':
        return 'alternate_email';
      case 'linkedin':
        return 'work';
      case 'youtube':
        return 'play_circle_outline';
      default:
        return 'share';
    }
  }
}
