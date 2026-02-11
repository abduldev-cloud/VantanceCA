import 'package:vantanceCA/helpers/services/notification_service.dart';
import 'package:vantanceCA/helpers/services/teacher_service.dart';
import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/models/create_task_model.dart';
import 'package:vantanceCA/widgets/comman_dialog_texfield.dart';
import 'package:vantanceCA/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/widgets/common_dialog_numberfield.dart';
import 'package:flutter/services.dart';

class TeacherWritingFingerprintDialogTwo extends StatefulWidget {
  final ContentTheme contentTheme;
  final String dueDate;
  final String classId;
  final String instituteId;
  final String alfresco_site_id;
  final String alfresco_user_id;
  final String alfresco_class_id;
  final String GradeId;

  const TeacherWritingFingerprintDialogTwo({
    super.key,
    required this.contentTheme,
    required this.dueDate,
    required this.classId,
    required this.instituteId,
    required this.alfresco_site_id,
    required this.alfresco_user_id,
    required this.alfresco_class_id,
    required this.GradeId,
  });

  @override
  State<TeacherWritingFingerprintDialogTwo> createState() =>
      _TeacherWritingFingerprintDialogTwoState();
}

class _TeacherWritingFingerprintDialogTwoState
    extends State<TeacherWritingFingerprintDialogTwo> {
  final TextEditingController titleController = TextEditingController();
  // final DateTimePickerController dateTimeController = Get.put(DateTimePickerController());
  final TextEditingController targetWordCountController =
      TextEditingController();
  final TextEditingController promptController = TextEditingController();
  bool isLoading = false;

  Future<void> createTask() async {
    // Validate first
    if (titleController.text.isEmpty ||
        targetWordCountController.text.isEmpty ||
        promptController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => isLoading = true);

    final localTeacherId = LocalStorage.getDBEntityID() ?? "";
    final createdBy = LocalStorage.getDBUserID() ?? localTeacherId;
    final folderPath = "${widget.GradeId}/Fingerprint";

    try {
      final request = CreateTaskRequest(
        instituteId: widget.instituteId,
        classId: widget.classId,
        teacherId: localTeacherId,
        taskTypeId: "FINGERPRINT",
        title: titleController.text,
        prompt: promptController.text,
        dueDate: widget.dueDate,
        targetWordCount: int.tryParse(targetWordCountController.text) ?? 500,
        createdBy: createdBy,
      );

      final response = await TeacherService.createTaskAPI(request);

      if (response != null) {
        final taskId = response.taskId;

        final alfrescoRequest = CreateTaskAlfrescoRequest(
          siteId: widget.alfresco_site_id,
          alfrescoClassId: widget.alfresco_class_id,
          alfrescoUserId: widget.alfresco_user_id,
          workflowDefinition: "activitiAdhoc",
          folderPath: folderPath,
          title: titleController.text,
          description: promptController.text,
          dueDate: widget.dueDate,
          taskID: taskId ?? "",
        );

        final alfrescoResponse =
            await TeacherService.createTaskAlfrescoAPI(alfrescoRequest);
        print("alfresco_response");
        print(alfrescoResponse);

        if (alfrescoResponse != null) {
          print("alfresco_response is not null");
        }

        // ✅ Close the dialog FIRST
        if (mounted) {
          setState(() => isLoading = false);
        }
        Navigator.of(context).pop(); // Close the current dialog

        // ✅ Show success snackbar
        Get.snackbar(
          "Success",
          "Writing Fingerprint scheduled successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // ✅ Navigate to detail page
        Get.toNamed("/teacher/fingerprintdetail", arguments: {
          "taskId": taskId,
        });

        // Send notification (async, doesn't block UI)
        NotificationService.sendNotificationAllLeaners(
                classId: widget.classId,
                teacherId: localTeacherId,
                type: "Fingerprint")
            .then((fingerprintNotificationResponse) {
          if (fingerprintNotificationResponse != null) {
            print("FingerprintNotificationresponse");
            print(fingerprintNotificationResponse);
          } else {
            print("FingerprintNotificationresponse is null");
          }
        });
      } else {
        // ✅ Task creation failed
        if (mounted) {
          setState(() => isLoading = false);
        }

        Get.snackbar(
          "Failed",
          "Writing Fingerprint scheduling failed. Please try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        print("task creation failed");
      }
    } catch (e) {
      // ✅ Handle errors properly
      if (mounted) {
        setState(() => isLoading = false);
      }

      Get.snackbar(
        'Error',
        "Failed to create task: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
      print("Error creating task: $e");
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    targetWordCountController.dispose();
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
      backgroundColor: widget.contentTheme.kFEFDFF,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      content: SizedBox(
        width: MySpacing.fullWidth(context) * 0.35,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Spacer(),
                Column(
                  children: [
                    Text(
                      "Schedule Writing Fingerprint",
                      style: GoogleFonts.inter(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w600,
                        color: widget.contentTheme.k1C244B,
                      ),
                    ),
                    MyText.bodySmall(
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: widget.contentTheme.k172640,
                      ),
                      "A simpler prompt leads to a more accurate fingerprint",
                    ),
                  ],
                ),
                Spacer(),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close))
              ],
            ),
            30.verticalSpace,
            CommonDialogTextfield(
                title: "Title",
                controller: titleController,
                inputFormatters: [LengthLimitingTextInputFormatter(100)]),
            15.verticalSpace,
            CommonDialogNumberfield(
                title: "Target Word #", controller: targetWordCountController),
            15.verticalSpace,
            TextInputFields(
                controller: promptController,
                maxLine: 4,
                inputFormatters: [LengthLimitingTextInputFormatter(1000)])
          ],
        ),
      ),
      actions: [
        Align(
          child: InkWell(
            onTap: isLoading ? null : createTask,
            child: Container(
              margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
              padding: EdgeInsets.symmetric(horizontal: 45.w, vertical: 10.h),
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
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "Schedule",
                      style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.contentTheme.kFEFDFF),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
