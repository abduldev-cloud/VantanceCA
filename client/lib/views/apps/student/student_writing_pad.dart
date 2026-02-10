import 'dart:collection';
import 'dart:typed_data';
import 'package:binary_success/controller/apps/student/student_writing_pad_controller.dart';
import 'package:binary_success/helpers/services/auth_services.dart';
import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart'
    as app_storage;
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_responsiv.dart';
import 'package:binary_success/helpers/widgets/my_screen_media_type.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/models/submit_draft_model.dart';
import 'package:binary_success/views/apps/student/widget/student_html_widget.dart';
import 'package:binary_success/views/apps/student/widget/student_writingpad_left.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:binary_success/helpers/network/api_service.dart';
import '../../../helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/helpers/services/notification_service.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;

class StudentWritingPadPage extends StatefulWidget {
  const StudentWritingPadPage({super.key});

  @override
  StudentWritingPadPageState createState() => StudentWritingPadPageState();
}

class StudentWritingPadPageState extends State<StudentWritingPadPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late StudentWritingPadController controller;
  final HtmlEditorController _htmlEditorController = HtmlEditorController();
  final bool _draftLoaded = false; // track if draft already loaded
  String? _lastStatus;
  bool hasLoadedDraft = false; // state variable
  int wWordCount = 0;
  String lastValidHtmlContent = '';
  String previousContent = '<p></p>';
  String zoomedValue = "100%"; // Store zoom level
  bool hasClearedOnFocus = false;
  String taskID = '';
  String getLoadingMessage(String taskType, String action) {
    if (taskType == 'ASSIGNMENT') {
      if (action == 'save') return "Saving assignment...";
      if (action == 'submit') return "Submitting assignment...";
    } else {
      if (action == 'save') return "Saving fingerprint...";
      if (action == 'submit') return "Submitting fingerprint...";
    }
    return "Processing...";
  }

  @override
  void initState() {
    super.initState();
    final String task = Get.arguments as String;
    taskID = task;
    controller = Get.put(StudentWritingPadController(
      taskId: task,
    ));
  }

  int getWordCount(String htmlContent) {
    final RegExp htmlTags = RegExp(r'<[^>]+>');
    String cleanText = htmlContent.replaceAll(htmlTags, ' ');
    cleanText = cleanText.replaceAll('&nbsp;', ' ');
    List<String> words = cleanText
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    return words.length;
  }
// ! Dont remove this command

// void _restrictWordCount(String content) async {
//   // ✅ Get dynamic target word count from model
//   final taskSummaryList = controller.writingPadModel.value.taskSummary;
//   final summary = (taskSummaryList != null && taskSummaryList.isNotEmpty)
//       ? taskSummaryList.first
//       : null;

//   final int maxWordCount = summary?.targetWordCount ?? 500;

//   int wordCount = getWordCount(content);

//   if (wordCount > maxWordCount) {
//     // Restore previous content if limit crossed
//     _htmlEditorController.setText(previousContent);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Word limit of $maxWordCount reached!')),
//     );
//   } else {
//     previousContent = content;
//   }
// }

// double _calculatePercent() {
//   final taskSummaryList = controller.writingPadModel.value.taskSummary;
//   final summary = (taskSummaryList != null && taskSummaryList.isNotEmpty)
//       ? taskSummaryList.first
//       : null;

//   final targetWordCount = summary?.targetWordCount ?? 500;
//   if (targetWordCount == 0) return 0.0;

//   return (wWordCount / targetWordCount).clamp(0.0, 1.0);
// }

