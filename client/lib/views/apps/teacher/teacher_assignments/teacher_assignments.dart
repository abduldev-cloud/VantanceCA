import 'package:binary_success/controller/apps/teacher/teacher_assignments_controller.dart';
import 'package:binary_success/helpers/utils/my_shadow.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/models/teachers_assignments_model.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:intl/intl.dart';
import 'package:binary_success/views/apps/teacher/dialog/teacher_create_assignment_diaog.dart';

class TeacherAssignmentsPage extends StatefulWidget {
  const TeacherAssignmentsPage({super.key});

  @override
  TeacherAssignmentsPageState createState() => TeacherAssignmentsPageState();
}

class TeacherAssignmentsPageState extends State<TeacherAssignmentsPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherAssignmentsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherAssignmentsController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 3,
      child: GetBuilder<TeacherAssignmentsController>(
        init: controller,
        builder: (controller) {
          return Obx(() {
            if (controller.isLoading.value) {
              return SizedBox(
                height: MySpacing.fullHeight(context) * 0.80,
                child: Center(
                  child: CircularProgressIndicator(
                    color: contentTheme.darkPurple,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommanTitlebar(
                    contentTheme: contentTheme,
                    title: "Assignments",
                    subTitle:
                        "Plan, edit, and grade assignments across all classes",
                    buttonTitle: "Create Assignment",
                    onTap: () {
                      Get.dialog(
                        TeacherCreateAssignmentDiaog(
                            contentTheme: contentTheme),
                      );
                    },
                  ).paddingOnly(right: MySpacing.fullWidth(context) * 0.02),

                  // Tab Cards Section
                  if (controller.assignmentsData.value != null)
                    Column(
                      children: [
                        Row(
                          children: [
                            // Active Assignments Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.onTabChanged(0);
                                },
                                child: buildCard(
                                  "${controller.assignmentsData.value!.taskCounts.first.activeTasks}",
                                  "Active Assignments",
                                  controller.selectedIndex.value == 0,
                                  contentTheme.k0A8041,
                                ),
                              ).paddingOnly(right: 40.w),
                            ),
                            // Scheduled Assignments Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.onTabChanged(1);
                                },
                                child: buildCard(
                                  "${controller.assignmentsData.value!.taskCounts.first.scheduledTasks}",
                                  "Scheduled Assignments",
                                  controller.selectedIndex.value == 1,
                                  contentTheme.orange,
                                ),
                              ).paddingOnly(right: 40.w),
                            ),
                            // Draft Assignments Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  controller.onTabChanged(2);
                                },
                                child: buildCard(
                                  "${controller.assignmentsData.value!.taskCounts.first.draftTasks}",
                                  "Draft Assignments",
                                  controller.selectedIndex.value == 2,
                                  contentTheme.darkPurple,
                                ),
                              ),
                            ),
                          ],
                        ).paddingOnly(
                          bottom: 20,
                          left: 5,
                          top: 17,
                          right: MySpacing.fullHeight(context) * 0.06,
                        ),

                        // Assignment List for Selected Tab
                        SizedBox(
                          height: MySpacing.fullHeight(context) * 0.65,
                          child: buildAssignmentList(
                              controller.assignmentsData.value!.taskSummary),
                        ).paddingOnly(
                            right: MySpacing.fullHeight(context) * 0.08),
                      ],
                    )
                  else
                    SizedBox(
                      height: MySpacing.fullHeight(context) * 0.80,
                      child: Center(
                        child: MyText.bodySmall(
                          "No Data Available",
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget buildCard(
      String value, String title, bool isSelected, Color textColor) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      child: MyCard(
        shadow: isSelected ? MyShadow(color: Colors.transparent) : null,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        gradient: isSelected
            ? LinearGradient(colors: [
                Color(0xffEEECFF),
                Color(0xffEEECFF),
                Color(0xffDBEBFF),
              ])
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.bodyMedium(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? contentTheme.k142228 : contentTheme.k7E7E7E,
              ),
            ),
            SizedBox(height: 8.h),
            MyText.bodySmall(
              value,
              style: GoogleFonts.inter(
                fontSize: 32.sp,
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAssignmentList(List<TaskSummary> assignments) {
    if (assignments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            MyText.bodySmall(
              "No assignments found",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            MyText.bodySmall(
              "Assignments will appear here once created",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final task = assignments[index];
        String formattedDate;
        try {
          formattedDate =
              DateFormat("MMM dd, yyyy").format(DateTime.parse(task.dueDate));
        } catch (_) {
          formattedDate = task.dueDate;
        }

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: MyCard.circular(
            borderRadiusAll: 25,
            bordered: true,
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium(
                        task.taskTitle,
                        // fontSize: 20.sp,
                        // fontWeight: 600,
                        // color: contentTheme.k142228,
                        style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF142228),
                      ),
                      ),
                      // MyText.bodySmall(
                      //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                      //   fontSize: 14,
                      //   fontWeight: 500,
                      //   color:
                      //       contentTheme.k142228, // or any suitable muted color
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      // ),
                      MySpacing.height(12),
                      Wrap(
                        spacing: 20.w,
                        runSpacing: 8.h,
                        children: [
                          _buildInfoRow(
                            "assets/icon/students.png",
                            "${task.submittedCount}/${task.totalLearners} Submitted",
                          ),
                          _buildInfoRow(
                            "assets/icon/classes.png",
                            task.className,
                          ),
                          _buildInfoRow(
                            "assets/icon/grade.png",
                            task.gradeName,
                          ),
                          _buildInfoRow(
                            "assets/icon/calendar.png",
                            formattedDate,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                InkWell(
                  onTap: () {
                    Get.toNamed("/teacher/assignmentdetail", arguments: {
                      "taskId": task.taskId,
                    });
                  },
                  child: MyContainer.bordered(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    borderColor: contentTheme.borderColor,
                    borderRadiusAll: 25,
                    bordered: true,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility,
                            size: 18, color: contentTheme.k142228),
                        MySpacing.width(6),
                        MyText.bodyMedium(
                          "View Details",
                          fontSize: 14,
                          fontWeight: 500,
                          color: contentTheme.k142228,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String iconPath, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          iconPath,
          height: 22.w,
          width: 22.h,
          color: const Color(0xFF142228)
        ),
        MySpacing.width(6),
        MyText.bodySmall(
          text,
          fontSize: 12.sp,
          fontWeight: 400,
          color: const Color(0xFF142228)
        ),
      ],
    );
  }
}
