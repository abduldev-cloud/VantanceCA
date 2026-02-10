import 'package:binary_success/models/teacher_fingerprint_model.dart';
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

class TeacherFingerprintWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  final List<TeachersFingerPrintModel> modelList;
  const TeacherFingerprintWidget({
    super.key,
    required this.contentTheme,
    required this.modelList,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding:
          EdgeInsets.only(left: 5.w, top: 15.h, bottom: 10.h, right: 30.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final TeachersFingerPrintModel model = modelList[index];
        return classesCard(
          classDescription: model.classDescription ?? "",
          className: model.className ?? "",
          fingerPrintCount: model.fingerprintsSubmitted ?? 0,
          gradeName: model.gradeName ?? "",
          status: model.classStatus ?? "",
          studentCount: model.totalStudents ?? 0,
          teacherName: model.teacherName ?? "",
          term: model.term ?? "",
          academicYear: model.academicYear ?? 0,
          numActiveAssignments: model.numActiveAssignments ?? 0,
          lastFingerprintTaskId: model.taskId ?? "", // ✅ use getter from model
        );
      },
      separatorBuilder: (context, index) => MySpacing.height(25),
      itemCount: modelList.length,
    );
  }

  Widget classesCard({
    required String className,
    required String status,
    required int studentCount,
    required int fingerPrintCount,
    required String term,
    required String gradeName,
    required String classDescription,
    required String teacherName,
    required int academicYear,
    required int numActiveAssignments,
    required String lastFingerprintTaskId,
  }) {
    return MyCard.circular(
      borderRadiusAll: 25.r,
      bordered: true,
      padding:
          EdgeInsets.only(left: 25.w, top: 18.h, bottom: 18.h, right: 40.w),
      child: Row(
        children: [
          // ===== Left content =====
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
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, bottom: 4.h, top: 2.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          width: 2.w,
                          color: contentTheme.k0A8041.withValues(alpha: 0.50),
                        ),
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: MyText.bodyMedium(
                        status.toLowerCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.k0A8041,
                        ),
                      ),
                    )
                  ],
                ),
                MyText.bodySmall(
                  classDescription,
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
                        Image.asset(Images.students,
                            width: 19.w, height: 21.h),
                        MySpacing.width(9),
                        MyText.bodySmall(
                          "$studentCount students",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.activeAssignment,
                            width: 24.w, height: 24.h),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          "$numActiveAssignments Active Assignments",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.calendar,
                            width: 22.w, height: 22.h),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          "$term, $academicYear",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.grade, width: 18.w, height: 18.h),
                        8.horizontalSpace,
                        MyText.bodySmall(
                          gradeName,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(Images.fingerprint,
                            width: 18.w, height: 18.h),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          "$fingerPrintCount Writing Fingerprints submitted",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),

          // ===== View Details Button =====
          InkWell(
            onTap: () {
              if (lastFingerprintTaskId.isNotEmpty) {
                Get.toNamed(
                  "/teacher/fingerprintdetail",
                  arguments: {"taskId": lastFingerprintTaskId},
                );
              } else {
                Get.snackbar(
                  "Error",
                  "No fingerprint task available for this class",
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: MyContainer.bordered(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
              borderColor: contentTheme.borderColor,
              borderRadiusAll: 25.r,
              bordered: true,
              child: Row(
                children: [
                  Image.asset(Images.rightArrow,
                      width: 15.w, height: 14.h),
                  10.horizontalSpace,
                  MyText.bodyMedium(
                    "View Details",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
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
