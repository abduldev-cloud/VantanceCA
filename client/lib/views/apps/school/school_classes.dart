import 'package:vantanceCA/controller/apps/school/school_classes_controller.dart';
import 'package:vantanceCA/helpers/utils/my_shadow.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/apps/school/widget/school_archived_class_widget.dart';
import 'package:vantanceCA/views/apps/school/widget/school_active_class_widget.dart';
import 'package:vantanceCA/views/apps/school/widget/school_total_student_widget.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SchoolClassesPage extends StatefulWidget {
  const SchoolClassesPage({super.key});

  @override
  State<SchoolClassesPage> createState() => _SchoolClassesPageState();
}

class _SchoolClassesPageState extends State<SchoolClassesPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late SchoolClassesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SchoolClassesController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 1,
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title Bar
            // CommanTitlebar(
            //   contentTheme: contentTheme,
            //   title: "Classes",
            //   subTitle: "Access class rosters and teacher progress",
            //   buttonTitle:
            //       (controller.selectedIndex.value == 3) ? "" : "Create Class",
            //   onTap: () {
            //     Get.dialog(
            //       AlertDialog(
            //         contentPadding:
            //             EdgeInsets.symmetric(horizontal: 35.w, vertical: 25.h),
            //         backgroundColor: contentTheme.kFEFDFF,
            //         shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(25)),
            //         content: SizedBox(
            //           width: MySpacing.fullWidth(context) * 0.35,
            //           child: Form(
            //             key: controller.formKey,
            //             child: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Text(
            //                   "Create Class",
            //                   style: GoogleFonts.inter(
            //                     fontSize: 26.sp,
            //                     fontWeight: FontWeight.w600,
            //                     color: contentTheme.k1C244B,
            //                   ),
            //                 ),
            //                 MyText.bodySmall(
            //                   style: GoogleFonts.inter(
            //                     fontSize: 16.sp,
            //                     fontWeight: FontWeight.w400,
            //                     color: contentTheme.k172640,
            //                   ),
            //                   "Please fill out this form to create your class",
            //                 ),
            //                 40.verticalSpace,
            //                 CommonDialogTextfield(
            //                     title: "Class Name",
            //                     controller: controller.className),
            //                 15.verticalSpace,
            //                 CommonDialogTextfield(
            //                     title: "Class Description",
            //                     controller: controller.classDescription),
            //                 15.verticalSpace,
            //                 CommonDialogDropdown(
            //                     itemList: controller.grades,
            //                     selectedValue: controller.selectedGrade.value,
            //                     contentTheme: contentTheme,
            //                     title: "Grade",
            //                     onChanged: (value) {
            //                       controller.selectedGrade.value =
            //                           value ?? controller.grades.first;
            //                     }),
            //                 15.verticalSpace,
            //                 CommonDialogTextfield(
            //                     title: "# Students",
            //                     controller: controller.maxLearners),
            //                 15.verticalSpace,
            //                 CommonDialogTextfield(
            //                     title: "Class Invite Code",
            //                     controller: controller.classInviteCode),
            //               ],
            //             ),
            //           ),
            //         ),
            //         actions: [
            //           Align(
            //             child: InkWell(
            //               onTap: () async {
            //                 if (controller.formKey.currentState!.validate()) {
            //                   final success = await controller.createClass();
            //                   if (success) {
            //                     Get.back();
            //                     controller.resetForm();
            //                   }
            //                 }
            //               },
            //               child: Container(
            //                 margin:
            //                     EdgeInsets.only(top: 10.h, bottom: 10.h),
            //                 padding: EdgeInsets.symmetric(
            //                     horizontal: 45.w, vertical: 7.h),
            //                 decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(50.r),
            //                     gradient: const LinearGradient(
            //                       begin: Alignment.centerLeft,
            //                       end: Alignment.centerRight,
            //                       colors: [
            //                         Color(0xff004AAD),
            //                         Color(0xffCB6CE6),
            //                       ],
            //                     )),
            //                 child: Text(
            //                   "Create",
            //                   style: GoogleFonts.inter(
            //                       fontSize: 14.sp,
            //                       fontWeight: FontWeight.w600,
            //                       color: contentTheme.kFEFDFF),
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // ),

            /// Top Tabs as Cards
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () => controller.onTabChanged(1),
                    child: buildCard(
                      controller.activeClassCount.toString(),
                      "Active Classes",
                      controller.selectedIndex.value == 1,
                      contentTheme.k0A8041,
                    ).paddingOnly(right: 40),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () => controller.onTabChanged(2),
                    child: buildCard(
                      controller.archivedClassCount.toString(),
                      "Archived Classes",
                      controller.selectedIndex.value == 2,
                      contentTheme.orange,
                    ).paddingOnly(right: 40),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () => controller.onTabChanged(3),
                    child: buildCard(
                      controller.totalStudentCount.toString(),
                      "Total Current Students",
                      controller.selectedIndex.value == 3,
                      contentTheme.darkPurple,
                    ),
                  ),
                ),
              ],
            ).paddingOnly(bottom: 20.h, left: 5.w, top: 17.h),

            /// Page Content
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Active Tab
                  controller.isLoading.value &&
                          controller.selectedIndex.value == 1
                      ? const Center(child: CircularProgressIndicator())
                      : SchoolActiveClassWidget(
                          contentTheme: contentTheme,
                          classList: controller.classList,
                        ),

                  // Archived Tab
                  controller.isLoading.value &&
                          controller.selectedIndex.value == 2
                      ? const Center(child: CircularProgressIndicator())
                      : SchoolArchivedClassWidget(
                          contentTheme: contentTheme,
                          classList: controller.classList,
                        ),

                  // Total Students Tab
                  controller.isLoading.value &&
                          controller.selectedIndex.value == 3
                      ? const Center(child: CircularProgressIndicator())
                      : SchoolTotalStudentWidget(
                          contentTheme: contentTheme,
                          totalStudents: controller.totalStudentCount,
                          students: controller.studentsList,
                        ),
                ],
              ),
            ),
          ],
        ).paddingOnly(
          bottom: MySpacing.fullHeight(context) * 0.045,
          right: MySpacing.fullWidth(context) * 0.06,
        ),
      ),
    );
  }

  /// Card Styling
  Widget buildCard(
      String value, String title, bool isSelected, Color textColor) {
    return MyCard(
      shadow: isSelected ? MyShadow(color: Colors.transparent) : null,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      color: isSelected ? null : Colors.white,
      borderRadius: BorderRadius.circular(25),
      gradient: isSelected
          ? const LinearGradient(
              colors: [Color(0xffEEECFF), Color(0xffEEECFF), Color(0xffDBEBFF)],
            )
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
            value,
            style: GoogleFonts.inter(
              color: textColor,
              fontSize: 35.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
