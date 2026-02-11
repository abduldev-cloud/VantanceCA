import 'package:vantanceCA/controller/apps/admin/admin_dashboard_controller.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';

import 'package:vantanceCA/views/apps/school/ai_usage_monthly_chart.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_popupmenu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  AdminDashboardPageState createState() => AdminDashboardPageState();
}

class AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late AdminDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.85, // Set this to match your sidebar's height (adjust if needed)
              child: SingleChildScrollView(
                child: Column(
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
                                  text: "${LocalStorage.getUserName()}",
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
                        // Refresh button

                        MySpacing.width(15),
                        // Container(
                        //   padding:
                        //       EdgeInsets.symmetric(horizontal: 25.w, vertical: 8.h),
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(50),
                        //       gradient: LinearGradient(
                        //         begin: Alignment.centerLeft,
                        //         end: Alignment.centerRight,
                        //         colors: [
                        //           Color(0xff004AAD),
                        //           Color(0xffCB6CE6),
                        //         ],
                        //       )),
                        //   // child: Row(
                        //   //   mainAxisSize: MainAxisSize.min,
                        //   //   mainAxisAlignment: MainAxisAlignment.center,
                        //   //   children: [
                        //   //     Icon(Icons.add,
                        //   //         color: contentTheme.kFEFDFF, size: 20.r),
                        //   //     MySpacing.width(15),
                        //   //     // Text(
                        //   //     //   "Impersonate User",
                        //   //     //   style: GoogleFonts.inter(
                        //   //     //       fontSize: 12.sp,
                        //   //     //       fontWeight: FontWeight.w600,
                        //   //     //       color: contentTheme.kFEFDFF),
                        //   //     // ),
                        //   //   ],
                        //   // ),
                        // ),
                      ],
                    ),
                    // Error display for any data loading errors
                    Obx(() => controller.hasAnyError
                        ? Container(
                            margin: EdgeInsets.only(top: 18.h, bottom: 10.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade600, size: 20.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    controller.combinedErrorMessage,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => controller.refreshAllData(),
                                  child: Text(
                                    "Retry",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink()),
                    18.verticalSpace,
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
                                  horizontal: 35.w, vertical: 20.h),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                  width: 1, color: contentTheme.borderColor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            onPressed:
                                                controller.isLoading.value
                                                    ? null
                                                    : () => controller
                                                        .refreshAiUsageData(),
                                            icon: controller.isLoading.value
                                                ? SizedBox(
                                                    width: 16.w,
                                                    height: 15.h,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  )
                                                : Icon(Icons.refresh,
                                                    size: 20.sp),
                                            tooltip: "Refresh AI Usage Data",
                                          )),
                                    ],
                                  ),
                                  // Remove the Container entirely and use this Obx
                                  Obx(() {
                                    if (controller.hasError.value) {
                                      // Show Snackbar
                                      Future.delayed(Duration.zero, () {
                                        Get.snackbar(
                                          "Error",
                                          "Failed to fetch AI usage data for email: ${controller.errorMessage.value}",
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red.shade50,
                                          colorText: Colors.red.shade700,
                                          icon: Icon(Icons.error_outline,
                                              color: Colors.red.shade600),
                                          margin: EdgeInsets.all(8),
                                          duration: Duration(seconds: 3),
                                        );
                                      });

                                      // Reset the error flag to prevent multiple snackbars
                                      controller.hasError.value = false;
                                    }

                                    // Return empty widget since snackbar is shown separately
                                    return SizedBox.shrink();
                                  }),
                                  Row(
                                    children: [
                                      Text.rich(TextSpan(children: [
                                        TextSpan(
                                            text: "Time Range:\t",
                                            style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: contentTheme.k142228)),
                                      ])),
                                      Obx(() => CommanPopupmenu(
                                          contentTheme: contentTheme,
                                          title: controller
                                              .selectedTimeRange.value,
                                          list: ["7d", "14d", "30d", "Term 1"],
                                          onChanged: (String? newValue) {
                                            if (newValue != null) {
                                              controller
                                                  .updateTimeRange(newValue);
                                            }
                                          }))
                                    ],
                                  ),

                                  Row(children: [
                                    Expanded(
                                      child: Obx(() => trendingChartCard(
                                            title: "Writing Fingerprint",
                                            subTitle: "Average Deviation",
                                            count: controller.isLoading.value
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
                                          MySpacing.fullWidth(context) * 0.01,
                                    ),
                                    Expanded(
                                      child: Obx(() => trendingChartCard(
                                            title: "Writing Fingerprint",
                                            subTitle: "Total",
                                            count: controller.isLoading.value
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
                                          MySpacing.fullWidth(context) * 0.01,
                                    ),
                                    Expanded(
                                      child: Obx(() => trendingChartCard(
                                            title: "AI Prompt Used",
                                            subTitle: "Average",
                                            count: controller.isLoading.value
                                                ? "..."
                                                : controller
                                                    .aiPromptUsageAverage
                                                    .toStringAsFixed(1),
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
                                          MySpacing.fullWidth(context) * 0.01,
                                    ),
                                    Expanded(
                                      child: Obx(() => trendingChartCard(
                                            title: "AI Prompt Used",
                                            subTitle: "Total",
                                            count: controller.isLoading.value
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
                                  ]).paddingOnly(top: 8.h, bottom: 14.h),
                                  MyCard.circular(
                                    color: contentTheme.kFEFDFF,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 25.w, vertical: 15.h),
                                    borderRadius: BorderRadius.circular(22.r),
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
                                                fontWeight: FontWeight.w600,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                            Spacer(),
                                            SizedBox(
                                                width:
                                                    12), // Increased space before Class dropdown

                                            // Class Dropdown (with improved truncation)
                                            Expanded(
                                              flex: 3,
                                              child: Obx(() {
                                                // Map classList model to class name list for dropdown items
                                                final classItems = controller
                                                    .classList
                                                    .map((cls) =>
                                                        cls.className ??
                                                        "Unknown")
                                                    .toList();

                                                // Current selected class or "All"
                                                String displayClass = controller
                                                        .selectedClass
                                                        .value
                                                        .isNotEmpty
                                                    ? controller
                                                        .selectedClass.value
                                                    : "All";

                                                // Truncate long class names for display
                                                if (displayClass.length > 40) {
                                                  displayClass =
                                                      "${displayClass.substring(0, 25)}…";
                                                }

                                                return dropdownCard(
                                                  selectedItem: displayClass,
                                                  title: "Class:\t",
                                                  item: classItems.isNotEmpty
                                                      ? classItems
                                                      : ["All"],
                                                  onChanged:
                                                      (String? newValue) {
                                                    if (newValue != null) {
                                                      controller.onClassChanged(
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

                                              return DropdownButton<String>(
                                                // internal value (bound to controller)
                                                value: controller
                                                    .selectedPeriodBucket.value,
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
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14.sp,
                                                        color: contentTheme
                                                            .k142228,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) {
                                                    controller
                                                        .selectedPeriodBucket
                                                        .value = newValue;
                                                    controller
                                                        .fetchAiUsageOverview();
                                                  }
                                                },
                                                underline: const SizedBox(),
                                                // ✅ show display text for selected item
                                                selectedItemBuilder:
                                                    (BuildContext context) {
                                                  return displayMap.entries
                                                      .map((entry) {
                                                    return Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        entry.value,
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 14.sp,
                                                          color: contentTheme
                                                              .k142228,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                MySpacing.fullHeight(context) *
                                                    0.18,
                                            child:
                                                Obx(() => AIUsageBarChartWidget(
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
                        20.horizontalSpace,
                        Expanded(
                            child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.62,
                          child: Card(
                            margin: EdgeInsets.only(left: 20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 18),
                              child: Obx(() {
                                if (controller.isSupportTicketsLoading.value) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                if (controller.hasSupportTicketsError.value) {
                                  return Center(
                                    child: Text(
                                      controller
                                          .supportTicketsErrorMessage.value,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                }
                                if (controller.supportTicketsList.isEmpty) {
                                  return Center(
                                    child: Text(
                                      "No support tickets available",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  );
                                }

                                // CAP AT 10, SCROLLABLE, ADD TOP GAP
                                final displayTickets = controller
                                    .supportTicketsList
                                    .take(10)
                                    .toList();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Add a vertical gap here (match analytics section)
                                    SizedBox(
                                        height:
                                            13), // adjust this to your UI as needed
                                    Text(
                                      "Support Tickets",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 13),
                                    SizedBox(
                                      height:
                                          350, // fixed height for scrollable area
                                      child: ListView.separated(
                                        itemCount: displayTickets.length,
                                        separatorBuilder: (context, index) =>
                                            Divider(height: 22),
                                        itemBuilder: (context, index) {
                                          final ticket = displayTickets[index];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Ticket number: only the number in purple
                                              Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "Ticket #: ",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .black, // label in black
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: ticket.ticketNumber,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .purple, // number in purple
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // User name in bold
                                              Text(
                                                "User Name: ${ticket.userName}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              // Priority text
                                              Text(
                                                  "Priority: ${ticket.priority}"),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                );
                              }),
                            ),
                          ),
                        ))
                      ],
                    )
                  ],
                ).paddingOnly(right: 50.w, left: 5.w, bottom: 60.h),
              ));
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

  Widget buildSorting(String title) {
    return MyText.labelLarge(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: contentTheme.darkPurple,
      ),
    ).paddingSymmetric(vertical: 3);
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'p1':
        return Colors.red;
      case 'medium':
      case 'p2':
        return Colors.orange;
      case 'low':
      case 'p3':
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'closed':
      case 'resolved':
        return Colors.green;
      case 'open':
      case 'pending':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      default:
        return Colors.grey;
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
  Widget studentCountCard() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: MyCard.circular(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(width: 1, color: contentTheme.borderColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodySmall(
                        "Total Schools",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.k142228,
                        ),
                      ),
                      3.verticalSpace,
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => MyText.bodySmall(
                                    controller.isPlatformLoading.value
                                        ? "..."
                                        : "${controller.activeSchoolsCount}",
                                    style: GoogleFonts.inter(
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.w600,
                                        color: contentTheme.k0A8041),
                                  )),
                              MyText.bodySmall(
                                "Active",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                          MySpacing.width(80),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Obx(() => MyText.bodySmall(
                                    controller.isPlatformLoading.value
                                        ? "..."
                                        : "${controller.inactiveSchoolsCount}",
                                    style: GoogleFonts.inter(
                                      fontSize: 35.sp,
                                      fontWeight: FontWeight.w600,
                                      color: contentTheme.orange,
                                    ),
                                  )),
                              MyText.bodySmall(
                                "Inactive",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      30.verticalSpace,
                      InkWell(
                        onTap: () {
                          Get.toNamed("/admin/schools");
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.w, vertical: 7.h),
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
                      MySpacing.height(20),
                    ],
                  ))),
          30.horizontalSpace,
          Expanded(
              child: MyCard.circular(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(width: 1, color: contentTheme.borderColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodySmall(
                        "Total Users",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.k142228,
                        ),
                      ),
                      3.verticalSpace,
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() => MyText.bodySmall(
                                    controller.isPlatformLoading.value
                                        ? "..."
                                        : "${controller.activeUsersCount}",
                                    style: GoogleFonts.inter(
                                        fontSize: 35.sp,
                                        fontWeight: FontWeight.w600,
                                        color: contentTheme.k0A8041),
                                  )),
                              MyText.bodySmall(
                                "Active",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                          80.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Obx(() => MyText.bodySmall(
                                    controller.isPlatformLoading.value
                                        ? "..."
                                        : "${controller.inactiveUsersCount}",
                                    style: GoogleFonts.inter(
                                      fontSize: 35.sp,
                                      fontWeight: FontWeight.w600,
                                      color: contentTheme.orange,
                                    ),
                                  )),
                              MyText.bodySmall(
                                "Inactive",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      30.verticalSpace,
                      InkWell(
                        onTap: () {
                          Get.toNamed("/admin/users");
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.w, vertical: 7.h),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.r),
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
                      MySpacing.height(20),
                    ],
                  ))),
          30.horizontalSpace,
          Expanded(
              child: MyCard.circular(
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                  borderRadius: BorderRadius.circular(25),
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
                                controller.isPlatformLoading.value
                                    ? "..."
                                    : "${controller.activeStudents24hr}",
                                style: GoogleFonts.inter(
                                  fontSize: 35.sp,
                                  fontWeight: FontWeight.w600,
                                  color: contentTheme.darkPurple,
                                ),
                              )),
                          MyText.bodySmall(
                            "Students using VantanceCA in the last 24h",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: contentTheme.k142228,
                            ),
                          ),
                        ],
                      ),
                      30.verticalSpace,
                      Obx(() => controller.isPlatformLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildCard("Grade 09", "..."),
                                buildCard("Grade 10", "..."),
                                buildCard("Grade 11", "..."),
                                buildCard("Grade 12", "..."),
                              ],
                            )
                          : controller.hasPlatformError.value
                              ? Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red, size: 24.sp),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Failed to load grade data",
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => controller
                                            .refreshPlatformDashboard(),
                                        child: Text("Retry"),
                                      ),
                                    ],
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: _buildGradeCards(controller),
                                ))
                    ],
                  ))),
        ],
      );

  List<Widget> _buildGradeCards(AdminDashboardController controller) {
    final gradeBreakdown = controller.gradeWiseBreakdown;
    final grades = ['Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];

    return grades.map((grade) {
      final count = gradeBreakdown?[grade] ?? 0;
      return buildCard(grade, count.toString());
    }).toList();
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
}
