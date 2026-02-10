import 'package:binary_success/models/teachers_assignments_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
class TeacherAssignmentWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  final List<TaskSummary> list;

  const TeacherAssignmentWidget({
    super.key,
    required this.contentTheme,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Center(
        child: MyText.bodyMedium(
          "No assignments available",
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(left: 5.w, top: 15.h, right: 50.w, bottom: 10.h),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // For embedding inside scroll view
      itemBuilder: (context, index) {
        TaskSummary model = list[index];
        return classesCard(
          taskId: model.taskId,
          title: model.taskTitle,
          className: model.className,
          gradeLevel: model.gradeName,
          subMittedCount: model.submittedCount,
          totalStudentCount: model.totalLearners,
          dueDate: model.dueDate,
        );
      },
      separatorBuilder: (context, index) => MySpacing.height(25),
      itemCount: list.length,
    );
  }

  Widget classesCard({
    required String taskId, // Added this
    required String title,
    required String className,
    required String gradeLevel,
    required int subMittedCount,
    required int totalStudentCount,
    required String dueDate,
  }) {
    return MyCard.circular(
      borderRadiusAll: 25.r,
      bordered: true,
      padding: EdgeInsets.only(left: 25.w, top: 18.h, bottom: 18.h, right: 40.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: contentTheme.k142228,
                  ),
                 
                ),
                MySpacing.height(5),
                MyText.bodySmall(
                  "Due: $dueDate",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: contentTheme.k142228,
                  ),
                ),
                MySpacing.height(15),
                Row(
                  children: [
                    Row(
                      children: [
                        Image.asset(Images.students, width: 18.w, height: 18.h),
                        8.horizontalSpace,
                        MyText.bodySmall(
                          "$subMittedCount/$totalStudentCount submitted",
                          style: GoogleFonts.inter(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(Images.classes, width: 20.w, height: 20.h),
                        8.horizontalSpace,
                        MyText.bodySmall(
                          className,
                          style: GoogleFonts.inter(fontSize: 12.sp),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20.w),
                    Row(
                      children: [
                        Image.asset(Images.grade, width: 20.w, height: 20.h),
                        8.horizontalSpace,
                        MyText.bodySmall(
                          gradeLevel,
                          style: GoogleFonts.inter(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // Use actual taskId for navigation
              Get.toNamed("/teacher/assignmentdetail", arguments: {
                "taskId": taskId,
              });
            },
            child: MyContainer.bordered(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              borderColor: contentTheme.borderColor,
              borderRadiusAll: 25.r,
              bordered: true,
              child: Row(
                children: [
                  Image.asset(Images.eye, width: 20.w, height: 20.h),
                  MySpacing.width(8),
                  MyText.bodyMedium(
                    "View",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.k142228,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
