import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class EngagementChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dailyAnalytics;

  const EngagementChartWidget({
    Key? key,
    required this.dailyAnalytics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
              Text(
                'Engagement Over Time',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              _buildLegend(),
            ],
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: dailyAnalytics.isEmpty ? _buildEmptyChart() : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem('Engagement Rate', Colors.blue),
        SizedBox(width: 3.w),
        _buildLegendItem('Reach', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No data available',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Publish some content to see analytics',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final sortedData = List<Map<String, dynamic>>.from(dailyAnalytics)
      ..sort((a, b) => DateTime.parse(a['analytics_date'])
          .compareTo(DateTime.parse(b['analytics_date'])));

    final spots = <FlSpot>[];
    final reachSpots = <FlSpot>[];

    for (int i = 0; i < sortedData.length; i++) {
      final data = sortedData[i];
      final engagementRate =
          (data['avg_engagement_rate'] as num?)?.toDouble() ?? 0.0;
      final reach = (data['total_reach'] as num?)?.toDouble() ?? 0.0;

      spots.add(FlSpot(i.toDouble(), engagementRate));
      reachSpots
          .add(FlSpot(i.toDouble(), reach / 100)); // Scale reach for visibility
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[200],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: sortedData.length > 7
                  ? (sortedData.length / 5).ceil().toDouble()
                  : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sortedData.length)
                  return const SizedBox.shrink();

                final date =
                    DateTime.parse(sortedData[index]['analytics_date']);
                return Text(
                  DateFormat('MM/dd').format(date),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [Colors.blue.withAlpha(204), Colors.blue],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withAlpha(77),
                  Colors.blue.withAlpha(26),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minX: 0,
        maxX: (sortedData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(spots),
      ),
    );
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxY * 1.2).ceilToDouble(); // Add 20% padding
  }
}