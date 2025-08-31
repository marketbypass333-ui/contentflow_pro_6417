import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class TopPostsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> topPosts;

  const TopPostsWidget({
    Key? key,
    required this.topPosts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Top Performing Posts',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          topPosts.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: topPosts
                      .take(5)
                      .map((post) => _buildPostItem(post))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 48.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'No posts available',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Publish content to see performance analytics',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    final analytics = post['post_analytics'] != null &&
            (post['post_analytics'] as List).isNotEmpty
        ? (post['post_analytics'] as List)[0]
        : <String, dynamic>{};

    final engagementRate = analytics['engagement_rate']?.toDouble() ?? 0.0;
    final reach = analytics['reach'] as int? ?? 0;
    final likes = analytics['likes_count'] as int? ?? 0;
    final comments = analytics['comments_count'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildPlatformBadge(post['platform']),
              SizedBox(width: 2.w),
              _buildContentTypeBadge(post['content_type']),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getEngagementColor(engagementRate).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${engagementRate.toStringAsFixed(1)}%',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: _getEngagementColor(engagementRate),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            post['title'] ??
                post['content']?.toString().substring(0, 50) ??
                'Untitled Post',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (post['content'] != null) ...[
            SizedBox(height: 1.h),
            Text(
              post['content'].toString(),
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildMetric(Icons.visibility_outlined, reach, 'reach'),
              SizedBox(width: 4.w),
              _buildMetric(Icons.favorite_outline, likes, 'likes'),
              SizedBox(width: 4.w),
              _buildMetric(Icons.comment_outlined, comments, 'comments'),
              const Spacer(),
              Text(
                _formatDate(post['published_at']),
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformBadge(String platform) {
    Color color;
    String label;

    switch (platform) {
      case 'facebook':
        color = const Color(0xFF1877F2);
        label = 'FB';
        break;
      case 'instagram':
        color = const Color(0xFFE4405F);
        label = 'IG';
        break;
      case 'twitter':
        color = const Color(0xFF1DA1F2);
        label = 'TW';
        break;
      case 'linkedin':
        color = const Color(0xFF0A66C2);
        label = 'LI';
        break;
      case 'tiktok':
        color = Colors.black;
        label = 'TT';
        break;
      case 'youtube':
        color = const Color(0xFFFF0000);
        label = 'YT';
        break;
      default:
        color = Colors.grey;
        label = platform.toUpperCase().substring(0, 2);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContentTypeBadge(String contentType) {
    IconData icon;
    Color color;

    switch (contentType) {
      case 'image':
        icon = Icons.image_outlined;
        color = Colors.purple;
        break;
      case 'video':
        icon = Icons.play_circle_outlined;
        color = Colors.red;
        break;
      case 'text':
        icon = Icons.text_fields;
        color = Colors.blue;
        break;
      case 'carousel':
        icon = Icons.view_carousel_outlined;
        color = Colors.orange;
        break;
      case 'story':
        icon = Icons.auto_stories_outlined;
        color = Colors.green;
        break;
      case 'reel':
        icon = Icons.movie_outlined;
        color = Colors.pink;
        break;
      default:
        icon = Icons.article_outlined;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        size: 14.sp,
        color: color,
      ),
    );
  }

  Widget _buildMetric(IconData icon, int value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: Colors.grey[600],
        ),
        SizedBox(width: 1.w),
        Text(
          _formatNumber(value),
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getEngagementColor(double rate) {
    if (rate >= 15.0) return Colors.green;
    if (rate >= 10.0) return Colors.orange;
    if (rate >= 5.0) return Colors.blue;
    return Colors.red;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}