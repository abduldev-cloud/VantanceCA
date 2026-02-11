import 'package:vantanceCA/controller/apps/student/student_assignment_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/helpers/widgets/my_text_style.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/models/student_assignment_model.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/custom_pop_menu.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StudentAssignmentPage extends StatefulWidget {
  const StudentAssignmentPage({super.key});

  @override
  StudentAssignmentPageState createState() => StudentAssignmentPageState();
}

class StudentAssignmentPageState extends State<StudentAssignmentPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late StudentAssignmentController controller;
  final RxString _sortLabel = 'Earliest Due Date'.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(StudentAssignmentController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      shrinkContent: true,
      selectedPage: 1,
      child: GetBuilder(
        init: controller,
        builder: (_) {
          return Obx(
            () => controller.isLoading.value
                ? SizedBox(
                    height: MySpacing.fullHeight(context) * 0.80,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 34), // Added top spacing
                      MyText.titleMedium(
                        "Practices",
                        style: GoogleFonts.inter(
                          fontSize: 22.sp, // Reduced to 24sp (was 28)
                          letterSpacing: -0.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyText.bodySmall(
                        "View current and upcoming practices.",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.changeTab(0),
                              child: buildCard(
                                "${controller.activeTasksCount}",
                                "Pending",
                                controller.selectedTabIndex.value == 0,
                                const Color(0xFFFF3B30),
                                null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.changeTab(1),
                              child: buildCard(
                                "${controller.pendingReviewCount}",
                                "Upcoming",
                                controller.selectedTabIndex.value == 1,
                                const Color(0xFFFF9500),
                                null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.changeTab(2),
                              child: buildCard(
                                "${controller.gradedCount}",
                                "Completed",
                                controller.selectedTabIndex.value == 2,
                                const Color(0xFF34C759),
                                EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ).paddingOnly(top: 24.h),
                      // === Search + Sort Row ===
                      Padding(
                        padding: EdgeInsets.only(
                          top: 30.h,
                          bottom: 30.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 280,
                              child: TextFormField(
                                maxLines: 1,
                                style: MyTextStyle.bodyMedium(),
                                onChanged: controller.applySearch,
                                decoration: InputDecoration(
                                  hintText: "Search",
                                  hintStyle: MyTextStyle.bodySmall(
                                    fontSize: 12.sp,
                                    xMuted: true,
                                    color: const Color(0xff9A9A9B),
                                  ),
                                  border: outlineInputBorder,
                                  enabledBorder: outlineInputBorder,
                                  focusedBorder: outlineInputBorder,
                                  prefixIcon: const Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      FeatherIcons.search,
                                      size: 14,
                                    ),
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 30,
                                    maxWidth: 30,
                                    minHeight: 32,
                                    maxHeight: 32,
                                  ),
                                  contentPadding: MySpacing.xy(16, 12),
                                  isCollapsed: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                ),
                              ),
                            ),
                            MySpacing.width(15),
                            CustomPopupMenu(
                              backdrop: true,
                              onChange: (_) {},
                              menu: Material(
                                color: Colors.transparent,
                                child: MyContainer.bordered(
                                  borderRadiusAll: 10.r,
                                  borderColor: contentTheme.borderColor,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 6.h),
                                  child: Row(
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              alignment:
                                                  PlaceholderAlignment.middle,
                                              child: Icon(
                                                Icons.filter_list,
                                                size: 16,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                            WidgetSpan(
                                              child: SizedBox(width: 8),
                                            ),
                                            TextSpan(
                                              text: "Filter",
                                              style: MyTextStyle.bodySmall(
                                                fontSize: 12.sp,
                                                fontWeight: 600,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              menuBuilder: (_) => buildSortingMenu(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          final tasks = controller.filteredTasks;
                          if (tasks.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    controller.emptyAsset,
                                    width: 80,
                                    height: 80,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    controller.emptyMessage,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: EdgeInsets.only(
                              bottom: MySpacing.fullHeight(context) * 0.02,
                            ),
                            shrinkWrap: true,
                            itemCount: tasks.length,
                            separatorBuilder: (context, index) =>
                                MySpacing.height(20),
                            itemBuilder: (context, index) {
                              final AssignmentTask task = tasks[index];
                              String buttonLabel = "Start Practices";
                              return classesSubCard(
                                task: task,
                                promt: task.taskTitle ?? "",
                                gradeName: task.classGrade ?? "",
                                className: task.className ?? "",
                                classID: task.classId ?? "",
                                dueDate: _parseDate(task.dueDate, task.dueTime),
                                studentName: controller.learnerName,
                                buttonLabel: buttonLabel,
                              );
                            },
                          );
                        }),
                      )
                    ],
                  ).paddingOnly(
                    right: 40,
                    bottom: MySpacing.fullHeight(context) * 0.05,
                    left: 40,
                  ),
          );
        },
      ),
    );
  }

  Widget buildSortingMenu() {
    return Material(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText.labelLarge("Sort by : "),
            MySpacing.height(8),
            _sortOption(
                label: 'Earliest Due Date',
                onTap: () {
                  controller.sortBy('Earliest Due Date');
                  _sortLabel.value = 'Earliest Due Date';
                  Get.back();
                }),
            MySpacing.height(6),
            _sortOption(
                label: 'Latest Due Date',
                onTap: () {
                  controller.sortBy('Latest Due Date');
                  _sortLabel.value = 'Latest Due Date';
                  Get.back();
                }),
          ],
        ),
      ),
    );
  }

  Widget _sortOption({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            8.horizontalSpace,
            MyText.bodySmall(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: contentTheme.k142228,
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String? dateString, String? timeString) {
    try {
      if (dateString == null || dateString.isEmpty) {
        throw Exception("Missing date");
      }
      String cleanDate = dateString.replaceAll(RegExp(r'\s+'), ' ').trim();
      String cleanTime = (timeString ?? "12:00 AM").trim();
      String combined = "$cleanDate $cleanTime";
      final formatter = DateFormat("MMMM d, yyyy hh:mm a");
      return formatter.parse(combined);
    } catch (e) {
      return DateTime(2000, 1, 1);
    }
  }

  Widget classesSubCard({
    required AssignmentTask task,
    required String promt,
    required String gradeName,
    required String className,
    required String classID,
    required DateTime dueDate,
    required String studentName,
    required String buttonLabel,
  }) {
    // Design Match: White clean card with subtle shadow/border
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEBEB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title (Left) + Button (Right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodyMedium(
                      promt.isNotEmpty ? promt : "Assignment Title",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp, // Reduced from 18
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w700, // Bold
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    MyText.bodySmall(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp, // Reduced from 14
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Pill Button "Start Practices"
              InkWell(
                onTap: () {
                  controller.startAssignment(task);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8), // Smaller padding
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFD0D0D0)),
                  ),
                  child: MyText.bodySmall(
                    buttonLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp, // Reduced from 14
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16), // Reduced height

          // Row 2: Metadata Icons
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _buildMetaItem(Images.book, className),
              _buildMetaItem(
                  Images.calendar, DateFormat("MMMM d, yyyy").format(dueDate)),
              _buildMetaItem(Images.clock, "00:10:30"),
              // _buildMetaItem(Images.help, "20"),
              _buildMetaItem(Images.calendar, "Weekly"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String iconPath, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(iconPath,
            width: 14,
            height: 14,
            color: const Color(0xFF555555)), // Smaller icon
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12.sp, // Reduced from 14
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  Widget buildCard(
    String count,
    String title,
    bool isSelected,
    Color textColor,
    EdgeInsetsGeometry? margin,
  ) {
    // Design Match: Always White Clean Card
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white, // Always white
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFEBEBEB), width: 1), // Static neutral border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            count,
            style: GoogleFonts.inter(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
