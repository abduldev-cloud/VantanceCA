import 'package:binary_success/controller/apps/school/school_classes_controller.dart';
import 'package:binary_success/helpers/utils/my_shadow.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/models/teacher_classes_model.dart';
import 'package:binary_success/views/apps/teacher/widget/teacher_classes_detail_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/controller/apps/teacher/teacher_view_class_controller.dart';

class TeacherClassesDetailPage extends StatefulWidget {
  const TeacherClassesDetailPage({super.key});

  @override
  TeacherClassesDetailPageState createState() =>
      TeacherClassesDetailPageState();
}

class TeacherClassesDetailPageState extends State<TeacherClassesDetailPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late SchoolClassesController controller;
  final TeacherClassViewController teacherViewController =
      Get.put(TeacherClassViewController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(SchoolClassesController());
  }

  @override
  Widget build(BuildContext context) {
    final ClassInfo classInfo = Get.arguments as ClassInfo;
    return Layout(
      selectedPage: 1,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommanTitlebar(
                contentTheme: contentTheme,
                title: classInfo.className ?? "-",
                subTitle: "${classInfo.numStudents ?? 0} students",
                // buttonTitle: "Create Class",
                // onTap: () {
                //   Get.dialog(
                //     AlertDialog(
                //       contentPadding: EdgeInsets.symmetric(
                //           horizontal: 35.w, vertical: 25.h),
                //       backgroundColor: contentTheme.kFEFDFF,
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(25)),
                //       content: SizedBox(
                //         width: MySpacing.fullWidth(context) * 0.35,
                //         child: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Text(
                //               "Create Class",
                //               style: GoogleFonts.inter(
                //                 fontSize: 26.sp,
                //                 fontWeight: FontWeight.w600,
                //                 color: contentTheme.k1C244B,
                //               ),
                //             ),
                //             MyText.bodySmall(
                //               style: GoogleFonts.inter(
                //                 fontSize: 16.sp,
                //                 fontWeight: FontWeight.w400,
                //                 color: contentTheme.k172640,
                //               ),
                //               "Please fill out this form to create your class",
                //             ),
                //             40.verticalSpace,
                //             CommonDialogTextfield(
                //                 title: "Class Name",
                //                 controller: TextEditingController()),
                //             15.verticalSpace,
                //             CommonDialogTextfield(
                //                 title: "Class Description",
                //                 controller: TextEditingController()),
                //             15.verticalSpace,
                //             CommonDialogTextfield(
                //                 title: "Grade",
                //                 controller: TextEditingController()),
                //             15.verticalSpace,
                //             CommonDialogDropdown(
                //                 itemList: [],
                //                 selectedValue: "",
                //                 contentTheme: contentTheme,
                //                 title: "# Students"),
                //             15.verticalSpace,
                //             CommonDialogTextfield(
                //                 title: "Class Invite Code",
                //                 controller: TextEditingController()),
                //           ],
                //         ),
                //       ),
                //       actions: [
                //         Align(
                //           child: Container(
                //             margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                //             padding: EdgeInsets.symmetric(
                //                 horizontal: 45.w, vertical: 7.h),
                //             decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(50.r),
                //                 gradient: LinearGradient(
                //                   begin: Alignment.centerLeft,
                //                   end: Alignment.centerRight,
                //                   colors: [
                //                     Color(0xff004AAD),
                //                     Color(0xffCB6CE6),
                //                   ],
                //                 )),
                //             child: Text(
                //               "Create",
                //               style: GoogleFonts.inter(
                //                   fontSize: 14.sp,
                //                   fontWeight: FontWeight.w600,
                //                   color: contentTheme.kFEFDFF),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   );
                // },
              ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
              Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final summary = teacherViewController.classSummary.value;
                      final totalSubmitted =
                          summary?.totalSubmitted?.toString() ?? "-";
                      return InkWell(
                        splashFactory: NoSplash.splashFactory,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          controller.selectedIndex(1);
                          controller.pageController.jumpToPage(0);
                        },
                        child: buildCard(totalSubmitted, "Submissions", false,
                            contentTheme.k0A8041),
                      ).paddingOnly(right: 40.w);
                    }),
                  ),
                  Expanded(
                    child: Obx(() {
                      final summary = teacherViewController.classSummary.value;
                      final totalPending =
                          summary?.totalPendingReview?.toString() ?? "-";
                      return InkWell(
                        splashFactory: NoSplash.splashFactory,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          controller.selectedIndex(2);
                          controller.pageController.jumpToPage(1);
                        },
                        child: buildCard(totalPending, "Pending", false,
                            contentTheme.orange),
                      ).paddingOnly(right: 40.w);
                    }),
                  ),
                  Expanded(
                    child: Obx(() {
                      final summary = teacherViewController.classSummary.value;
                      final avgGrade =
                          summary?.avgTeacherGrade?.toStringAsFixed(1) ?? "-";
                      return InkWell(
                        splashFactory: NoSplash.splashFactory,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onTap: () {
                          controller.selectedIndex(3);
                          controller.pageController.jumpToPage(2);
                        },
                        child: buildCard(avgGrade, "Average Score", false,
                            contentTheme.darkPurple),
                      );
                    }),
                  ),
                ],
              ).paddingOnly(
                  bottom: 20.h,
                  left: 5.w,
                  top: 17.h,
                  right: MySpacing.fullWidth(context) * 0.04),
              SizedBox(
                  height: MySpacing.fullHeight(context) * 0.62,
                  child: PageView(
                    controller: controller.pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      TeacherClassesDetailWidget(contentTheme: contentTheme),
                      TeacherClassesDetailWidget(contentTheme: contentTheme),
                      TeacherClassesDetailWidget(contentTheme: contentTheme)
                    ],
                  ))
            ],
          );
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
      String percentage, String title, bool isGradiant, Color textColor) {
    return MyCard(
      shadow: isGradiant ? MyShadow(color: Colors.transparent) : null,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      color: isGradiant ? null : Colors.white,
      borderRadius: BorderRadius.circular(25),
      gradient: isGradiant
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
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          MyText.bodySmall(
            percentage,
            style: GoogleFonts.inter(
              fontSize: 35.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
