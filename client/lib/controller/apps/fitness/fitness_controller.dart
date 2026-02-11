import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vantanceCA/controller/my_controller.dart';

class ChartSampleData {
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  final dynamic x;
  final num? y;
  final dynamic xValue;
  final num? yValue;
  final num? secondSeriesYValue;
  final num? thirdSeriesYValue;
  final Color? pointColor;
  final num? size;
  final String? text;
  final num? open;
  final num? close;
  final num? low;
  final num? high;
  final num? volume;
}

class FitnessController extends MyController {
  String selectedActivity = "Year";
  String selectedFood = "Year";
  String selectedOutPut = "Year";

  bool showTrailingAndLeadingDates = false;
  bool enablePastDates = true;
  bool enableSwipingSelection = true;
  bool enableViewNavigation = true;
  bool showActionButtons = true;
  bool isWeb = false;
  bool showWeekNumber = false;

  final List<ChartSampleData> activityChart = <ChartSampleData>[
    ChartSampleData(x: 'Mon', y: 0),
    ChartSampleData(x: 'Tue', y: 30),
    ChartSampleData(x: 'Wed', y: 35),
    ChartSampleData(x: 'The', y: 30),
    ChartSampleData(x: 'Fri', y: 45),
    ChartSampleData(x: 'Sat', y: 40),
    ChartSampleData(x: 'Sun', y: 55)
  ];

  List<RadialBarSeries<ChartSampleData, String>> getRadialBarSeries() {
    final List<ChartSampleData> chartData = <ChartSampleData>[
      ChartSampleData(
          x: 'Stretching\n25 Minutes',
          y: 25,
          text: 'Stretching  ',
          xValue: null,
          pointColor: const Color.fromRGBO(0, 201, 230, 1.0)),
      ChartSampleData(
          x: 'Crossfit\n40 Minutes',
          y: 43,
          text: 'Crossfit  ',
          xValue: null,
          pointColor: const Color.fromRGBO(63, 224, 0, 1.0)),
      ChartSampleData(
          x: 'Yoga\n55 Minutes',
          y: 58,
          text: 'Yoga  ',
          xValue: null,
          pointColor: const Color.fromRGBO(226, 1, 26, 1.0)),
    ];
    final List<RadialBarSeries<ChartSampleData, String>> list =
        <RadialBarSeries<ChartSampleData, String>>[
      RadialBarSeries<ChartSampleData, String>(
          animationDuration: 0,
          maximumValue: 100,
          radius: '100%',
          gap: '16%',
          innerRadius: '50%',
          dataSource: chartData,
          cornerStyle: CornerStyle.bothCurve,
          xValueMapper: (ChartSampleData data, _) => data.x as String,
          yValueMapper: (ChartSampleData data, _) => data.y,
          pointColorMapper: (ChartSampleData data, _) => data.pointColor,
          dataLabelMapper: (ChartSampleData data, _) => data.text,
          dataLabelSettings: const DataLabelSettings(isVisible: true))
    ];
    return list;
  }

  void onSelectedActivity(String time) {
    selectedActivity = time;
    update();
  }

  void onSelectedFood(String time) {
    selectedFood = time;
    update();
  }

  void onSelectedOutPut(String time) {
    selectedOutPut = time;
    update();
  }
}
