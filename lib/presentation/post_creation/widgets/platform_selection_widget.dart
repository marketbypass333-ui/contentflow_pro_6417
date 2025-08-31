import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PlatformSelectionWidget extends StatefulWidget {
  final List<String> selectedPlatforms;
  final Function(List<String>) onPlatformsChanged;

  const PlatformSelectionWidget({
    Key? key,
    required this.selectedPlatforms,
    required this.onPlatformsChanged,
  }) : super(key: key);

  @override
  State<PlatformSelectionWidget> createState() =>
      _PlatformSelectionWidgetState();
}

class _PlatformSelectionWidgetState extends State<PlatformSelectionWidget> {
  final List<Map<String, dynamic>> platforms = [
    {
      'name': 'Facebook',
      'icon': 'facebook',
      'color': Color(0xFF1877F2),
      'preview':
          'https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=60&h=60&fit=crop&crop=center'
    },
    {
      'name': 'Instagram',
      'icon': 'camera_alt',
      'color': Color(0xFFE4405F),
      'preview':
          'https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=60&h=60&fit=crop&crop=center'
    },
    {
      'name': 'Twitter',
      'icon': 'alternate_email',
      'color': Color(0xFF1DA1F2),
      'preview':
          'https://images.unsplash.com/photo-1611605698335-8b1569810432?w=60&h=60&fit=crop&crop=center'
    },
    {
      'name': 'LinkedIn',
      'icon': 'business',
      'color': Color(0xFF0A66C2),
      'preview':
          'https://images.unsplash.com/photo-1611224923853-80b023f02d71?w=60&h=60&fit=crop&crop=center'
    },
    {
      'name': 'TikTok',
      'icon': 'music_note',
      'color': Color(0xFF000000),
      'preview':
          'https://images.unsplash.com/photo-1611162618071-b39a2ec055fb?w=60&h=60&fit=crop&crop=center'
    },
    {
      'name': 'YouTube',
      'icon': 'play_circle_filled',
      'color': Color(0xFFFF0000),
      'preview':
          'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=60&h=60&fit=crop&crop=center'
    },
  ];

  void _togglePlatform(String platformName) {
    List<String> updatedPlatforms = List.from(widget.selectedPlatforms);

    if (updatedPlatforms.contains(platformName)) {
      updatedPlatforms.remove(platformName);
    } else {
      updatedPlatforms.add(platformName);
    }

    widget.onPlatformsChanged(updatedPlatforms);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลือกแพลตฟอร์ม',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: platforms.map((platform) {
              final isSelected =
                  widget.selectedPlatforms.contains(platform['name']);

              return GestureDetector(
                onTap: () => _togglePlatform(platform['name']),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: platform['color'],
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        child: CustomImageWidget(
                          imageUrl: platform['preview'],
                          width: 6.w,
                          height: 6.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: platform['icon'],
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        platform['name'],
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: AppTheme.primary,
                          size: 4.w,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (widget.selectedPlatforms.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'เลือกแล้ว ${widget.selectedPlatforms.length} แพลตฟอร์ม: ${widget.selectedPlatforms.join(', ')}',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
