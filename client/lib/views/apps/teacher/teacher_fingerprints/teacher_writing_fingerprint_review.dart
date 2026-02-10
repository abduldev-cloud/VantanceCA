import 'package:binary_success/controller/apps/teacher/teacher_writing_fingerprint_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';

T? getArgument<T>(String key) =>
    Get.arguments != null && Get.arguments[key] != null
        ? Get.arguments[key] as T?
        : null;

class TeacherWritingFingerprintReview extends StatefulWidget {
  final String learnerId;
  final String taskId;

  const TeacherWritingFingerprintReview({
    super.key,
    required this.learnerId,
    required this.taskId,
  });

  @override
  TeacherWritingFingerprintReviewState createState() =>
      TeacherWritingFingerprintReviewState();
}

class TeacherWritingFingerprintReviewState
    extends State<TeacherWritingFingerprintReview>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherWritingFingerprintController controller;
  final _essayScrollController = ScrollController();

  late List<dynamic> submittedLearners;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherWritingFingerprintController());

    // Accept passed list and index, else fallback to single view
    submittedLearners = getArgument<List>('submittedLearners') ?? [];
    currentIndex = getArgument<int>('currentIndex') ?? 0;

    print(
        'Loaded review, submittedLearners: $submittedLearners, currentIndex: $currentIndex');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use navigation arguments, not widget properties
      final learnerId = getArgument<String>('learnerId') ?? widget.learnerId;
      final taskId = getArgument<String>('taskId') ?? widget.taskId;

      print('Calling API with learnerId: $learnerId, taskId: $taskId');

      controller.getFingerprintReviewDetails(
        learnerId: learnerId,
        taskId: taskId,
      );
    });
  }

  void _goToNextLearner() {
    print(
        '_goToNextLearner called, currentIndex: $currentIndex, total: ${submittedLearners.length}');
    if (submittedLearners.isEmpty ||
        currentIndex >= submittedLearners.length - 1) {
      print('No next learner, end of list');
      return;
    }

    final next = submittedLearners[currentIndex + 1];
    print('Navigating to next learner: $next');

    setState(() {
      currentIndex = currentIndex + 1;
    });

    controller.getFingerprintReviewDetails(
      learnerId: next['learnerId'],
      taskId: next['taskId'],
    );

    print('API called directly with next learner ID: ${next['learnerId']}');
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 2,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommanTitlebar(
                contentTheme: contentTheme,
                title: "Writing Fingerprint",
                subTitle:
                    "Track and verify each student's unique writing style",
                buttonTitle: "",
              ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
              15.verticalSpace,

              /// ✅ We replaced `Expanded` with `SizedBox` to control the height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.77,
                child: GetBuilder<TeacherWritingFingerprintController>(
                  init: controller,
                  builder: (controller) {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.reviewError.isNotEmpty) {
                      return Center(
                        child: Text(
                          controller.reviewError.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    final review = controller.fingerprintReviewDetails.value;
                    if (review == null) {
                      return const Center(
                        child: Text(
                          "No review details found.",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return MyCard(
                      margin: EdgeInsets.only(
                          right: MySpacing.fullWidth(context) * 0.04),
                      padding: EdgeInsets.symmetric(
                          vertical: 25.h, horizontal: 35.w),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      child: Scrollbar(
                        controller: _essayScrollController,
                        thumbVisibility: false,
                        child: SingleChildScrollView(
                          controller: _essayScrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.titleMedium(
                                        review.studentFullName ??
                                            "Unknown Student",
                                        style: GoogleFonts.inter(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w600,
                                          color: contentTheme.black,
                                        ),
                                      ),
                                      2.verticalSpace,
                                      MyText.bodySmall(
                                        review.taskTitle ??
                                            "Unknown Task Title",
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: contentTheme.k142228,
                                        ),
                                      ),
                                    ],
                                  ),
                                  30.horizontalSpace,
                                  Row(
                                    children: [
                                      Image.asset(
                                        Images.calendar,
                                        width: 15.w,
                                        height: 15.h,
                                      ),
                                      MySpacing.width(7),
                                      MyText.bodySmall(
                                        review.submittedAt != null
                                            ? _formatDate(review.submittedAt!)
                                            : "Date not available",
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: contentTheme.k142228,
                                        ),
                                      ),
                                    ],
                                  ),
                                  30.horizontalSpace,
                                  MyText.bodySmall(
                                    review.submittedWordCount != null
                                        ? "${review.submittedWordCount} words "
                                        : review.wordCount != null
                                            ? "${review.wordCount} words"
                                            : "Word count not available",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: contentTheme.k142228,
                                    ),
                                  ),
                                ],
                              ),
                              35.verticalSpace,
                              Obx(() {
                                final htmlContent =
                                    controller.fingerprintHtmlContent.value;
                                if (htmlContent.isNotEmpty) {
                                  return Html(
                                    data: htmlContent,
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(15.sp),
                                        color: contentTheme.k142228,
                                      ),
                                    },
                                  );
                                } else {
                                  return MyText.bodySmall(
                                    review.essayText ??
                                        "Essay text not available.",
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w400,
                                      color: contentTheme.k142228,
                                    ),
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 70,
            child: MouseRegion(
              cursor: SystemMouseCursors.click, // 👈 Shows hand cursor on hover
              child: GestureDetector(
                onTap: _goToNextLearner,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: (submittedLearners.isEmpty ||
                            currentIndex >= submittedLearners.length - 1)
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF1679FF), Color(0xFFBE40FE)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x22000058),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                    color: (submittedLearners.isEmpty ||
                            currentIndex >= submittedLearners.length - 1)
                        ? Colors.grey.shade300
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        color: (submittedLearners.isEmpty ||
                                currentIndex >= submittedLearners.length - 1)
                            ? Colors.grey
                            : Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "Next",
                        style: TextStyle(
                          color: (submittedLearners.isEmpty ||
                                  currentIndex >= submittedLearners.length - 1)
                              ? Colors.grey
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
