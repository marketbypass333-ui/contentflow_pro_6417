import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ContentInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final List<String> selectedPlatforms;
  final Function(String) onTextChanged;

  const ContentInputWidget({
    Key? key,
    required this.controller,
    required this.selectedPlatforms,
    required this.onTextChanged,
  }) : super(key: key);

  @override
  State<ContentInputWidget> createState() => _ContentInputWidgetState();
}

class _ContentInputWidgetState extends State<ContentInputWidget> {
  bool _isExpanded = false;

  final Map<String, int> platformLimits = {
    'Twitter': 280,
    'Instagram': 2200,
    'Facebook': 63206,
    'LinkedIn': 3000,
    'TikTok': 150,
    'YouTube': 5000,
  };

  int get _currentLimit {
    if (widget.selectedPlatforms.isEmpty) return 2200;

    int minLimit = platformLimits.values.reduce((a, b) => a < b ? a : b);
    for (String platform in widget.selectedPlatforms) {
      int limit = platformLimits[platform] ?? 2200;
      if (limit < minLimit) minLimit = limit;
    }
    return minLimit;
  }

  Color get _counterColor {
    int currentLength = widget.controller.text.length;
    double ratio = currentLength / _currentLimit;

    if (ratio >= 1.0) return AppTheme.error;
    if (ratio >= 0.8) return AppTheme.warning;
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'เนื้อหาโพสต์',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _isExpanded ? 'expand_less' : 'expand_more',
                        color: AppTheme.textSecondary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _isExpanded ? 'ย่อ' : 'ขยาย',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isExpanded ? 25.h : 15.h,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onTextChanged,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'เขียนเนื้อหาที่คุณต้องการโพสต์...',
                hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(4.w),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.selectedPlatforms.isNotEmpty)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'ขีดจำกัด: ${_currentLimit} ตัวอักษร',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primary,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _counterColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${widget.controller.text.length}/${_currentLimit}',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: _counterColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          if (widget.controller.text.length > _currentLimit) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.error,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'เนื้อหายาวเกินขีดจำกัดของแพลตฟอร์มที่เลือก',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.error,
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
