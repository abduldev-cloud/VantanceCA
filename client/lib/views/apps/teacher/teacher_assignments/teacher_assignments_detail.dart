import 'package:binary_success/controller/apps/teacher/teacher_assignments_controller.dart';
import 'package:binary_success/helpers/utils/my_shadow.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/views/apps/teacher/dialog/teacher_create_assignment_diaog.dart';
import 'package:binary_success/views/apps/teacher/widget/teacher_assignment_detail_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherAssignmentsDetail extends StatefulWidget {
  const TeacherAssignmentsDetail({super.key});

  @override
  TeacherAssignmentsDetailState createState() => TeacherAssignmentsDetailState();
}

class TeacherAssignmentsDetailState extends State<TeacherAssignmentsDetail>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherAssignmentsController controller;

 @override
void initState() {
  super.initState();
  controller = Get.isRegistered<TeacherAssignmentsController>()
      ? Get.find<TeacherAssignmentsController>()
      : Get.put(TeacherAssignmentsController());

  final taskId = Get.arguments?["taskId"];
  if (taskId != null) {
    controller.getAssignmentDetail(taskId);
  }
}

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 3,
      child: Obx(() {
        final stats = controller.taskStats.value;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titlebar with overflow handling
              CommanTitlebar(
                contentTheme: contentTheme,
                title: stats?.taskTitle ?? "Assignment Detail",
                subTitle: "",
                buttonTitle: "Create Assignment",
                onTap: () {
                  Get.dialog(TeacherCreateAssignmentDiaog(contentTheme: contentTheme));
                },
              ).paddingOnly(
                right: MySpacing.fullWidth(context) * 0.04,
              ),

              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: buildCard(
                      "${stats?.totalSubmitted ?? 0}",
                      "Submissions",
                      false,
                      contentTheme.k0A8041,
                    ).paddingOnly(right: 40.w),
                  ),
                  Expanded(
                    child: buildCard(
                      "${stats?.totalMissing ?? 0}",
                      "Missing",
                      false,
                      contentTheme.orange,
                    ).paddingOnly(right: 40.w),
                  ),
                 Expanded(
  child: buildCard(
    (stats?.avgTeacherGrade == null || stats?.avgTeacherGrade == 0)
        ? "-" // Show dash with /10
        : "${stats!.avgTeacherGrade}",
    "Average Score",
    false,
    contentTheme.darkPurple,
  ),
),

                ],
              ).paddingOnly(
                left: 5.w,
                top: 17.h,
                right: MySpacing.fullWidth(context) * 0.04,
              ),

              // Students detail widget
              SizedBox(
                height: MySpacing.fullHeight(context) * 0.68,
                child: TeacherAssignmentDetailWidget(contentTheme: contentTheme),
              ),
            ],
          ).paddingOnly(bottom: 50),
        );
      }),
    );
  }

  Widget buildCard(String value, String title, bool isGradient, Color textColor) {
    return MyCard(
      shadow: isGradient ? MyShadow(color: Colors.transparent) : null,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      color: isGradient ? null : Colors.white,
      borderRadius: BorderRadius.circular(25.r),
      gradient: isGradient
          ? const LinearGradient(colors: [
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
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          MyText.bodySmall(
            value,
            style: GoogleFonts.inter(
              fontSize: 36.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
