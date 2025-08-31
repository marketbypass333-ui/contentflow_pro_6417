import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class AudienceInsightsWidget extends StatefulWidget {
  final Map<String, dynamic> insights;

  const AudienceInsightsWidget({
    Key? key,
    required this.insights,
  }) : super(key: key);

  @override
  State<AudienceInsightsWidget> createState() => _AudienceInsightsWidgetState();
}

class _AudienceInsightsWidgetState extends State<AudienceInsightsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          Text(
            'Audience Insights',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 3.h),
          _buildTabBar(),
          SizedBox(height: 3.h),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Age Groups'),
          Tab(text: 'Gender'),
          Tab(text: 'Location'),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 300,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildAgeInsights(),
          _buildGenderInsights(),
          _buildLocationInsights(),
        ],
      ),
    );
  }

  Widget _buildAgeInsights() {
    final ageData = widget.insights['age'] as List<Map<String, dynamic>>? ?? [];

    if (ageData.isEmpty) {
      return _buildEmptyState('No age data available');
    }

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: ageData.map((data) {
                final percentage =
                    (data['percentage'] as num?)?.toDouble() ?? 0.0;
                return PieChartSectionData(
                  color: _getAgeGroupColor(data['age_group']),
                  value: percentage,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Expanded(
          flex: 1,
          child: _buildLegend(ageData, 'age_group', _getAgeGroupColor),
        ),
      ],
    );
  }

  Widget _buildGenderInsights() {
    final genderData =
        widget.insights['gender'] as List<Map<String, dynamic>>? ?? [];

    if (genderData.isEmpty) {
      return _buildEmptyState('No gender data available');
    }

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: genderData.map((data) {
                final percentage =
                    (data['percentage'] as num?)?.toDouble() ?? 0.0;
                return PieChartSectionData(
                  color: _getGenderColor(data['gender']),
                  value: percentage,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 60,
                  titleStyle: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Expanded(
          flex: 1,
          child: _buildLegend(genderData, 'gender', _getGenderColor),
        ),
      ],
    );
  }

  Widget _buildLocationInsights() {
    final locationData =
        widget.insights['location'] as List<Map<String, dynamic>>? ?? [];

    if (locationData.isEmpty) {
      return _buildEmptyState('No location data available');
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: locationData.length,
            itemBuilder: (context, index) {
              final data = locationData[index];
              final percentage =
                  (data['percentage'] as num?)?.toDouble() ?? 0.0;
              final location = data['location'] as String? ?? 'Unknown';

              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: _getLocationColor(index),
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        location,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      width: 20.w,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _getLocationColor(index),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(List<Map<String, dynamic>> data, String key,
      Color Function(String) getColor) {
    return Wrap(
      spacing: 3.w,
      runSpacing: 1.h,
      children: data.map((item) {
        final value = item[key] as String? ?? '';
        final percentage = (item['percentage'] as num?)?.toDouble() ?? 0.0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: getColor(value),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insights_outlined,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAgeGroupColor(String ageGroup) {
    switch (ageGroup) {
      case '18-24':
        return Colors.blue;
      case '25-34':
        return Colors.green;
      case '35-44':
        return Colors.orange;
      case '45-54':
        return Colors.purple;
      case '55+':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getGenderColor(String gender) {
    switch (gender) {
      case 'female':
        return Colors.pink;
      case 'male':
        return Colors.blue;
      case 'other':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getLocationColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }
}