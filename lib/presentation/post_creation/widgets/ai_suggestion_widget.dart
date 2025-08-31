import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AiSuggestionWidget extends StatefulWidget {
  final Function(String) onSuggestionSelected;
  final List<String> selectedPlatforms;

  const AiSuggestionWidget({
    Key? key,
    required this.onSuggestionSelected,
    required this.selectedPlatforms,
  }) : super(key: key);

  @override
  State<AiSuggestionWidget> createState() => _AiSuggestionWidgetState();
}

class _AiSuggestionWidgetState extends State<AiSuggestionWidget> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestions = [];

  final List<Map<String, dynamic>> mockSuggestions = [
    {
      'title': 'เทรนด์วันนี้',
      'content':
          'สวัสดีวันจันทร์! เริ่มต้นสัปดาห์ใหม่ด้วยพลังงานบวก ✨ วันนี้เป็นโอกาสใหม่ในการทำสิ่งดีๆ #MondayMotivation #PositiveVibes',
      'hashtags': ['#MondayMotivation', '#PositiveVibes', '#NewWeek'],
      'category': 'แรงบันดาลใจ',
      'engagement': 'สูง'
    },
    {
      'title': 'เนื้อหาธุรกิจ',
      'content':
          'การสร้างแบรนด์ที่แข็งแกร่งเริ่มต้นจากการเข้าใจลูกค้าอย่างลึกซึ้ง 🎯 ใช้เวลาฟังความต้องการของพวกเขา และสร้างสิ่งที่ตอบโจทย์จริงๆ #Business #Branding',
      'hashtags': ['#Business', '#Branding', '#CustomerFirst'],
      'category': 'ธุรกิจ',
      'engagement': 'กลาง'
    },
    {
      'title': 'ไลฟ์สไตล์',
      'content':
          'เคล็ดลับการใช้ชีวิตให้สมดุล: 🌱 ออกกำลังกายสม่ำเสมอ 📚 อ่านหนังสือ 🧘‍♀️ ทำสมาธิ 👥 ใช้เวลากับคนที่รัก #LifeBalance #Wellness',
      'hashtags': ['#LifeBalance', '#Wellness', '#HealthyLiving'],
      'category': 'ไลฟ์สไตล์',
      'engagement': 'สูง'
    },
    {
      'title': 'เทคโนโลยี',
      'content':
          'AI กำลังเปลี่ยนแปลงโลกของเรา 🤖 จากการช่วยเหลือในงานประจำวัน ไปจนถึงการสร้างสรรค์ศิลปะ เราอยู่ในยุคที่น่าตื่นเต้น! #AI #Technology #Future',
      'hashtags': ['#AI', '#Technology', '#Future', '#Innovation'],
      'category': 'เทคโนโลยี',
      'engagement': 'กลาง'
    },
    {
      'title': 'อาหารและเครื่องดื่ม',
      'content':
          'สูตรกาแฟเย็นแสนอร่อย ☕️ เอสเปรสโซ่ 2 ช็อต + นมสด + น้ำแข็ง + น้ำตาลเล็กน้อย = ความสุขในแก้วเดียว! #Coffee #Recipe #Homemade',
      'hashtags': ['#Coffee', '#Recipe', '#Homemade', '#Delicious'],
      'category': 'อาหาร',
      'engagement': 'สูง'
    },
  ];

  Future<void> _generateSuggestions() async {
    setState(() => _isLoading = true);

    // Simulate AI processing
    await Future.delayed(Duration(seconds: 2));

    // Filter suggestions based on selected platforms
    List<Map<String, dynamic>> filteredSuggestions = List.from(mockSuggestions);

    if (widget.selectedPlatforms.contains('Instagram')) {
      filteredSuggestions = filteredSuggestions.map((suggestion) {
        Map<String, dynamic> modified = Map.from(suggestion);
        modified['content'] = '${modified['content']} 📸';
        return modified;
      }).toList();
    }

    if (widget.selectedPlatforms.contains('Twitter')) {
      filteredSuggestions = filteredSuggestions.map((suggestion) {
        Map<String, dynamic> modified = Map.from(suggestion);
        if (modified['content'].length > 250) {
          modified['content'] =
              '${modified['content'].substring(0, 240)}... 🧵';
        }
        return modified;
      }).toList();
    }

    setState(() {
      _suggestions = filteredSuggestions.take(3).toList();
      _isLoading = false;
    });
  }

  void _showSuggestionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'คำแนะนำจาก AI',
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
              child: _isLoading
                  ? _buildLoadingState()
                  : _suggestions.isEmpty
                      ? _buildEmptyState()
                      : _buildSuggestionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'AI กำลังสร้างคำแนะนำ...',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'กรุณารอสักครู่',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'lightbulb_outline',
            color: AppTheme.textSecondary,
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'ไม่พบคำแนะนำ',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'ลองเลือกแพลตฟอร์มก่อนเพื่อรับคำแนะนำที่เหมาะสม',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      suggestion['category'],
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: suggestion['engagement'] == 'สูง'
                          ? AppTheme.success.withValues(alpha: 0.2)
                          : AppTheme.warning.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'การมีส่วนร่วม: ${suggestion['engagement']}',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: suggestion['engagement'] == 'สูง'
                            ? AppTheme.success
                            : AppTheme.warning,
                        fontSize: 9.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                suggestion['title'],
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                suggestion['content'],
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 1.w,
                runSpacing: 1.h,
                children:
                    (suggestion['hashtags'] as List<String>).map((hashtag) {
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      hashtag,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primary,
                        fontSize: 9.sp,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSuggestionSelected(suggestion['content']);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'ใช้คำแนะนำนี้',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: GestureDetector(
        onTap: () {
          _generateSuggestions();
          _showSuggestionBottomSheet();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.accentLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: Colors.white,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'รับคำแนะนำจาก AI',
                style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'arrow_forward',
                color: Colors.white,
                size: 5.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
