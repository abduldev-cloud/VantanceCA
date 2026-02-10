import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';

import 'package:binary_success/models/teacher_view_class_model.dart';
import 'package:binary_success/controller/apps/school/school_class_view_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:get/get.dart';

class SchoolArchivedClassWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  final List<dynamic> classList;

  const SchoolArchivedClassWidget({
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
            // Icon
            Image.asset(
              Images.classes,
              width: 60,
              height: 60,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),

            // Main message
            Text(
              "No Archived Classes Available",
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
              "Classes will appear here once archived",
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
    final className = data['class_name'] ?? '-';
    final description = data['description'] ?? '';
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
          /// Left: main class info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + status badge
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
                    SizedBox(width: 10.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          width: 2,
                          color: contentTheme.orange.withAlpha(127),
                        ),
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: MyText.bodyMedium(
                        "archived",
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.orange,
                        ),
                      ),
                    ),
                  ],
                ),

                /// Description
                MyText.bodySmall(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: contentTheme.k142228,
                  ),
                ),

                SizedBox(height: 25.h),

                /// Info row
                Row(
                  children: [
                    /// Students count
                    Row(
                      children: [
                        Image.asset(Images.students, width: 19.w, height: 21.h),
                        MySpacing.width(9),
                        MyText.bodySmall(
                          "$numStudents students",
                          fontSize: 12.sp,
                          fontWeight: 400,
                          color: contentTheme.k142228,
                        ),
                      ],
                    ),

                    /// Calendar
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Image.asset(Images.calendar,
                              width: 22.w, height: 22.h),
                          SizedBox(width: 9.w),
                          MyText.bodySmall(
                            "$term $year",
                            fontSize: 12.sp,
                            fontWeight: 400,
                            color: contentTheme.k142228,
                          ),
                        ],
                      ),
                    ),

                    /// Grade
                    Row(
                      children: [
                        Image.asset(Images.grade, width: 18.w, height: 18.h),
                        SizedBox(width: 9.w),
                        MyText.bodySmall(
                          grade,
                          fontSize: 12.sp,
                          fontWeight: 400,
                          color: contentTheme.k142228,
                        ),
                      ],
                    ),

                    /// Fingerprints count
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        children: [
                          Image.asset(Images.fingerprint,
                              width: 18.w, height: 18.h),
                          SizedBox(width: 9.w),
                          MyText.bodySmall(
                            "$numFingerprints Writing Fingerprints submitted",
                            fontSize: 12.sp,
                            fontWeight: 400,
                            color: contentTheme.k142228,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Right: view details button
          InkWell(
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
                    fontSize: 16.sp,
                    fontWeight: 600,
                    color: contentTheme.k142228,
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
