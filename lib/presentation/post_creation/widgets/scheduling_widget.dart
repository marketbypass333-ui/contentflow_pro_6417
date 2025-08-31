import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SchedulingWidget extends StatefulWidget {
  final DateTime? scheduledDateTime;
  final Function(DateTime?) onScheduleChanged;
  final bool isImmediate;
  final Function(bool) onImmediateChanged;

  const SchedulingWidget({
    Key? key,
    required this.scheduledDateTime,
    required this.onScheduleChanged,
    required this.isImmediate,
    required this.onImmediateChanged,
  }) : super(key: key);

  @override
  State<SchedulingWidget> createState() => _SchedulingWidgetState();
}

class _SchedulingWidgetState extends State<SchedulingWidget> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.scheduledDateTime != null) {
      _selectedDate = widget.scheduledDateTime!;
      _selectedTime = TimeOfDay.fromDateTime(widget.scheduledDateTime!);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _updateScheduledDateTime();
    }
  }

  Future<void> _selectTime() async {
    if (Platform.isIOS) {
      await _showIOSTimePicker();
    } else {
      await _showAndroidTimePicker();
    }
  }

  Future<void> _showIOSTimePicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => Container(
        height: 40.h,
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
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ยกเลิก',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    'เลือกเวลา',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _updateScheduledDateTime();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'เสร็จ',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                ),
                onDateTimeChanged: (DateTime dateTime) {
                  setState(() {
                    _selectedTime = TimeOfDay.fromDateTime(dateTime);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAndroidTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
      _updateScheduledDateTime();
    }
  }

  void _updateScheduledDateTime() {
    final DateTime scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    widget.onScheduleChanged(scheduledDateTime);
  }

  String _formatDate(DateTime date) {
    final List<String> months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute น.';
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
            'กำหนดการโพสต์',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Immediate posting option
          GestureDetector(
            onTap: () => widget.onImmediateChanged(true),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: widget.isImmediate
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      widget.isImmediate ? AppTheme.primary : AppTheme.border,
                  width: widget.isImmediate ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isImmediate
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: 2,
                      ),
                      color: widget.isImmediate
                          ? AppTheme.primary
                          : Colors.transparent,
                    ),
                    child: widget.isImmediate
                        ? Center(
                            child: Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'โพสต์ทันที',
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'เผยแพร่โพสต์ทันทีหลังจากกดปุ่มโพสต์',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'flash_on',
                    color: widget.isImmediate
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Scheduled posting option
          GestureDetector(
            onTap: () => widget.onImmediateChanged(false),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: !widget.isImmediate
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      !widget.isImmediate ? AppTheme.primary : AppTheme.border,
                  width: !widget.isImmediate ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 5.w,
                    height: 5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: !widget.isImmediate
                            ? AppTheme.primary
                            : AppTheme.border,
                        width: 2,
                      ),
                      color: !widget.isImmediate
                          ? AppTheme.primary
                          : Colors.transparent,
                    ),
                    child: !widget.isImmediate
                        ? Center(
                            child: Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'กำหนดเวลาโพสต์',
                          style:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'เลือกวันและเวลาที่ต้องการเผยแพร่',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: !widget.isImmediate
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),

          // Date and time selection (only show when scheduled is selected)
          if (!widget.isImmediate) ...[
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
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
                              CustomIconWidget(
                                iconName: 'calendar_today',
                                color: AppTheme.primary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'วันที่',
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _formatDate(_selectedDate),
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
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
                              CustomIconWidget(
                                iconName: 'access_time',
                                color: AppTheme.primary,
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'เวลา',
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _formatTime(_selectedTime),
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.success,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'โพสต์จะถูกเผยแพร่อัตโนมัติในเวลาที่กำหนด',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.success,
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
