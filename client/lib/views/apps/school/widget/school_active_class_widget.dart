import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:get/get.dart';

import 'package:vantanceCA/models/teacher_classes_model.dart';

import 'package:vantanceCA/models/teacher_view_class_model.dart';
import 'package:vantanceCA/controller/apps/school/school_class_view_controller.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';

class SchoolActiveClassWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  final List<dynamic> classList;

  const SchoolActiveClassWidget({
    super.key,
    required this.contentTheme,
    required this.classList,
  });

  @override
  Widget build(BuildContext context) {
    if (classList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              Images.classes,
              width: 60,
              height: 60,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),

            // Main message
            Text(
              "No Active Classes Available",
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
              "Classes will appear here once active",
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
      padding: EdgeInsets.only(left: 5, top: 15, right: 2),
      itemCount: classList.length,
      separatorBuilder: (context, index) => 25.verticalSpace,
      itemBuilder: (context, index) => _classCard(classList[index]),
    );
  }

  Widget _classCard(dynamic data) {
    final classId = data['class_id'] ?? '';
    final status = data['class_status'] ?? '';
    final className = data['class_name'] ?? '-';
    final description = data['description'] ?? '';
    final teacherSalutation = data['teacher_salutation'] ?? '';
    final teacherFirstName = data['teacher_first_name'] ?? '';
    final teacherLastName = data['teacher_last_name'] ?? '';
    final teacherFullName =
        '$teacherSalutation $teacherFirstName $teacherLastName'.trim();
    final numStudents = data['num_students']?.toString() ?? '0';
    final term = data['term'] ?? '';
    final year = data['academic_year']?.toString() ?? '';
    final grade = data['grade_name'] ?? '';
    final numFingerprints =
        data['num_last_fingerprint_submitted']?.toString() ?? '0';

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
                    MyText.bodyMedium(
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
                        border: Border.all(
                          width: 2,
                          color: contentTheme.k0A8041.withAlpha(127),
                        ),
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: MyText.bodyMedium(
                        "active",
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.k0A8041,
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
                    color: contentTheme.k142228,
                  ),
                ),
                25.verticalSpace,
                Row(
                  children: [
                    Row(
                      children: [
                        Image.asset(Images.students, width: 19.w, height: 21.h),
                        MySpacing.width(9),
                        MyText.bodySmall(
                          "$numStudents students",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          Images.activeAssignment,
                          width: 24.w,
                          height: 24.h,
                        ),
                        MyText.bodySmall(
                          teacherFullName,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                        // 8.horizontalSpace,
                        // Optionally fill with teacher/assignment info if available from backend
                      ],
                    ).paddingSymmetric(horizontal: 20.w),
                    Row(
                      children: [
                        Image.asset(Images.calendar, width: 22.w, height: 22.h),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          "$term $year",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(Images.grade, width: 18.w, height: 18.h),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          grade,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20.w),
                    Row(
                      children: [
                        Image.asset(Images.fingerprint,
                            width: 18.w, height: 18.h),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          "$numFingerprints Writing Fingerprints Submitted",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            // onTap: () {
            //   // You can add View Details functionality here
            // },
            onTap: () async {
              final classId = data['class_id'];
              final teacherId = data['teacher_id'];
              final className = data['class_name'] ?? '';
              final teacherSalutation = data['teacher_salutation'] ?? '';
              final teacherFirstName = data['teacher_first_name'] ?? '';
              final teacherLastName = data['teacher_last_name'] ?? '';

              final detailController =
                  Get.isRegistered<SchoolClassViewController>()
                      ? Get.find<SchoolClassViewController>()
                      : Get.put(SchoolClassViewController());

              await detailController.fetchClassStudents(teacherId, classId);

              Get.toNamed("/school/classesdetail", arguments: {
                "classId": classId,
                "teacherId": teacherId,
                "className": className,
                "teacherFullName":
                    '$teacherSalutation $teacherFirstName $teacherLastName'
                        .trim(),
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
                    "View Details",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: contentTheme.k142228,
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
}
