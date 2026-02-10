import 'package:binary_success/controller/apps/student/student_writing_pad_controller.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/models/writing_pad_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentWritingpadLeft extends StatelessWidget {
  final StudentWritingPadController controller;
  final ContentTheme contentTheme;

  const StudentWritingpadLeft({
    super.key,
    required this.controller,
    required this.contentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MySpacing.fullWidth(context) * 0.21,
      color: const Color(0xFFE8F0FE),
      padding: EdgeInsets.only(left: 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Get.offAllNamed(
                  '/student/class'); // forces hard reload of that page
            },
            child: Image.asset(
              Images.logoIcon,
              width: MySpacing.fullWidth(context) * 0.08,
              fit: BoxFit.fitWidth,
              height: 70.h,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xffCB6CE6),
                      const Color(0xff004AAD),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(MySpacing.fullWidth(context) * 0.01),
                child: Text(
                  controller.getInitials(controller
                          .writingPadModel()
                          .taskSummary
                          ?.first
                          .learnerFirstName ??
                      ""),
                  style: GoogleFonts.roboto(
                      fontSize: MySpacing.fullWidth(context) * 0.015,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
              15.horizontalSpace,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "${controller.writingPadModel().taskSummary?.first.learnerFirstName}'s Writing Pad",
                      style: GoogleFonts.roboto(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w600,
                      )),
                  Text(
                    "${controller.writingPadModel().taskSummary?.first.gradeName ?? ""}\n${controller.writingPadModel().taskSummary?.last.className ?? ""}",
                    style: GoogleFonts.roboto(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xff9668D2),
                    ),
                  ),
                ],
              )
            ],
          ),
          30.verticalSpace,
          // Hide TabBar + TabBarView when task_type == "FINGERPRINT"
          if (controller.writingPadModel().taskSummary?.first.taskType !=
              "FINGERPRINT") ...[
            Obx(() => TabBar(
                  onTap: (value) {
                    controller.selectedTabIndex(value);
                  },
                  indicator: BoxDecoration(color: Colors.transparent),
                  padding: EdgeInsets.zero,
                  dividerHeight: 0.h,
                  isScrollable: true,
                  indicatorPadding: EdgeInsets.zero,
                  labelPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 2.w),
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(
                        iconMargin: EdgeInsets.zero,
                        child: tab(
                            title: "AI Helper",
                            isSelected:
                                controller.selectedTabIndex.value == 0)),
                    Tab(
                      iconMargin: EdgeInsets.zero,
                      child: tab(
                          title: "Rubric",
                          isSelected: controller.selectedTabIndex.value == 1),
                    ),
                    Tab(
                        iconMargin: EdgeInsets.zero,
                        child: tab(
                            title: "Examples",
                            isSelected: controller.selectedTabIndex.value == 2))
                  ],
                ).paddingOnly(right: 10)),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // AI Helper Tab
                  Container(
                    padding:
                        EdgeInsets.only(bottom: 20.w, right: 10.w, top: 20.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color(0xffEEECFF),
                          const Color(0xffEEECFF),
                          const Color(0xffDBEBFF),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(Images.elephantSmall,
                                width: 40.w, height: 40.h),
                            3.horizontalSpace,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Sage AI",
                                    style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        color: contentTheme.black,
                                        fontWeight: FontWeight.w500)),
                                Obx(() => Text(
                                      "${controller.aiPromptsUsed.value}/${controller.aiPromptsLimit} prompts used",
                                      style: GoogleFonts.inter(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                        fontStyle: FontStyle.italic,
                                        color: contentTheme.darkPurple,
                                      ),
                                    )),
                              ],
                            )
                          ],
                        ),
                        MySpacing.height(15),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  width: 0.5, color: contentTheme.kD9D9D9),
                              color: contentTheme.kFEFDFF),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                Images.bulb,
                                width: 22.w,
                                height: 22,
                              ),
                              12.horizontalSpace,
                              Text(
                                "Help me brainstorm!",
                                style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                              10.horizontalSpace,
                              Image.asset(
                                Images.star,
                                width: 16.w,
                                height: 17,
                              ),
                            ],
                          ),
                        ),
                        MySpacing.height(15),
                        // In the AI Helper Tab, replace the Expanded widget containing ListView with:
                        Expanded(
                          child: Obx(() => Padding(
                                padding: EdgeInsets.zero,
                                child: Scrollbar(
                                  thickness: 6.w,
                                  radius: Radius.circular(8.w),
                                  child: ListView.separated(
                                    padding: EdgeInsets.only(
                                        top: 10.h, bottom: 10.h),
                                    itemCount: controller.sageAIList.length,
                                    separatorBuilder: (context, index) =>
                                        MySpacing.height(10),
                                    itemBuilder: (context, index) {
                                      final message =
                                          controller.sageAIList[index];
                                      return Align(
                                        alignment: message.isMe
                                            ? Alignment.topRight
                                            : Alignment.topLeft,
                                        child: Container(
                                          margin: message.isMe
                                              ? EdgeInsets.only(left: 30.w)
                                              : EdgeInsets.only(right: 30.w),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 0.5,
                                                color: contentTheme.kD9D9D9),
                                            color: contentTheme.kFEFDFF,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 5),
                                          child: message.isThinking
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 14.w,
                                                      height: 14.h,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 1.5,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                Colors.blue),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    Text(
                                                      message.text,
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Text(
                                                  message.text,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )),
                        ),
                        Obx(() {
                          // Check your TRUE block condition (status, taskType, or other as required)

                          final status = controller.writingPadModel.value
                                  .taskSummary?.first.taskStatus ??
                              '';
                          final promptsUsed = controller.aiPromptsUsed.value;
                          final promptsLimit = controller.aiPromptsLimit;

                          // Disable input if status is SUBMITTED/GRADED OR if all prompts are used
                          final shouldDisableInput = status == 'SUBMITTED' ||
                              status == 'GRADED' ||
                              promptsUsed >= promptsLimit;

                          String hintText;
                          if (status == 'SUBMITTED' || status == 'GRADED') {
                            hintText =
                                "This chat is locked after submission/grade.";
                          } else if (promptsUsed >= promptsLimit) {
                            hintText =
                                "You have used all your available prompts.";
                          } else {
                            hintText = "Type your message...";
                          }

                          return Container(
                            margin: EdgeInsets.only(top: 10.h),
                            constraints: BoxConstraints(maxHeight: 120.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(width: 0.2),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    enabled: !shouldDisableInput,
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: shouldDisableInput
                                          ? Colors.grey
                                          : contentTheme.black,
                                    ),
                                    controller: controller.sageAI,
                                    maxLines: null,
                                    keyboardType: TextInputType.multiline,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 20.h),
                                      hintText: hintText,
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                    onFieldSubmitted: (value) {
                                      if (!shouldDisableInput &&
                                          value.trim().isNotEmpty) {
                                        // Clear the text field immediately
                                        controller.sageAI.clear();

                                        String studentResponse = Get.find<
                                                StudentWritingPadController>()
                                            .currentWritingContent
                                            .value;
                                        controller.listenToSSEWithDio(value,
                                            studentResponse); // Pass value instead of using controller.sageAI.text
                                      }
                                    },
                                  ),
                                ),
                                InkWell(
                                  onTap: shouldDisableInput
                                      ? null
                                      : () async {
                                          // Get the message before clearing
                                          String userMessage =
                                              controller.sageAI.text;
                                          // Clear the text field immediately
                                          controller.sageAI.clear();

                                          String studentResponse = controller
                                              .currentWritingContent.value;
                                          await controller.listenToSSEWithDio(
                                              userMessage,
                                              studentResponse); // Pass userMessage
                                        },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10.r),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xffCB6CE6),
                                          Color(0xff004AAD),
                                        ],
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 5.w, vertical: 10.h),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(Images.sendCross,
                                            width: 20.w, height: 20.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  // Rubrics Tab - scrollable area
                  Container(
                    padding:
                        EdgeInsets.only(bottom: 20.w, right: 3.w, top: 20.h),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                          const Color(0xffEEECFF),
                          const Color(0xffEEECFF),
                          const Color(0xffDBEBFF),
                        ])),
                    child: Obx(() {
                      final rubrics =
                          controller.writingPadModel.value.rubrics ?? [];
                      if (rubrics.isEmpty) {
                        return const Center(
                            child: Text("No rubrics available"));
                      }
                      final groupedRubrics = <String, List<Rubric>>{};
                      for (var rubric in rubrics) {
                        final title = rubric.rubricTitle ?? "";
                        groupedRubrics.putIfAbsent(title, () => []).add(rubric);
                      }
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Scrollbar(
                          thickness: 6.w,
                          radius: Radius.circular(8.w),
                          child: ListView.separated(
                            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                            itemCount: groupedRubrics.length,
                            separatorBuilder: (_, __) => MySpacing.height(10),
                            itemBuilder: (context, index) {
                              final title =
                                  groupedRubrics.keys.elementAt(index);
                              final rubricGroup = groupedRubrics[title]!;
                              return groupedRubricCard(title, rubricGroup);
                            },
                          ),
                        ),
                      );
                    }),
                  ),

                  // Examples Tab - scrollable area
                  Container(
                    padding: EdgeInsets.only(top: 20, right: 3.w, bottom: 20),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                          const Color(0xffEEECFF),
                          const Color(0xffEEECFF),
                          const Color(0xffDBEBFF),
                        ])),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xffCB6CE6),
                                        const Color(0xff004AAD),
                                      ],
                                    )),
                                width: 40,
                                height: 40,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(Images.exampleSearch,
                                        width: 24.w, height: 24.h),
                                  ],
                                )),
                            MySpacing.width(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Examples",
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: contentTheme.black,
                                    )),
                                Text(
                                  "Writing samples to guide you",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    color: contentTheme.darkPurple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        MySpacing.height(15),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: Scrollbar(
                              thickness: 6.w,
                              radius: Radius.circular(8.w),
                              child: SingleChildScrollView(
                                padding:
                                    EdgeInsets.only(top: 10.h, bottom: 10.h),
                                child: Obx(() {
                                  final examples = controller
                                          .writingPadModel.value.examples ??
                                      [];
                                  if (examples.isEmpty) {
                                    return Container(
                                      width: 320, // Fixed width
                                      // No height set, so it will depend on content (dynamic)
                                      alignment: Alignment.center,
                                      child: Text("No Example available"),
                                    );
                                  }
                                  final strongExamples = examples
                                      .where((e) => e.criterionType == 'STRONG')
                                      .toList();
                                  final weakExamples = examples
                                      .where((e) => e.criterionType == 'WEAK')
                                      .toList();
                                  final orderedExamples = [
                                    ...strongExamples,
                                    ...weakExamples
                                  ];
                                  return SizedBox(
                                    width: 400, // Fixed width for the card
                                    // No fixed height: height will expand with the content
                                    child: exampleCard(orderedExamples),
                                  );
                                }),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  // Rubric card with symmetric padding
  Widget groupedRubricCard(String title, List<Rubric> group) {
    final int commonPoints = group.isNotEmpty ? group.first.maxPoints ?? 0 : 0;

    // Force correct rubric order: STRONG, MEDIUM, WEAK
    final orderMap = {'STRONG': 0, 'MEDIUM': 1, 'WEAK': 2};
    final sortedGroup = List<Rubric>.from(group)
      ..sort((a, b) => (orderMap[a.criterionType ?? 'WEAK'] ?? 2)
          .compareTo(orderMap[b.criterionType ?? 'WEAK'] ?? 2));

    return MyContainer(
      color: Colors.white,
      borderColor: contentTheme.kD9D9D9,
      borderRadiusAll: 10,
      bordered: true,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.black,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "$commonPoints points",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: contentTheme.black,
                  ),
                ),
              ],
            ),
          ),
          MySpacing.height(8),
          ...sortedGroup.map((rubric) {
            final displayColor = rubric.criterionDisplayColorCd != null
                ? Color(int.parse(
                    rubric.criterionDisplayColorCd!.replaceFirst('#', '0xFF')))
                : Colors.black;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    Images.checkMark,
                    width: 24.w,
                    height: 24,
                    color: displayColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      rubric.criteriaDesc ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: displayColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget rubricCard(Rubric rubric) {
    Color displayColor = rubric.criterionDisplayColorCd != null
        ? Color(int.parse(
            rubric.criterionDisplayColorCd!.replaceFirst('#', '0xFF')))
        : Colors.black;

    return MyContainer(
      color: Colors.white,
      borderColor: contentTheme.kD9D9D9,
      borderRadiusAll: 10,
      bordered: true,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    rubric.rubricTitle ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.black,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  "${rubric.maxPoints} points",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: contentTheme.black,
                  ),
                ),
              ],
            ),
          ),
          MySpacing.height(8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  Images.checkMark,
                  width: 24.w,
                  height: 24,
                  color: displayColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    rubric.criteriaDesc ?? "",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: displayColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          MySpacing.height(8),
        ],
      ),
    );
  }

  Widget exampleCard(List<Example> examples) {
    return MyContainer(
      color: Colors.white,
      borderColor: contentTheme.kD9D9D9,
      borderRadiusAll: 10,
      bordered: true,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: examples.map((example) {
          final isStrong = example.criterionType == 'STRONG';
          final title = isStrong ? 'Strong Thesis' : 'Weak Thesis';
          final reasonTitle = isStrong ? 'Why It’s Strong:' : 'Why It’s Weak:';
          final titleColor =
              isStrong ? contentTheme.k0A8041 : contentTheme.k950909;
          final textColor =
              isStrong ? contentTheme.k0A8041 : contentTheme.k950909;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              Text(
                example.exampleThesis ?? "",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
              MySpacing.height(15),
              Text(
                reasonTitle,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              Text(
                example.exampleReason ?? "",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
              MySpacing.height(15),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget tab({required String title, bool isSelected = false}) {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? null : contentTheme.kD9D9EB,
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xffEEECFF),
                  const Color(0xffEEECFF),
                  const Color(0xffDBEBFF),
                ],
              )
            : null,
        border: Border(
          top: BorderSide(color: contentTheme.kCDCBE0, width: 1),
          right: BorderSide(color: contentTheme.kCDCBE0, width: 1),
          left: BorderSide(color: contentTheme.kCDCBE0, width: 1),
        ),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r)),
      ),
      child: MyText.titleMedium(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: contentTheme.k142228,
        ),
      ),
    );
  }
}
