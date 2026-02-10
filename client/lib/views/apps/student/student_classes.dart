import 'package:binary_success/controller/apps/student/student_dashboard_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/views/layouts/layout.dart';

class StudentClassesPage extends StatefulWidget {
  const StudentClassesPage({super.key});

  @override
  StudentClassesPageState createState() => StudentClassesPageState();
}

class StudentClassesPageState extends State<StudentClassesPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late StudentDashboardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StudentDashboardController());
  }

  /// Normalize status string (handles uppercase from API)
  String normalizeStatus(String status) {
    return status.trim().toLowerCase();
  }

  Color borderColor(String status) {
    switch (normalizeStatus(status)) {
      case "active":
        return const Color(0xff0A8041).withOpacity(0.50);
      case "archived":
        return const Color(0xffDA612B).withOpacity(0.50);
      default:
        return const Color(0xff0A8041).withOpacity(0.50);
    }
  }

  Color textColor(String status) {
    switch (normalizeStatus(status)) {
      case "active":
        return const Color(0xff0A8041);
      case "archived":
        return const Color(0xffDA612B);
      default:
        return const Color(0xff0A8041);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Layout(
        shrinkContent: true,
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 34),
              Text(
                "Papers",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                "View your current papers and assignments.",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: contentTheme.k142228,
                ),
              ),
              controller.isLoading.value
                  ? SizedBox(
                      height: MySpacing.fullHeight(context) * 0.70,
                      child: const Center(child: CircularProgressIndicator()))
                  : Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.only(
                          left: 5,
                          top: 15,
                          right: ((controller.studentClassData.value
                                          .classDetails?.length ??
                                      0) >
                                  5)
                              ? MySpacing.fullWidth(context) * 0.02
                              : 0,
                        ),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final classItem = controller
                              .studentClassData.value.classDetails?[index];

                          return classesCard(
                            className: classItem?.className ?? "",
                            description: classItem?.description ?? "",
                            studentCount: classItem?.numStudents ?? 0,
                            assignmentsCount:
                                classItem?.numActiveAssignments ?? 0,
                            status: classItem?.classStatus ?? "",
                            fingerPrintStatus:
                                classItem?.lastFingerprintTaskStatus ?? "",
                            grade: controller.studentClassData.value
                                    .learnerSummary?[0].gradeName ??
                                "",
                            studentID: controller.studentClassData.value
                                    .learnerSummary?[0].learnerId ??
                                "",
                            classID: classItem?.classId ?? "",
                            term: classItem?.term ?? "",
                            academicYear:
                                classItem?.academicYear?.toString() ?? "",
                          );
                        },
                        separatorBuilder: (context, index) =>
                            MySpacing.height(25),
                        itemCount: controller
                                .studentClassData.value.classDetails?.length ??
                            0,
                      ).paddingOnly(bottom: 10.h),
                    )
            ],
          ).paddingOnly(
            bottom: MySpacing.fullHeight(context) * 0.05,
            right: MySpacing.fullWidth(context) * 0.02,
            left: 40,
          );
        }),
      ),
    );
  }

  Widget classesCard({
    required String className,
    required String description,
    required int studentCount,
    required int assignmentsCount,
    required String status,
    required String fingerPrintStatus,
    required String grade,
    required String studentID,
    required String classID,
    required String term,
    required String academicYear,
  }) {
    final normalizedStatus = normalizeStatus(status);
    final normalizedFingerprint = normalizeStatus(fingerPrintStatus);

    return MyCard.circular(
      borderRadiusAll: 25.r,
      bordered: true,
      padding:
          EdgeInsets.only(left: 25.w, top: 18.h, bottom: 18.h, right: 40.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      className,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                    10.horizontalSpace,
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        border:
                            Border.all(width: 2, color: borderColor(status)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        normalizedStatus, // ✅ now always lowercase
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor(status),
                        ),
                      ),
                    )
                  ],
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: contentTheme.k142228,
                  ),
                ),
                25.verticalSpace,
                Wrap(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.students, width: 19.w, height: 21.h),
                        MySpacing.width(9),
                        Text("$studentCount students",
                            style: GoogleFonts.inter(fontSize: 12.sp)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.activeAssignment,
                            width: 24.w, height: 24.h),
                        9.horizontalSpace,
                        Text("$assignmentsCount active assignments",
                            style: GoogleFonts.inter(fontSize: 12.sp)),
                      ],
                    ).paddingSymmetric(horizontal: 20.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.calendar, width: 15.w, height: 15.w),
                        9.horizontalSpace,
                        Text("$term $academicYear",
                            style: GoogleFonts.inter(fontSize: 12.sp)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.grade, width: 18.w, height: 18.h),
                        9.horizontalSpace,
                        Text(grade, style: GoogleFonts.inter(fontSize: 12.sp)),
                      ],
                    ).paddingSymmetric(horizontal: 20.w),

                    // ✅ Only show fingerprint if submitted
                    if (normalizedFingerprint == "submitted")
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(Images.fingerprint,
                              width: 18.w, height: 18.h),
                          9.horizontalSpace,
                          Text(
                            "Writing Fingerprint submitted",
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
            onTap: () async {
              controller.classID.value = classID;
              controller.className.value = className;

              /// Load tasks for this class
              await controller.getStudentViewClassData(classId: classID);

              /// Navigate to detail page
              Get.offNamed("/student/classdetail");
            },
            child: MyContainer.bordered(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              borderColor: contentTheme.borderColor,
              borderRadiusAll: 25.r,
              bordered: true,
              child: Row(
                children: [
                  Image.asset(Images.eye, width: 20.w, height: 20.h),
                  8.horizontalSpace,
                  Text(
                    "View Schedule",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
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
