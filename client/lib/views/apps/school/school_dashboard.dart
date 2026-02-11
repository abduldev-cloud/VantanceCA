import 'package:vantanceCA/controller/apps/school/school_dashboard_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/views/apps/school/student_chart.dart';
import 'package:vantanceCA/views/apps/school/ai_usage_monthly_chart.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_popupmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SchoolDashboardPage extends StatefulWidget {
  const SchoolDashboardPage({super.key});

  @override
  SchoolDashboardPageState createState() => SchoolDashboardPageState();
}

class SchoolDashboardPageState extends State<SchoolDashboardPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late SchoolDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SchoolDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "Welcome Back,\t",
                          style: GoogleFonts.inter(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w600,
                              color: contentTheme.k142228)),
                      TextSpan(
                          text: LocalStorage.getUserName() ?? "User",
                          style: GoogleFonts.inter(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w600,
                              color: contentTheme.darkPurple))
                    ])),
                  ),
                  // Obx(() => IconButton(
                  //       onPressed: controller.isLoading.value
                  //           ? null
                  //           : () => controller.refreshAnalytics(),
                  //       icon: controller.isLoading.value
                  //           ? SizedBox(
                  //               width: 20.w,
                  //               height: 20.h,
                  //               child:
                  //                   CircularProgressIndicator(strokeWidth: 2),
                  //             )
                  //           : Icon(Icons.refresh, size: 24.r),
                  //       tooltip: "Refresh Analytics",
                  //     )),
                ],
              ),
              MyText.bodyMedium(
                "Here’s what’s happening with your students.",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: contentTheme.k142228,
                ),
              ),
              // Error display
              Obx(() => controller.hasError.value
                  ? Container(
                      margin: EdgeInsets.only(top: 10.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade600, size: 20.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: MyText.bodySmall(
                              controller.errorMessage.value,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.refreshAnalytics(),
                            child: Text("Retry",
                                style: TextStyle(color: Colors.red.shade600)),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink()),
              18.verticalSpace,
              SizedBox(
                  height: 590, // Match sidebar height
                  child: Scrollbar(
                    // Optional for web/desktop visual feedback
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          studentCountCard(),
                          25.verticalSpace,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: MyCard.circular(
                                    color: contentTheme.kFEFDFF,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25.w, vertical: 20.h),
                                    borderRadius: BorderRadius.circular(25.r),
                                    border: Border.all(
                                        width: 1,
                                        color: contentTheme.borderColor),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            MyText.bodySmall(
                                              "AI Usage Overview",
                                              style: GoogleFonts.inter(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w600,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                            Spacer(),
                                            // Refresh button for AI usage data
                                            Obx(() => IconButton(
                                                  onPressed: controller
                                                          .isLoading.value
                                                      ? null
                                                      : () => controller
                                                          .refreshAiUsageData(),
                                                  icon:
                                                      controller.isLoading.value
                                                          ? SizedBox(
                                                              width: 16.w,
                                                              height: 16.h,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2),
                                                            )
                                                          : Icon(Icons.refresh,
                                                              size: 20.sp),
                                                  tooltip:
                                                      "Refresh AI Usage Data",
                                                )),
                                          ],
                                        ),
                                        // Error display for AI usage data
                                        Obx(() => controller.hasError.value
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    top: 8.h, bottom: 8.h),
                                                padding: EdgeInsets.all(8.w),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6.r),
                                                  border: Border.all(
                                                      color:
                                                          Colors.red.shade200),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.error_outline,
                                                        color:
                                                            Colors.red.shade600,
                                                        size: 16.sp),
                                                    SizedBox(width: 6.w),
                                                    Expanded(
                                                      child: Text(
                                                        "Failed to fetch AI usage data for email: ${controller.errorMessage.value}",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 10.sp,
                                                          color: Colors
                                                              .red.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox.shrink()),
                                        Row(
                                          children: [
                                            Text.rich(TextSpan(children: [
                                              TextSpan(
                                                  text: "Time Range:\t",
                                                  style: GoogleFonts.inter(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: contentTheme
                                                          .k142228)),
                                            ])),
                                            Obx(() => CommanPopupmenu(
                                                contentTheme: contentTheme,
                                                title: controller
                                                    .selectedTimeRange.value,
                                                list: [
                                                  "7d",
                                                  "14d",
                                                  "30d",
                                                  "Term 1"
                                                ],
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    controller.updateTimeRange(
                                                        newValue);
                                                  }
                                                }))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  Obx(() => trendingChartCard(
                                                        title:
                                                            "Writing Fingerprint",
                                                        subTitle:
                                                            "Average Deviation",
                                                        count: controller
                                                                .isLoading.value
                                                            ? "..."
                                                            : "${controller.writingFingerprintAverageDeviation.toStringAsFixed(1)}%",
                                                        periodLabel: controller
                                                                    .selectedTimeRange
                                                                    .value ==
                                                                "Term 1"
                                                            ? "Term 1"
                                                            : "last ${controller.selectedTimeRange.value}",
                                                        trend: controller
                                                            .writingFingerprintAverageDeviationTrendValue,
                                                      )),
                                            ),
                                            SizedBox(
                                              width:
                                                  MySpacing.fullWidth(context) *
                                                      0.01,
                                            ),
                                            Expanded(
                                              child:
                                                  Obx(() => trendingChartCard(
                                                        title:
                                                            "Writing Fingerprint",
                                                        subTitle: "Total",
                                                        count: controller
                                                                .isLoading.value
                                                            ? "..."
                                                            : "${controller.writingFingerprintTotal}",
                                                        periodLabel: controller
                                                                    .selectedTimeRange
                                                                    .value ==
                                                                "Term 1"
                                                            ? "Term 1"
                                                            : "last ${controller.selectedTimeRange.value}",
                                                        trend: controller
                                                            .writingFingerprintTotalTrendValue,
                                                      )),
                                            ),
                                            SizedBox(
                                              width:
                                                  MySpacing.fullWidth(context) *
                                                      0.01,
                                            ),
                                            Expanded(
                                              child:
                                                  Obx(() => trendingChartCard(
                                                        title: "AI Prompt Used",
                                                        subTitle: "Average",
                                                        count: controller
                                                                .isLoading.value
                                                            ? "..."
                                                            : controller
                                                                .aiPromptUsageAverage
                                                                .toStringAsFixed(
                                                                    1),
                                                        periodLabel: controller
                                                                    .selectedTimeRange
                                                                    .value ==
                                                                "Term 1"
                                                            ? "Term 1"
                                                            : "last ${controller.selectedTimeRange.value}",
                                                        trend: controller
                                                            .aiPromptUsageAverageTrendValue,
                                                      )),
                                            ),
                                            SizedBox(
                                              width:
                                                  MySpacing.fullWidth(context) *
                                                      0.01,
                                            ),
                                            Expanded(
                                              child:
                                                  Obx(() => trendingChartCard(
                                                        title: "AI Prompt Used",
                                                        subTitle: "Total",
                                                        count: controller
                                                                .isLoading.value
                                                            ? "..."
                                                            : controller
                                                                .formattedAiPromptUsageTotal,
                                                        periodLabel: controller
                                                                    .selectedTimeRange
                                                                    .value ==
                                                                "Term 1"
                                                            ? "Term 1"
                                                            : "last ${controller.selectedTimeRange.value}",
                                                        trend: controller
                                                            .aiPromptUsageTotalTrendValue,
                                                      )),
                                            ),
                                            SizedBox(
                                              width:
                                                  MySpacing.fullWidth(context) *
                                                      0.01,
                                            ),
                                          ],
                                        ).paddingOnly(top: 8, bottom: 14),
                                        MyCard.circular(
                                          color: contentTheme.kFEFDFF,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25.w, vertical: 15.h),
                                          borderRadius:
                                              BorderRadius.circular(22.r),
                                          border: Border.all(
                                              width: 1,
                                              color: contentTheme.borderColor),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Average Writing Fingerprints Alerts",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          contentTheme.k142228,
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  SizedBox(
                                                      width:
                                                          12), // Increased space before Class dropdown

                                                  // Class Dropdown (with improved truncation)
                                                  Expanded(
                                                    flex:
                                                        3, // Give more flex to the class dropdown for longer names
                                                    child: Obx(() {
                                                      final classItems =
                                                          controller.classList
                                                              .map((cls) =>
                                                                  cls.className ??
                                                                  "Unknown")
                                                              .toList();

                                                      String displayClass =
                                                          controller
                                                                  .selectedClass
                                                                  .value
                                                                  .isNotEmpty
                                                              ? controller
                                                                  .selectedClass
                                                                  .value
                                                              : "All";
                                                      if (displayClass.length >
                                                          25) {
                                                        // Truncate if too long
                                                        displayClass =
                                                            "${displayClass.substring(0, 20)}…";
                                                      }

                                                      return dropdownCard(
                                                        selectedItem:
                                                            displayClass,
                                                        title: "Class:\t",
                                                        item: classItems
                                                                .isNotEmpty
                                                            ? classItems
                                                            : ["All"],
                                                        onChanged:
                                                            (String? newValue) {
                                                          if (newValue !=
                                                              null) {
                                                            controller
                                                                .onClassChanged(
                                                                    newValue);
                                                          }
                                                        },
                                                      );
                                                    }),
                                                  ),

                                                  SizedBox(
                                                      width:
                                                          12), // Spacing after Class dropdown

                                                  // Period Dropdown
                                                  Obx(() {
                                                    // Mapping between internal value and display text
                                                    final displayMap = {
                                                      'year': 'Yearly',
                                                      'month': 'Monthly',
                                                      'week': 'Weekly',
                                                    };

                                                    return DropdownButton<
                                                        String>(
                                                      // internal value (bound to controller)
                                                      value: controller
                                                          .selectedPeriodBucket
                                                          .value,
                                                      dropdownColor:
                                                          contentTheme.kFEFDFF,
                                                      // map through items
                                                      items: displayMap.entries
                                                          .map((entry) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: entry
                                                              .key, // internal value
                                                          child: Text(
                                                            entry
                                                                .value, // user-visible text
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 14.sp,
                                                              color:
                                                                  contentTheme
                                                                      .k142228,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (String? newValue) {
                                                        if (newValue != null) {
                                                          controller
                                                              .selectedPeriodBucket
                                                              .value = newValue;
                                                          controller
                                                              .fetchAiUsageOverview();
                                                        }
                                                      },
                                                      underline:
                                                          const SizedBox(),
                                                      // ✅ show display text for selected item
                                                      selectedItemBuilder:
                                                          (BuildContext
                                                              context) {
                                                        return displayMap
                                                            .entries
                                                            .map((entry) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                              entry.value,
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 14.sp,
                                                                color:
                                                                    contentTheme
                                                                        .k142228,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          );
                                                        }).toList();
                                                      },
                                                    );
                                                  }),
                                                ],
                                              ),
                                              Divider(),
                                              12.verticalSpace,
                                              SizedBox(
                                                  height: MySpacing.fullHeight(
                                                          context) *
                                                      0.18,
                                                  child: Obx(() =>
                                                      AIUsageBarChartWidget(
                                                        monthlyData: controller
                                                                .aiUsageOverview
                                                                .value
                                                                ?.monthlyWritingDashboard
                                                                ?.monthlyDataList ??
                                                            [
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0,
                                                              0
                                                            ],
                                                      ))),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )),
                              15.horizontalSpace,
                              Expanded(
                                  child: MyCard.circular(
                                margin: EdgeInsets.only(left: 15.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 45.w, vertical: 25.h),
                                borderRadius: BorderRadius.circular(25.r),
                                height: MySpacing.fullHeight(context) * 0.52,
                                border: Border.all(
                                    width: 1, color: contentTheme.borderColor),
                                child: Column(
                                  children: [
                                    MyText.bodySmall(
                                      "Latest Notifications",
                                      style: GoogleFonts.inter(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                        color: contentTheme.k142228,
                                      ),
                                    ),
                                    20.verticalSpace,
                                    Expanded(
                                      child: Obx(() {
                                        if (controller
                                            .isLoadingNotifications.value) {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      contentTheme.darkPurple),
                                            ),
                                          );
                                        }

                                        if (controller.notifications.isEmpty) {
                                          return Center(
                                            child: MyText.bodySmall(
                                              "No notifications available",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.inter(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w400,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                          );
                                        }

                                        return ListView.separated(
                                          shrinkWrap: true,
                                          itemBuilder: (context, index) {
                                            final notification =
                                                controller.notifications[index];
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                MyText.bodySmall(
                                                  notification.title,
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: contentTheme.k142228,
                                                  ),
                                                ),
                                                if (notification
                                                    .message.isNotEmpty) ...[
                                                  5.verticalSpace,
                                                  MyText.bodySmall(
                                                    notification.message,
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: contentTheme
                                                          .k142228
                                                          .withOpacity(0.7),
                                                    ),
                                                  ),
                                                ],
                                                5.verticalSpace,
                                                MyText.bodySmall(
                                                  _formatTimestamp(
                                                      notification.timestamp),
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: contentTheme
                                                        .darkPurple
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              Divider(
                                            height: 20.h,
                                            color: contentTheme.kC6C3C3,
                                          ),
                                          itemCount: controller
                                                      .notifications.length >
                                                  5
                                              ? 5
                                              : controller.notifications.length,
                                        );
                                      }),
                                    )
                                  ],
                                ),
                              ))
                            ],
                          ).paddingOnly(left: 5.w, right: 10.w)
                        ],
                      ),
                    ),
                  ))
            ],
          ).paddingOnly(right: 40.w);
        },
      ),
    );
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
        return SizedBox.shrink(); // This shows nothing
    }
  }

  Widget trendingChartCard({
    required String title,
    required String subTitle,
    required String count,
    required String periodLabel, // added parameter for dynamic period label
    required String trend,
  }) =>
      Container(
        alignment: Alignment.center,
        width: MySpacing.fullWidth(context) * 0.38,
        height: MySpacing.fullHeight(context) * 0.20,
        padding: EdgeInsets.symmetric(
            horizontal: MySpacing.fullWidth(context) * 0.00),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
            color: contentTheme.background,
            gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.centerRight,
                colors: [
                  Color(0xffEEECFF),
                  Color(0xffEEECFF),
                  Color(0xffDBEBFF),
                ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText.bodySmall(
              title,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: contentTheme.k142228,
              ),
            ),
            MyText.bodySmall(
              subTitle,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: contentTheme.k142228,
              ),
            ),
            5.verticalSpace,
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // ✅ Center horizontally
              crossAxisAlignment:
                  CrossAxisAlignment.center, // ✅ Center vertically
              children: [
                MyText.bodySmall(
                  count,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
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

  Widget studentCountCard() => IntrinsicHeight(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // force equal heights
        children: [
          Expanded(
              child: MyCard.circular(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(width: 1, color: contentTheme.borderColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodySmall(
                        "Assignments",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.k142228,
                        ),
                      ),
                      3.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pending Review Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => MyText.bodySmall(
                                    controller.isLoading.value
                                        ? "..."
                                        : "${controller.pendingReviewCount}",
                                    style: GoogleFonts.inter(
                                      fontSize: 35.sp,
                                      fontWeight: FontWeight.w600,
                                      color: contentTheme.orange,
                                    ),
                                  )),
                              SizedBox(
                                  height: 4
                                      .h), // Add spacing between number and label
                              MyText.bodySmall(
                                "Pending Review",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                          // Graded Column
                          Padding(
                            padding: EdgeInsets.only(right: 35.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => MyText.bodySmall(
                                      controller.isLoading.value
                                          ? "..."
                                          : "${controller.gradedCount}",
                                      style: GoogleFonts.inter(
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.w600,
                                        color: contentTheme.k0A8041,
                                      ),
                                    )),
                                SizedBox(height: 4.h),
                                MyText.bodySmall(
                                  "Graded",
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: contentTheme.k142228,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      18.verticalSpace,
                      InkWell(
                        onTap: () {
                          Get.toNamed("/school/classes");
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.w, vertical: 5.h),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xff004AAD),
                                  Color(0xffCB6CE6),
                                ],
                              )),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "View All",
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: contentTheme.kFEFDFF),
                              ),
                              5.horizontalSpace,
                              Icon(Icons.keyboard_arrow_right_rounded,
                                  color: contentTheme.kFEFDFF, size: 20.r)
                            ],
                          ),
                        ),
                      ),
                      8.verticalSpace,
                    ],
                  ))),
          30.horizontalSpace,
          Expanded(
              child: MyCard.circular(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(width: 1, color: contentTheme.borderColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodySmall(
                        "Active Teachers",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.k142228,
                        ),
                      ),
                      3.verticalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => MyText.bodySmall(
                                controller.isLoading.value
                                    ? "..."
                                    : "${controller.activeTeachersCount}",
                                style: GoogleFonts.inter(
                                  fontSize: 35.sp,
                                  fontWeight: FontWeight.w600,
                                  color: contentTheme.darkPurple,
                                ),
                              )),
                          MyText.bodySmall(
                            "Teachers using binarySuccess in the last 24h",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: contentTheme.k142228,
                            ),
                          ),
                        ],
                      ),
                      35.verticalSpace,
                      Obx(() => controller.isLoading.value
                          ? Center(child: CircularProgressIndicator())
                          : controller.teacherGradeBreakdown.isEmpty
                              ? Center(
                                  child: MyText.bodySmall(
                                    "No grade data available",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: contentTheme.k142228,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: controller.teacherGradeBreakdown
                                      .take(
                                          4) // Limit to 4 items to fit the layout
                                      .map((breakdown) => Container(
                                            margin:
                                                EdgeInsets.only(right: 30.w),
                                            child: buildCard(
                                              breakdown.gradeName ?? "Unknown",
                                              "${breakdown.teacherCount ?? 0}",
                                            ),
                                          ))
                                      .toList(),
                                ))
                    ],
                  ))),
          30.horizontalSpace,
          Expanded(
              child: MyCard.circular(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(width: 1, color: contentTheme.borderColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodySmall(
                        "Active Students",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.k142228,
                        ),
                      ),
                      3.verticalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => MyText.bodySmall(
                                controller.isLoading.value
                                    ? "..."
                                    : "${controller.activeStudentsCount}",
                                style: GoogleFonts.inter(
                                  fontSize: 35.sp,
                                  fontWeight: FontWeight.w600,
                                  color: contentTheme.darkPurple,
                                ),
                              )),
                          MyText.bodySmall(
                            "Students using binarySuccess in the last 24h",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: contentTheme.k142228,
                            ),
                          ),
                        ],
                      ),
                      35.verticalSpace,
                      Obx(() => controller.isLoading.value
                          ? Center(child: CircularProgressIndicator())
                          : controller.studentGradeBreakdown.isEmpty
                              ? Center(
                                  child: MyText.bodySmall(
                                    "No grade data available",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: contentTheme.k142228,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: controller.studentGradeBreakdown
                                      .take(
                                          4) // Limit to 4 items to fit the layout
                                      .map((breakdown) => Container(
                                            margin:
                                                EdgeInsets.only(right: 30.w),
                                            child: buildCard(
                                              breakdown.gradeName ?? "Unknown",
                                              "${breakdown.studentCount ?? 0}",
                                            ),
                                          ))
                                      .toList(),
                                ))
                    ],
                  ))),
        ],
      ).paddingOnly(left: 5.w, right: 10.w, top: 5.h));

  Widget dropdownCard(
      {required String title,
      required List<String> item,
      required String selectedItem,
      void Function(String?)? onChanged}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
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

  Widget buildCard(
    String title,
    String count,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MyText.bodySmall(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: contentTheme.k142228,
          ),
        ),
        MyText.bodySmall(
          count,
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: contentTheme.darkPurple,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
    } else {
      return "Just now";
    }
  }
}
