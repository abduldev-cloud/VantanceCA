import 'package:vantanceCA/controller/apps/teacher/teacher_classes_controller.dart';
import 'package:vantanceCA/models/teacher_classes_model.dart'; // Make sure this contains ClassInfo etc.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';

// import 'package:vantanceCA/controller/apps/teacher/teacher_view_details_controller.dart';
import 'package:vantanceCA/models/teacher_classes_model.dart';

import 'package:vantanceCA/models/teacher_view_class_model.dart';
import 'package:vantanceCA/controller/apps/teacher/teacher_view_class_controller.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';

class TeacherClassWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  final TeacherClassesController controller;

  const TeacherClassWidget({
    super.key,
    required this.contentTheme,
    required this.controller,
  });

  // @override
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      // final classes = controller.classList;
      final classes = controller.displayedClasses;

      // if (classes.isEmpty) {
      //   return Center(child: Text("No ${controller.selectedStatus.value.toLowerCase()} classes available."));
      // }
      if (classes.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Image.asset(
                Images.classes, // ✅ your asset
                width: 60,
                height: 60,
                color: Colors.grey.shade400, // optional tint
              ),
              SizedBox(height: 16),

              // Main message
              Text(
                "No ${controller.selectedStatus.value.toLowerCase()} classes available.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),

              // Sub text
              Text(
                "Classes will appear here once created",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.only(left: 5.w, top: 15.h, bottom: 2.h),
        itemCount: classes.length,
        separatorBuilder: (context, index) => MySpacing.height(25),
        itemBuilder: (context, index) {
          final classInfo = classes[index];
          return classesCard(
            className: classInfo.className ?? "",
            studentCount: classInfo.numStudents ?? 0,
            status: classInfo.classStatus ?? "",
            fall:
                "${classInfo.term ?? ""} ${classInfo.academicYear?.toString() ?? ""}",
            gradeName: classInfo.gradeName ?? "",
            fingerPrintCount: classInfo.numLastFingerprintSubmitted ?? 0,
            assignmentCount: classInfo.numActiveAssignments ?? 0,
            description: classInfo.description ?? "",
            classId: classInfo.classId ?? "",
          );
        },
      );
    });
  }
}

Widget classesCard({
  required String className,
  required int studentCount,
  required String status,
  required String fall,
  required String gradeName,
  required int fingerPrintCount,
  required int assignmentCount,
  required String description,
  required String classId,
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
              Row(
                children: [
                  MyText.bodyMedium(
                    className,
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF142228),
                    ),
                  ),
                  10.horizontalSpace,
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        width: 2,
                        // color: const Color(0xFF142228).withOpacity(0.50),
                        color: status.toLowerCase() == "archived"
                            ? ContentTheme().orange
                            : ContentTheme().k0A8041,
                      ),
                      color: Colors.transparent,
                    ),
                    child: MyText.bodyMedium(
                      status.toLowerCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        // color: const Color(0xFF142228),
                        color: status.toLowerCase() == "archived"
                            ? ContentTheme().orange
                            : ContentTheme().k0A8041,
                      ),
                    ),
                  ),
                ],
              ),
              MyText.bodySmall(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF142228),
                ),
              ),
              MySpacing.height(25),
              Row(
                children: [
                  Row(
                    children: [
                      Image.asset(Images.students, width: 19.w, height: 21.h),
                      9.horizontalSpace,
                      MyText.bodySmall(
                        "$studentCount students",
                        fontSize: 12.sp,
                        fontWeight: 400,
                        color: const Color(0xFF142228),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(Images.activeAssignment,
                          width: 24.w, height: 24.h),
                      9.horizontalSpace,
                      MyText.bodySmall(
                        "$assignmentCount Assignments",
                        fontSize: 12.sp,
                        fontWeight: 400,
                        color: const Color(0xFF142228),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 20.w),
                  Row(
                    children: [
                      Image.asset(Images.calendar, width: 22.w, height: 22.h),
                      9.horizontalSpace,
                      MyText.bodySmall(
                        fall,
                        fontSize: 12.sp,
                        fontWeight: 400,
                        color: const Color(0xFF142228),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(Images.grade, width: 18.w, height: 18.h),
                      9.horizontalSpace,
                      MyText.bodySmall(
                        gradeName,
                        fontSize: 12.sp,
                        fontWeight: 400,
                        color: const Color(0xFF142228),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 20.w),
                  Row(
                    children: [
                      Image.asset(Images.fingerprint,
                          width: 18.w, height: 18.w),
                      9.horizontalSpace,
                      MyText.bodySmall(
                        "$fingerPrintCount Fingerprints submitted",
                        fontSize: 12.sp,
                        fontWeight: 400,
                        color: const Color(0xFF142228),
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
            final teacherId = LocalStorage.getDBEntityID();
            if (teacherId == null || teacherId.isEmpty) {
              return;
            }

            final detailController =
                Get.isRegistered<TeacherClassViewController>()
                    ? Get.find<TeacherClassViewController>()
                    : Get.put(TeacherClassViewController());

            try {
              await detailController.fetchClassStudents(teacherId, classId);
            } catch (e) {}
            final selectedClass = ClassInfo(
              classId: classId,
              className: className,
              description: description,
              classStatus: status,
              numStudents: studentCount,
              numActiveAssignments: assignmentCount,
              term: fall,
              academicYear: int.tryParse(fall.split(" ").last) ?? 0,
              gradeName: gradeName,
              numLastFingerprintSubmitted: fingerPrintCount,
            );

            Get.toNamed("/teacher/classesdetail", arguments: selectedClass);
          },
          child: MyContainer.bordered(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            borderColor: const Color(0xFF142228),
            borderRadiusAll: 25.r,
            bordered: true,
            child: Row(
              children: [
                Image.asset(Images.eye, width: 20.w, height: 20),
                9.horizontalSpace,
                MyText.bodyMedium(
                  "View Details",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF142228),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
