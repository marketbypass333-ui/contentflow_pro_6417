import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MediaAttachmentWidget extends StatefulWidget {
  final List<XFile> attachedMedia;
  final Function(List<XFile>) onMediaChanged;

  const MediaAttachmentWidget({
    Key? key,
    required this.attachedMedia,
    required this.onMediaChanged,
  }) : super(key: key);

  @override
  State<MediaAttachmentWidget> createState() => _MediaAttachmentWidgetState();
}

class _MediaAttachmentWidgetState extends State<MediaAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _showCameraPreview = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) return;

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Settings error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      List<XFile> updatedMedia = List.from(widget.attachedMedia);
      updatedMedia.add(photo);
      widget.onMediaChanged(updatedMedia);

      setState(() => _showCameraPreview = false);
    } catch (e) {
      debugPrint('Photo capture error: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        List<XFile> updatedMedia = List.from(widget.attachedMedia);
        updatedMedia.addAll(images);
        widget.onMediaChanged(updatedMedia);
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        List<XFile> updatedMedia = List.from(widget.attachedMedia);
        updatedMedia.add(video);
        widget.onMediaChanged(updatedMedia);
      }
    } catch (e) {
      debugPrint('Video picker error: $e');
    }
  }

  void _removeMedia(int index) {
    List<XFile> updatedMedia = List.from(widget.attachedMedia);
    updatedMedia.removeAt(index);
    widget.onMediaChanged(updatedMedia);
  }

  Widget _buildMediaThumbnail(XFile media, int index) {
    return Container(
      width: 20.w,
      height: 20.w,
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(
                    media.path,
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.surface,
                      child: CustomIconWidget(
                        iconName: 'broken_image',
                        color: AppTheme.textSecondary,
                        size: 8.w,
                      ),
                    ),
                  )
                : Image.file(
                    File(media.path),
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.surface,
                      child: CustomIconWidget(
                        iconName: 'broken_image',
                        color: AppTheme.textSecondary,
                        size: 8.w,
                      ),
                    ),
                  ),
          ),
          if (media.path.toLowerCase().contains('.mp4') ||
              media.path.toLowerCase().contains('.mov'))
            Positioned(
              bottom: 1.w,
              left: 1.w,
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: Colors.white,
                  size: 3.w,
                ),
              ),
            ),
          Positioned(
            top: 1.w,
            right: 1.w,
            child: GestureDetector(
              onTap: () => _removeMedia(index),
              child: Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: Colors.white,
                  size: 3.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สื่อแนบ',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),

          // Media attachment buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showCameraPreview = !_showCameraPreview),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'camera_alt',
                          color: AppTheme.primary,
                          size: 6.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'กล้อง',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'photo_library',
                          color: AppTheme.success,
                          size: 6.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'รูปภาพ',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'videocam',
                          color: AppTheme.warning,
                          size: 6.w,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'วิดีโอ',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Camera preview
          if (_showCameraPreview &&
              _isCameraInitialized &&
              _cameraController != null)
            Container(
              margin: EdgeInsets.only(top: 2.h),
              height: 30.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    CameraPreview(_cameraController!),
                    Positioned(
                      bottom: 2.h,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                setState(() => _showCameraPreview = false),
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: CustomIconWidget(
                                iconName: 'close',
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _capturePhoto,
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(35),
                              ),
                              child: CustomIconWidget(
                                iconName: 'camera',
                                color: Colors.white,
                                size: 8.w,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: SizedBox(width: 6.w, height: 6.w),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Media thumbnails
          if (widget.attachedMedia.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              height: 22.w,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.attachedMedia.length,
                itemBuilder: (context, index) =>
                    _buildMediaThumbnail(widget.attachedMedia[index], index),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
