import 'dart:collection';
import 'dart:convert';

import 'package:vantanceCA/controller/apps/teacher/teacher_grading_controller.dart';
import 'package:vantanceCA/helpers/services/teacher_service.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/models/teachers_grading_model.dart';
import 'package:vantanceCA/views/apps/teacher/dialog/teacher_writing_fingerprint_dialog.dart';
import 'package:vantanceCA/views/apps/teacher/widget/confirm_grade_dialog.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/common_status_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/gestures.dart';
import 'package:vantanceCA/views/apps/teacher/widget/web_selectable_html.dart';

import 'package:flutter/services.dart';

class TeacherGradingReviewPage extends StatefulWidget {
  const TeacherGradingReviewPage({super.key});

  @override
  TeacherGradingReviewPageState createState() =>
      TeacherGradingReviewPageState();
}

class TeacherGradingReviewPageState extends State<TeacherGradingReviewPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherGradingController controller;
  GradingViewApiResponse? data;
  ContentWithGrade? dataContent;
  bool isLoading = true;
  dynamic gradingData;
  bool isSubmittingGrade = false;
  late TextEditingController teacherGradeController;

  int? selectionStart;
  int? selectionEnd;
  String selectedText = "";
  OverlayEntry? _activePopup;

  void updateSelection(int start, int end, String text) {
    selectionStart = start;
    selectionEnd = end;
    selectedText = text;
    print("Updated selection: [$start:$end] → $text");
  }

  Future<void> _showAddCommentDialog({
    required String learnerTaskId,
    required String teacherId,
    required int selectionStart,
    required int selectionEnd,
    required String selectedText,
  }) async {
    final TextEditingController commentController = TextEditingController();
    bool isSubmitting = false;

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                constraints: const BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      // Don't remove this again
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "Selected: \"$selectedText\"",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(8, -8), // (x, y) → right & up
                          child: IconButton(
                            icon: const Icon(Icons.close,
                                size: 22, color: Colors.black87),
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: commentController,
                      maxLength: 500,
                      maxLines: null,
                      minLines: 1,
                      keyboardType:
                          TextInputType.multiline, // Don't remove this again
                      decoration: InputDecoration(
                        hintText: "Enter Comment (max 500 chars)",
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.inter(
                          fontSize: 18.sp,
                          color: const Color(0xffB4B4B4),
                        ),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        color: Colors.black,
                      ),
                      autofocus: true,
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: isSubmitting
                            ? null
                            : () async {
                                final commentText =
                                    commentController.text.trim();
                                if (commentText.isEmpty) {
                                  Get.snackbar(
                                      "Validation", "Please enter a comment.");
                                  return;
                                }
                                if (commentText.length > 500) {
                                  Get.snackbar("Validation",
                                      "Comment must be 500 characters or less.");
                                  return;
                                }
                                setState(() => isSubmitting = true);

                                final newCommentId = await TeacherGradingService
                                    .saveLearnerTaskComments(reviewComments: {
                                  "comment_id": "",
                                  "learner_task_id": learnerTaskId,
                                  "teacher_id": teacherId,
                                  "comment_text": commentText,
                                  "selection_start": selectionStart,
                                  "selection_end": selectionEnd,
                                });

                                setState(() => isSubmitting = false);

                                if (newCommentId != null) {
                                  this.setState(() {
                                    (data?.comments as List).add({
                                      // Don't remove this again
                                      "comment_id": newCommentId,
                                      "comment_text": commentText,
                                      "teacher_id": teacherId,
                                      "created_date":
                                          DateTime.now().toIso8601String(),
                                      "selection_start": selectionStart,
                                      "selection_end": selectionEnd,
                                    });

                                    selectionStart = 0;
                                    selectionEnd = 0;
                                    selectedText = "";
                                  });

                                  Get.back(); // close dialog
                                  StatusDialog.show(
                                    isSuccess: true,
                                    message: "Comment added successfully.",
                                    autoCloseSeconds: 2,
                                  );
                                } else {
                                  Get.snackbar(
                                      "Error", "Failed to add comment");
                                }
                              },
                        child: isSubmitting
                            ? SizedBox(
                                width: 24.w,
                                height: 24.h,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : SvgPicture.string(
                                '''
                              <svg width="28" height="28" viewBox="0 0 30 30" fill="none" xmlns="http://www.w3.org/2000/svg"> <path d="M13.5 14.7L12.15 16.05C11.875 16.325 11.525 16.4625 11.1 16.4625C10.675 16.4625 10.325 16.325 10.05 16.05C9.775 15.775 9.6375 15.425 9.6375 15C9.6375 14.575 9.775 14.225 10.05 13.95L13.95 10.05C14.25 9.75001 14.6 9.60001 15 9.60001C15.4 9.60001 15.75 9.75001 16.05 10.05L19.95 13.95C20.225 14.225 20.3625 14.575 20.3625 15C20.3625 15.425 20.225 15.775 19.95 16.05C19.675 16.325 19.325 16.4625 18.9 16.4625C18.475 16.4625 18.125 16.325 17.85 16.05L16.5 14.7V19.5C16.5 19.925 16.356 20.281 16.068 20.568C15.78 20.855 15.424 20.999 15 21C14.576 21.001 14.22 20.857 13.932 20.568C13.644 20.279 13.5 19.923 13.5 19.5V14.7ZM15 9.53674e-06C12.925 9.53674e-06 10.975 0.394009 9.15 1.18201C7.325 1.97001 5.7375 3.03851 4.3875 4.38751C3.0375 5.73651 1.969 7.32401 1.182 9.15001C0.395002 10.976 0.0010019 12.926 1.89873e-06 15C-0.000998101 17.074 0.393002 19.024 1.182 20.85C1.971 22.676 3.0395 24.2635 4.3875 25.6125C5.7355 26.9615 7.323 28.03 9.15 28.818C10.977 29.606 12.927 30 15 30C17.073 30 19.023 29.606 20.85 28.818C22.677 28.03 24.2645 26.9615 25.6125 25.6125C26.9605 24.2635 28.0295 22.676 28.8195 20.85C29.6095 19.024 30.003 17.074 30 15C29.997 12.926 29.603 10.976 28.818 9.15001C28.033 7.32401 26.9645 5.73651 25.6125 4.38751C24.2605 3.03851 22.673 1.96951 20.85 1.18051C19.027 0.39151 17.077 -0.00199127 15 9.53674e-06ZM15 3.00001C18.35 3.00001 21.1875 4.16251 23.5125 6.48751C25.8375 8.81251 27 11.65 27 15C27 18.35 25.8375 21.1875 23.5125 23.5125C21.1875 25.8375 18.35 27 15 27C11.65 27 8.8125 25.8375 6.4875 23.5125C4.1625 21.1875 3 18.35 3 15C3 11.65 4.1625 8.81251 6.4875 6.48751C8.8125 4.16251 11.65 3.00001 15 3.00001Z" fill="#9F3CBB"/> </svg>
                              ''',
                                width: 28.r,
                                height: 28.r,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  @override
  void initState() {
    super.initState();

    controller = Get.put(TeacherGradingController());

    final args = Get.arguments;
    if (args is TeachersGradingModel) {
      gradingData = args;
    } else if (args is Map<String, dynamic>) {
      gradingData = TeachersGradingModel.fromJson(args);
    } else {
      gradingData = null; // Handle unexpected argument type gracefully
    }

    teacherGradeController = TextEditingController(
        text: (gradingData?.teacherGrade?.toString()) ?? '');

    // Setup JS listener for comment-icon clicks (Web Only)
    /*
    html.document.addEventListener('click', (event) {
      if (event.target is html.Element) {
        final el = event.target as html.Element;
        final commentIcon = el.closest('.comment-icon');
        if (commentIcon != null) {
          _showCommentPopup(context, commentIcon);
        }
      }
    });

    // Listen for hover events
    html.document.addEventListener('mouseover', (event) {
      if (event.target is html.Element) {
        final el = event.target as html.Element;
        final commentIcon = el.closest('.comment-icon');
        if (commentIcon != null) {
          _showCommentPopup(context, commentIcon);
        }
      }
    });
    */

    fetchGradingData();
  }

  @override
  void dispose() {
    teacherGradeController.dispose();
    _activePopup?.remove();
    _activePopup = null;
    super.dispose();
  }

  Future<void> fetchGradingData() async {
    try {
      if (gradingData is TeachersGradingModel) {
        final model = gradingData as TeachersGradingModel;

        // 🔹 First API call
        final response = await TeacherGradingService.getTeacherGradingview(
          task_id: model.taskId,
          learner_id: model.learnerId,
        );

        if (response == null || response.taskSummary.isEmpty) {
          print("❌ No task summary data found");
          setState(() => isLoading = false);
          return;
        }

        final summary = response.taskSummary.first;

        // 🔹 Build student_id
        final studentId =
            "${model.learnerFirstName.toLowerCase()}${model.learnerLastName.toLowerCase()}-${model.learnerId}";

        print("studentId = $studentId");

        // 🔹 Second API call
        final contentResponse =
            await TeacherGradingService.getTeacherGradingContent(
          site_id: summary.alfrescoSiteId,
          folder_path: (summary.alfrescoFolderPath.isNotEmpty)
              ? summary.alfrescoFolderPath
              : "${summary.gradeName.replaceAll(" ", "")}/Assignment",
          student_id: studentId,
          task_id: (summary.alfrescoTaskId != null)
              ? summary.alfrescoTaskId.toString()
              : summary.taskId.toString(),
          file_name: (summary.fileName ?? "").replaceAll(".html", ""),
        );

        setState(() {
          data = response;
          dataContent = contentResponse;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching grading data: $e");
      setState(() => isLoading = false);
    }
  }

  void _showCommentPopup(BuildContext context, dynamic anchor) {
    _activePopup?.remove();
    _activePopup = null;

    // Web-only logic disabled for mobile build
    /*
    final overlay = Overlay.of(context);
    final rect = anchor.getBoundingClientRect();

    final commentText = anchor.getAttribute("data-comment-text") ?? "";
    final teacherName =
        anchor.getAttribute("data-teacher-name") ?? "Unknown Teacher";
    final createdAt = anchor.getAttribute("data-created-date") ?? "";

    String formattedDate = createdAt;
    try {
      final dt = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays >= 1) {
        formattedDate = "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
      } else if (diff.inHours >= 1) {
        formattedDate =
            "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
      } else if (diff.inMinutes >= 1) {
        formattedDate =
            "${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago";
      } else {
        formattedDate = "just now";
      }
    } catch (_) {}

    final entry = OverlayEntry(
      builder: (context) => Positioned(
        left: (rect.left + rect.width + 12).toDouble(),
        top: rect.top.toDouble(),
        child: MouseRegion(
          onExit: (_) {
            _activePopup?.remove();
            _activePopup = null;
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacherName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          _activePopup?.remove();
                          _activePopup = null;
                        },
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    commentText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    _activePopup = entry;
    */
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Layout(
        selectedPage: 4,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (data == null) {
      return Layout(
        selectedPage: 4,
        child: Center(child: Text("Failed to load data")),
      );
    }
    final taskSummary =
        data!.taskSummary.isNotEmpty ? data!.taskSummary.first : null;
    final studentName = taskSummary != null
        ? "${taskSummary.learnerFirstName} ${taskSummary.learnerLastName}"
        : "Unknown";
    final taskTitle = taskSummary?.taskTitle ?? "Unknown Task";
    final submittedDate = taskSummary != null
        ? DateFormat("MMM d, yyyy hh:mm a")
            .format(DateTime.parse(taskSummary.submittedAt))
        : "Unknown";
    final deviation = taskSummary?.deviationPercentage ?? 0;
    final wordCount = taskSummary?.submittedWordCount ?? 0;
    final summary = data?.taskSummary.first;
    final isGradeSubmitted = (summary?.taskStatus ?? '') == 'GRADED' &&
        summary?.teacherGrade != null;
    final totalPoints = calculateTotalMaxPoints(data!.rubrics);
    // From second API
    final contentHtml =
        dataContent?.contentHtml ?? "<p>No content submitted</p>";

    final selectedClassId = summary?.classId ?? "";
    final commentsList = data?.comments is List ? data!.comments : [];

    final integrationType = summary?.integrationType;

    final learnerTaskId = summary?.learnerTaskId ?? "";
    final teacherId = summary?.teacherId ?? "";

    return Layout(
      selectedPage: 4,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium(
                          "Grading",
                          style: GoogleFonts.inter(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: contentTheme.k142228,
                          ),
                        ),
                        MyText.bodySmall(
                          "Review work and enter a final grade",
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
                        Get.dialog(
                          TeacherWritingFingerprintDialog(
                              contentTheme: contentTheme),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.w, vertical: 8.h),
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
                                  studentName,
                                  style: GoogleFonts.inter(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    color: contentTheme.black,
                                  ),
                                ),
                                2.verticalSpace,
                                MyText.bodySmall(
                                  taskTitle,
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
                                  submittedDate,
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
                            // Image.asset(Images.comment,
                            //     width: 20.w, height: 20.h),
                            // 80.horizontalSpace,
                            InkWell(
                              onTap: () async {
                                if (isGradeSubmitted) {
                                  Get.snackbar("Info",
                                      "Cannot add comment. Task already graded.");
                                  return;
                                }

                                if (selectionStart == null ||
                                    selectionEnd == null ||
                                    selectionEnd! <= selectionStart!) {
                                  Get.snackbar("Validation",
                                      "Please select at least one character in the student content.");
                                  return;
                                }
                                if (data != null &&
                                    data!.taskSummary.isNotEmpty) {
                                  await _showAddCommentDialog(
                                    learnerTaskId: learnerTaskId,
                                    teacherId: teacherId,
                                    selectionStart: selectionStart!,
                                    selectionEnd: selectionEnd!,
                                    selectedText: selectedText,
                                  );
                                }
                              },
                              child: Image.asset(
                                Images.comment,
                                width: 20.w,
                                height: 20.h,
                              ),
                            ),
                          ],
                        ),
                        25.verticalSpace,
                        // Render content with selectable HTML

                        RichSelectableHtml(
                          htmlContent: contentHtml,
                          comments: commentsList, // pass the comments
                          onSelectionChanged: updateSelection,
                          isGradeSubmitted: isGradeSubmitted,
                          gradingData: gradingData,
                          learnerTaskId: learnerTaskId,
                          onCommentsUpdated: (updatedComments) {
                            setState(() {
                              commentsList
                                ..clear()
                                ..addAll(updatedComments);
                            });
                          },
                          onTextClick: (position) {
                            if (selectionStart! > 0 &&
                                selectionEnd! > 0 &&
                                selectedText.isNotEmpty) {
                              setState(() {
                                selectionStart = 0;
                                selectionEnd = 0;
                                selectedText = "";
                              });
                            }
                          },
                          onIconClick: (webHtmlSelectedText) {
                            if (webHtmlSelectedText.isNotEmpty) {
                              setState(() {
                                selectionStart = 0;
                                selectionEnd = 0;
                                selectedText = "";
                              });
                            }
                          },
                        ),
                      ],
                    )),
                20.verticalSpace,
                Row(
                  children: [
                    MyCard(
                      padding: EdgeInsets.symmetric(
                          vertical: 25.h, horizontal: 35.w),
                      height: MySpacing.fullHeight(context) * 0.30,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      child: DefaultTabController(
                        key: const Key("TabBar"),
                        length: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 70.h, // Reduced height for TabBar
                              child: TabBar(
                                onTap: (value) =>
                                    controller.selectedTabIndex(value),
                                indicator: const BoxDecoration(
                                    color: Colors.transparent),
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
                                          context,
                                          title: "AI Chat Log",
                                          isSelected: controller
                                                  .selectedTabIndex.value ==
                                              0,
                                        )),
                                  ),
                                  Tab(
                                    child: Obx(() => tab(
                                          context,
                                          title: "Rubric",
                                          isSelected: controller
                                                  .selectedTabIndex.value ==
                                              1,
                                        )),
                                  ),
                                ],
                              ).paddingOnly(
                                  left: MySpacing.fullWidth(context) * 0.05),
                            ),
                            SizedBox(
                              height: MySpacing.fullHeight(context) * 0.16,
                              width: MySpacing.fullWidth(context) * 0.53,
                              child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  // AI Chat Log Tab
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.w, vertical: 15.h),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1,
                                            color: contentTheme.borderColor),
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xffEEECFF),
                                            Color(0xffEEECFF),
                                            Color(0x0ffdbeff),
                                          ],
                                        ),
                                      ),
                                      child: data!.aiPrompts.isEmpty
                                          ? MyText.bodySmall(
                                              "No AI chat log available.")
                                          : ListView.separated(
                                              itemCount: data!.aiPrompts.length,
                                              shrinkWrap: true,
                                              separatorBuilder:
                                                  (context, index) =>
                                                      MySpacing.height(10),
                                              itemBuilder: (context, index) {
                                                final prompt =
                                                    data!.aiPrompts[index];
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    buildAIHelperCard(
                                                      context: context,
                                                      isMe:
                                                          true, // User chat on right
                                                      text: prompt.promptText,
                                                    ),
                                                    8.verticalSpace,
                                                    buildAIHelperCard(
                                                      context: context,
                                                      isMe:
                                                          false, // AI response on left
                                                      text: prompt.aiResponse,
                                                    ),
                                                  ],
                                                );
                                              },
                                            )),

                                  // Rubric Tab
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20.w, vertical: 15.h),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: contentTheme.borderColor),
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
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
                                        children: data!.rubrics.isEmpty
                                            ? [
                                                Center(
                                                  child: MyText.bodySmall(
                                                      "No rubric data available."),
                                                )
                                              ]
                                            : rubricsGroupedByChart(
                                                data!.rubrics),
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
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      color: Colors.white,
                      width: MySpacing.fullWidth(context) * 0.14,
                      borderRadius: BorderRadius.circular(25.r),
                      child: Column(
                        children: [
                          MyText.bodyMedium(
                            "Enter Grade",
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: contentTheme.black,
                            ),
                          ),
                          TextField(
                            controller: teacherGradeController,
                            keyboardType: TextInputType.number,
                            enabled:
                                !isGradeSubmitted, // lock editing if graded
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 65.sp,
                              fontWeight: FontWeight.w500,
                              color: contentTheme.darkPurple,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "0",
                              hintStyle: GoogleFonts.inter(
                                fontSize: 65.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xffB4B4B4).withAlpha(0x44),
                              ),
                            ),
                          ),
                          Text.rich(TextSpan(children: [
                            TextSpan(
                              text: teacherGradeController.text.isEmpty
                                  ? "0"
                                  : teacherGradeController.text,
                              style: GoogleFonts.inter(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w500,
                                color: contentTheme.darkPurple,
                              ),
                            ),
                            TextSpan(
                              text: "/$totalPoints",
                              style: GoogleFonts.inter(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w500,
                                color: contentTheme.black,
                              ),
                            ),
                          ])),
                          10.verticalSpace,
                          if (!isGradeSubmitted) // Hide button once graded
                            InkWell(
                              onTap: () async {
                                final grade =
                                    teacherGradeController.text.trim();
                                if (grade.isEmpty) {
                                  Get.snackbar("Error", "Please enter a grade");
                                  return;
                                }
                                final gradeNum = int.tryParse(grade);
                                if (gradeNum == null ||
                                    gradeNum < 0 ||
                                    gradeNum > totalPoints) {
                                  Get.snackbar("Error",
                                      "Please enter a valid grade between 0 and $totalPoints");
                                  return;
                                }

                                // 🔹 Show confirm dialog
                                Get.dialog(
                                  ConfirmGradeDialog(
                                    grade: grade,
                                    totalPoints:
                                        totalPoints, // pass the dynamic totalPoints
                                    onConfirm: () async {
                                      if (gradingData is TeachersGradingModel) {
                                        final model =
                                            gradingData as TeachersGradingModel;
                                        final success =
                                            await TeacherGradingService
                                                .updateTeacherGrade(
                                          taskId: model.taskId,
                                          learnerId: model.learnerId,
                                          teacherGrade: grade,
                                        );
                                        Get.back(); // close confirm dialog first
                                        if (integrationType != null &&
                                            integrationType.toLowerCase() !=
                                                'excel') {
                                          if (success) {
                                            // 🔹 Call push_grades API
                                            final teacherId = data!.taskSummary
                                                    .first.teacherId ??
                                                "";
                                            final pushSuccess =
                                                await PushGradesService
                                                    .pushGrade(
                                              assignmentId: model.taskId,
                                              teacherId: teacherId,
                                              classId: selectedClassId,
                                              learnerId: model.learnerId,
                                              comments: "",
                                              postedGrade: grade,
                                            );

                                            StatusDialog.show(
                                              isSuccess: true,
                                              message:
                                                  "Grade has been submitted successfully.",
                                              autoCloseSeconds: 2,
                                              onClose: () {
                                                Get.toNamed("/teacher/grading");
                                              },
                                            );
                                          } else {
                                            StatusDialog.show(
                                              isSuccess: false,
                                              message:
                                                  "Failed to update grade. Please try again.",
                                              autoCloseSeconds: 2,
                                            );
                                          }
                                        } else {
                                          StatusDialog.show(
                                            isSuccess: true,
                                            message:
                                                "Grade has been submitted successfully.",
                                            autoCloseSeconds: 2,
                                            onClose: () {
                                              Get.toNamed("/teacher/grading");
                                            },
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  barrierDismissible: false,
                                );
                              },

                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30.w, vertical: 7.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xffCB6CE6),
                                      Color(0xff004AAD),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(Images.submitArrow,
                                        width: 16.w, height: 16.h),
                                    5.horizontalSpace,
                                    Text(
                                      "Submit",
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ! below code is needed
//                             child: Container(
//   padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 7.h),
//   decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(50),
//     gradient: isSubmittingGrade
//         ? const LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFCCCCCC),
//               Color(0xFF999999),
//             ],
//           )
//         : const LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xffCB6CE6),
//               Color(0xff004AAD),
//             ],
//           ),
//   ),
//   child: Row(  // ← ADD THIS
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       if (isSubmittingGrade)
//         SizedBox(
//           width: 16.w,
//           height: 16.h,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         )
//       else
//         Image.asset(Images.submitArrow, width: 16.w, height: 16.h),
//       5.horizontalSpace,
//       Text(
//         isSubmittingGrade ? "Submitting..." : "Submit",
//         style: GoogleFonts.inter(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w500,
//           color: Colors.white,
//         ),
//       ),
//     ],
//   ),
// ),
                              // ! below code is ended
                            ),
                        ],
                      ),
                    ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04)
                  ],
                )
              ],
            ).paddingSymmetric(horizontal: 5.w, vertical: 5.h),
          ).paddingOnly(bottom: 50.h);
        },
      ),
    );
  }

  List<Widget> rubricsGroupedByChart(List rubrics) {
    Map<String, List> grouped = {};

    // Group rubrics by rubricTitle
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

// Helper method to calculate total max points from entire rubric list
  int calculateTotalMaxPoints(List rubrics) {
    Map<String, List> grouped = {};

    for (var rubric in rubrics) {
      String key = rubric.rubricTitle ?? '';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(rubric);
    }

    int total = 0;
    for (var group in grouped.entries) {
      if (group.value.isNotEmpty) {
        total += (group.value[0] as dynamic).maxPoints as int;
      }
    }
    return total;
  }

  Color _hexToColor(String hex) {
    if (hex.isEmpty) return Colors.black;
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    int val = int.parse(hex, radix: 16);
    return Color(val);
  }
}

