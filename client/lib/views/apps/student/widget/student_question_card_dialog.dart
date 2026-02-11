import 'package:flutter/material.dart';
import 'package:vantanceCA/models/student_performance_report_question_model.dart';
import 'package:vantanceCA/app_colors.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final VoidCallback? onTap;

  const QuestionCard({super.key, required this.question, this.onTap});

  Color _getStatusColor(QuestionStatus status) {
    switch (status) {
      case QuestionStatus.correctAnswered: return AppColors.correct;
      case QuestionStatus.wrongAnswered: return AppColors.wrong;
      case QuestionStatus.partiallyAnswered: return AppColors.partial;
      case QuestionStatus.notAnswered: return AppColors.partial; // Using orangeish for NA text as per image design logic often varies, but let's stick to partial color or generic
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isNA = question.status == QuestionStatus.notAnswered;
    Color statusColor = isNA ? AppColors.partial : _getStatusColor(question.status); 

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16), // Reduce width via margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 16,
            offset: const Offset(0, 0), // Shadow on all sides
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(builder: (context, constraints) {
                  final bool isMobile = constraints.maxWidth < 600;

                  // Components
                  final title = Text(
                    "Question ${question.id}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );

                  final statusText = Text(
                    question.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );

                  final description = Text(
                    question.description,
                    style: const TextStyle(
                        color: Colors.black, height: 1.5, fontSize: 13),
                  );

                  final progressBar = LayoutBuilder(
                    builder: (context, constraints) {
                      double width = constraints.maxWidth;
                      return Container(
                        height: 4,
                        alignment: Alignment.centerLeft,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.centerLeft,
                          children: [
                            // Background Track
                            Container(
                              width: double.infinity,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            // Foreground Indicator
                            Builder(builder: (context) {
                              // Calculate position based on Status strictly
                              double start = 0.0;
                              double end = 0.0;

                              // Slots: NA(0-0.25), WA(0.25-0.5), PA(0.5-0.75), CA(0.75-1.0)
                              switch (question.status) {
                                case QuestionStatus.notAnswered:
                                  start = 0.0;
                                  end = 0.25;
                                  break;
                                case QuestionStatus.wrongAnswered:
                                  start = 0.25;
                                  end = 0.50;
                                  break;
                                case QuestionStatus.partiallyAnswered:
                                  start = 0.50;
                                  end = 0.75;
                                  break;
                                case QuestionStatus.correctAnswered:
                                  start = 0.75;
                                  end = 1.0;
                                  break;
                              }

                              return Positioned(
                                left: width * start,
                                width: width * (end - start),
                                child: Container(
                                  height: 4, // Slightly reduced thickness
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        const SizedBox(height: 8),
                        statusText,
                        const SizedBox(height: 12),
                        description,
                        const SizedBox(height: 24),
                        progressBar,
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              const SizedBox(height: 8),
                              statusText,
                              const SizedBox(height: 8),
                              description,
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              const SizedBox(height: 30), // Alignment spacer
                              progressBar,
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
