import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class RecommendationsWidget extends StatelessWidget {
  final Map<String, dynamic> analyticsData;

  const RecommendationsWidget({
    Key? key,
    required this.analyticsData,
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
              Icon(
                Icons.auto_awesome,
                color: Colors.purple,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'AI-Powered Recommendations',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ..._generateRecommendations().map(
              (recommendation) => _buildRecommendationCard(recommendation)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateRecommendations() {
    final engagementRate =
        (analyticsData['avg_engagement_rate'] as num?)?.toDouble() ?? 0.0;
    final totalReach = (analyticsData['total_reach'] as num?)?.toInt() ?? 0;
    final followerGrowth =
        (analyticsData['follower_growth'] as num?)?.toInt() ?? 0;
    final totalPosts = (analyticsData['total_posts'] as num?)?.toInt() ?? 0;

    List<Map<String, dynamic>> recommendations = [];

    // Engagement rate recommendations
    if (engagementRate < 5.0) {
      recommendations.add({
        'type': 'engagement',
        'icon': Icons.favorite_outline,
        'color': Colors.red,
        'title': 'Boost Engagement Rate',
        'description':
            'Your engagement rate is below 5%. Try posting more interactive content like polls, questions, and behind-the-scenes content.',
        'priority': 'high',
        'actionable': true,
      });
    } else if (engagementRate < 10.0) {
      recommendations.add({
        'type': 'engagement',
        'icon': Icons.trending_up,
        'color': Colors.orange,
        'title': 'Improve Engagement Rate',
        'description':
            'Good start! To reach 10%+ engagement, focus on posting during peak audience activity times and use trending hashtags.',
        'priority': 'medium',
        'actionable': true,
      });
    } else {
      recommendations.add({
        'type': 'engagement',
        'icon': Icons.star_outline,
        'color': Colors.green,
        'title': 'Excellent Engagement!',
        'description':
            'Your engagement rate is above 10%! Keep up the great work by maintaining consistent quality content.',
        'priority': 'low',
        'actionable': false,
      });
    }

    // Posting frequency recommendations
    if (totalPosts < 10) {
      recommendations.add({
        'type': 'frequency',
        'icon': Icons.schedule,
        'color': Colors.blue,
        'title': 'Increase Posting Frequency',
        'description':
            'Post at least 3-5 times per week to maintain audience engagement and improve algorithm visibility.',
        'priority': 'high',
        'actionable': true,
      });
    }

    // Reach optimization
    if (totalReach < 1000) {
      recommendations.add({
        'type': 'reach',
        'icon': Icons.visibility,
        'color': Colors.purple,
        'title': 'Expand Your Reach',
        'description':
            'Use relevant hashtags, collaborate with other accounts, and share content to stories to increase visibility.',
        'priority': 'medium',
        'actionable': true,
      });
    }

    // Follower growth recommendations
    if (followerGrowth <= 0) {
      recommendations.add({
        'type': 'growth',
        'icon': Icons.person_add,
        'color': Colors.teal,
        'title': 'Accelerate Follower Growth',
        'description':
            'Engage with your audience comments, use location tags, and create shareable content to attract new followers.',
        'priority': 'high',
        'actionable': true,
      });
    }

    // Optimal posting times
    recommendations.add({
      'type': 'timing',
      'icon': Icons.access_time,
      'color': Colors.indigo,
      'title': 'Optimal Posting Times',
      'description':
          'Based on your audience activity, the best times to post are 8-10 AM and 7-9 PM on weekdays.',
      'priority': 'medium',
      'actionable': true,
    });

    // Content diversity
    recommendations.add({
      'type': 'content',
      'icon': Icons.palette,
      'color': Colors.pink,
      'title': 'Diversify Content Types',
      'description':
          'Mix your content with images, videos, carousels, and stories. Video content typically gets 3x more engagement.',
      'priority': 'medium',
      'actionable': true,
    });

    return recommendations;
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPriorityColor(recommendation['priority']).withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (recommendation['color'] as Color).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  recommendation['icon'] as IconData,
                  color: recommendation['color'] as Color,
                  size: 16.sp,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  recommendation['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              _buildPriorityBadge(recommendation['priority']),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            recommendation['description'] as String,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          if (recommendation['actionable'] == true) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      _handleRecommendationAction(recommendation['type']),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        (recommendation['color'] as Color).withAlpha(26),
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Take Action',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: recommendation['color'] as Color,
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

  Widget _buildPriorityBadge(String priority) {
    Color color;
    String label;

    switch (priority) {
      case 'high':
        color = Colors.red;
        label = 'HIGH';
        break;
      case 'medium':
        color = Colors.orange;
        label = 'MED';
        break;
      case 'low':
        color = Colors.green;
        label = 'LOW';
        break;
      default:
        color = Colors.grey;
        label = 'N/A';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleRecommendationAction(String type) {
    // Handle different recommendation actions
    switch (type) {
      case 'engagement':
        // Navigate to content creation with engagement tips
        break;
      case 'frequency':
        // Navigate to content calendar
        break;
      case 'reach':
        // Navigate to hashtag suggestions
        break;
      case 'growth':
        // Navigate to audience insights
        break;
      case 'timing':
        // Navigate to scheduling options
        break;
      case 'content':
        // Navigate to content ideas
        break;
    }
  }
}