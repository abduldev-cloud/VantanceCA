import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/widgets/comman_dialog_dropdown.dart';
import 'package:binary_success/widgets/comman_dialog_texfield.dart';
import 'package:binary_success/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/controller/widgets/date_time_picker_controller.dart';
import 'package:binary_success/widgets/custom_time_picker_field.dart';
import 'package:binary_success/widgets/custom_date_picker_field.dart';
import 'package:binary_success/services/assignment_service.dart';
import 'package:binary_success/models/assignment_request.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:intl/intl.dart';
import 'package:binary_success/helpers/services/teacher_service.dart';
import 'package:binary_success/widgets/common_dialog_numberfield.dart';
import 'package:binary_success/widgets/common_status_dialog.dart';
import 'package:binary_success/helpers/services/notification_service.dart';
import 'package:flutter/services.dart';

// ---------- Data model for rubric ----------
class RubricData {
  String criteria;
  String maxPoints;
  String strong;
  String medium;
  String weak;

  RubricData({
    required this.criteria,
    required this.maxPoints,
    required this.strong,
    required this.medium,
    required this.weak,
  });
}

class TeacherCreateAssignmentDiaog extends StatefulWidget {
  final ContentTheme contentTheme;
  const TeacherCreateAssignmentDiaog({super.key, required this.contentTheme});

  @override
  State<TeacherCreateAssignmentDiaog> createState() =>
      _TeacherCreateAssignmentDiaogState();
}

