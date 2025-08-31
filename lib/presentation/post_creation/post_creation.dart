import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/ai_suggestion_widget.dart';
import './widgets/content_input_widget.dart';
import './widgets/media_attachment_widget.dart';
import './widgets/platform_options_widget.dart';
import './widgets/platform_selection_widget.dart';
import './widgets/scheduling_widget.dart';

class PostCreation extends StatefulWidget {
  const PostCreation({Key? key}) : super(key: key);

  @override
  State<PostCreation> createState() => _PostCreationState();
}

class _PostCreationState extends State<PostCreation>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> _selectedPlatforms = [];
  List<XFile> _attachedMedia = [];
  DateTime? _scheduledDateTime;
  bool _isImmediate = true;
  Map<String, dynamic> _platformOptions = {};
  bool _isPosting = false;
  bool _isDraftSaved = false;

  // Auto-save timer
  DateTime _lastSaveTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onContentChanged);
    _autoSaveDraft();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    setState(() {
      _isDraftSaved = false;
    });
    _autoSaveDraft();
  }

  void _autoSaveDraft() {
    Future.delayed(Duration(seconds: 2), () {
      if (_contentController.text.isNotEmpty &&
          DateTime.now().difference(_lastSaveTime).inSeconds > 2) {
        _saveDraft();
      }
    });
  }

  void _saveDraft() {
    setState(() {
      _isDraftSaved = true;
      _lastSaveTime = DateTime.now();
    });

    // Show subtle save indicator
    if (mounted) {
      Fluttertoast.showToast(
        msg: "บันทึกร่างอัตโนมัติแล้ว",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.success.withValues(alpha: 0.8),
        textColor: Colors.white,
        fontSize: 12.sp,
      );
    }
  }

  void _onPlatformsChanged(List<String> platforms) {
    setState(() {
      _selectedPlatforms = platforms;
    });
  }

  void _onMediaChanged(List<XFile> media) {
    setState(() {
      _attachedMedia = media;
    });
  }

  void _onScheduleChanged(DateTime? dateTime) {
    setState(() {
      _scheduledDateTime = dateTime;
    });
  }

  void _onImmediateChanged(bool immediate) {
    setState(() {
      _isImmediate = immediate;
    });
  }

  void _onPlatformOptionsChanged(Map<String, dynamic> options) {
    setState(() {
      _platformOptions = options;
    });
  }

  void _onSuggestionSelected(String suggestion) {
    setState(() {
      _contentController.text = suggestion;
    });
  }

  bool _validatePost() {
    if (_selectedPlatforms.isEmpty) {
      _showErrorMessage('กรุณาเลือกแพลตฟอร์มอย่างน้อย 1 แพลตฟอร์ม');
      return false;
    }

    if (_contentController.text.trim().isEmpty && _attachedMedia.isEmpty) {
      _showErrorMessage('กรุณาเพิ่มเนื้อหาหรือสื่อแนบ');
      return false;
    }

    // Check character limits for selected platforms
    final Map<String, int> platformLimits = {
      'Twitter': 280,
      'Instagram': 2200,
      'Facebook': 63206,
      'LinkedIn': 3000,
      'TikTok': 150,
      'YouTube': 5000,
    };

    for (String platform in _selectedPlatforms) {
      int limit = platformLimits[platform] ?? 2200;
      if (_contentController.text.length > limit) {
        _showErrorMessage(
            'เนื้อหายาวเกินขีดจำกัดของ $platform ($limit ตัวอักษร)');
        return false;
      }
    }

    if (!_isImmediate && _scheduledDateTime == null) {
      _showErrorMessage('กรุณาเลือกวันและเวลาที่ต้องการโพสต์');
      return false;
    }

    if (!_isImmediate &&
        _scheduledDateTime != null &&
        _scheduledDateTime!.isBefore(DateTime.now())) {
      _showErrorMessage('ไม่สามารถกำหนดเวลาในอดีตได้');
      return false;
    }

    return true;
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.error,
      textColor: Colors.white,
      fontSize: 12.sp,
    );
  }

  void _showSuccessMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.success,
      textColor: Colors.white,
      fontSize: 12.sp,
    );
  }

  Future<void> _publishPost() async {
    if (!_validatePost()) return;

    setState(() => _isPosting = true);

    try {
      // Simulate API call to Ayrshare
      await Future.delayed(Duration(seconds: 3));

      // Haptic feedback on success
      HapticFeedback.lightImpact();

      if (_isImmediate) {
        _showSuccessMessage('โพสต์เผยแพร่สำเร็จแล้ว!');
      } else {
        _showSuccessMessage('กำหนดการโพสต์สำเร็จแล้ว!');
      }

      // Navigate back or to dashboard
      Navigator.pop(context);
    } catch (e) {
      _showErrorMessage('เกิดข้อผิดพลาดในการโพสต์ กรุณาลองใหม่อีกครั้ง');
    } finally {
      setState(() => _isPosting = false);
    }
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ตัวอย่างโพสต์',
                    style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.textSecondary,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(4.w),
                itemCount: _selectedPlatforms.length,
                itemBuilder: (context, index) {
                  final platform = _selectedPlatforms[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 3.h),
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          platform,
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _contentController.text,
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        if (_attachedMedia.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'สื่อแนบ: ${_attachedMedia.length} ไฟล์',
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.textPrimary,
              size: 6.w,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สร้างโพสต์ใหม่',
              style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_isDraftSaved)
              Text(
                'บันทึกร่างแล้ว',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.success,
                  fontSize: 9.sp,
                ),
              ),
          ],
        ),
        actions: [
          if (_contentController.text.isNotEmpty || _attachedMedia.isNotEmpty)
            GestureDetector(
              onTap: _showPreview,
              child: Container(
                margin: EdgeInsets.only(right: 2.w),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'preview',
                      color: AppTheme.textPrimary,
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'ดูตัวอย่าง',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  // Platform Selection
                  PlatformSelectionWidget(
                    selectedPlatforms: _selectedPlatforms,
                    onPlatformsChanged: _onPlatformsChanged,
                  ),

                  SizedBox(height: 3.h),

                  // Content Input
                  ContentInputWidget(
                    controller: _contentController,
                    selectedPlatforms: _selectedPlatforms,
                    onTextChanged: (text) => setState(() {}),
                  ),

                  SizedBox(height: 3.h),

                  // Media Attachment
                  MediaAttachmentWidget(
                    attachedMedia: _attachedMedia,
                    onMediaChanged: _onMediaChanged,
                  ),

                  SizedBox(height: 3.h),

                  // AI Suggestions
                  AiSuggestionWidget(
                    onSuggestionSelected: _onSuggestionSelected,
                    selectedPlatforms: _selectedPlatforms,
                  ),

                  SizedBox(height: 3.h),

                  // Scheduling
                  SchedulingWidget(
                    scheduledDateTime: _scheduledDateTime,
                    onScheduleChanged: _onScheduleChanged,
                    isImmediate: _isImmediate,
                    onImmediateChanged: _onImmediateChanged,
                  ),

                  SizedBox(height: 3.h),

                  // Platform Options
                  PlatformOptionsWidget(
                    selectedPlatforms: _selectedPlatforms,
                    platformOptions: _platformOptions,
                    onOptionsChanged: _onPlatformOptionsChanged,
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isPosting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        side: BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'ยกเลิก',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isPosting ? null : _publishPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isPosting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 4.w,
                                  height: 4.w,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'กำลังโพสต์...',
                                  style: AppTheme.darkTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName:
                                      _isImmediate ? 'send' : 'schedule_send',
                                  color: Colors.white,
                                  size: 5.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  _isImmediate ? 'โพสต์' : 'กำหนดการ',
                                  style: AppTheme.darkTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
