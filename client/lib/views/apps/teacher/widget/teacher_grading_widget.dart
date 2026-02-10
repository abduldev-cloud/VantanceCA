import 'package:binary_success/helpers/services/notification_service.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/models/teachers_grading_model.dart';
import 'package:binary_success/widgets/custom_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/controller/apps/teacher/teacher_grading_controller.dart';

class TeacherGradingWidget extends StatefulWidget {
  final ContentTheme contentTheme;
  final List<TeachersGradingModel> list;
  final String status; // for filtering + header

  const TeacherGradingWidget({
    super.key,
    required this.contentTheme,
    required this.list,
    this.status = "all",
  });

  @override
  State<TeacherGradingWidget> createState() => _TeacherGradingWidgetState();
}

class _TeacherGradingWidgetState extends State<TeacherGradingWidget> {
  String searchQuery = '';
  String sortOption = 'Newest';
  int currentPage = 1;
  final int itemsPerPage = 6;

  // Column widths
  final double wStudent = 140;
  final double wFingerprint = 140;
  final double wTitle = 240;
  final double wSubmitted = 120;
  final double wWordCount = 120;
  final double wGrade = 120;
  final double wAction = 140;

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==== Formatters ====
  String _formatWordCount(int? wc) {
    if (wc == null || wc == 0) return "-";
    return NumberFormat.decimalPattern().format(wc);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat("MMM dd, yyyy hh:mm a").format(date);
  }

