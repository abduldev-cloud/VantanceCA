import 'package:binary_success/controller/apps/teacher/teacher_dashboard_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/helpers/widgets/my_text_style.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/apps/school/student_chart.dart';
import 'package:binary_success/views/apps/school/ai_usage_monthly_chart.dart';
import 'package:binary_success/views/apps/teacher/dialog/teacher_create_assignment_diaog.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_popupmenu.dart';
import 'package:binary_success/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  TeacherDashboardPageState createState() => TeacherDashboardPageState();
}

class TeacherDashboardPageState extends State<TeacherDashboardPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 0,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: "Welcome Back,\t",
                            style: GoogleFonts.inter(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.k142228)),
                        TextSpan(
                            text: LocalStorage.getUserName() ?? "",
                            style: GoogleFonts.inter(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.darkPurple))
                      ])),
                      MyText.bodyMedium(
                        "Here’s what’s happening with your students.",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: contentTheme.k142228,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Get.dialog(TeacherCreateAssignmentDiaog(
                          contentTheme: contentTheme));
                      // Get.dialog(
                      //   AlertDialog(
                      //     backgroundColor: contentTheme.kFEFDFF,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(25)),
                      //     content: SizedBox(
                      //       width: MySpacing.fullWidth(context) * 0.35,
                      //       child: Column(
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: [
                      //           Text(
                      //             "Add Teacher",
                      //             style: GoogleFonts.inter(
                      //               fontSize: 26.sp,
                      //               fontWeight: FontWeight.w600,
                      //               color: contentTheme.k1C244B,
                      //             ),
                      //           ),
                      //           MyText.bodySmall(
                      //             style: GoogleFonts.inter(
                      //               fontSize: 16.sp,
                      //               fontWeight: FontWeight.w400,
                      //               color: contentTheme.k172640,
                      //             ),
                      //             "Add a teacher to your Binary Success roster",
                      //           ),
                      //           40.verticalSpace,
                      //           Row(
                      //             children: [
                      //               MyText.bodySmall(
                      //                 "Salutation",
                      //                 style: GoogleFonts.inter(
                      //                   fontSize: 16.sp,
                      //                   fontWeight: FontWeight.w400,
                      //                   color: contentTheme.k142228,
                      //                 ),
                      //               ),
                      //               50.horizontalSpace,
                      //               Expanded(
                      //                 child: DropdownButtonFormField(
                      //                   onChanged: (value) {},
                      //                   style: GoogleFonts.inter(
                      //                     fontSize: 14.sp,
                      //                     fontWeight: FontWeight.w400,
                      //                     color: contentTheme.k142228,
                      //                   ),
                      //                   value: "Mr.",
                      //                   dropdownColor: contentTheme.background,
                      //                   menuMaxHeight: 200.h,
                      //                   items: ["Mr.", "Ms."]
                      //                       .map((gender) => DropdownMenuItem(
                      //                           value: gender,
                      //                           child: MyText.labelMedium(
                      //                               style: GoogleFonts.inter(
                      //                                 fontSize: 14,
                      //                                 fontWeight:
                      //                                     FontWeight.w400,
                      //                                 color:
                      //                                     contentTheme.k142228,
                      //                               ),
                      //                               gender)))
                      //                       .toList(),
                      //                   icon: Icon(
                      //                     LucideIcons.chevronDown,
                      //                     size: 20.r,
                      //                   ),
                      //                   decoration: InputDecoration(
                      //                       hintText: "Select gender",
                      //                       hintStyle: MyTextStyle.bodySmall(
                      //                           xMuted: true),
                      //                       border: outlineInputBorder.copyWith(
                      //                           borderSide: BorderSide(
                      //                               color:
                      //                                   contentTheme.kC5CAD1)),
                      //                       enabledBorder:
                      //                           outlineInputBorder.copyWith(
                      //                               borderSide: BorderSide(
                      //                                   color: contentTheme
                      //                                       .kC5CAD1)),
                      //                       focusedBorder:
                      //                           outlineInputBorder.copyWith(
                      //                               borderSide: BorderSide(
                      //                                   color: contentTheme
                      //                                       .kC5CAD1)),
                      //                       contentPadding: MySpacing.symmetric(
                      //                           horizontal: 16.w,
                      //                           vertical: 16.h),
                      //                       isCollapsed: true,
                      //                       floatingLabelBehavior:
                      //                           FloatingLabelBehavior.never),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //           15.verticalSpace,
                      //           Row(
                      //             children: [
                      //               MyText.bodySmall(
                      //                 "Teacher Name",
                      //                 style: GoogleFonts.inter(
                      //                   fontSize: 16.sp,
                      //                   fontWeight: FontWeight.w400,
                      //                   color: contentTheme.k142228,
                      //                 ),
                      //               ),
                      //               15.horizontalSpace,
                      //               Expanded(
                      //                   child: TextInputFields(
                      //                 textStyle: GoogleFonts.inter(
                      //                   fontSize: 14.sp,
                      //                   fontWeight: FontWeight.w400,
                      //                   color: contentTheme.k142228,
                      //                 ),
                      //                 hintText: "",
                      //                 controller: TextEditingController(
                      //                     text: "John Smith"),
                      //               )),
                      //             ],
                      //           ),
                      //           15.verticalSpace,
                      //           Row(
                      //             children: [
                      //               MyText.bodySmall(
                      //                 "Email        ",
                      //                 style: GoogleFonts.inter(
                      //                   fontSize: 16.sp,
                      //                   fontWeight: FontWeight.w400,
                      //                   color: contentTheme.k142228,
                      //                 ),
                      //               ),
                      //               50.horizontalSpace,
                      //               Expanded(
                      //                   child: TextInputFields(
                      //                 textStyle: GoogleFonts.inter(
                      //                   fontSize: 14.sp,
                      //                   fontWeight: FontWeight.w400,
                      //                   color: contentTheme.k142228,
                      //                 ),
                      //                 hintText: "",
                      //                 controller: TextEditingController(
                      //                     text: "jsmith@centralvalleyprep.org"),
                      //               )),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //     actions: [
                      //       Align(
                      //         child: Container(
                      //           margin:
                      //               EdgeInsets.only(top: 10.h, bottom: 10.h),
                      //           padding: EdgeInsets.symmetric(
                      //               horizontal: 45.w, vertical: 8.h),
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(50.r),
                      //               gradient: LinearGradient(
                      //                 begin: Alignment.centerLeft,
                      //                 end: Alignment.centerRight,
                      //                 colors: [
                      //                   Color(0xff004AAD),
                      //                   Color(0xffCB6CE6),
                      //                 ],
                      //               )),
                      //           child: Text(
                      //             "Add",
                      //             style: GoogleFonts.inter(
                      //                 fontSize: 14.sp,
                      //                 fontWeight: FontWeight.w600,
                      //                 color: contentTheme.kFEFDFF),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                          Icon(Icons.add,
                              color: contentTheme.kFEFDFF, size: 22),
                          MySpacing.width(15),
                          Text(
                            "Create Assignment",
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.kFEFDFF),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              18.verticalSpace,
              Expanded(
                child: Obx(() => (controller.isLoading.value ||
                        controller.isDashboardLoading.value)
                    ? SizedBox(
                        height: MySpacing.fullHeight(context) * 0.80,
                        child: Center(
                            child: CircularProgressIndicator(
                          color: contentTheme.darkPurple,
                        )))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            studentCountCard(),
                            MySpacing.height(25),
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
                                                            .isAiUsageLoading
                                                            .value
                                                        ? null
                                                        : () => controller
                                                            .refreshAiUsageData(),
                                                    icon: controller
                                                            .isAiUsageLoading
                                                            .value
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
                                          Obx(() => controller
                                                  .hasAiUsageError.value
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
                                                        color: Colors
                                                            .red.shade200),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.error_outline,
                                                          color: Colors
                                                              .red.shade600,
                                                          size: 16.sp),
                                                      SizedBox(width: 6.w),
                                                      Expanded(
                                                        child: Text(
                                                          "Failed to fetch AI usage data for email: ${controller.aiUsageErrorMessage.value}",
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
                                                  onChanged:
                                                      (String? newValue) {
                                                    if (newValue != null) {
                                                      controller
                                                          .updateTimeRange(
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
                                                                  .isAiUsageLoading
                                                                  .value
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
                                                width: MySpacing.fullWidth(
                                                        context) *
                                                    0.02,
                                              ),
                                              Expanded(
                                                child:
                                                    Obx(() => trendingChartCard(
                                                          title:
                                                              "Writing Fingerprint",
                                                          subTitle: "Total",
                                                          count: controller
                                                                  .isAiUsageLoading
                                                                  .value
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
                                                width: MySpacing.fullWidth(
                                                        context) *
                                                    0.02,
                                              ),
                                              Expanded(
                                                child:
                                                    Obx(() => trendingChartCard(
                                                          title:
                                                              "AI Prompt Used",
                                                          subTitle: "Average",
                                                          count: controller
                                                                  .isAiUsageLoading
                                                                  .value
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
                                                width: MySpacing.fullWidth(
                                                        context) *
                                                    0.02,
                                              ),
                                              Expanded(
                                                child:
                                                    Obx(() => trendingChartCard(
                                                          title:
                                                              "AI Prompt Used",
                                                          subTitle: "Total",
                                                          count: controller
                                                                  .isAiUsageLoading
                                                                  .value
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
                                                width: MySpacing.fullWidth(
                                                        context) *
                                                    0.02,
                                              ),
                                            ],
                                          ).paddingOnly(top: 8, bottom: 14),

                                          MyCard.circular(
                                            color: contentTheme.kFEFDFF,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25.w,
                                                vertical: 15.h),
                                            borderRadius:
                                                BorderRadius.circular(22.r),
                                            border: Border.all(
                                                width: 1,
                                                color:
                                                    contentTheme.borderColor),
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
                                                        color: contentTheme
                                                            .k142228,
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
                                                        if (displayClass
                                                                .length >
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
                                                          onChanged: (String?
                                                              newValue) {
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
                                                            contentTheme
                                                                .kFEFDFF,
                                                        // map through items
                                                        items: displayMap
                                                            .entries
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
                                                          if (newValue !=
                                                              null) {
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
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize:
                                                                      14.sp,
                                                                  color: contentTheme
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
                                                    height:
                                                        MySpacing.fullHeight(
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
                                    margin: EdgeInsets.only(left: 20.w),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 30.w, vertical: 25.h),
                                    borderRadius: BorderRadius.circular(25.r),
                                    border: Border.all(
                                        width: 1.w,
                                        color: contentTheme.borderColor),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        MyText.bodySmall(
                                          "Writing Fingerprint Alerts",
                                          style: GoogleFonts.inter(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w600,
                                            color: contentTheme.k142228,
                                          ),
                                        ),
                                        16.verticalSpace,
                                        Text(
                                          "Possible Authorship Anomaly",
                                          style: GoogleFonts.inter(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                            color: contentTheme.k142228,
                                          ),
                                        ),
                                        2.verticalSpace,
                                        Text(
                                          "These submissions show potential deviation.",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w400,
                                            color: contentTheme.k142228
                                                .withOpacity(0.75),
                                          ),
                                        ),
                                        18.verticalSpace,
                                        Obx(() {
                                          final alerts = controller
                                              .writingFingerprintAlerts;
                                          if (alerts.isEmpty) {
                                            return Column(
                                              children: [
                                                Icon(Icons.check_circle_outline,
                                                    color: Colors.green,
                                                    size: 24.sp),
                                                8.verticalSpace,
                                                Text(
                                                  "No Anomalies Detected",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                                4.verticalSpace,
                                                Text(
                                                  "All submissions appear authentic",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w400,
                                                    fontStyle: FontStyle.italic,
                                                    color: contentTheme.k142228
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                          return ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: alerts.length,
                                            separatorBuilder: (_, idx) =>
                                                Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12.h),
                                              child: Divider(
                                                color: contentTheme.borderColor
                                                    .withOpacity(1),
                                                thickness: 2.8,
                                                height: 1.8,
                                              ),
                                            ),
                                            itemBuilder: (context, idx) {
                                              final alert = alerts[idx];
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    alert.studentName ??
                                                        "Unknown Student",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          contentTheme.k142228,
                                                    ),
                                                  ),
                                                  2.verticalSpace,
                                                  Text(
                                                    "Potential ${alert.formattedDeviation} deviation.",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: contentTheme
                                                          .k142228
                                                          .withOpacity(0.85),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ).paddingOnly(left: 5.w)
                          ],
                        ).paddingOnly(
                          top: 2.h,
                          right: 2.h,
                        ),
                      ).paddingOnly(
                        bottom: MySpacing.fullHeight(context) * 0.04)),
              )
            ],
          ).paddingOnly(right: 50.w);
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MyCard.circular(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(width: 1.w, color: contentTheme.borderColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodySmall(
                      "Pending Review",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                    4.verticalSpace,
                    Obx(() => MyText.bodySmall(
                          controller.isDashboardLoading.value
                              ? "..."
                              : "${controller.pendingSubmissionsCount}",
                          style: GoogleFonts.inter(
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.orange,
                          ),
                        )),
                    6.verticalSpace,
                    MyText.bodySmall(
                      "Submissions awaiting review",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: contentTheme.k142228,
                      ),
                    ),
                    25.verticalSpace,
                    GestureDetector(
                      onTap: () {
                        // Add your GetX navigation logic here
                        Get.toNamed('/teacher/grading?tab=0');

                        // Or use a specific widget: Get.to(() => TeacherGradingPage());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff004AAD), Color(0xffCB6CE6)],
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View All",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.kFEFDFF,
                              ),
                            ),
                            4.horizontalSpace,
                            Icon(Icons.keyboard_arrow_right_rounded,
                                color: contentTheme.kFEFDFF, size: 20.r),
                          ],
                        ),
                      ),
                    ),
                    16.verticalSpace,
                  ],
                ),
              ),
            ),
            20.horizontalSpace,
            Expanded(
              child: MyCard.circular(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(width: 1.w, color: contentTheme.borderColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodySmall(
                      "Graded This Week",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                    4.verticalSpace,
                    Obx(() => MyText.bodySmall(
                          controller.isDashboardLoading.value
                              ? "..."
                              : "${controller.gradedThisWeekCount}",
                          style: GoogleFonts.inter(
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.k0A8041,
                          ),
                        )),
                    6.verticalSpace,
                    MyText.bodySmall(
                      "Recently graded assignments",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: contentTheme.k142228,
                      ),
                    ),
                    25.verticalSpace,
                    GestureDetector(
                      onTap: () {
                        // Add your GetX navigation logic here
                        Get.toNamed('/teacher/grading?tab=1');

                        // Or use a specific widget: Get.to(() => TeacherGradingPage());
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xff004AAD), Color(0xffCB6CE6)],
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View All",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.kFEFDFF,
                              ),
                            ),
                            4.horizontalSpace,
                            Icon(Icons.keyboard_arrow_right_rounded,
                                color: contentTheme.kFEFDFF, size: 20.r),
                          ],
                        ),
                      ),
                    ),
                    16.verticalSpace,
                  ],
                ),
              ),
            ),
            20.horizontalSpace,
            Expanded(
              child: MyCard.circular(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(width: 1.w, color: contentTheme.borderColor),
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
                    4.verticalSpace,
                    Obx(() => MyText.bodySmall(
                          controller.isDashboardLoading.value
                              ? "..."
                              : "${controller.activeStudentsCount}",
                          style: GoogleFonts.inter(
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.darkPurple,
                          ),
                        )),
                    6.verticalSpace,
                    MyText.bodySmall(
                      "Students using Binary Success in the last 24h",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: contentTheme.k142228,
                      ),
                    ),
                    25.verticalSpace,
                    Obx(() => controller.isDashboardLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink()),
                    16.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ).paddingOnly(left: 5),
      );

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
}
