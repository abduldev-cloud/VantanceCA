import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/theme/app_style.dart';

class BarChartSample1 extends StatefulWidget {
  BarChartSample1({super.key});

  List<Color> get availableColors => <Color>[
        AppColors.notificationErrorActionColor,
        AppColors.notificationErrorBGColor,
        AppColors.notificationErrorTextColor,
        AppColors.ratingStarColor,
        AppColors.notificationErrorBGColor,
        AppColors.notificationErrorBGColor,
      ];

  final Color barBackgroundColor = Color(0xffF3F2FF);
  final Color barColor = AppColors.notificationErrorActionColor;
  final Color touchedBarColor = AppColors.notificationErrorBGColor;

  @override
  State<StatefulWidget> createState() => BarChartSample1State();
}

class BarChartSample1State extends State<BarChartSample1> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      mainBarData(),
      duration: animDuration,
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 12,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barsSpace: 1,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? widget.touchedBarColor : barColor,
          width: 15.w,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffCB6CE6),
              Color(0xff004AAD),
            ],
          ),
          borderSide: isTouched
              ? BorderSide(color: widget.touchedBarColor)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(12, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 6.5, isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 9, isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 11.5, isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 6.5, isTouched: i == touchedIndex);
          case 7:
            return makeGroupData(7, 7.5, isTouched: i == touchedIndex);
          case 8:
            return makeGroupData(8, 8.5, isTouched: i == touchedIndex);
          case 9:
            return makeGroupData(9, 9.5, isTouched: i == touchedIndex);
          case 10:
            return makeGroupData(10, 10.5, isTouched: i == touchedIndex);
          case 11:
            return makeGroupData(11, 11.5, isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    return BarChartData(
      groupsSpace: 1,
      alignment: BarChartAlignment.spaceBetween,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 30,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return Text('0',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff142228)));
                case 5:
                  return Text('1,000',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff142228)));
                case 10:
                  return Text('2,000',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff142228)));
                case 15:
                  return Text('3,000',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff142228)));
                case 20:
                  return Text('4,000',
                      style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff142228)));
                default:
                  return const SizedBox.shrink(); // Hide other ticks
              }
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final style = GoogleFonts.inter(
      color: Color(0xff142228),
      fontWeight: FontWeight.w400,
      fontSize: 10.sp,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('JAN', style: style);
        break;
      case 1:
        text = Text('FEB', style: style);
        break;
      case 2:
        text = Text('MAR', style: style);
        break;

      case 3:
        text = Text('APR', style: style);
        break;
      case 4:
        text = Text('MAY', style: style);
        break;
      case 5:
        text = Text('JUN', style: style);
        break;
      case 6:
        text = Text('JUL', style: style);
        break;
      case 7:
        text = Text('AUG', style: style);
        break;
      case 8:
        text = Text('SEP', style: style);
        break;
      case 9:
        text = Text('OCT', style: style);
        break;
      case 10:
        text = Text('NOV', style: style);
        break;
      default:
        text = Text('DEC', style: style);
        break;
    }
    return SideTitleWidget(
      meta: meta,
      space: 12.sp,
      child: text,
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      animDuration + const Duration(milliseconds: 50),
    );
    if (isPlaying) {
      await refreshState();
    }
  }
}
