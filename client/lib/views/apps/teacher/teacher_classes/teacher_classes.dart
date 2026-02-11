import 'package:vantanceCA/controller/apps/teacher/teacher_classes_controller.dart';
import 'package:vantanceCA/helpers/utils/my_shadow.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/views/apps/teacher/widget/teacher_class_widget.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherClassesPage extends StatefulWidget {
  const TeacherClassesPage({super.key});

  @override
  TeacherClassesPageState createState() => TeacherClassesPageState();
}

class TeacherClassesPageState extends State<TeacherClassesPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherClassesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherClassesController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
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
                title: "Classes",
                subTitle: "Manage your classes and view student rosters",
                buttonTitle:
                    "", //Added a null valued button Title to avoid the Error
                // buttonTitle: "Create Class",
                // onTap: () {
                //   Get.dialog(
                //     AlertDialog(
                //       contentPadding: EdgeInsets.symmetric(
                //           horizontal: 35.w, vertical: 25.h),
                //       backgroundColor: contentTheme.kFEFDFF,
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(25.r)),
                //       content: SizedBox(
                //         width: MySpacing.fullWidth(context) * 0.35,
                //         child: Form(
                //           key: controller.formKey,
                //           child: Column(
                //             mainAxisSize: MainAxisSize.min,
                //             children: [
                //               Text(
                //                 "Create Class",
                //                 style: GoogleFonts.inter(
                //                   fontSize: 26.sp,
                //                   fontWeight: FontWeight.w600,
                //                   color: contentTheme.k1C244B,
                //                 ),
                //               ),
                //               MyText.bodySmall(
                //                 style: GoogleFonts.inter(
                //                   fontSize: 16.sp,
                //                   fontWeight: FontWeight.w400,
                //                   color: contentTheme.k172640,
                //                 ),
                //                 "Please fill out this form to create your class",
                //               ),
                //               40.verticalSpace,
                //               CommonDialogTextfield(
                //                   title: "Class Name",
                //                   hintText: "Enter class name",
                //                   controller: controller.className,
                //                 ),
                //               15.verticalSpace,
                //               CommonDialogTextfield(
                //                   title: "Class Description",
                //                   hintText: "Enter class description",
                //                   controller: controller.classDescription),
                //               15.verticalSpace,
                //               CommonDialogDropdown(
                //                   itemList: ["Grade 7", "Grade 8", "Grade 9", "Grade 10", "Grade 11", "Grade 12"],
                //                   selectedValue: "Grade 7",
                //                   contentTheme: contentTheme,
                //                   title: "Grade",
                //                   onChanged: (value) {
                //                     controller.classGrade.text = value ?? "Grade 7";
                //                   }),
                //               15.verticalSpace,
                //               CommonDialogNumberfield(
                //                   title: "# Students",
                //                   hintText: "Enter number of students",
                //                   controller: controller.maxLearners),
                //               15.verticalSpace,
                //             ],
                //           ),
                //         ),
                //       ),
                //       actions: [
                //         Align(
                //           child: InkWell(
                //             onTap: () async {
                //               if (controller.formKey.currentState!.validate()) {
                //                 final success = await controller.createClass();
                //                 if (success) {
                //                   Get.back();
                //                   controller.clearForm();
                //                 }
                //               }
                //             },
                //             child: Container(
                //               margin: EdgeInsets.only(top: 10.h, bottom: 10),
                //               padding: EdgeInsets.symmetric(
                //                   horizontal: 45.w, vertical: 7),
                //               decoration: BoxDecoration(
                //                   borderRadius: BorderRadius.circular(50.r),
                //                   gradient: LinearGradient(
                //                     begin: Alignment.centerLeft,
                //                     end: Alignment.centerRight,
                //                     colors: [
                //                       Color(0xff004AAD),
                //                       Color(0xffCB6CE6),
                //                     ],
                //                   )),
                //               child: Text(
                //                 "Create",
                //                 style: GoogleFonts.inter(
                //                     fontSize: 14.sp,
                //                     fontWeight: FontWeight.w600,
                //                     color: contentTheme.kFEFDFF),
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   );
                // },
              ),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => InkWell(
                          splashFactory: NoSplash.splashFactory,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () => controller.onTab(0), // Active
                          child: buildCard(
                            controller.activeClassesCount.value.toString(),
                            "Active Classes",
                            controller.selectedIndex.value == 0,
                            contentTheme.k0A8041,
                          ),
                        ).paddingOnly(right: 40.w)),
                  ),
                  Expanded(
                    child: Obx(() => InkWell(
                          splashFactory: NoSplash.splashFactory,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () => controller.onTab(1), // Archived
                          child: buildCard(
                            controller.archivedClassesCount.value.toString(),
                            "Archived Classes",
                            controller.selectedIndex.value == 1,
                            contentTheme.orange,
                          ),
                        ).paddingOnly(right: 40.w)),
                  ),
                  Expanded(
                    child: Obx(() => InkWell(
                          splashFactory: NoSplash.splashFactory,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          // onTap: () => controller.onTab(2), // Students
                          child: buildCard(
                            controller.totalCurrentStudents.value.toString(),
                            "Total Current Students",
                            controller.selectedIndex.value == 2,
                            contentTheme.darkPurple,
                          ),
                        )),
                  ),
                ],
              ).paddingOnly(bottom: 20.h, left: 5.w, top: 17.h, right: 5.w),
              SizedBox(
                  height: MySpacing.fullHeight(context) * 0.58,
                  child: PageView(
                    controller: controller.pageController,
                    physics: NeverScrollableScrollPhysics(),
                    //
                    onPageChanged: controller.onTab,
                    children: [
                      TeacherClassWidget(
                          contentTheme: contentTheme, controller: controller),
                      TeacherClassWidget(
                          contentTheme: contentTheme, controller: controller),
                      TeacherClassWidget(
                          contentTheme: contentTheme, controller: controller)
                    ],
                  ))
            ],
          ).paddingOnly(
              right: MySpacing.fullWidth(context) * 0.04,
              bottom: MySpacing.fullHeight(context) * 0.05);
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
          4.verticalSpace,
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
      padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 25.h),
      color: isGradiant ? null : Colors.white,
      borderRadius: BorderRadius.circular(25.r),
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
          MyText.bodySmall(percentage,
              style: GoogleFonts.inter(
                fontSize: 35.sp,
                color: textColor,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
