import 'package:vantanceCA/controller/apps/teacher/teacher_writing_fingerprint_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/views/apps/teacher/dialog/teacher_writing_fingerprint_dialog.dart';
import 'package:vantanceCA/views/apps/teacher/widget/teacher_fingerprint_widget.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherWritingFingerprintPage extends StatefulWidget {
  const TeacherWritingFingerprintPage({super.key});

  @override
  TeacherWritingFingerprintPageState createState() =>
      TeacherWritingFingerprintPageState();
}

class TeacherWritingFingerprintPageState
    extends State<TeacherWritingFingerprintPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherWritingFingerprintController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherWritingFingerprintController());
  }


  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 2,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Obx(() => controller.isLoading.value
              ? SizedBox(
                  height: MySpacing.fullHeight(context) * 0.80,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: contentTheme.darkPurple,
                  )))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommanTitlebar(
                        contentTheme: contentTheme,
                        title: "Writing Fingerprint",
                        subTitle:
                            "Track and verify each student’s unique writing style",
                        buttonTitle: "Schedule Writing Fingerprint Session",
                        onTap: () {
                          Get.dialog(
                            TeacherWritingFingerprintDialog(
                                contentTheme: contentTheme),
                          );
                        },
                      ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ Writing Fingerprint Alert Button
SizedBox(
  width: MySpacing.fullHeight(context) * 0.15,
  height: MySpacing.fullHeight(context) * 0.14,
  child: InkWell(
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    onTap: () {
      // Navigate to teacher dashboard
      Get.toNamed('/teacher/dashboard');
    },
    child: MyCard(
      padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 3.w),
      color: Colors.white,
      borderRadius: BorderRadius.circular(25.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Images.gradiantFingerprint,
              width: 50.w, height: 50.h),
          10.verticalSpace,
          Text(
            "View Alerts",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: contentTheme.primary,
            ),
          )
        ],
      ),
    ),
  ),
),

                          25.horizontalSpace,

                          // ✅ Setup Guide Box styled like design
                          Expanded(
                            flex: 5,
                            child: InkWell(
                              splashFactory: NoSplash.splashFactory,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () {
                                controller.selectedIndex(2);
                                controller.pageController.jumpToPage(1);
                              },
                              child: MyCard(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20.h, horizontal: 22.w),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Writing Fingerprint Set-up Guide",
                                      style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: contentTheme.k142228),
                                    ),
                                    6.verticalSpace,
                                    Text(
                                      "Schedule a Writing Fingerprint session early in the school year during class time. Make sure it’s closely monitored with no AI use or outside help. This creates each student’s baseline writing style for future authorship checks.",
                                      style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                          color: contentTheme.k142228),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).paddingOnly(bottom: 15.h, left: 5.w, top: 20.h),

                     // ✅ Fingerprint Widget Section - Fixed Scrollable
SizedBox(
  height: MySpacing.fullHeight(context) * 0.65,
  child: SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min, // This is key!
      children: [
        TeacherFingerprintWidget(
          contentTheme: contentTheme,
          modelList: controller.teacherFingerPrintList,
        ),
      ],
    ),
  ),
),

                    ],
                  ),
                ));
        },
      ),
    );
  }

  Widget buildSorting(String title, String description) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.labelLarge(title),
          MySpacing.height(4),
          MyText.bodySmall(description)
        ],
      ),
    );
  }

  Widget classesSubCard() {
    return MyCard.circular(
        borderRadiusAll: 25,
        bordered: true,
        padding: EdgeInsets.only(left: 25, top: 18, bottom: 18, right: 40),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(
                    "Author Spotlight: George Orwell",
                    fontSize: 20,
                    fontWeight: 600,
                    color: contentTheme.k142228,
                  ),
                  MyText.bodySmall(
                    "Writing with clarity, conviction, and political purpose",
                    fontSize: 14,
                    fontWeight: 400,
                    color: contentTheme.k142228,
                  ),
                  MySpacing.height(25),
                  Row(
                    children: [
                      Row(
                        children: [
                          Image.asset(Images.calendar, width: 18, height: 18),
                          MySpacing.width(9),
                          MyText.bodySmall(
                            "September 25, 2025",
                            fontSize: 12,
                            fontWeight: 400,
                            color: contentTheme.k142228,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset(Images.clock, width: 18, height: 18),
                          MySpacing.width(9),
                          MyText.bodySmall(
                            "11:59 PM",
                            fontSize: 12,
                            fontWeight: 400,
                            color: contentTheme.k142228,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 20),
                      Row(
                        children: [
                          Image.asset(Images.classes, width: 18, height: 18),
                          MySpacing.width(9),
                          MyText.bodySmall(
                            "Creative Writing 101",
                            fontSize: 12,
                            fontWeight: 400,
                            color: contentTheme.k142228,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset(Images.grade, width: 18, height: 18),
                          MySpacing.width(9),
                          MyText.bodySmall(
                            "Grade 11",
                            fontSize: 12,
                            fontWeight: 400,
                            color: contentTheme.k142228,
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 20),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Get.toNamed("/student/writingpad");
              },
              child: MyContainer.bordered(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                borderColor: contentTheme.borderColor,
                borderRadiusAll: 25,
                bordered: true,
                child: Row(
                  children: [
                    Image.asset(Images.eye, width: 20, height: 20),
                    MySpacing.width(8),
                    MyText.bodyMedium(
                      "Start Assignment",
                      fontSize: 16,
                      fontWeight: 600,
                      color: contentTheme.k142228,
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget buildCard(
    String percentage,
    String title,
  ) {
    return MyCard(
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 25.w),
      color: Colors.white,
      borderRadius: BorderRadius.circular(25.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium(
            title,
            style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: contentTheme.k142228),
          ),
          5.verticalSpace,
          MyText.bodySmall(
            percentage,
            style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: contentTheme.k142228),
          ),
        ],
      ),
    );
  }
}