  String _headerTitle() {
    switch (widget.status.toLowerCase()) {
      case "pending":
        return "Pending Reviews";
      case "submitted":
        return "Submitted Assignments";
      case "graded":
        return "Graded Assignments";
      case "assigned":
        return "Assigned Tasks";
      default:
        return "All Assignments";
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacherGradingController>();
    final q = searchQuery.trim().toLowerCase();

    return Obx(() {
      // 1. Start with whichever tab list
      List<TeachersGradingModel> pageItems;
      switch (controller.selectedTabIndex.value) {
        case 0:
          pageItems = controller.submittedTasks;
          break;
        case 1:
          pageItems = controller.gradedTasks;
          break;
        default:
          pageItems = controller.allTasks;
      }

      // ==== FILTER ====
      pageItems = pageItems.where((m) {
        if (q.isEmpty) return true;
        return (m.learnerFirstName ?? '').toLowerCase().contains(q) ||
            (m.learnerLastName ?? '').toLowerCase().contains(q);
      }).toList();

      // 🔹 Apply sort
      pageItems.sort((a, b) {
        final aDate = a.dueDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.dueDateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        switch (sortOption) {
          case 'learner A → Z':
            return (a.fullName ?? '').compareTo(b.fullName ?? '');
          case 'learner Z → A':
            return (b.fullName ?? '').compareTo(a.fullName ?? '');
          case 'Oldest':
            return aDate.compareTo(bDate);
          case 'Newest':
            return bDate.compareTo(aDate);
          case 'Word Count ↑':
            return (a.wordCount ?? 0).compareTo(b.wordCount ?? 0);
          case 'Word Count ↓':
            return (b.wordCount ?? 0).compareTo(a.wordCount ?? 0);
          default:
            return 0;
        }
      });

      final pageIndex = controller.currentPage.value;
      final totalItems = controller.totalCount.value;
      final totalPages = controller.totalPages.value;

      final showingFrom =
          pageItems.isEmpty ? 0 : ((pageIndex - 1) * controller.pageSize) + 1;
      final showingTo =
          pageItems.isEmpty ? 0 : showingFrom + pageItems.length - 1;

      return MyCard.circular(
        margin: EdgeInsets.only(
          bottom: 60.h,
          left: 5.w,
          top: 30.h,
          right: MySpacing.fullWidth(context) * 0.04,
        ),
        borderRadiusAll: 25.r,
        bordered: false,
        padding: EdgeInsets.only(left: 0, top: 30.h, bottom: 0, right: 0),
        child: Center(
          // 👈 centers inside card
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MySpacing.fullWidth(context) * 1, // 👈 shrink table width
            ),
            child: Column(
              children: [
// ==== HEADER ====
                if (widget.list.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Row(
                      children: [
                        Text(
                          "All Students",
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black, // ✅ changed to dark black
                          ),
                        ),
                        const Spacer(),
                        // ==== Search Box ====
                        SizedBox(
                          width: 180.w,
                          height: 36.h,
                          child: TextField(
                            controller: searchController,
                            onChanged: (v) => setState(() {
                              searchQuery = v;
                              currentPage = 1;
                            }),
                            style: GoogleFonts.inter(fontSize: 12.sp),
                            decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xff9A9A9B),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 22,
                                color: Color(0xff6B7280),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 8.h),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide:
                                    const BorderSide(color: Color(0xffE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: const BorderSide(
                                    color: Color(
                                        0xffE5E7EB)), // ✅ remove blue outline on focus
                              ),
                            ),
                          ),
                        ),
                        16.horizontalSpace,
                        // ==== Sort Dropdown ====
                        CustomPopupMenu(
                          backdrop: true,
                          onChange: (_) {},
                          menu: MyContainer.bordered(
                            borderRadiusAll: 8.r,
                            borderColor: widget.contentTheme.borderColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 6.h),
                            child: Row(
                              children: [
                                Text("Sort by : ",
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: widget.contentTheme.k7E7E7E)),
                                Text(sortOption,
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: widget.contentTheme.k142228)),
                                4.horizontalSpace,
                                Icon(
                                  Icons.keyboard_arrow_down_sharp,
                                  size: 20,
                                  color: widget.contentTheme.k3D3C42,
                                ),
                              ],
                            ),
                          ),
                          menuBuilder: (_) => Material(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                'Newest',
                                'Oldest',
                                'Student A → Z',
                                'Student Z → A',
                                'Word Count ↑',
                                'Word Count ↓'
                              ].map((option) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      sortOption = option;
                                      currentPage = 1;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12.w, vertical: 8.h),
                                    child: Text(option,
                                        style:
                                            GoogleFonts.inter(fontSize: 12.sp)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                16.verticalSpace,

// ==== TABLE OR EMPTY STATE ====
                if (pageItems.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            Images.grading,
                            height: 64.sp,
                            width: 64.sp,
                            color: Colors
                                .grey[400], // only works with monochrome assets
                          ),
                          SizedBox(height: 16.h),
                          MyText.bodySmall(
                            // 👇 check if it’s a search empty or full empty
                            q.isNotEmpty
                                ? "No assignments found"
                                : "No assignments available",
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8.h),
                          MyText.bodySmall(
                            q.isNotEmpty
                                ? ""
                                : "Assignments will appear here once available",
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // ==== TABLE HEADER ====
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                    child: Row(
                      children: [
                        _headerCell("Student", wStudent),
                        _headerCell("Fingerprint", wFingerprint),
                        _headerCell("Assignment", wTitle),
                        _headerCell("Submitted", wSubmitted),
                        _headerCell("Word Count", wWordCount),
                        _headerCell("Grade", wGrade),
                        _headerCell("Action", wAction),
                      ],
                    ),
                  ),
                  Divider(color: const Color(0xffE5E7EB), thickness: 1),

                  // ==== TABLE BODY ====

                  Expanded(
                    child: ListView.separated(
                      itemCount: pageItems.length,
                      separatorBuilder: (_, __) => Divider(
                        color: const Color(0xffE5E7EB),
                        thickness: 1,
                        indent: 24.w,
                        endIndent: 24.w,
                      ),
                      itemBuilder: (context, index) {
                        final m = pageItems[index];
                        final graded = (m.teacherGrade ?? 0) > 0;
                        final teacherGrade = m.teacherGrade ?? 0;
                        final totalPoints = m.totalPoints ??
                            1; // use 1 or any fallback to avoid divide by zero
                        final gradeDisplay =
                            graded ? "$teacherGrade/$totalPoints" : "-";

                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 8.h),
                          child: Row(
                            children: [
                              _centerCell(
                                Text(
                                  m.fullName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                wStudent,
                              ),
                              _centerCell(
                                m.hasFingerprint
                                    ? const Icon(Icons.fingerprint,
                                        size: 25, color: Colors.black)
                                    : const Text("-",
                                        textAlign: TextAlign.center),
                                wFingerprint,
                              ),
                              _centerCell(
                                Text(
                                  m.assignmentTitle,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                wTitle,
                              ),
                              _centerCell(
                                Text(
                                  _formatDate(m.submittedDateTime),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                wSubmitted,
                              ),
                              _centerCell(
                                Text(
                                  _formatWordCount(m.wordCount),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                wWordCount,
                              ),
                              _centerCell(
                                Text(
                                  gradeDisplay,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                wGrade,
                              ),
                              _centerCell(
                                (m.status == "SUBMITTED" && !graded)
                                    ? _actionButtonStyled(
                                        label: "Review",
                                        type: "review",
                                        onTap: () {
                                          Get.toNamed("/teacher/gradingreview",
                                              arguments: m);
                                        },
                                      )
                                    : (m.status == "GRADED" || graded)
                                        ? _actionButtonStyled(
                                            label: "View",
                                            type: "view",
                                            onTap: () {
                                              Get.toNamed(
                                                  "/teacher/gradingreview",
                                                  arguments: m);
                                            },
                                          )
                                        : _actionButtonStyled(
                                            label: "Remind",
                                            type: "remind",
                                            onTap: () {
                                              final uid = m.userId ?? "";
                                              if (uid.isEmpty) {
                                                print(
                                                    "User ID is missing for this learner.");
                                                return;
                                              }
                                              print(
                                                  "Sending reminder to user ID: $uid");
                                              remindStudent(
                                                  uid, m.assignmentTitle);
                                            },
                                          ),
                                wAction,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // ==== PAGINATION FOOTER ====
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Text(
                          "Showing $showingTo of $totalItems learners",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xff6B7280),
                          ),
                        ),
                        const Spacer(),
                        _pagination(
                          totalPages: controller.totalPages.value,
                          current: controller.currentPage.value,
                          onJump: (p) => controller.goToPage(p),
                          onPrev: controller.currentPage.value > 1
                              ? () => controller
                                  .goToPage(controller.currentPage.value - 1)
                              : null,
                          onNext: controller.currentPage.value <
                                  controller.totalPages.value
                              ? () => controller
                                  .goToPage(controller.currentPage.value + 1)
                              : null,
                        ),
                      ],
                    ),
                  )
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  void remindStudent(String? userId, String assignmentTitle) async {
    if (userId == null || userId.isEmpty) {
      print("Cannot send reminder: userId is null or empty.");
      Get.snackbar("Error", "User ID is missing. Cannot send reminder.");
      return;
    }

    try {
      await NotificationService.sendRemindNotification(
        userId: userId,
        title: "Assignment Reminder",
        message:
            "You have a pending assignment: $assignmentTitle. Please complete it soon.",
      );
      print(
          "Reminder notification sent: userId=$userId, assignment=$assignmentTitle");
      Get.snackbar("Success", "Reminder sent to student.");
    } catch (e) {
      print("Failed to send reminder notification: $e");
      Get.snackbar("Error", "Failed to send reminder notification.");
    }
  }

  Widget _headerCell(String text, double width) => SizedBox(
        width: width.w,
        child: Center(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff142228),
            ),
          ),
        ),
      );

  Widget _centerCell(Widget child, double width) =>
      SizedBox(width: width.w, child: Center(child: child));

  Widget _actionButtonStyled({
    required String label,
    required String type,
    required VoidCallback onTap,
  }) {
    Color? bgColor;
    Gradient? gradient;
    Color borderColor = Colors.transparent;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case "review":
        gradient = const LinearGradient(
          colors: [Color(0xFF9C27FF), Color(0xFF0066FF)],
        );
        icon = Icons.remove_red_eye;
        break;
      case "view":
        bgColor = Colors.white;
        borderColor = const Color(0xffC6C3C3);
        icon = Icons.remove_red_eye;
        textColor = const Color(0xff142228);
        break;
      case "remind":
        bgColor = const Color(0xffE0E7FF);
        icon = Icons.notifications_none;
        textColor = const Color(0xff111827);
        break;
      default:
        icon = Icons.help;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110.w,
        height: 34.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.r),
          color: bgColor,
          gradient: gradient,
          border: Border.all(width: 1, color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: textColor),
            6.horizontalSpace,
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ==== Pagination ====
  Widget _pagination({
    required int totalPages,
    required int current,
    required void Function(int) onJump,
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    List<int> numbersToShow() {
      final set = <int>{1, totalPages};
      for (var p = current - 1; p <= current + 1; p++) {
        if (p >= 1 && p <= totalPages) set.add(p);
      }
      if (totalPages >= 4) set.add(2);
      final list = set.toList()..sort();
      return list;
    }

    Widget box({
      required Widget child,
      required VoidCallback? onTap,
      bool active = false,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xff6441EF), Color(0xff0D63E0)],
                  )
                : null,
            color: active ? null : const Color(0xffF3F4F6),
          ),
          child: DefaultTextStyle.merge(
            style: GoogleFonts.inter(
              color: active ? Colors.white : const Color(0xff374151),
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12.sp,
            ),
            child: child,
          ),
        ),
      );
    }

    final nums = numbersToShow();
    final children = <Widget>[
      box(child: const Icon(Icons.chevron_left, size: 16), onTap: onPrev),
    ];

    for (int i = 0; i < nums.length; i++) {
      final n = nums[i];
      final prev = i == 0 ? null : nums[i - 1];
      if (prev != null && n - prev > 1) {
        children.add(Text("…",
            style: GoogleFonts.inter(color: const Color(0xff6B7280))));
      }
      children.add(box(
        child: Text("$n"),
        active: n == current,
        onTap: () => onJump(n),
      ));
    }

    children.add(
        box(child: const Icon(Icons.chevron_right, size: 16), onTap: onNext));
    return Row(children: children);
  }
}
