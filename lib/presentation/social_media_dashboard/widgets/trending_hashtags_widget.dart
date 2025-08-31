import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TrendingHashtagsWidget extends StatelessWidget {
  const TrendingHashtagsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Static trending hashtags for demo
    final List<Map<String, dynamic>> trendingHashtags = [
      {'tag': 'SocialMediaMarketing', 'count': 12500, 'growth': '+15%'},
      {'tag': 'ContentCreator', 'count': 8900, 'growth': '+8%'},
      {'tag': 'DigitalMarketing', 'count': 7200, 'growth': '+22%'},
      {'tag': 'TechNews', 'count': 5800, 'growth': '+5%'},
      {'tag': 'StartupLife', 'count': 4300, 'growth': '+12%'},
      {'tag': 'Innovation', 'count': 3700, 'growth': '+18%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'แฮชแท็กยอดนิยม',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                _showAllHashtagsBottomSheet(context, trendingHashtags);
              },
              child: Text(
                'ดูทั้งหมด',
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
        Container(
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
            children: [
              // Top trending hashtags
              ...trendingHashtags
                  .take(3)
                  .map((hashtag) => _buildHashtagItem(hashtag, true)),

              SizedBox(height: 2.h),

              // Popular hashtag chips
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  '#เนื้อหาดี',
                  '#โซเชียลมีเดีย',
                  '#มาร์เก็ตติ้ง',
                  '#ธุรกิจออนไลน์',
                  '#คอนเทนต์',
                  '#ดิจิทัล',
                ].map((tag) => _buildHashtagChip(tag)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHashtagItem(Map<String, dynamic> hashtag, bool showGrowth) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(1.5.w),
            ),
            child: Icon(
              Icons.trending_up,
              size: 4.w,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${hashtag['tag']}',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  '${_formatNumber(hashtag['count'])} โพสต์',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (showGrowth) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(26),
                borderRadius: BorderRadius.circular(1.w),
              ),
              child: Text(
                hashtag['growth'],
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(4.w),
                onTap: () => _useHashtag(hashtag['tag']),
                child: Padding(
                  padding: EdgeInsets.all(1.w),
                  child: Icon(
                    Icons.add_circle_outline,
                    size: 5.w,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHashtagChip(String tag) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6.w),
        onTap: () => _useHashtag(tag.replaceAll('#', '')),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6.w),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Text(
            tag,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _useHashtag(String tag) {
    // TODO: Implement hashtag usage - could copy to clipboard or navigate to post creation
    debugPrint('Using hashtag: #$tag');
  }

  void _showAllHashtagsBottomSheet(
      BuildContext context, List<Map<String, dynamic>> hashtags) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(0.5.h),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'แฮชแท็กยอดนิยมทั้งหมด',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView.separated(
                itemCount: hashtags.length,
                separatorBuilder: (context, index) => SizedBox(height: 2.h),
                itemBuilder: (context, index) =>
                    _buildHashtagItem(hashtags[index], true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}