Widget buildAIHelperCard(
    {required bool isMe, required String text, required BuildContext context}) {
  final contentTheme = Theme.of(context);

  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: ConstrainedBox(
      constraints: BoxConstraints(
        // User (isMe) gets 70%, AI gets 55%
        maxWidth: MediaQuery.of(context).size.width * (isMe ? 0.70 : 0.55),
      ),
      child: Container(
        margin:
            isMe ? EdgeInsets.only(left: 10.w) : EdgeInsets.only(right: 30.w),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: contentTheme.colorScheme.surface,
          border: Border.all(width: 1, color: contentTheme.dividerColor),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          text.isNotEmpty ? text : "(No content)",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: contentTheme.colorScheme.onSurface,
          ),
        ),
      ),
    ),
  );
}

Widget tab(BuildContext context,
    {required String title, bool isSelected = false}) {
  final contentTheme = Theme.of(context);

  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 3.h), // Reduce horizontal and vertical padding
    alignment: Alignment.center, // You can use .bottomCenter if needed
    decoration: BoxDecoration(
      color: isSelected ? null : Colors.white,
      gradient: isSelected
          ? const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xffEEECFF),
                Color(0xffEEECFF),
                Color(0xffDBEBFF),
              ],
            )
          : null,
      border: Border(
        top: BorderSide(color: contentTheme.dividerColor, width: 1),
        right: BorderSide(color: contentTheme.dividerColor, width: 1),
        left: BorderSide(color: contentTheme.dividerColor, width: 1),
      ),
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r)),
    ),
    child: MyText.titleMedium(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp, // Smaller font
        fontWeight: FontWeight.w600,
        color: contentTheme.textTheme.bodyMedium?.color ?? Colors.black87,
      ),
    ),
  );
}