// ! above code is ends
  void _showSubmitConfirmationDialog() {
    // Get task type from controller
    final taskSummary = controller.writingPadModel().taskSummary?.first;
    final taskType = taskSummary?.taskType ?? 'ASSIGNMENT';

    // Determine dialog content based on task type
    String title =
        taskType == 'ASSIGNMENT' ? 'Confirm Submission' : 'Confirm Submission';
    String message = taskType == 'ASSIGNMENT'
        ? 'Are you sure you want to submit this assignment?'
        : 'Are you sure you want to submit this fingerprint?';

    showDialog(
      context: context,
      barrierDismissible: true, // allow closing when clicking outside
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => true, // allow back button to close dialog
          child: Scaffold(
            backgroundColor: Colors.black54,
            body: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 520,
                margin: EdgeInsets.only(top: 200),
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // "Confirm Assignment",
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      // "Are you sure you want to submit this assignment ?",
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () async {
                                Navigator.of(dialogContext).pop();

                                // Show loading dialog with conditional message if needed
                                if (taskType == 'ASSIGNMENT') {
                                  _showLoadingDialog(
                                      "Submitting assignment...");
                                } else {
                                  _showLoadingDialog(
                                      "Submitting fingerprint...");
                                }

                                String? getTex =
                                    await _htmlEditorController.getText();
                                if (getTex.trim().isEmpty) {
                                  Navigator.of(context)
                                      .pop(); // Close loading dialog
                                  Get.snackbar(
                                    "Error",
                                    "Please fill all fields",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  return;
                                }

                                await _submitAssignment(taskID);

                                Navigator.of(context)
                                    .pop(); // Close loading dialog after submission
                              },
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Color(0xff004AAD),
                                      Color(0xffCB6CE6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    "Confirm",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => Navigator.of(dialogContext).pop(),
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xFFD1D5DB),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
// ! final code is in above

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xffCB6CE6),
                      ),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      message,
                      style: GoogleFonts.inter(
                        color: Color(0xFF374151),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String disableCopyPasteJS = """
    document.addEventListener('contextmenu', event => event.preventDefault());
    document.addEventListener('copy', e => e.preventDefault());
    document.addEventListener('paste', e => e.preventDefault());
    document.addEventListener('cut', e => e.preventDefault());
    document.onkeydown = function (e) {
      if ((e.ctrlKey && e.key === 'c') || (e.ctrlKey && e.key === 'v') || (e.ctrlKey && e.key === 'x')) {
        e.preventDefault();
      }
    }
  """;

  String addPaddingJS = """
    document.getElementsByClassName('note-editable')[0].style.padding = '0px 16px';
  """;

  String fixParagraphMarginJS = """
    const style = document.createElement('style');
    style.innerHTML = `
      p, div {
        margin-top: 0px !important;
        margin-bottom: 4px !important;
      }
    `;
    document.head.appendChild(style);
  """;

  String customOptions = """
    document.addEventListener('paste', function(e) {
      e.preventDefault();
    });
  """;

  double _getScaleFactor(String zoomLevel) {
    switch (zoomLevel) {
      case 'Fit':
        return 1.0;
      case '50%':
        return 0.5;
      case '75%':
        return 0.75;
      case '90%':
        return 0.9;
      case '100%':
        return 1.0;
      default:
        return 1.0;
    }
  }

  Future<void> _uploadAssignment(String taskID) async {
    // Get editor content
    String? getTex = await _htmlEditorController.getText();

    if (getTex.trim().isEmpty) {
      print("Editor is empty");
      return;
    }

    final taskSummary = controller.writingPadModel().taskSummary?.first;
    if (taskSummary == null) return;

    final alfrescoSiteId = taskSummary.alfrescoSiteId ?? "null";
    final alfrescoTaskId = taskSummary.alfrescoTaskId ?? "null";
    final alfrescoLearnerId = taskSummary.alfrescoLearnerId ?? "null";

    // Always use folder path from model
    final folderPath = taskSummary.alfrescoFolderPath ?? "";

    // Convert HTML string to bytes
    Uint8List bytes = Uint8List.fromList(getTex.codeUnits);

    // Build request
    final request = DraftAssignmentAlfrescoRequest(
      siteId: alfrescoSiteId,
      folderPath: folderPath,
      alfrescoTaskId: alfrescoTaskId,
      alfrescoStudentID: alfrescoLearnerId,
      htmlBytes: bytes,
      fileName: "editor_content_$taskID.html",
    );

    // Convert to FormData
    final formData = await request.toFormData();
    final dioInstance = dio.Dio();

    try {
      final response = await dioInstance.post(
        "${API.baseURl}/alfresco/save-draft",
        data: formData,
        options: dio.Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      print("Upload success: ${response.data}");
      final fileNameFromAlfresco = response.data["file_name"];
      final learnerId = app_storage.LocalStorage.getDBEntityID() ?? '';

      final dbresponse =
          await AssignmentAlfrescoDraftService.saveLearnerTaskAsDraft(
        taskId: taskID,
        learnerId: learnerId,
        wordCount: wWordCount.toString(),
        fileName: fileNameFromAlfresco,
      );

      if (dbresponse == true) {
        Get.snackbar(
          "Success",
          "Draft saved successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to save draft in DB",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error uploading assignment: $e");
      Get.snackbar(
        "Error",
        "Failed to save draft",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitAssignment(String taskID) async {
    // Get editor content
    String? getTex = await _htmlEditorController.getText();

    if (getTex.trim().isEmpty) {
      print("Editor is empty");
      return;
    }

    final taskSummary = controller.writingPadModel().taskSummary?.first;
    if (taskSummary == null) return;

    final alfrescoSiteId = taskSummary.alfrescoSiteId ?? "null";
    final alfrescoTaskId = taskSummary.alfrescoTaskId ?? "null";
    final alfrescoLearnerId = taskSummary.alfrescoLearnerId ?? "null";
    final alfrescoTeacherId = taskSummary.alfrescoTeacherId ?? "null";
    final folderPath = taskSummary.alfrescoFolderPath ?? "";
    final taskTitle = taskSummary.taskTitle ?? "null";

    final noticeType =
        taskSummary.taskType == "ASSIGNMENT" ? "Assignments" : "Fingerprint";
    final noticeMgs = taskSummary.taskType == "ASSIGNMENT"
        ? "Assignments Submitted"
        : "Fingerprint Submitted";

    final learnerId = app_storage.LocalStorage.getDBEntityID() ?? '';

    // Convert HTML string to bytes
    Uint8List bytes = Uint8List.fromList(getTex.codeUnits);

    // Build request
    final request = DraftAssignmentAlfrescoRequest(
      siteId: alfrescoSiteId,
      folderPath: folderPath,
      alfrescoTaskId: alfrescoTaskId,
      alfrescoStudentID: alfrescoLearnerId,
      alfrescoTeacherId: alfrescoTeacherId,
      htmlBytes: bytes,
      fileName: "editor_content_$taskID.html",
    );

    final formData = await request.toFormDataSubmit();
    final dioInstance = dio.Dio();

    try {
      final response = await dioInstance.post(
        "${API.baseURl}/alfresco/submit",
        data: formData,
        options: dio.Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      print("Submit success: ${response.data}");
      final fileNameFromAlfresco = response.data["file_name"];
      final wordCount = wWordCount.toString();

      final dbResponse = await APIService.post(
        forcedBaseUrl: API.baseURl,
        path:
            "/db/writingpad/submit_learner_task/?task_id=$taskID&learner_id=$learnerId&word_count=$wordCount&file_name=$fileNameFromAlfresco",
      );

      if (dbResponse.statusCode == 200 || dbResponse.statusCode == 201) {
        // Call the deviation analysis API after successful submission
        try {
          final deviationResponse = await dioInstance.post(
            "${API.baseURl}/ai/get_student_deviation_analysis",
            data: {
              "student_id": learnerId,
              "task_id": taskID,
              "student_response": getTex,
            },
            options: dio.Options(headers: {"Content-Type": "application/json"}),
          );

          print("Deviation analysis result: ${deviationResponse.data}");
        } catch (e) {
          print("Error calling deviation analysis API: $e");
          // Don't show error to user as this is a background process
        }
        Get.snackbar(
          "Success",
          "$noticeMgs successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed('/student/assignment', arguments: {"refresh": true});
        });
      }
    } catch (e) {
      print("Error submitting assignment: $e");
      Get.snackbar(
        "Error",
        "Failed to submit assignment",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyResponsive(
      builder: (p0, p1, MyScreenMediaType type) => (type.isMobile ||
              type.isTablet)
          ? Center(
              child: MyText.labelMedium(
                "Mobile view is not supportable",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            )
          : DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: Color(0xffF3F2FF),
                body: Obx(
                  () => controller.isLoading.value
                      ? Center(child: CircularProgressIndicator())
                      : Row(
                          children: [
                            StudentWritingpadLeft(
                              controller: controller,
                              contentTheme: contentTheme,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    color: Color(0xFFE8F0FE),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Color(0xffCB6CE6),
                                                    Color(0xff004AAD),
                                                  ],
                                                ),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 5.w,
                                                vertical: 8.h,
                                              ),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Image.asset(
                                                    Images.book,
                                                    width: 24.w,
                                                    height: 24.h,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            MySpacing.width(10),
                                            Text(
                                              "Assignment Instructions",
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                          ],
                                        ).paddingOnly(top: 15.h),
                                        5.verticalSpace,
                                        MyContainer(
                                          color: Colors.white,
                                          borderColor: contentTheme.kD9D9D9,
                                          borderRadiusAll: 10,
                                          height:
                                              MySpacing.fullHeight(context) *
                                                  0.15,
                                          bordered: true,
                                          margin: EdgeInsets.only(
                                              right: 30.w, bottom: 20),
                                          padding: EdgeInsets.only(
                                            left: 40.w,
                                            right: 20,
                                            //top: 10,
                                            bottom: 5,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // FIX: Remove Expanded, add fixed height for prompt section
                                              SizedBox(
                                                height: 75
                                                    .h, // or the height you want
                                                width: double
                                                    .infinity, // Ensures scroll area fills parent width
                                                child: Scrollbar(
                                                  thickness: 6.w,
                                                  radius: Radius.circular(8.w),
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: MyText.titleMedium(
                                                      controller
                                                              .writingPadModel()
                                                              .taskSummary
                                                              ?.first
                                                              .taskPrompt ??
                                                          "",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14.sp,
                                                        color:
                                                            contentTheme.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    Images.calendar,
                                                    width: 25.w,
                                                    height: 25.h,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "Due\t",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 10.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    contentTheme
                                                                        .k142228,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: DateFormat(
                                                                      'MMMM d, y')
                                                                  .format(controller
                                                                          .writingPadModel()
                                                                          .taskSummary
                                                                          ?.first
                                                                          .dueDate ??
                                                                      DateTime
                                                                          .now()),
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 10.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    contentTheme
                                                                        .primary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "at\t",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 10.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    contentTheme
                                                                        .k142228,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "${DateFormat.jm().format(controller.writingPadModel().taskSummary?.first.dueDate ?? DateTime.now())} PST",
                                                              style: GoogleFonts
                                                                  .inter(
                                                                fontSize: 10.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color:
                                                                    contentTheme
                                                                        .primary,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  30.horizontalSpace,
                                                  // Countdown + clock icon section
                                                  Obx(() {
                                                    final summary = controller
                                                        .writingPadModel()
                                                        .taskSummary
                                                        ?.first;
                                                    final taskStatus =
                                                        summary?.taskStatus ??
                                                            '';
                                                    final teacherGrade =
                                                        summary?.teacherGrade ??
                                                            0;

                                                    // Compute totalPoints here inside Obx to keep scope valid
                                                    final totalPoints = controller
                                                            .writingPadModel()
                                                            .rubrics
                                                            ?.fold(
                                                              0,
                                                              (sum, r) =>
                                                                  sum +
                                                                  (r.maxPoints ??
                                                                      0),
                                                            ) ??
                                                        0;

                                                    final showCountdown = controller
                                                                .countdownText
                                                                .value !=
                                                            "Past due date" &&
                                                        !(taskStatus ==
                                                                'SUBMITTED' ||
                                                            (taskStatus ==
                                                                    'GRADED' &&
                                                                teacherGrade !=
                                                                    0));

                                                    if (!showCountdown) {
                                                      return SizedBox.shrink();
                                                    }

                                                    return Row(
                                                      children: [
                                                        Image.asset(
                                                          Images.clock,
                                                          width: 25.w,
                                                          height: 25.h,
                                                        ),
                                                        MySpacing.width(5),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text: controller
                                                                    .countdownText
                                                                    .value,
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: contentTheme
                                                                      .primary,
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    " to finish",
                                                                style:
                                                                    GoogleFonts
                                                                        .inter(
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: contentTheme
                                                                      .k142228,
                                                                ),
                                                              ),
                                                              if (taskStatus ==
                                                                  'GRADED')
                                                                TextSpan(
                                                                  text:
                                                                      "  $teacherGrade/$totalPoints",
                                                                  style:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontSize:
                                                                        12.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: contentTheme
                                                                        .primary,
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                  30.horizontalSpace,
                                                  Image.asset(
                                                    Images.dashboardIcon,
                                                    width: 25.w,
                                                    height: 25.h,
                                                  ),
                                                  MySpacing.width(5),
                                                  Text.rich(
                                                    TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "Target:\t",
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: contentTheme
                                                                .primary,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              "${controller.writingPadModel().taskSummary?.first.targetWordCount ?? 0} words",
                                                          style:
                                                              GoogleFonts.inter(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: contentTheme
                                                                .k142228,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Builder(
                                                    builder: (context) {
                                                      final summary = controller
                                                          .writingPadModel()
                                                          .taskSummary
                                                          ?.first;
                                                      // Compute totalPoints again here separately for Builder scope
                                                      final totalPoints = controller
                                                              .writingPadModel()
                                                              .taskSummary
                                                              ?.first
                                                              .totalPoints ??
                                                          0;
                                                      if ((summary?.taskStatus ??
                                                                  '') ==
                                                              'GRADED' &&
                                                          summary?.teacherGrade !=
                                                              null) {
                                                        return Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            SizedBox(
                                                                width: 16.w),
                                                            Image.asset(
                                                              Images.gradeLms,
                                                              width: 25.w,
                                                              height: 25.h,
                                                            ),
                                                            MySpacing.width(5),
                                                            Text.rich(
                                                              TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                    text:
                                                                        "Grade:\t",
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          10.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: contentTheme
                                                                          .primary,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text:
                                                                        "${summary?.teacherGrade ?? 0}/$totalPoints",
                                                                    style: GoogleFonts
                                                                        .inter(
                                                                      fontSize:
                                                                          10.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: contentTheme
                                                                          .k142228,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      return SizedBox.shrink();
                                                    },
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ).paddingOnly(left: 20.w),
                                  ),
                                  25.verticalSpace,
                                  StudentHtmlWidget(
                                    contentTheme: contentTheme,
                                    htmlEditorController: _htmlEditorController,
                                    onZoomChanged: (value) {
                                      setState(() {
                                        zoomedValue = value;
                                      });
                                    },
                                  ),
                                  15.verticalSpace,
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width:
                                          MySpacing.fullWidth(context) * 0.26,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Builder(
                                            builder: (context) {
                                              final taskSummaryList = controller
                                                  .writingPadModel
                                                  .value
                                                  .taskSummary;
                                              final summary =
                                                  (taskSummaryList != null &&
                                                          taskSummaryList
                                                              .isNotEmpty)
                                                      ? taskSummaryList.first
                                                      : null;

                                              final status =
                                                  summary?.taskStatus ?? '';
                                              final minWordCount =
                                                  0; // Make this dynamic if needed
                                              final targetWordCount =
                                                  summary?.targetWordCount ??
                                                      500;

                                              // Show submitted/graded word count if not editing, else show live word count
                                              final bool isReadOnly =
                                                  status == 'SUBMITTED' ||
                                                      status == 'GRADED';

                                              final int displayWordCount = isReadOnly
                                                  ? (summary
                                                          ?.submittedWordCount ??
                                                      0)
                                                  : wWordCount; // includes DRAFT and ASSIGNED live counts

                                              // ✅ Allow typing beyond target by removing cap
                                              final cappedWordCount =
                                                  displayWordCount;

                                              // Clamp the percent value to [0.0, 1.0]
                                              final percent =
                                                  targetWordCount > 0
                                                      ? (cappedWordCount /
                                                              targetWordCount)
                                                          .clamp(0.0, 1.0)
                                                      : 0.0;

                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Align(
                                                    child: Text(
                                                      "$displayWordCount Words",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: contentTheme
                                                            .k142228,
                                                      ),
                                                    ),
                                                  ),
                                                  MySpacing.height(5),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        "$minWordCount",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: contentTheme
                                                              .k142228,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            MySpacing.fullWidth(
                                                                    context) *
                                                                0.23,
                                                        child:
                                                            LinearPercentIndicator(
                                                          progressColor:
                                                              contentTheme
                                                                  .darkPurple,
                                                          barRadius:
                                                              Radius.circular(
                                                                  20.r),
                                                          percent:
                                                              percent, // always in [0.0, 1.0]
                                                          lineHeight: 8.h,
                                                          isRTL: false,
                                                        ),
                                                      ),
                                                      Text(
                                                        "$targetWordCount",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: contentTheme
                                                              .k142228,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ).paddingOnly(right: 60.w),
                                  ),

                                  20.verticalSpace,

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Left section: Pencil + Task title
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Icon container
                                            Container(
                                              width: 32.w,
                                              height: 32.w,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.r),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Color(0xffCB6CE6),
                                                    Color(0xff004AAD),
                                                  ],
                                                ),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  Images.pencil,
                                                  width: 18.w,
                                                  height: 18.w,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            // Title text
                                            Obx(() => Text(
                                                  controller
                                                          .writingPadModel()
                                                          .taskSummary
                                                          ?.first
                                                          .taskTitle ??
                                                      "",
                                                  style: GoogleFonts.inter(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: contentTheme.k142228,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),

                                      // SAVED TIME INDICATOR (left of Save Draft button)
                                      Obx(() {
                                        final draftupdatedAt = controller
                                            .writingPadModel()
                                            .taskSummary
                                            ?.first
                                            .draftUpdatedAt;
                                        if (draftupdatedAt != null) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 20.0),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  Images
                                                      .checkMark, // Replace with Asset if needed
                                                  color: Colors.black,
                                                  width: 20.w,
                                                  height: 20,
                                                ),
                                                SizedBox(width: 6),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Saved ",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: timeago.format(
                                                            draftupdatedAt),
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color(
                                                              0xffCB6CE6), // Your purple color
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return SizedBox.shrink();
                                        }
                                      }),

                                      // Save Draft button
                                      if (wWordCount > 0)
                                        Align(
                                          child: InkWell(
                                            onTap: () async {
                                              String? getTex =
                                                  await _htmlEditorController
                                                      .getText();
                                              if (getTex.isEmpty) {
                                                Get.snackbar("Error",
                                                    "Please fill all fields",
                                                    backgroundColor: Colors.red,
                                                    colorText: Colors.white);
                                                return;
                                              }
// Example - get taskType from your model or controller
                                              String taskType = controller
                                                      .writingPadModel
                                                      .value
                                                      .taskSummary
                                                      ?.first
                                                      .taskType ??
                                                  '';

                                              if (taskType == 'ASSIGNMENT') {
                                                _showLoadingDialog(
                                                    "Saving assignment...");
                                              } else {
                                                _showLoadingDialog(
                                                    "Saving fingerprint...");
                                              }

                                              await _uploadAssignment(taskID);

                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 7),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.save,
                                                    color: contentTheme.kFEFDFF,
                                                    size: 16.sp,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Save Draft",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          contentTheme.kFEFDFF,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                      MySpacing.width(12),

                                      if (wWordCount > 0)
                                        Align(
                                          child: InkWell(
                                            onTap: () {
                                              _showSubmitConfirmationDialog(); // Show confirmation dialog instead of direct submission
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 7),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.play_arrow,
                                                    color: contentTheme.kFEFDFF,
                                                    size: 16.sp,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "Submit",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          contentTheme.kFEFDFF,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                      MySpacing.width(12),
                                    ],
                                  ).paddingSymmetric(horizontal: 20.w),

                                  5.verticalSpace,
                                  Expanded(
                                    child: Transform.scale(
                                      scale: _getScaleFactor(zoomedValue),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: 30.w,
                                            left: 30,
                                            bottom: 35.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 33.w, vertical: 15.h),
                                        child: Obx(() {
                                          final status = controller
                                                  .writingPadModel
                                                  .value
                                                  .taskSummary
                                                  ?.first
                                                  .taskStatus ??
                                              '';
                                          final showReadOnlyHtml =
                                              status == 'SUBMITTED' ||
                                                  status == 'GRADED';

                                          if (showReadOnlyHtml) {
                                            final htmlContent = controller
                                                .learnerHtmlContent.value;
                                            return SingleChildScrollView(
                                              child: SizedBox(
                                                // Enforce fixed height so editor does not shrink when content empty
                                                height: MySpacing.fullHeight(
                                                        context) *
                                                    0.50,
                                                child: htmlContent.isNotEmpty
                                                    ? Html(data: htmlContent)
                                                    : Container(
                                                        color: Colors.white,
                                                        child: Center(
                                                          child: Text(
                                                            "No response loaded.",
                                                            style: GoogleFonts
                                                                .inter(
                                                              fontSize: 16.sp,
                                                              color: Color(
                                                                  0xFF6B7280),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            );
                                          } else {
                                            return GestureDetector(
                                              onTap: () {
                                                // Force regain focus when tapped
                                                FocusScope.of(context)
                                                    .unfocus();
                                                // _htmlEditorController
                                                //     .editorController
                                                //     ?.requestFocus();
                                              },
                                              child: HtmlEditor(
                                                controller:
                                                    _htmlEditorController,
                                                htmlEditorOptions:
                                                    HtmlEditorOptions(
                                                  autoAdjustHeight: false,
                                                  hint: "Enter...",
                                                ),
                                                otherOptions: OtherOptions(
                                                  height: MySpacing.fullHeight(
                                                          context) *
                                                      0.50,
                                                ),
                                                htmlToolbarOptions:
                                                    HtmlToolbarOptions(
                                                  defaultToolbarButtons: [],
                                                  dropdownElevation: 0,
                                                  dropdownIconSize: 0,
                                                  gridViewHorizontalSpacing: 0,
                                                  dropdownItemHeight: 0,
                                                  toolbarItemHeight: 0,
                                                  gridViewVerticalSpacing: 0,
                                                ),
                                                callbacks: Callbacks(
                                                  onInit: () async {
                                                    if (controller
                                                        .learnerHtmlContent
                                                        .value
                                                        .isNotEmpty) {
                                                      _htmlEditorController
                                                          .setText(controller
                                                              .learnerHtmlContent
                                                              .value);
                                                    }
                                                  },
                                                  onFocus: () {
                                                    FocusScope.of(context)
                                                        .unfocus(); // release any other TextField
                                                    if (!hasClearedOnFocus) {
                                                      _htmlEditorController
                                                          .getText()
                                                          .then((currentText) {
                                                        if (currentText
                                                                .trim()
                                                                .isEmpty ||
                                                            currentText
                                                                    .trim() ==
                                                                '<p><br></p>' ||
                                                            currentText
                                                                    .trim() ==
                                                                '<p></p>') {
                                                          _htmlEditorController
                                                              .setText('');
                                                        }
                                                      });
                                                      hasClearedOnFocus = true;
                                                    }
                                                  },
                                                  onBlur: () {
                                                    hasClearedOnFocus = false;
                                                  },
                                                  onChangeContent:
                                                      (String? changed) {
                                                    setState(() {
                                                      wWordCount = getWordCount(
                                                          changed ?? '');
                                                      //_restrictWordCount(changed ?? ''); //! Don't erase this line
                                                    });
                                                    controller
                                                        .currentWritingContent
                                                        .value = changed ?? '';
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }),
                                      ),
                                    ),
                                  ),

                                  // ---- End HtmlEditor section ----
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
    );
  }
}
