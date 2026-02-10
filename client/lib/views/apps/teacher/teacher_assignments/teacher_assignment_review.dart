import 'package:binary_success/controller/apps/teacher/teacher_assignments_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/apps/teacher/dialog/teacher_writing_fingerprint_dialog.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class TeacherAssignmentReview extends StatefulWidget {
  const TeacherAssignmentReview({super.key});

  @override
  TeacherAssignmentReviewState createState() => TeacherAssignmentReviewState();
}

class TeacherAssignmentReviewState extends State<TeacherAssignmentReview>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherAssignmentsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherAssignmentsController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getAssignmentReview(
        Get.arguments?['learnerId'] ?? 'REPLACE_WITH_REAL_LEARNER_ID',
        Get.arguments?['taskId'] ?? 'REPLACE_WITH_REAL_TASK_ID',
      );
    });
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return "${_monthString(date.month)} ${date.day}, ${date.year} ${_formatTime(date)}";
    } catch (e) {
      return dateString;
    }
  }

  String _monthString(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dt) {
    int hour = dt.hour;
    String meridian = 'AM';
    if (hour >= 12) {
      meridian = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    String minute = dt.minute.toString().padLeft(2, '0');
    return "$hour:$minute $meridian";
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 4,
      child: GetBuilder<TeacherAssignmentsController>(
        init: controller,
        builder: (controller) {
          final review = controller.reviewData.value;

          final aiPrompts = review?.aiPrompts ?? [];
          final rubrics = review?.rubrics ?? [];

          final learnerName =
              (review?.learnerTaskSummary.learnerFirstName ?? '') +
                  ((review?.learnerTaskSummary.learnerLastName ?? '').isNotEmpty
                      ? ' ${review!.learnerTaskSummary.learnerLastName}'
                      : '');

          final assignmentTitle = review?.learnerTaskSummary.taskTitle ?? '';
          final submittedAt =
              formatDate(review?.learnerTaskSummary.submittedAt);
          final deviation = review?.learnerTaskSummary.deviationPercentage ?? 0;
          final wordCount = review?.learnerTaskSummary.targetWordCount ?? 0;
          final teacherGrade = review?.learnerTaskSummary.teacherGrade;

          // --- Loading, error, fallback states ---
          if (controller.isReviewLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.reviewError.isNotEmpty) {
            return Center(
                child: Text(
              controller.reviewError.value,
              style: const TextStyle(color: Colors.red),
            ));
          }

          // --- Only show fallback when truly ALL major sections are empty ---
          final hasLearner =
              (review?.learnerTaskSummary.learnerId.isNotEmpty ?? false);
          final hasPrompts = aiPrompts.isNotEmpty;
          final hasRubrics = rubrics.isNotEmpty;

          if (!(hasLearner || hasRubrics)) {
            return const Center(
              child: Text(
                "No review data available for this submission.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // --- Actual content ---
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium(
                          "Graded",
                          style: GoogleFonts.inter(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: contentTheme.k142228,
                          ),
                        ),
                        MyText.bodySmall(
                          "Review student submission and AI feedback",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Get.dialog(
                          TeacherWritingFingerprintDialog(
                            contentTheme: contentTheme,
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.r),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xff004AAD),
                              Color(0xffCB6CE6),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,
                                color: contentTheme.kFEFDFF, size: 20.r),
                            10.horizontalSpace,
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
                ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
                15.verticalSpace,
                // Main Card with learner details
                MyCard(
                  margin: EdgeInsets.only(
                      right: MySpacing.fullWidth(context) * 0.04),
                  padding:
                      EdgeInsets.symmetric(vertical: 25.h, horizontal: 35.w),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.titleMedium(
                                learnerName,
                                style: GoogleFonts.inter(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: contentTheme.black,
                                ),
                              ),
                              2.verticalSpace,
                              MyText.bodySmall(
                                assignmentTitle,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                          30.horizontalSpace,
                          Row(
                            children: [
                              Image.asset(Images.calendar,
                                  width: 15.w, height: 15.h),
                              7.horizontalSpace,
                              MyText.bodySmall(
                                submittedAt,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                          30.horizontalSpace,
                          Row(
                            children: [
                              Image.asset(Images.fingerprint,
                                  width: 22.w, height: 22.h),
                              7.horizontalSpace,
                              MyText.bodySmall(
                                "Deviation: $deviation%",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ],
                          ),
                          30.horizontalSpace,
                          MyText.bodySmall(
                            "$wordCount words",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: contentTheme.k142228,
                            ),
                          ),
                          30.horizontalSpace,
                          Image.asset(Images.comment,
                              width: 20.w, height: 20.h),
                          80.horizontalSpace,
                        ],
                      ),
                      25.verticalSpace,
                      // REACTIVE learner HTML content from Alfresco
                      Obx(() {
                        final htmlContent = controller.learnerHtmlContent.value;

                        if (htmlContent.isEmpty) {
                          return MyText.bodySmall(
                            "No learner response available.",
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: contentTheme.k142228,
                            ),
                          );
                        }

                        return HtmlWidget(
                          htmlContent,
                        );
                      }),
                    ],
                  ),
                ),
                20.verticalSpace,
                // Tab view with AI Chat Log and Rubric
                Row(
                  children: [
                    MyCard(
                      padding: EdgeInsets.symmetric(
                          vertical: 25.h, horizontal: 35.w),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      child: DefaultTabController(
                        key: const Key("TabBar"),
                        length: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TabBar(
                              onTap: (value) =>
                                  controller.changeReviewTab(value),
                              indicator: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              padding: EdgeInsets.zero,
                              dividerHeight: 0,
                              isScrollable: true,
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              tabAlignment: TabAlignment.start,
                              tabs: [
                                Tab(
                                    iconMargin: EdgeInsets.zero,
                                    child: Obx(() => tab(
                                          title: "AI Chat Log",
                                          isSelected: controller
                                                  .selectedTabIndex.value ==
                                              0,
                                        ))),
                                Tab(
                                    child: Obx(() => tab(
                                          title: "Rubric",
                                          isSelected: controller
                                                  .selectedTabIndex.value ==
                                              1,
                                        ))),
                              ],
                            ).paddingOnly(
                                left: MySpacing.fullWidth(context) * 0.05),
                            SizedBox(
                              height: MySpacing.fullHeight(context) * 0.16,
                              width: MySpacing.fullWidth(context) * 0.53,
                              child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: contentTheme.borderColor),
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xffEEECFF),
                                          Color(0xffEEECFF),
                                          Color(0x0ffdbeff),
                                        ],
                                      ),
                                    ),
                                    child: aiPrompts.isEmpty
                                        ? MyText.bodySmall(
                                            "No AI chat log available.")
                                        : ListView.separated(
                                            itemBuilder: (context, index) {
                                              final prompt =
                                                  aiPrompts[index].promptText;
                                              final response =
                                                  aiPrompts[index].aiResponse;
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  buildAIHelperCard(
                                                      isMe: false,
                                                      text: prompt),
                                                  8.verticalSpace,
                                                  buildAIHelperCard(
                                                      isMe: true,
                                                      text: response),
                                                ],
                                              );
                                            },
                                            itemCount: aiPrompts.length,
                                            shrinkWrap: true,
                                            separatorBuilder:
                                                (context, index) =>
                                                    10.verticalSpace,
                                          ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: contentTheme.borderColor),
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xffEEECFF),
                                          Color(0xffEEECFF),
                                          Color(0x0ffdbeff),
                                        ],
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: rubrics.isEmpty
                                            ? [
                                                Center(
                                                  child: MyText.bodySmall(
                                                      "No rubric data available."),
                                                )
                                              ]
                                            : rubricsGroupedByChart(rubrics),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    25.horizontalSpace,
                    MyCard(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      width: MySpacing.fullWidth(context) * 0.14,
                      child: Column(
                        children: [
                          MyText.bodyMedium(
                            "Grade",
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: contentTheme.black,
                            ),
                          ),
                          MyText.bodyMedium(
                            teacherGrade?.toString() ?? "--",
                            style: GoogleFonts.inter(
                              fontSize: 65.sp,
                              fontWeight: FontWeight.w500,
                              color: teacherGrade == null
                                  ? Colors.grey.withAlpha(112)
                                  : contentTheme.black,
                            ),
                          ),
                        ],
                      ),
                    ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildAIHelperCard({required bool isMe, required String text}) {
    return Container(
      margin: isMe ? EdgeInsets.only(left: 20.w) : EdgeInsets.only(right: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: contentTheme.kFEFDFF,
        border: Border.all(width: 1, color: contentTheme.borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text.isNotEmpty ? text : "(No content)",
        style: GoogleFonts.inter(
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
          color: contentTheme.black,
        ),
      ),
    );
  }

  Widget tab({required String title, required bool isSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: isSelected ? null : Colors.white,
        gradient: isSelected
            ? const LinearGradient(
                colors: [
                  Color(0xffEEECFF),
                  Color(0xffEEECFF),
                  Color(0x0ffdbeff),
                ],
              )
            : null,
        border: Border(
          top: BorderSide(color: contentTheme.kCDCBE0),
          right: BorderSide(color: contentTheme.kCDCBE0),
          left: BorderSide(color: contentTheme.kCDCBE0),
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
      ),
      child: MyText.titleMedium(
        title,
        style: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: contentTheme.k142228,
        ),
      ),
    );
  }

  List<Widget> rubricsGroupedByChart(List rubrics) {
    Map<String, List> grouped = {};
    for (var rubric in rubrics) {
      String key = (rubric.rubricTitle ?? '') as String;
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(rubric);
    }
    return grouped.entries.map((entry) {
      final key = entry.key;
      final items = entry.value;
      final maxPoints =
          items.isNotEmpty ? (items[0] as dynamic).maxPoints as int : 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium(
                key,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: contentTheme.black,
                ),
              ),
              MyText.bodyMedium(
                "$maxPoints points",
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: contentTheme.black,
                ),
              ),
            ],
          ),
          10.verticalSpace,
          ...items.map((r) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 20,
                    color: _hexToColor((r as dynamic).criterionDisplayColorCd),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: Text(
                      (r as dynamic).criteriaDesc,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: _hexToColor(r.criterionDisplayColorCd),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          20.verticalSpace,
        ],
      );
    }).toList();
  }

  Color _hexToColor(String hex) {
    if (hex.isEmpty) return Colors.black;
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    int val = int.parse(hex, radix: 16);
    return Color(val);
  }
}