class _TeacherCreateAssignmentDiaogState
    extends State<TeacherCreateAssignmentDiaog> {
  final TextEditingController rubricCountController =
      TextEditingController(text: "1");
  final TextEditingController titleController = TextEditingController();
  final TextEditingController promptController = TextEditingController();
  final TextEditingController wordCountController = TextEditingController();
  final DateTimePickerController dateTimeController = Get.put(
    DateTimePickerController(),
    permanent: true,
  );

  final List<RubricData> rubricList = [];

  // --- Data structures for class/grade ---
  Map<String, List<String>> _gradesByClass = {};
  Map<String, Map<String, String>> _classIdByClassGrade = {};
  Map<String, String> _firstClassIdByClass = {};
  final Map<String, String?> _alfrescoClassIdByClassId = {};

  List<String> classOptions = [];
  List<String> gradeOptions = [];

  String? selectedClass;
  String? selectedGrade;
  String? selectedClassId;
  String? instituteId;
  String? alfresco_user_id;
  String? alfresco_site_id;
  String? selectedAlfrescoClassId;

  bool isLoadingClasses = false;

  @override
  void initState() {
    super.initState();
    fetchAllClasses();
  }

  String? _resolveClassId(String? className, String? gradeName) {
    if (className == null || className.isEmpty) return null;
    final byGrade = _classIdByClassGrade[className];
    if (gradeName != null && gradeName.isNotEmpty && byGrade != null) {
      final id = byGrade[gradeName];
      if (id != null && id.isNotEmpty) {
        // ✅ set alfresco_class_id whenever classId is chosen
        selectedAlfrescoClassId = _alfrescoClassIdByClassId[id];
        return id;
      }
    }
    final fallback = _firstClassIdByClass[className];
    selectedAlfrescoClassId =
        fallback != null ? _alfrescoClassIdByClassId[fallback] : null;
    print(fallback);
    return fallback;
  }

  Future<void> fetchAllClasses() async {
    setState(() => isLoadingClasses = true);
    final localTeacherId = LocalStorage.getDBEntityID() ?? "";

    try {
      final response = await TeacherService.getTeacherSFClassAPI(
        teacherId: localTeacherId,
        classStatus: "Active",
      );

      if (response != null && response.outStatus == "SUCCESS") {
        final Map<String, Set<String>> tempGradesByClass = {};
        final Map<String, Map<String, String>> tempIdByClassGrade = {};
        final Map<String, String> tempFirstIdByClass = {};

        instituteId = response.teacherSummary.first.institute_id ?? '';
        alfresco_user_id = response.teacherSummary.first.alfresco_user_id ?? '';
        alfresco_site_id = response.teacherSummary.first.alfresco_site_id ?? '';

        for (final c in response.classDetails ?? []) {
          final className = (c.className ?? '').toString();
          if (className.isEmpty) continue;

          final gradeName = c.gradeName?.toString();
          final classId = (c.classId ?? '').toString();

          // ✅ Safe access to alfresco_class_id
          String? alfrescoClassId;
          try {
            alfrescoClassId = (c as dynamic).alfresco_class_id?.toString();
          } catch (e) {
            alfrescoClassId = null; // fallback if property doesn’t exist
          }

          // Debug log
          debugPrint(
            "CLASS: $className | GRADE: $gradeName | classId=$classId | alfresco_class_id=$alfrescoClassId",
          );

          tempGradesByClass.putIfAbsent(className, () => <String>{});

          if (gradeName != null && gradeName.isNotEmpty) {
            tempGradesByClass[className]!.add(gradeName);
            tempIdByClassGrade.putIfAbsent(className, () => {});
            tempIdByClassGrade[className]![gradeName] = classId;
          }

          tempFirstIdByClass.putIfAbsent(className, () => classId);

          // ✅ store alfresco_class_id (even null safely)
          _alfrescoClassIdByClassId[classId] = alfrescoClassId;
        }

        // Convert sets to sorted lists
        final Map<String, List<String>> finalGradesByClass = {};
        for (final entry in tempGradesByClass.entries) {
          final list = entry.value.toList()..sort();
          finalGradesByClass[entry.key] = list;
        }

        final List<String> finalClassOptions = finalGradesByClass.keys.toList()
          ..sort();

        setState(() {
          _gradesByClass = finalGradesByClass;
          _classIdByClassGrade = tempIdByClassGrade;
          _firstClassIdByClass = tempFirstIdByClass;

          classOptions = finalClassOptions;

          // Initialize selections
          selectedClass = classOptions.isNotEmpty ? classOptions.first : null;
          gradeOptions = selectedClass != null
              ? (_gradesByClass[selectedClass!] ?? [])
              : [];
          selectedGrade = gradeOptions.isNotEmpty ? gradeOptions.first : null;
          selectedClassId = _resolveClassId(selectedClass, selectedGrade);
        });
      }
    } catch (e, st) {
      debugPrint("Error fetching classes: $e\n$st");
    } finally {
      setState(() => isLoadingClasses = false);
    }
  }

  void onClassChanged(String? className) {
    if (className == null || className.isEmpty) return;
    setState(() {
      selectedClass = className;
      gradeOptions = _gradesByClass[className] ?? [];
      selectedGrade = gradeOptions.isNotEmpty ? gradeOptions.first : null;
      selectedClassId = _resolveClassId(selectedClass, selectedGrade);
    });
  }

  void onGradeChanged(String? grade) {
    if (grade == null || grade.isEmpty) return;
    setState(() {
      selectedGrade = grade;
      selectedClassId = _resolveClassId(selectedClass, selectedGrade);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
      backgroundColor: widget.contentTheme.kFEFDFF,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      content: SizedBox(
        width: screenWidth * 0.35,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(context, "Create Assignment",
                  "Complete the fields to set up your assignment"),
              30.verticalSpace,
              CommonDialogTextfield(
                title: "Title",
                controller: titleController,
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
              ),
              15.verticalSpace,
              CommonDialogNumberfield(
                title: "Target Words",
                controller: wordCountController,
              ),
              15.verticalSpace,
              CommonDialogDropdown(
                hintText: "Select Number of Rubrics",
                itemList: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
                selectedValue: "1",
                contentTheme: widget.contentTheme,
                title: "Number of Rubric",
                onChanged: (value) {
                  rubricCountController.text = value ?? "1";
                },
              ),
              15.verticalSpace,
              // --- Date & Time ---
              CommonDatePicker(
                contentTheme: widget.contentTheme,
                title: "Date",
                controller: dateTimeController,
                onChanged: (date) =>
                    dateTimeController.updateSelectedDate(date ?? ''),
              ),
              15.verticalSpace,
              CommonTimePicker(
                contentTheme: widget.contentTheme,
                title: "Due by",
                controller: dateTimeController,
                onChanged: (time) =>
                    dateTimeController.updateSelectedTime(time ?? ''),
              ),
              15.verticalSpace,
              // --- Class Dropdown ---
              if (isLoadingClasses)
                const Center(child: CircularProgressIndicator())
              else if (classOptions.isNotEmpty)
                CommonDialogDropdown(
                  itemList: classOptions,
                  selectedValue: selectedClass ?? classOptions.first,
                  contentTheme: widget.contentTheme,
                  title: "Class",
                  onChanged: (value) => onClassChanged(value),
                )
              else
                MyText.bodySmall("No classes found"),
              15.verticalSpace,
              // --- Grade Dropdown ---
              if (!isLoadingClasses && gradeOptions.isNotEmpty)
                CommonDialogDropdown(
                  itemList: gradeOptions,
                  selectedValue: selectedGrade ?? gradeOptions.first,
                  contentTheme: widget.contentTheme,
                  title: "Grade",
                  onChanged: (value) => onGradeChanged(value),
                ),
              15.verticalSpace,
              TextInputFields(
                maxLine: 5,
                hintText: "Details",
                controller: promptController,
                inputFormatters: [LengthLimitingTextInputFormatter(1000)],
              ),
              20.verticalSpace,
              Center(
                child: InkWell(
                  onTap: () {
                    if (titleController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter a title",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (wordCountController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter target words",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (rubricCountController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please select number of rubrics",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (dateTimeController.selectedDate.value.isEmpty) {
                      Get.snackbar("Error", "Please select a date",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (dateTimeController.selectedTime.value.isEmpty) {
                      Get.snackbar("Error", "Please select a time",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (selectedClassId == null || selectedClassId!.isEmpty) {
                      Get.snackbar("Error", "Please select a class and grade",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (promptController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter assignment details",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    Get.back(); // close Create Assignment
                    int count = int.tryParse(rubricCountController.text) ?? 1;
                    _openRubricDialogs(context, count, screenWidth);
                  },
                  child: _gradientButton("Next"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

// ---------- Header ----------
  Widget _header(BuildContext context, String title, String subtitle) {
    return Stack(
      children: [
        Center(
          child: Column(
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.contentTheme.k1C244B)),
              SizedBox(height: 6.h),
              MyText.bodySmall(
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: widget.contentTheme.k172640,
                ),
                subtitle,
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: InkWell(
            onTap: () => Get.back(result: null), // return null → stop loop
            child:
                Icon(Icons.close, size: 24, color: widget.contentTheme.k172640),
          ),
        ),
      ],
    );
  }

// ---------- Sequential rubric dialogs ----------
  void _openRubricDialogs(
      BuildContext context, int rubricCount, double screenWidth) async {
    rubricList.clear();

    for (int i = 1; i <= rubricCount; i++) {
      RubricData? rubric = await Get.dialog<RubricData>(
        _rubricDialog(context, i, rubricCount, screenWidth),
        barrierDismissible: false,
      );

      if (rubric == null) {
        return;
      }

      rubricList.add(rubric);
    }

    // After all rubrics → final dialog
    Get.dialog(_finalDialog(context, screenWidth), barrierDismissible: false);
  }

// ---------- Single rubric dialog ----------
  Widget _rubricDialog(
      BuildContext context, int index, int total, double screenWidth) {
    final rubricController = TextEditingController();
    final maxPointsController = TextEditingController();
    final strongController = TextEditingController();
    final mediumController = TextEditingController();
    final weakController = TextEditingController();

    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
      backgroundColor: widget.contentTheme.kFEFDFF,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      content: SizedBox(
        width: screenWidth * 0.35,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _header(
                  context, "Rubric $index of $total", "Enter rubric details"),
              30.verticalSpace,
              CommonDialogTextfield(
                  title: "Rubric Criteria",
                  controller: rubricController,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)]),
              15.verticalSpace,
              CommonDialogNumberfield(
                  title: "Max Points", controller: maxPointsController),
              15.verticalSpace,
              CommonDialogTextfield(
                  title: "Strong",
                  controller: strongController,
                  inputFormatters: [LengthLimitingTextInputFormatter(250)]),
              15.verticalSpace,
              CommonDialogTextfield(
                  title: "Medium",
                  controller: mediumController,
                  inputFormatters: [LengthLimitingTextInputFormatter(250)]),
              15.verticalSpace,
              CommonDialogTextfield(
                  title: "Weak",
                  controller: weakController,
                  inputFormatters: [LengthLimitingTextInputFormatter(250)]),
              20.verticalSpace,
              Center(
                child: InkWell(
                  onTap: () {
                    if (rubricController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter rubric criteria",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    final maxPoints = maxPointsController.text.trim();

                    if (maxPoints.isEmpty) {
                      Get.snackbar("Error", "Please enter max points",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    final points = int.tryParse(maxPoints);

                    if (points == null || points < 1 || points > 10) {
                      Get.snackbar(
                          "Error", "Max points must be between 1 and 10",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    if (strongController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter strong description",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (mediumController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter medium description",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    if (weakController.text.trim().isEmpty) {
                      Get.snackbar("Error", "Please enter weak description",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }

                    Get.back(
                      result: RubricData(
                        criteria: rubricController.text.trim(),
                        maxPoints: maxPointsController.text.trim(),
                        strong: strongController.text.trim(),
                        medium: mediumController.text.trim(),
                        weak: weakController.text.trim(),
                      ),
                    );
                  },
                  child: _gradientButton("Next"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _finalDialog(BuildContext context, double screenWidth) {
    final strongThesisController = TextEditingController();
    final whyStrongController = TextEditingController();
    final weakThesisController = TextEditingController();
    final whyWeakController = TextEditingController();

    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
      backgroundColor: widget.contentTheme.kFEFDFF,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
      content: SizedBox(
        width: screenWidth * 0.35,
        child: Scrollbar(
          radius: Radius.circular(10),
          thickness: 6,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(right: 12.0), // Padding to prevent overlap
            child: Column(
              children: [
                _header(context, "Create Example",
                    "Enter your Example for this assignment"),
                30.verticalSpace,
                CommonDialogTextfield(
                  title: "Strong Thesis",
                  controller: strongThesisController,
                  maxLines: 3,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
                15.verticalSpace,
                CommonDialogTextfield(
                  title: "Why It's Strong",
                  controller: whyStrongController,
                  maxLines: 5,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
                15.verticalSpace,
                CommonDialogTextfield(
                  title: "Weak Thesis",
                  controller: weakThesisController,
                  maxLines: 3,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
                15.verticalSpace,
                CommonDialogTextfield(
                  title: "Why It's Weak",
                  controller: whyWeakController,
                  maxLines: 5,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
                20.verticalSpace,
                Center(
                  child: InkWell(
                    onTap: () async {
                      if (strongThesisController.text.trim().isEmpty) {
                        Get.snackbar("Error", "Please enter strong thesis",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
                      if (whyStrongController.text.trim().isEmpty) {
                        Get.snackbar(
                            "Error", "Please enter why it is strong thesis",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
                      if (weakThesisController.text.trim().isEmpty) {
                        Get.snackbar("Error", "Please enter weak thesis",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
                      if (whyWeakController.text.trim().isEmpty) {
                        Get.snackbar(
                            "Error", "Please enter why it is weak thesis",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }

                      await _createAssignment(
                        context,
                        strongThesis: strongThesisController.text.trim(),
                        whyStrong: whyStrongController.text.trim(),
                        weakThesis: weakThesisController.text.trim(),
                        whyWeak: whyWeakController.text.trim(),
                      );
                      Get.back(closeOverlays: true);
                    },
                    child: _gradientButton("Create"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Create Assignment API Call ----------
  Future<void> _createAssignment(
    BuildContext context, {
    required String strongThesis,
    required String whyStrong,
    required String weakThesis,
    required String whyWeak,
  }) async {
    try {
      Get.dialog(
        Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.blue,
            size: 50,
          ),
        ),
        barrierDismissible: false,
      );

      final DateTimePickerController dateTimeController =
          Get.find<DateTimePickerController>();

      final dateFormat = DateFormat('MMM dd, yyyy');
      final date = dateFormat.parse(dateTimeController.selectedDate.value);

      final timeFormat = DateFormat('hh:mm a');
      final time = timeFormat.parse(dateTimeController.selectedTime.value);

      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      String dueDate = dateTime.toIso8601String();

      List<Rubric> rubrics = [];
      for (var rubricData in rubricList) {
        rubrics.add(Rubric(
          rubricTitle: rubricData.criteria,
          maxPoints: int.tryParse(rubricData.maxPoints) ?? 4,
          criteria: [
            Criterion(
              criterionTypeId: "STRONG",
              criteriaDesc: rubricData.strong,
            ),
            Criterion(
              criterionTypeId: "MEDIUM",
              criteriaDesc: rubricData.medium,
            ),
            Criterion(
              criterionTypeId: "WEAK",
              criteriaDesc: rubricData.weak,
            ),
          ],
        ));
      }

      // Build examples list from parameters
      List<Example> examples = [
        Example(
          criterionType: "STRONG",
          exampleThesis: strongThesis,
          exampleReason: whyStrong,
        ),
        Example(
          criterionType: "WEAK",
          exampleThesis: weakThesis,
          exampleReason: whyWeak,
        ),
      ];

      final entityId = LocalStorage.getDBEntityID() ?? '';
      final createdBy = LocalStorage.getDBUserID() ?? entityId;
      final folderPath = "$selectedGrade/Assignmnet";
      final assignmentService = AssignmentService();

      final assignmentRequest = AssignmentRequest(
        instituteId: instituteId ?? "",
        classId: selectedClassId ?? "",
        teacherId: entityId,
        taskTypeId: "ASSIGNMENT",
        title: titleController.text,
        prompt: promptController.text,
        dueDate: dueDate,
        targetWordCount: int.tryParse(wordCountController.text) ?? 500,
        createdBy: createdBy,
        rubrics: rubrics,
        examples: examples, // pass examples here
      );

      final response =
          await assignmentService.createAssignment(assignmentRequest);

      if (response['message'] == "Assignment created successfully") {
        final data = response['data'];
        final taskID = data['out_task_id'];
        print("taskID: $taskID");
        StatusDialog.show(
          isSuccess: true,
          message: "Class assignment created successfully!",
          autoCloseSeconds: 2,
          onClose: () {
            Get.back();
            Get.toNamed("/teacher/assignmentdetail",
                arguments: {"taskId": taskID});
            print("On success");
          },
        );

        final alfrescoRequest = CreateAssignmentAlfrescoRequest(
          siteId: alfresco_site_id ?? "",
          alfrescoClassId: selectedAlfrescoClassId ?? "",
          alfrescoUserId: alfresco_user_id ?? "",
          workflowDefinition: "activitiAdhoc",
          folderPath: folderPath,
          title: titleController.text,
          description: promptController.text,
          dueDate: dueDate,
          taskId: taskID,
        );
        final alfrescoResponse =
            await AssignmentService.createAssignmentAlfrescoAPI(
                alfrescoRequest);
        if (alfrescoResponse != null) {
          print("alfrescoResponse");
          print(alfrescoResponse);
        } else {
          print("alfrescoResponse is null");
        }

        final assignmentLMSRequest = AssignmentLMSRequests(
          binarySuccess_assignment_id: taskID,
          binarySuccess_class_id: selectedClassId ?? "",
          binarySuccess_teacher_id: entityId,
          name: titleController.text,
          description: promptController.text,
          due_at: dueDate,
        );

        final CheckStatusresponse =
            await AssignmentService.checkIntegrationModeAPI(
                instituteId: instituteId ?? '');
        final integrationType =
            CheckStatusresponse?["INTEGRATION_TYPE"] as String?;

        if (integrationType != null &&
            integrationType.toLowerCase() != "excel") {
          final LMSPushresponse =
              await assignmentService.LMSPushAssignment(assignmentLMSRequest);
          print("LMSPushresponse");
          print(LMSPushresponse);
        }

        final AssignmentNotificationresponse =
            await NotificationService.sendNotificationAllLeaners(
          classId: selectedClassId ?? '',
          teacherId: entityId,
          type: "Assignment",
        );
        if (AssignmentNotificationresponse != null) {
          print("AssignmentNotificationresponse");
          print(AssignmentNotificationresponse);
        } else {
          print("AssignmentNotificationresponse is null");
        }
      } else {
        String errorMessage =
            response['message'] ?? "Something went wrong. Please try again.";
        StatusDialog.show(
            isSuccess: false,
            message: "Class creation failed. Please try again.");
        return;
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ---------- Gradient button ----------
  Widget _gradientButton(String text) {
    return Container(
      width: 200.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.r),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xff004AAD), Color(0xffCB6CE6)],
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}
