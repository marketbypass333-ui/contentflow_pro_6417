import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RecentPostsSection extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final VoidCallback onRefresh;

  const RecentPostsSection({
    Key? key,
    required this.posts,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'โพสต์ล่าสุด',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh,
                size: 4.w,
                color: AppTheme.primary,
              ),
              label: Text(
                'รีเฟรช',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        posts.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                separatorBuilder: (context, index) => SizedBox(height: 2.h),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPostCard(post);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
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
      child: Column(
        children: [
          Icon(
            Icons.post_add_outlined,
            size: 15.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'ยังไม่มีโพสต์',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'เริ่มสร้างเนื้อหาแรกของคุณ',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final String title = post['title'] ?? 'ไม่มีชื่อเรื่อง';
    final String content = post['content'] ?? '';
    final String status = post['status'] ?? 'draft';
    final DateTime? publishedAt = post['published_at'] != null
        ? DateTime.tryParse(post['published_at'])
        : null;
    final DateTime createdAt =
        DateTime.tryParse(post['created_at']) ?? DateTime.now();
    final String platform =
        post['connected_accounts']?['platform'] ?? 'unknown';
    final String accountName =
        post['connected_accounts']?['account_name'] ?? 'Unknown Account';

    final int likesCount = post['likes_count'] ?? 0;
    final int commentsCount = post['comments_count'] ?? 0;
    final int sharesCount = post['shares_count'] ?? 0;

    return Container(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with platform and status
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: _getPlatformColor(platform).withAlpha(26),
                  borderRadius: BorderRadius.circular(1.5.w),
                ),
                child: Icon(
                  _getPlatformIcon(platform),
                  size: 4.w,
                  color: _getPlatformColor(platform),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountName,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      timeago.format(createdAt, locale: 'th'),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(status),
            ],
          ),

          SizedBox(height: 2.h),

          // Post title
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 1.h),
          ],

          // Post content
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: 2.h),

          // Engagement metrics
          if (status == 'published') ...[
            Row(
              children: [
                _buildEngagementMetric(Icons.favorite_outline, likesCount),
                SizedBox(width: 4.w),
                _buildEngagementMetric(Icons.comment_outlined, commentsCount),
                SizedBox(width: 4.w),
                _buildEngagementMetric(Icons.share_outlined, sharesCount),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: Implement post actions (edit/boost)
                  },
                  icon: Icon(
                    Icons.more_vert,
                    size: 5.w,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Implement edit post
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 4.w,
                    color: AppTheme.primary,
                  ),
                  label: Text(
                    'แก้ไข',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'published':
        color = Colors.green;
        text = 'เผยแพร่แล้ว';
        break;
      case 'scheduled':
        color = Colors.orange;
        text = 'กำหนดเวลา';
        break;
      case 'draft':
        color = Colors.grey;
        text = 'ร่าง';
        break;
      case 'failed':
        color = Colors.red;
        text = 'ล้มเหลว';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEngagementMetric(IconData icon, int count) {
    return Row(
      children: [
        Icon(
          icon,
          size: 4.w,
          color: Colors.grey[600],
        ),
        SizedBox(width: 1.w),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
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
      case 'tiktok':
        return const Color(0xFF000000);
      case 'youtube':
        return const Color(0xFFFF0000);
      default:
        return AppTheme.primary;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
        return Icons.alternate_email;
      case 'linkedin':
        return Icons.work;
      case 'tiktok':
        return Icons.music_note;
      case 'youtube':
        return Icons.play_arrow;
      default:
        return Icons.public;
    }
  }
}