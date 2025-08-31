import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformOptionsWidget extends StatefulWidget {
  final List<String> selectedPlatforms;
  final Map<String, dynamic> platformOptions;
  final Function(Map<String, dynamic>) onOptionsChanged;

  const PlatformOptionsWidget({
    Key? key,
    required this.selectedPlatforms,
    required this.platformOptions,
    required this.onOptionsChanged,
  }) : super(key: key);

  @override
  State<PlatformOptionsWidget> createState() => _PlatformOptionsWidgetState();
}

class _PlatformOptionsWidgetState extends State<PlatformOptionsWidget> {
  bool _isExpanded = false;

  final List<String> instagramHashtags = [
    '#photography',
    '#instagood',
    '#photooftheday',
    '#beautiful',
    '#happy',
    '#love',
    '#nature',
    '#art',
    '#travel',
    '#lifestyle',
    '#fashion',
    '#food'
  ];

  final List<String> audienceOptions = [
    'สาธารณะ',
    'เพื่อน',
    'เฉพาะฉัน',
    'กำหนดเอง'
  ];

  void _updateOption(String platform, String key, dynamic value) {
    Map<String, dynamic> updatedOptions = Map.from(widget.platformOptions);
    if (!updatedOptions.containsKey(platform)) {
      updatedOptions[platform] = {};
    }
    updatedOptions[platform][key] = value;
    widget.onOptionsChanged(updatedOptions);
  }

  Widget _buildInstagramOptions() {
    if (!widget.selectedPlatforms.contains('Instagram'))
      return SizedBox.shrink();

    final options = widget.platformOptions['Instagram'] ?? {};
    final selectedHashtags = List<String>.from(options['hashtags'] ?? []);

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE4405F),
                      Color(0xFFFD1D1D),
                      Color(0xFFFFDC80)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Instagram',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'แฮชแท็กแนะนำ',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: instagramHashtags.map((hashtag) {
              final isSelected = selectedHashtags.contains(hashtag);
              return GestureDetector(
                onTap: () {
                  List<String> updatedHashtags = List.from(selectedHashtags);
                  if (isSelected) {
                    updatedHashtags.remove(hashtag);
                  } else {
                    updatedHashtags.add(hashtag);
                  }
                  _updateOption('Instagram', 'hashtags', updatedHashtags);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    hashtag,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (selectedHashtags.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'เลือกแล้ว: ${selectedHashtags.join(' ')}',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTwitterOptions() {
    if (!widget.selectedPlatforms.contains('Twitter')) return SizedBox.shrink();

    final options = widget.platformOptions['Twitter'] ?? {};
    final isThread = options['isThread'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Color(0xFF1DA1F2),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: CustomIconWidget(
                  iconName: 'alternate_email',
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Twitter',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () => _updateOption('Twitter', 'isThread', !isThread),
            child: Row(
              children: [
                Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: BoxDecoration(
                    color: isThread ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isThread ? AppTheme.primary : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child: isThread
                      ? CustomIconWidget(
                          iconName: 'check',
                          color: Colors.white,
                          size: 3.w,
                        )
                      : null,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สร้างเป็น Thread',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'แบ่งเนื้อหายาวเป็นหลายทวีต',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookOptions() {
    if (!widget.selectedPlatforms.contains('Facebook'))
      return SizedBox.shrink();

    final options = widget.platformOptions['Facebook'] ?? {};
    final selectedAudience = options['audience'] ?? 'สาธารณะ';

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: CustomIconWidget(
                  iconName: 'facebook',
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Facebook',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'ผู้ชมเป้าหมาย',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: audienceOptions.map((audience) {
              final isSelected = selectedAudience == audience;
              return GestureDetector(
                onTap: () => _updateOption('Facebook', 'audience', audience),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    audience,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPlatforms.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: AppTheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'ตัวเลือกขั้นสูง',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.textSecondary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            SizedBox(height: 3.h),
            _buildInstagramOptions(),
            _buildTwitterOptions(),
            _buildFacebookOptions(),
          ],
        ],
      ),
    );
  }
}
