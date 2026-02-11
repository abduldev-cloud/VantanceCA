import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/apps/teacher/dialog/teacher_writing_fingerprint_dialog_two.dart';
import 'package:vantanceCA/widgets/comman_dialog_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vantanceCA/controller/widgets/date_time_picker_controller.dart';
import 'package:vantanceCA/widgets/custom_time_picker_field.dart';
import 'package:vantanceCA/widgets/custom_date_picker_field.dart';
import 'package:vantanceCA/helpers/services/teacher_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';

class TeacherWritingFingerprintDialog extends StatefulWidget {
  final ContentTheme contentTheme;
  const TeacherWritingFingerprintDialog(
      {super.key, required this.contentTheme});

  @override
  State<TeacherWritingFingerprintDialog> createState() =>
      _TeacherWritingFingerprintDialogState();
}

class _TeacherWritingFingerprintDialogState
    extends State<TeacherWritingFingerprintDialog> {
  final DateTimePickerController dateTimeController =
      Get.put(DateTimePickerController());

  // --- Data structures ---
  // class -> list of grades
  Map<String, List<String>> _gradesByClass = {};
  // class -> (grade -> class_id)
  Map<String, Map<String, String>> _classIdByClassGrade = {};
  // class -> first seen class_id (fallback)
  Map<String, String> _firstClassIdByClass = {};

  final Map<String, String?> _alfrescoClassIdByClassId = {};

  // Dropdown sources
  List<String> classOptions = [];
  List<String> gradeOptions = [];

  // Selected values
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
          // debugPrint(
          //   "CLASS: $className | GRADE: $gradeName | classId=$classId | alfresco_class_id=$alfrescoClassId",
          // );

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

  Future<void> saveSelectionToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("class_id", selectedClassId ?? "");
    await prefs.setString("class_name", selectedClass ?? "");
    await prefs.setString("grade_name", selectedGrade ?? "");
    await prefs.setString("alfresco_class_id", selectedAlfrescoClassId ?? "");
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
            // --- Header ---
            Row(
              children: [
                const Spacer(),
                Column(
                  children: [
                    Text(
                      "Schedule Writing Fingerprint",
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
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
                      "Assign as early in the school year as possible",
                    ),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                )
              ],
            ),
            30.verticalSpace,

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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: MyText.bodySmall(
                  "No classes found",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: widget.contentTheme.k172640,
                  ),
                ),
              ),

            15.verticalSpace,

            // --- Grade Dropdown (dependent) ---
            if (!isLoadingClasses && gradeOptions.isNotEmpty)
              CommonDialogDropdown(
                itemList: gradeOptions,
                selectedValue: selectedGrade ?? gradeOptions.first,
                contentTheme: widget.contentTheme,
                title: "Grade",
                onChanged: (value) => onGradeChanged(value),
              ),

            15.verticalSpace,

            // --- Date Picker ---
            CommonDatePicker(
              contentTheme: widget.contentTheme,
              title: "Date",
              controller: dateTimeController,
              onChanged: (date) {
                dateTimeController.updateSelectedDate(date ?? '');
              },
            ),
            15.verticalSpace,

            // --- Time Picker ---
            CommonTimePicker(
              contentTheme: widget.contentTheme,
              title: "Due by",
              controller: dateTimeController,
              onChanged: (time) {
                dateTimeController.updateSelectedTime(time ?? '');
              },
            ),
          ],
        ),
      ),
      actions: [
        MySpacing.height(10),
        Align(
          child: InkWell(
            onTap: () async {
              // Save selections before navigating
              await saveSelectionToLocalStorage();
              final formattedDateTime =
                  dateTimeController.getFormattedDateTime();
              if (formattedDateTime.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Please fill all fields",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              } else {
                Get.back();
                print("instituteId: $instituteId");
                print("alfresco_class_id: $selectedAlfrescoClassId");
                Get.dialog(TeacherWritingFingerprintDialogTwo(
                  contentTheme: widget.contentTheme,
                  dueDate: formattedDateTime,
                  classId: selectedClassId ?? "",
                  GradeId: selectedGrade ?? "",
                  instituteId: instituteId ?? '',
                  alfresco_site_id: alfresco_site_id ?? '',
                  alfresco_user_id: alfresco_user_id ?? '',
                  alfresco_class_id: selectedAlfrescoClassId ?? '', // ✅ NEW
                ));
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xff004AAD),
                    Color(0xffCB6CE6),
                  ],
                ),
              ),
              child: Text(
                "Next",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.contentTheme.kFEFDFF,
                ),
              ),
            ),
          ),
        ),
        MySpacing.height(10),
      ],
    );
  }
}
