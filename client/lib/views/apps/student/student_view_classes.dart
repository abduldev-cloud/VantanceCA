import 'package:binary_success/controller/apps/student/student_dashboard_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/models/student_view_class_model.dart';

class StudentViewClassesPage extends StatefulWidget {
  const StudentViewClassesPage({super.key});

  @override
  StudentViewClassesPageState createState() => StudentViewClassesPageState();
}

class StudentViewClassesPageState extends State<StudentViewClassesPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late StudentDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<StudentDashboardController>();

    // ✅ Debug logs for selected class and current task list
    print("Selected Class: ${controller.className.value}");
    print("Initial Tasks Count: ${controller.studentViewClassList.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 0,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.studentViewClassList.isEmpty) {
          return Center(
            child: MyText.bodyMedium(
              "No assignments available for this class.",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: contentTheme.k142228,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.titleMedium(
              controller.className.value,
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: contentTheme.k142228,
              ),
            ),
            MyText.bodySmall(
              "Assignments for this class",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: contentTheme.k142228,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(
                  left: 10.w,
                  top: 15.h,
                  right: MySpacing.fullWidth(context) * 0.02,
                  bottom: 10.h,
                ),
                itemCount: controller.studentViewClassList.length,
                separatorBuilder: (context, index) => MySpacing.height(20),
                itemBuilder: (context, index) {
                  final StudentViewClassModel model =
                      controller.studentViewClassList[index];

                  return classesSubCard(
                    taskId: model.taskId ?? "",
                    title: model.assignmentTitle ?? "Untitled Task",
                    description:
                        model.assignmentDescription ?? "No description provided.",
                    dueDate: model.dueDate ?? "N/A",
                    dueTime: model.dueTime ?? "",
                    className: model.className ?? "",
                    gradName: controller.gradeName.value,
                    classID: model.classId ?? "",
                    buttonLabel: model.actionButtonLabel, // ✅ Uses getter
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget classesSubCard({
    required String title,
    required String taskId,
    required String description,
    required String dueDate,
    required String dueTime,
    required String className,
    required String gradName,
    required String classID,
    required String buttonLabel,
  }) {
    return MyCard.circular(
      borderRadiusAll: 20.r,
      bordered: true,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // <-- Updated for vertical centering!
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: contentTheme.k142228,
                  ),
                ),
                8.verticalSpace,
                MyText.bodySmall(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: contentTheme.k142228,
                  ),
                ),
                18.verticalSpace,
                Wrap(
                  spacing: 18.w,
                  runSpacing: 8.h,
                  children: [
                    _iconText(Images.calendar, dueDate),
                    _iconText(Images.clock, dueTime),
                    _iconText(Images.classes, className),
                    _iconText(Images.grade, gradName),
                  ],
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                Get.offNamed("/student/writingpad", arguments: taskId);
              },
              child: MyContainer.bordered(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                borderColor: contentTheme.borderColor,
                borderRadiusAll: 20.r,
                bordered: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(Images.rightArrow, width: 16.w, height: 16.h),
                    6.horizontalSpace,
                    MyText.bodyMedium(
                      buttonLabel,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _iconText(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(icon, width: 16.w, height: 16.h),
        6.horizontalSpace,
        MyText.bodySmall(text),
      ],
    );
  }
}
