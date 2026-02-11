import 'package:vantanceCA/helpers/services/notification_service.dart';
import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/helpers/widgets/my_text_style.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/widgets/custom_pop_menu.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/controller/apps/teacher/teacher_assignments_controller.dart';
import 'package:vantanceCA/models/teacher_assignment_detail_model.dart';

import 'package:vantanceCA/models/teachers_grading_model.dart';

class TeacherAssignmentDetailWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  const TeacherAssignmentDetailWidget({super.key, required this.contentTheme});

  // Removed Assignment Title, remaining columns will flex equally
  static final List<String> columnHeaders = [
    "Student",
    "Writing\nFingerprint",
    "Submitted",
    "Word Count",
    "Grade",
    "Action"
  ];

  @override
  Widget build(BuildContext context) {
    final TeacherAssignmentsController controller = Get.find();

    return MyCard.circular(
      margin: EdgeInsets.only(
          bottom: 10.h,
          left: 5.w,
          top: 25.h,
          right: MySpacing.fullWidth(context) * 0.04),
      borderRadiusAll: 25,
      bordered: false,
      padding: EdgeInsets.only(left: 16.w, top: 30.h, bottom: 0, right: 40.w),
      child: Column(
        children: [
          // ===== Header: Title + Search + Sort =====
          Padding(
            padding: EdgeInsets.only(left: 2.w, right: 10.w, bottom: 6.h),
            child: Row(
              children: [
                SizedBox(
                  width: 200.w,
                  child: MyText.bodySmall(
                    "All Students",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.black,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 280.w,
                  child: TextFormField(
                    maxLines: 1,
                    style: MyTextStyle.bodyMedium(),
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: MyTextStyle.bodySmall(
                          fontSize: 12.sp,
                          xMuted: true,
                          color: const Color(0xff9A9A9B)),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Color(0xffE1E1E1)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Color(0xffE1E1E1)),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(color: Color(0xffE1E1E1)),
                      ),
                      prefixIcon: const Align(
                          alignment: Alignment.center,
                          child: Icon(
                            FeatherIcons.search,
                            size: 14,
                          )),
                      prefixIconConstraints: const BoxConstraints(
                          minWidth: 30,
                          maxWidth: 30,
                          minHeight: 32,
                          maxHeight: 32),
                      contentPadding: MySpacing.xy(16.w, 12.h),
                      isCollapsed: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    onChanged: (value) {
                      controller.searchStudents(value.trim());
                    },
                  ),
                ),
                15.horizontalSpace,
                Obx(
                  () => CustomPopupMenu(
                    backdrop: true,
                    onChange: (_) {},
                    menu: MyContainer.bordered(
                      borderRadiusAll: 10.r,
                      borderColor: contentTheme.borderColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      child: Row(
                        children: [
                          Text.rich(TextSpan(children: [
                            TextSpan(
                                text: "Sort by : ",
                                style: MyTextStyle.bodySmall(
                                    fontSize: 12.sp,
                                    fontWeight: 400,
                                    color: contentTheme.k7E7E7E)),
                            TextSpan(
                                text: controller.selectedSort.value,
                                style: MyTextStyle.bodyLarge(
                                    fontSize: 12.sp,
                                    fontWeight: 600,
                                    color: contentTheme.k142228))
                          ])),
                          5.horizontalSpace,
                          Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: contentTheme.k3D3C42,
                          )
                        ],
                      ),
                    ),
                    menuBuilder: (_) => Material(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.sortOptions.map((option) {
                          return InkWell(
                            onTap: () {
                              controller.changeSort(option);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(option,
                                  style: GoogleFonts.inter(fontSize: 12.sp)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          10.verticalSpace,

          // ===== TABLE =====
          Expanded(
            child: Obx(() {
              final students = controller.students;

              if (controller.isDetailLoading.value) {
                return const Center(child: CircularProgressIndicator());
              } else if (students.isEmpty) {
                return Center(
                  child: MyText.bodyMedium(
                    "No students found",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: contentTheme.k142228,
                    ),
                  ),
                );
              }

              final currentTaskId = controller.currentTaskId?.isNotEmpty == true
                  ? controller.currentTaskId!
                  : (controller.taskStats.value?.taskId ?? '');

              return SizedBox.expand(
                child: DataTable(
                  dividerThickness: 1,
                  dataRowMinHeight: 65.h,
                  dataRowMaxHeight: 65.h,
                  checkboxHorizontalMargin: 0,
                  horizontalMargin: 0,
                  columnSpacing: 0,
                  columns: columnHeaders
                      .map((header) => DataColumn(
                            label: Expanded(
                              child: Text(
                                header,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ))
                      .toList(),
                  rows: students.map<DataRow>((learner) {
                    final fullName = '${learner.firstName} ${learner.lastName}';
                    final submittedAtStr = learner.submittedAt != null
                        ? _formatDate(learner.submittedAt!)
                        : "-";
                    final gradeStr =
                        (learner.grade != null && learner.totalPoints > 0)
                            ? "${learner.grade}/${learner.totalPoints}"
                            : "-";

                    return DataRow(cells: [
                      DataCell(Center(
                        child: Text(
                          fullName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                      DataCell(Center(
                        child: learner.hasFingerprintSubmitted
                            ? Image.asset(
                                Images.fingerprint,
                                width: 22.w,
                                height: 22.h,
                              )
                            : Text(
                                "-",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                      )),
                      DataCell(Center(
                        child: Text(
                          submittedAtStr,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                      DataCell(Center(
                        child: Text(
                          learner.submittedWordCount.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                      DataCell(Center(
                        child: Text(
                          gradeStr,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )),
                      DataCell(
                        Center(
                          child: _buildActionButton(
                            learner,
                            context,
                            currentTaskId,
                            controller, // pass the controller here
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      '',
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
    final hour12 =
        date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return "${monthNames[date.month]} ${date.day}, ${date.year} ${hour12.toString().padLeft(2, '0')}:$minute $ampm";
  }

  Widget _buildActionButton(Learner learner, BuildContext context,
      String taskId, TeacherAssignmentsController controller) {
    final taskStatus = learner.taskStatus.toUpperCase();

    // Get the task title from taskStats
    final assignmentTitle =
        controller.taskStats.value?.taskTitle ?? "Assignment Reminder";

    if (taskStatus == "GRADED") {
      return GestureDetector(
        onTap: () {
          final gradingModel = TeachersGradingModel(
            taskId: taskId,
            learnerId: learner.learnerId,
            learnerFirstName: learner.firstName,
            learnerLastName: learner.lastName,
            assignmentTitle: assignmentTitle,
            submittedDateTime: learner.submittedAt,
            wordCount: learner.submittedWordCount,
            teacherGrade: learner.grade?.toDouble(),
            totalPoints: learner.totalPoints.toDouble(),
            status: taskStatus,
            classId: '',
            className: '',
            assignmentContent: '',
            dueDate: '',
            submittedDate: learner.submittedAt?.toIso8601String() ?? '',
            score: learner.grade,
            learnerName: '${learner.firstName} ${learner.lastName}',
            hasFingerprint: learner.hasFingerprintSubmitted,
            userId: learner.userId ?? learner.learnerId,
          );

          Get.toNamed("/teacher/gradingreview", arguments: gradingModel);
        },
        child: _actionContainer("View Details", Images.eye, false),
      );
    } else if (taskStatus == "SUBMITTED") {
      return GestureDetector(
        onTap: () {
          final gradingModel = TeachersGradingModel(
            taskId: taskId,
            learnerId: learner.learnerId,
            learnerFirstName: learner.firstName,
            learnerLastName: learner.lastName,
            assignmentTitle: assignmentTitle,
            submittedDateTime: learner.submittedAt,
            wordCount: learner.submittedWordCount,
            teacherGrade: learner.grade?.toDouble(),
            totalPoints: learner.totalPoints.toDouble(),
            status: taskStatus,
            classId: '',
            className: '',
            assignmentContent: '',
            dueDate: '',
            submittedDate: learner.submittedAt?.toIso8601String() ?? '',
            score: learner.grade,
            learnerName: '${learner.firstName} ${learner.lastName}',
            hasFingerprint: learner.hasFingerprintSubmitted,
            userId: learner.userId ?? learner.learnerId,
          );

          Get.toNamed("/teacher/gradingreview", arguments: gradingModel);
        },
        child: _actionContainer("Review", Images.eye, true),
      );
    } else {
      return GestureDetector(
        onTap: () {
          if (learner.userId != null && learner.userId!.isNotEmpty) {
            // Use taskStats title directly
            remindStudent(learner.userId!, assignmentTitle);
          } else {
            Get.snackbar("Error", "User ID not found for this learner.");
          }
        },
        child: _actionContainer("Remind", Images.notification, false,
            remind: true),
      );
    }
  }

  void remindStudent(String? userId, String taskTitle) async {
    if (userId == null || userId.isEmpty) {
      print("Cannot send reminder: userId is null or empty.");
      Get.snackbar("Error", "User ID is missing. Cannot send reminder.");
      return;
    }

    try {
      await NotificationService.sendRemindNotification(
        userId: userId,
        title: "Assignment Reminder",
        message:
            "You have a pending assignment: $taskTitle. Please complete it soon.",
      );
      print(
          "Reminder notification sent: userId=$userId, assignment=$taskTitle");
      Get.snackbar("Success", "Reminder sent to student.");
    } catch (e) {
      print("Failed to send reminder notification: $e");
      Get.snackbar("Error", "Failed to send reminder notification.");
    }
  }

  Widget _actionContainer(String text, String iconPath, bool gradient,
      {bool remind = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.r),
        gradient: gradient
            ? const LinearGradient(
                colors: [Color(0xff004AAD), Color(0xffCB6CE6)])
            : null,
        color: remind
            ? const Color(0xffBED3F6)
            : gradient
                ? null
                : Colors.transparent,
        border: remind
            ? Border.all(width: 1, color: const Color(0xffC6C3C3))
            : (!gradient
                ? Border.all(width: 1, color: const Color(0xffC6C3C3))
                : null),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath,
              width: 16.w,
              height: 16.h,
              color: gradient ? Colors.white : Colors.black),
          6.horizontalSpace,
          Text(text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: gradient ? Colors.white : Colors.black,
              )),
        ],
      ),
    );
  }
}
