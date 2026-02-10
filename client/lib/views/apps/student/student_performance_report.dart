import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/apps/student/student_performance_controller.dart';
import 'package:binary_success/models/student_performance_report_question_model.dart';
import 'widget/student_question_card_dialog.dart';
import 'widget/student_performance_report_filter_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class PerformanceReportPage extends StatelessWidget {
  const PerformanceReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate controller
    final StudentPerformanceController controller =
        Get.put(StudentPerformanceController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final filteredQuestions = controller.filteredQuestions;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Header (with padding to match card alignment)
            LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumb items stacked
                        _buildMobileBreadcrumbItem("Paper ", "Accountancy"),
                        const SizedBox(height: 4),
                        _buildMobileBreadcrumbItem(
                            "Unit ", "Meaning Scope of Accounting"),
                        const SizedBox(height: 4),
                        _buildMobileBreadcrumbItem("Questions ", "8/10"),

                        const SizedBox(height: 12),

                        // Metadata stacked
                        _buildMobileBreadcrumbItem("Foundation: ", "May 2025"),
                        const SizedBox(height: 4),
                        _buildMobileBreadcrumbItem(
                            "Complete Date: ", "01/12/2025 | Daily"),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                            children: const [
                              TextSpan(text: "Paper "),
                              TextSpan(
                                  text: "Accountancy",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: " / Unit "),
                              TextSpan(
                                  text: "Meaning Scope of Accounting",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: " / Questions "),
                              TextSpan(
                                  text: "8/10",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                            children: const [
                              TextSpan(text: "Foundation: "),
                              TextSpan(
                                  text: "May 2025",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              TextSpan(text: " | Complete Date: "),
                              TextSpan(
                                  text: "01/12/2025 | Daily",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Title & Filter (with padding to match card alignment)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use a breakpoint, e.g. 600
                  bool isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
                    // Mobile: Wrap allows them to stack if needed, or we can force stacking
                    return Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 16.0,
                      children: [
                        Text(
                          "Performance Report",
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                            letterSpacing: 0,
                            color: Colors.black,
                          ),
                        ),
                        FilterDropdown(
                          onSelected: (status) {
                            controller.setFilter(status);
                          },
                        ),
                      ],
                    );
                  } else {
                    // Desktop: Row ensures spaceBetween works perfectly to push Filter to far right
                    return SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Performance Report",
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                          ),
                          FilterDropdown(
                            onSelected: (status) {
                              controller.setFilter(status);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // Stats Row
            // Stats Row
            LayoutBuilder(builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 600;
              final statsRow = Row(
                children: [
                  _buildStatLabel("NA", "Not Answered"),
                  _buildStatLabel("WA", "Wrong"),
                  _buildStatLabel("PA", "Partially"),
                  _buildStatLabel("CA", "Correct"),
                ],
              );

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isMobile
                    ? statsRow
                    : Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child:
                                  Container()), // Spacer matching Question Text
                          const SizedBox(width: 40),
                          Expanded(
                            flex: 1,
                            child: statsRow,
                          ),
                        ],
                      ),
              );
            }),

            const SizedBox(height: 32),

            // Question List
            ...filteredQuestions.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: QuestionCard(
                    question: q,
                    onTap: () {
                      // TODO: Navigate to the details page
                    },
                  ),
                )),
          ],
        ),
      );
    });
  }

  Widget _buildStatLabel(String text, String label) {
    return Expanded(
      child: Center(
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Colors.black)),
      ),
    );
  }

  Widget _buildMobileBreadcrumbItem(String label, String value) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
            fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500),
        children: [
          TextSpan(text: label),
          TextSpan(
              text: value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
