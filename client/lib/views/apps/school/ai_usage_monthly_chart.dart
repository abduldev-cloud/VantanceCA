import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Scale information for dynamic Y-axis
class _ScaleInfo {
  final int interval;
  final int maxValue;
  final int labelCount;

  _ScaleInfo({
    required this.interval,
    required this.maxValue,
    required this.labelCount,
  });
}

class AIUsageBarChartWidget extends StatelessWidget {
  final List<int> monthlyData;

  const AIUsageBarChartWidget({
    super.key,
    required this.monthlyData,
  });

  @override
  Widget build(BuildContext context) {
    // Generate dynamic labels based on data length
    final List<String> labels = _generateLabels(monthlyData.length);

    final maxValue = monthlyData.isNotEmpty
        ? monthlyData.reduce((a, b) => a > b ? a : b)
        : 0;

    final scaleInfo = maxValue > 0
        ? _calculateSmartScale(maxValue)
        : _ScaleInfo(interval: 5, maxValue: 20, labelCount: 5);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: scaleInfo.maxValue.toDouble(),
          minY: 0,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 40.w,
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % scaleInfo.interval != 0) return const SizedBox();
                  return Text(
                    _formatNumber(value.toInt()),
                    style: GoogleFonts.inter(
                      color: const Color(0xff142228),
                      fontWeight: FontWeight.w400,
                      fontSize: 8.sp,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      labels[index],
                      style: GoogleFonts.inter(
                        color: const Color(0xff142228),
                        fontWeight: FontWeight.w400,
                        fontSize: 9.sp,
                      ),
                      textAlign: TextAlign.center,
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
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(monthlyData.length, (index) {
            final value = monthlyData[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value.toDouble(),
                  width: 14.w,
                  borderRadius: BorderRadius.circular(8.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF014AAD), Color(0xFFCA6CE6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: scaleInfo.maxValue.toDouble(),
                    color: Colors.grey.withOpacity(0.1),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Generate labels dynamically based on data length
  /// Generate labels dynamically based on data length
  List<String> _generateLabels(int length) {
    final now = DateTime.now();

    if (length == 12) {
      // Last 12 months (including current)
      final months = List.generate(12, (i) {
        final date = DateTime(now.year, now.month - (11 - i));
        return _monthShortName(date.month);
      });
      return months;
    } else if (length == 30) {
      // Last 30 days (only date number)
      final days = List.generate(30, (i) {
        final date = now.subtract(Duration(days: 29 - i));
        return '${date.day}';
      });
      return days;
    } else if (length == 7) {
      // Last 7 days (Mon, Tue, etc.)
      final days = List.generate(7, (i) {
        final date = now.subtract(Duration(days: 6 - i));
        return _weekdayShortName(date.weekday);
      });
      return days;
    } else {
      // Fallback: numeric labels
      return List.generate(length, (i) => '${i + 1}');
    }
  }

  /// Helper for month short names
  String _monthShortName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[(month - 1) % 12];
  }

  /// Helper for weekday short names
  String _weekdayShortName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[(weekday - 1) % 7];
  }

  /// Calculate smart scale intervals
  _ScaleInfo _calculateSmartScale(int maxValue) {
    final preferredIntervals = [
      1,
      2,
      5,
      10,
      25,
      50,
      100,
      250,
      500,
      1000,
      2500,
      5000,
      10000,
      25000,
      50000,
      100000
    ];

    final targetLabels = 5;
    final roughInterval = maxValue / (targetLabels - 1);

    int bestInterval = preferredIntervals.last;
    for (final interval in preferredIntervals) {
      if (interval >= roughInterval) {
        bestInterval = interval;
        break;
      }
    }

    final actualMax = ((maxValue / bestInterval).ceil()) * bestInterval;
    final labelCount = (actualMax / bestInterval).round() + 1;

    return _ScaleInfo(
      interval: bestInterval,
      maxValue: actualMax,
      labelCount: labelCount,
    );
  }

  /// Format numbers (1K, 1.5K, etc.)
  String _formatNumber(int value) {
    if (value >= 1000000) {
      final millions = value / 1000000;
      return millions == millions.round()
          ? '${millions.round()}M'
          : '${millions.toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      final thousands = value / 1000;
      return thousands == thousands.round()
          ? '${thousands.round()}K'
          : '${thousands.toStringAsFixed(1)}K';
    } else {
      return value.toString();
    }
  }
}
