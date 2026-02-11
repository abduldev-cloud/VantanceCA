import 'package:vantanceCA/controller/apps/admin/admin_analytic_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/views/apps/school/ai_usage_monthly_chart.dart';

import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_popupmenu.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  AdminAnalyticsPageState createState() => AdminAnalyticsPageState();
}

class AdminAnalyticsPageState extends State<AdminAnalyticsPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late AdminAnalyticController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminAnalyticController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 2,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommanTitlebar(
                        contentTheme: contentTheme,
                        title: "Analytics",
                        subTitle:
                            "Track writing trends, performance, and AI use.",
                        buttonTitle: "")
                    .paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
                // Error display
                Obx(() => controller.hasError.value
                    ? Container(
                        margin: EdgeInsets.only(top: 10.h, right: MySpacing.fullWidth(context) * 0.04),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                controller.errorMessage.value,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink()),
                15.verticalSpace,
                MyCard.circular(
                  borderRadiusAll: 25.r,
                  margin: EdgeInsets.only(
                      right: MySpacing.fullWidth(context) * 0.04),
                  width: MySpacing.fullWidth(context),
                  bordered: true,
                  padding: EdgeInsets.only(
                      left: 25.w, top: 25.h, bottom: 30.h, right: 30.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MySpacing.fullWidth(context) * 0.27,
                        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // First Row: Title
    MyText.bodySmall(
      "Key Performance Indicators",
      style: GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: contentTheme.k142228,
      ),
    ),

    SizedBox(height: 8), // spacing between title and first dropdown

   // Second Row: First Dropdown (Time Range) - right aligned
    Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Obx(() => SizedBox(
              width: 150, // adjust width as needed
              child: dropdownCard(
                selectedItem: controller.selectedTimeRange.value,
                title: "Time Range :", 
                item: controller.timeRangeOptions,
                onChanged: (value) => value != null
                    ? controller.updateTimeRangeFilter(value)
                    : null,
              ),
            )),
      ],
    ),

                          30.verticalSpace,
                             Row(
      children: [
        Obx(() => trendingChartCard(
              title: "Writing Fingerprint",
              subTitle: "Average Deviation",
              count: controller.hasAiUsageData
                  ? "${controller.writingFingerprintAverageDeviation.toStringAsFixed(1)}%"
                  : controller.isLoading.value
                      ? "Loading..."
                      : controller.hasError.value
                          ? "Error"
                          : "No Data",
              periodLabel: controller.selectedTimeRange.value == "Term 1"
                  ? "term 1"
                  : "last ${controller.selectedTimeRange.value}",
              trend: controller.writingFingerprintAverageDeviationTrend,
            )),
        28.horizontalSpace,
        Obx(() => trendingChartCard(
              title: "Writing Fingerprint",
              subTitle: "Total",
              count: controller.hasAiUsageData
                  ? controller.writingFingerprintTotal.toString()
                  : controller.isLoading.value
                      ? "Loading..."
                      : controller.hasError.value
                          ? "Error"
                          : "No Data",
              periodLabel: controller.selectedTimeRange.value == "Term 1"
                  ? "term 1"
                  : "last ${controller.selectedTimeRange.value}",
          trend: controller.writingFingerprintTotalTrend,
            )),
      ],
    ),
                            30.verticalSpace,
                            Row(
                              children: [
                                 Obx(() => trendingChartCard(
              title: "Writing Fingerprint",
              subTitle: "Average Deviation",
              count: controller.hasAiUsageData
                  ? "${controller.writingFingerprintAverageDeviation.toStringAsFixed(1)}%"
                  : controller.isLoading.value
                      ? "Loading..."
                      : controller.hasError.value
                          ? "Error"
                          : "No Data",
              periodLabel: controller.selectedTimeRange.value == "Term 1"
                  ? "term 1"
                  : "last ${controller.selectedTimeRange.value}",
              trend: controller.writingFingerprintAverageDeviationTrend,
            )),
                                MySpacing.width(30),
                              Obx(() => trendingChartCard(
              title: "Writing Fingerprint",
              subTitle: "Total",
              count: controller.hasAiUsageData
                  ? controller.writingFingerprintTotal.toString()
                  : controller.isLoading.value
                      ? "Loading..."
                      : controller.hasError.value
                          ? "Error"
                          : "No Data",
              periodLabel: controller.selectedTimeRange.value == "Term 1"
                  ? "term 1"
                  : "last ${controller.selectedTimeRange.value}",
          trend: controller.writingFingerprintTotalTrend,
            )),
                              ],
                            ),
                            30.verticalSpace,
                            Row(
                              children: [
                                 Obx(() => trendingChartCard(
              title: "AI Prompt Used",
              subTitle: "Average",
              count: controller.hasAiUsageData
                  ? controller.aiPromptUsageAverage.toStringAsFixed(1)
                  : controller.isLoading.value
                      ? "Loading..."
                      : controller.hasError.value
                          ? "Error"
                          : "No Data",
              periodLabel: controller.selectedTimeRange.value == "Term 1"
                  ? "term 1"
                  : "last ${controller.selectedTimeRange.value}",
          trend: controller.aiPromptUsageAverageTrend,
            )),
                                MySpacing.width(30),
                               Obx(() => trendingChartCard(
              title: "AI Prompt Used",
              subTitle: "Total",
              count: controller.hasAiUsageData
                  ? controller.formattedAiPromptUsageTotal
                  : controller.isLoading.value
                      ? "Loading..."
                      : controller.hasError.value
                          ? "Error"
                          : "No Data",
              periodLabel: controller.selectedTimeRange.value == "Term 1"
                  ? "term 1"
                  : "last ${controller.selectedTimeRange.value}",
trend: controller.aiPromptUsageTotalTrend,
            )),
                                    
                              ],
                            )
                          ],
                        ),
                      ),
                      1.horizontalSpace,
              
 Expanded(
  child: Column(
    children: [
      // ---------- First Row: Teacher & Class ----------
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Teacher Dropdown
          SizedBox(
            width: 250,
 child: Obx(() {
        final instituteItems = controller.schoolOptions.isNotEmpty
            ? controller.schoolOptions
            : ["All"];
        return dropdownCard(
          selectedItem: controller.selectedInstitute.value.isNotEmpty
              ? controller.selectedInstitute.value
              : "All",
          title: "Institute:\t",
          item: instituteItems,
          onChanged: (String? newValue) {
            if (newValue != null) controller.onInstituteChanged(newValue);
          },
        );
      }),
    ),
          SizedBox(width: 30),
          // Class Dropdown
          SizedBox(
            width: 300,
            child: Obx(() {
        final classItems = controller.classList
            .map((cls) => cls.className ?? "Unknown")
            .toList();
        String displayClass = controller.selectedClass.value.isNotEmpty
            ? controller.selectedClass.value
            : "All";
       
        return dropdownCard(
          selectedItem: displayClass,
          title: "Class:\t",
          item: classItems.isNotEmpty ? classItems : ["All"],
          onChanged: (String? newValue) {
            if (newValue != null) controller.onClassChanged(newValue);
          },
        );
      }),
    ),
  ],
),

      SizedBox(height: 10),

      // ---------- Second Row: Term, Grade, Period, Refresh ----------
     Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Term Dropdown
    SizedBox(
      width: 250,
    child: dropdownCard(
        title: "Teacher :\t",
        selectedItem: controller.selectedTeacher.value.isNotEmpty
            ? controller.selectedTeacher.value
            : "All",
        item: controller.teacherList.isNotEmpty
            ? controller.teacherList
            : ["All"],
        onChanged: (value) {
          if (value != null) controller.onTeacherChanged(value);
        },
      ),
    ),
    SizedBox(width: 30),
    // Grade Dropdown
    SizedBox(
      width: 150,
          child: Obx(() {
        final gradeItems = controller.gradeList.isNotEmpty
            ? controller.gradeList
            : ["All"];
        return dropdownCard(
          selectedItem: controller.selectedGrade.value.isNotEmpty
              ? controller.selectedGrade.value
              : "All",
          title: "Grade: \t",
          item: gradeItems,
          onChanged: (String? newValue) {
            if (newValue != null) controller.onGradeChanged(newValue);
          },
        );
      }),
    ),
    // Push remaining widgets to the end
    Spacer(),
    // Period Bucket Dropdown
    SizedBox(
      width: 120,
      child: Obx(() => DropdownButton<String>(
        value: controller.selectedPeriodBucket.value,
        dropdownColor: contentTheme.kFEFDFF,
        items: <String>['year', 'month', 'week'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value[0].toUpperCase() + value.substring(1),
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: contentTheme.k142228,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.selectedPeriodBucket.value = newValue;
            controller.fetchAiUsageOverview();
          }
        },
        underline: SizedBox(),
        isExpanded: true,
      )),
    ),
    SizedBox(width: 16),
    // Refresh Icon
    SizedBox(
      width: 48,
      child: IconButton(
        onPressed: () async {
          controller.selectedClass.value = "All";
          controller.selectedGrade.value = "All";
           controller.selectedInstitute.value = "All";
          controller.selectedTeacher.value = "All";
          controller.selectedClassId.value = "";
          controller.selectedGradeId.value = "";
          controller.selectedPeriodBucket.value = "year";
          await controller.fetchadminClassFilters();
          await controller.fetchAiUsageOverview();
        },
        icon: Image.asset(
          Images.filterupdate,
          height: 20.sp,
          width: 20.sp,
          color: Colors.grey[400],
        ),
        tooltip: "Reset Dropdowns",
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
      ),
    ),
  ],
),


             40.verticalSpace,
                          MyCard.circular(
                            height: MySpacing.fullHeight(context) * 0.30,
                            color: contentTheme.kFEFDFF,
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 15.h),
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                                width: 1.w, color: contentTheme.borderColor),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total Submissions",
                                      style: GoogleFonts.inter(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: contentTheme.k142228,
                                      ),
                                    ),
                                  
                                  ],
                                ),
                                Divider(),
                                MySpacing.height(15),
                                Expanded(
                                  child: Obx(() => AIUsageBarChartWidget(
                                    monthlyData: controller.aiUsageOverview.value?.monthlyWritingDashboard?.monthlyDataList ?? [0,0,0,0,0,0,0,0,0,0,0,0],
                                  )),
                                ),
                              ],
                            ),
                          ),
                          MySpacing.height(20),
                          MyCard.circular(
                            height: MySpacing.fullHeight(context) * 0.30,
                            color: contentTheme.kFEFDFF,
                            padding: EdgeInsets.symmetric(
                                horizontal: 25.w, vertical: 15.h),
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                                width: 1.w, color: contentTheme.borderColor),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Average Writing Fingerprints Alerts",
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: contentTheme.k142228,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(),
                                MySpacing.height(15),
                                Expanded(
                                  child: Obx(() => AIUsageBarChartWidget(
                                    monthlyData: controller.aiUsageOverview.value?.monthlyWritingDashboard?.monthlyDataList ?? [0,0,0,0,0,0,0,0,0,0,0,0],
                                  )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ).paddingOnly(top: 5))
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget dropdownCard(
      {required String title,
      required List<String> item,
      required String selectedItem,
      void Function(String?)? onChanged}) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: contentTheme.k142228,
          ),
        ),
        Expanded(
            child: CommanPopupmenu(
                contentTheme: contentTheme,
                title: selectedItem,
                list: item,
                onChanged: onChanged))
      ],
    );
  }

  Widget customDateRangeCard() {
    return Row(
      children: [
        Text(
          "Time Range:\t",
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: contentTheme.k142228,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: contentTheme.borderColor),
              color: contentTheme.background,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDateRangePicker(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16.sp,
                          color: contentTheme.k142228,
                        ),
                        8.horizontalSpace,
                        Expanded(
                          child: Obx(() => Text(
                            controller.customDateRangeString,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: contentTheme.k142228,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 20.sp,
                  color: contentTheme.k142228,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: controller.customStartDate.value != null && controller.customEndDate.value != null
          ? DateTimeRange(
              start: controller.customStartDate.value!,
              end: controller.customEndDate.value!,
            )
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: contentTheme.darkPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: contentTheme.k142228,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.updateCustomDateRange(picked.start, picked.end);
    }
  }


Widget getArrowWidget(String? trend) {
  final normalized = (trend ?? "stable").trim().toLowerCase();
  switch (normalized) {
    case "up":
      return Image.asset(Images.upBarArrow, width: 20.w, height: 40.h);
    case "down":
      return Image.asset(Images.downBarArrow, width: 20.w, height: 40.h);
    case "stable":
    default:
      return SizedBox.shrink();  // This shows nothing
  }
}

  Widget trendingChartCard({
  required String title,
  required String subTitle,
  required String count,
  required String periodLabel,  // added parameter for dynamic period label
  required String trend,
}) =>
    Container(
      alignment: Alignment.center,
      width: MySpacing.fullWidth(context) * 0.12,
      height: MySpacing.fullHeight(context) * 0.18,
      padding: EdgeInsets.symmetric(horizontal: MySpacing.fullWidth(context) * 0.008),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: contentTheme.background,
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xffEEECFF),
                Color(0xffEEECFF),
                Color(0xffDBEBFF),
              ])),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyText.bodySmall(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: contentTheme.k142228,
            ),
          ),
          MyText.bodySmall(
            subTitle,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: contentTheme.k142228,
            ),
          ),
          5.verticalSpace,
          Row(
            children: [
              MyText.bodySmall(
                count,
                style: GoogleFonts.inter(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                  color: contentTheme.darkPurple,
                ),
              ),
              10.horizontalSpace,
       getArrowWidget(trend),

            ],
          ),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "in the\t",
                style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: contentTheme.k142228)),
            TextSpan(
                text: periodLabel,
                style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: contentTheme.darkPurple))
          ])),
        ],
      ),
    );
}
