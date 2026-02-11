import 'package:vantanceCA/controller/apps/teacher/teacher_writing_fingerprint_controller.dart';
import 'package:vantanceCA/helpers/utils/my_shadow.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/apps/teacher/dialog/teacher_writing_fingerprint_dialog.dart';
import 'package:vantanceCA/views/apps/teacher/widget/teacher_fingerprint_detail_widget.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherFingerprintDetail extends StatefulWidget {
  const TeacherFingerprintDetail({super.key});

  @override
  TeacherFingerprintDetailState createState() =>
      TeacherFingerprintDetailState();
}

class TeacherFingerprintDetailState extends State<TeacherFingerprintDetail>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherWritingFingerprintController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherWritingFingerprintController());

    final args = Get.arguments;
    final taskId = args?['taskId'];

    if (taskId != null && taskId.toString().isNotEmpty) {
      print("📩 ViewDetails Page received taskId: $taskId");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.getTaskStatsAndStudents(taskId);
      });
    } else {
      print("❌ No taskId passed to detail page; cannot load details.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 2,
      child: Obx(() {
        final details = controller.taskDetails.value;
        final stats = (details?.taskDetailsAndStats.isNotEmpty ?? false)
            ? details!.taskDetailsAndStats.first
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommanTitlebar(
              contentTheme: contentTheme,
              title: "Writing Fingerprint",
              subTitle: "Track and verify each student’s unique writing style",
              buttonTitle: "Schedule Writing Fingerprint Session",
              onTap: () {
                Get.dialog(
                  TeacherWritingFingerprintDialog(contentTheme: contentTheme),
                );
              },
            ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),

            // ===== Stats Cards Row =====
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    onTap: () {
                      controller.selectedIndex(1);
                      controller.pageController.jumpToPage(0);
                    },
                    child: buildCard(
                      stats != null ? stats.totalSubmitted.toString() : '0',
                      "Submissions",
                      false,
                      contentTheme.k0A8041,
                    ),
                  ).paddingOnly(right: 40.w),
                ),
                Expanded(
                  child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    onTap: () {
                      controller.selectedIndex(2);
                      controller.pageController.jumpToPage(1);
                    },
                    child: buildCard(
                      stats != null ? stats.totalMissing.toString() : '0',
                      "Missing",
                      false,
                      contentTheme.orange,
                    ),
                  ),
                ),
                // Removed Average Grade card as requested
              ],
            ).paddingOnly(
              left: 5.w,
              top: 17.h,
              right: MySpacing.fullWidth(context) * 0.04,
            ),

            // ===== PageView with Detail Widget =====
            SizedBox(
              height: MySpacing.fullHeight(context) * 0.64,
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : (details == null
                      ? Center(
                          child: Text(
                            "No data found for this task.",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : PageView(
                          controller: controller.pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            TeacherFingerprintDetailWidget(
                              contentTheme: contentTheme,
                            ),
                            TeacherFingerprintDetailWidget(
                              contentTheme: contentTheme,
                            ),
                            TeacherFingerprintDetailWidget(
                              contentTheme: contentTheme,
                            ),
                          ],
                        )),
            ),
          ],
        );
      }),
    );
  }

  // ===== Card builder =====
  Widget buildCard(
      String value, String title, bool isGradient, Color textColor) {
    return MyCard(
      shadow: isGradient ? MyShadow(color: Colors.transparent) : null,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      color: isGradient ? null : Colors.white,
      borderRadius: BorderRadius.circular(25.r),
      gradient: isGradient
          ? const LinearGradient(colors: [
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
            value,
            style: GoogleFonts.inter(
              fontSize: 36.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
