import 'package:binary_success/controller/apps/teacher/teacher_assignments_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherAssignmentView extends StatefulWidget {
  const TeacherAssignmentView({super.key});

  @override
  TeacherAssignmentViewState createState() => TeacherAssignmentViewState();
}

class TeacherAssignmentViewState extends State<TeacherAssignmentView>
    with SingleTickerProviderStateMixin, UIMixin {
  late TeacherAssignmentsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TeacherAssignmentsController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 3,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommanTitlebar(
                contentTheme: contentTheme,
                title: "To Kill a Mockingbird Human Nature Essay",
                subTitle:
                    "Analyze justice, bias, and conscience in To Kill a Mockingbird",
                buttonTitle: "",
              ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
              MySpacing.height(15),
              MyCard(
                  height: MySpacing.fullHeight(context) * 0.50,
                  margin: EdgeInsets.only(
                      right: MySpacing.fullWidth(context) * 0.04),
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText.titleMedium(
                                  "Assignment Details",
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: contentTheme.black,
                                  ),
                                ),
                                MySpacing.height(2),
                                MyText.bodySmall(
                                  "Due Date: Sep 21, 2025 02:30 PM",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: contentTheme.k142228,
                                  ),
                                ),
                              ],
                            ),
                            MySpacing.width(70),
                            Row(
                              children: [
                                MyText.bodySmall(
                                  "Target Words: 2,000 words",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: contentTheme.k142228,
                                  ),
                                ),
                              ],
                            ),
                            MySpacing.width(80),
                          ],
                        ),
                        MySpacing.height(25),
                        MyText.bodySmall(
                          "To Kill a Mockingbird explores how people respond to injustice in a divided society. Choose one character and explain how their experience with prejudice, empathy, or moral courage shapes their understanding of right and wrong. What does Harper Lee suggest about justice or human nature through this character’s journey? Use specific examples from the text to support your response.",
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                  )),
              MySpacing.height(20),
              MyCard(
                  margin: EdgeInsets.only(
                      right: MySpacing.fullWidth(context) * 0.04),
                  padding: EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rubric Criteria",
                        style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.black),
                      ),
                      MySpacing.height(10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1, color: contentTheme.borderColor),
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xffEEECFF),
                                  Color(0xffEEECFF),
                                  Color(0xffDBEBFF),
                                ])),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText.bodyMedium(
                                  "Character Insight",
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: contentTheme.black,
                                  ),
                                ),
                                MyText.bodyMedium(
                                  "4 points",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: contentTheme.black,
                                  ),
                                ),
                              ],
                            ),
                            MySpacing.height(15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(Images.checkMark,
                                    width: 20,
                                    height: 20,
                                    color: contentTheme.k0A8041),
                                MySpacing.width(10),
                                Expanded(
                                  child: Text(
                                    "Strong explanation of how the character is shaped by key themes",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: contentTheme.k0A8041),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(Images.checkMark,
                                    width: 20,
                                    height: 20,
                                    color: contentTheme.kA9730F),
                                MySpacing.width(10),
                                Expanded(
                                  child: Text(
                                    "General or somewhat underdeveloped explanation",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: contentTheme.kA9730F),
                                  ),
                                ),
                              ],
                            ).paddingSymmetric(vertical: 13),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(Images.checkMark,
                                    width: 20,
                                    height: 20,
                                    color: contentTheme.k950909),
                                MySpacing.width(10),
                                Expanded(
                                  child: Text(
                                    "Vague or unclear understanding",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: contentTheme.k950909),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ))
            ],
          );
        },
      ),
    );
  }
}
