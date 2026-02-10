import 'package:binary_success/controller/apps/teacher/teacher_grading_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/views/apps/teacher/dialog/teacher_create_assignment_diaog.dart';
import 'package:binary_success/views/apps/teacher/widget/teacher_grading_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherGradingPage extends StatefulWidget {
  const TeacherGradingPage({super.key});

  @override
  TeacherGradingPageState createState() => TeacherGradingPageState();
}

class TeacherGradingPageState extends State<TeacherGradingPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherGradingController controller;

@override
void initState() {
  super.initState();

  controller = Get.put(TeacherGradingController());

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    int initialTab = int.tryParse(Get.parameters['tab'] ?? '') ?? 0;
    await controller.switchTab(initialTab);
  });
}


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Layout(
        selectedPage: 4,
        child: Obx(() {
          final selected = controller.selectedTabIndex.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Title Bar =====
              CommanTitlebar(
                contentTheme: contentTheme,
                title: "Grading",
                subTitle: "Review and grade student work in one place",
                buttonTitle: "Create Assignment",
                onTap: () => Get.dialog(
                  TeacherCreateAssignmentDiaog(contentTheme: contentTheme),
                ),
              ).paddingOnly(
                right: MySpacing.fullWidth(context) * 0.04,
              ),

              // ===== Tabs Row =====
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.switchTab(0),
                      child: _tabCard(
                        title: "Pending Review",
                        count: "${controller.submittedCount.value}",
                        isSelected: selected == 0,
                        accent: contentTheme.orange,
                      ),
                    ).paddingOnly(right: 40.w),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.switchTab(1),
                      child: _tabCard(
                        title: "Graded Assignments",
                        count: "${controller.gradedCount.value}",
                        isSelected: selected == 1,
                        accent: contentTheme.k0A8041,
                      ),
                    ).paddingOnly(right: 40.w),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.switchTab(2),
                      child: _tabCard(
                        title: "Total Assignments",
                        count: "${controller.totalCount.value}",
                        isSelected: selected == 2,
                        accent: contentTheme.darkPurple,
                      ),
                    ),
                  ),
                ],
              ).paddingOnly(
                left: 5.w,
                top: 17.h,
                right: MySpacing.fullWidth(context) * 0.04,
              ),

              // ===== Table Section =====
              Expanded(
                child: controller.isLoading.value
                    ? Center(
                        child: CircularProgressIndicator(
                          color: contentTheme.darkPurple,
                        ),
                      )
                    : controller.allTasks.isEmpty
                        ? Center(
                            child: MyText.bodySmall(
                              "No Data Found",
                              style: GoogleFonts.inter(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.k142228,
                              ),
                            ),
                          )
                        : IndexedStack(
                            index: selected,
                            children: [
                              // ✅ Pending Review
                              TeacherGradingWidget(
                                contentTheme: contentTheme,
                                list: controller.allTasks
                                    .where((e) =>
                                        e.status == "SUBMITTED" &&
                                        (e.teacherGrade == null ||
                                            e.teacherGrade == 0))
                                    .toList(),
                              ),
                              // ✅ Graded
                              TeacherGradingWidget(
                                contentTheme: contentTheme,
                                list: controller.allTasks
                                    .where((e) =>
                                      e.status == "GRADED" ||
                                      ((e.teacherGrade ?? 0) > 0))
                                    .toList(),
                            ),
                              // ✅ All Assignments
                              TeacherGradingWidget(
                                contentTheme: contentTheme,
                                list: controller.allTasks.toList(),
                              ),
                            ],
                          ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---- Tab Card Widget
  Widget _tabCard({
    required String title,
    required String count,
    required bool isSelected,
    required Color accent,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xffE6F0FF) : Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(
          color: isSelected ? Colors.transparent : const Color(0xffE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium(
            title,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: contentTheme.k142228,
            ),
          ),
          MyText.bodySmall(
            count,
            style: GoogleFonts.inter(
              fontSize: 36.sp,
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
