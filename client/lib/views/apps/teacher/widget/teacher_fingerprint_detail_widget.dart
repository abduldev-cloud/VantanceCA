import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/helpers/widgets/my_text_style.dart';
import 'package:vantanceCA/images.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/controller/apps/teacher/teacher_writing_fingerprint_controller.dart';
import 'package:vantanceCA/models/teacher_fingerprint_detail_model.dart';

class TeacherFingerprintDetailWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  const TeacherFingerprintDetailWidget({super.key, required this.contentTheme});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacherWritingFingerprintController>();

    return Obx(() {
      final List<TaskDetailsPerStudent> students = controller.pagedStudents;
      final totalStudents =
          controller.taskDetails.value?.taskDetailsPerStudent.length ?? 0;
      final totalPages = (totalStudents / controller.pageSize).ceil();

      return MyCard.circular(
        margin: EdgeInsets.only(
          bottom: 10.h,
          left: 5.w,
          top: 25.h,
          right: MySpacing.fullWidth(context) * 0.04,
        ),
        borderRadiusAll: 25.r,
        bordered: false,
        padding:
            EdgeInsets.only(left: 40.w, top: 30.h, bottom: 0.h, right: 40.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ==== HEADER ====
              Row(
                children: [
                  MyText.bodySmall(
                    "All Students",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.black,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 280.w,
                    child: TextFormField(
                      onChanged: (value) =>
                          controller.searchStudents(value), // <-- ADD THIS LINE
                      maxLines: 1,
                      style: MyTextStyle.bodyMedium(),
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: MyTextStyle.bodySmall(
                          fontSize: 12.sp,
                          xMuted: true,
                          color: const Color(0xff9A9A9B),
                        ),
                        border: _borderStyle(),
                        enabledBorder: _borderStyle(),
                        focusedBorder: _borderStyle(),
                        prefixIcon: const Align(
                          alignment: Alignment.center,
                          child: Icon(FeatherIcons.search, size: 14),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 30.w,
                          maxWidth: 30.w,
                          minHeight: 32.h,
                          maxHeight: 32.h,
                        ),
                        contentPadding: MySpacing.xy(16.w, 12.h),
                        isCollapsed: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                  ),
                  15.horizontalSpace,
                  PopupMenuButton(
                    onSelected: (value) => controller
                        .setSortBy(value.toString()), // <-- ADD THIS LINE
                    itemBuilder: (_) =>
                        controller.sortOptions // <-- USE CONTROLLER OPTIONS
                            .map((behavior) => PopupMenuItem(
                                  value: behavior.toString(),
                                  height: 32.h,
                                  child: MyText.bodySmall(
                                    behavior,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: contentTheme.k142228,
                                    ),
                                  ),
                                ))
                            .toList(),
                    color: contentTheme.background,
                    child: MyContainer.bordered(
                      borderRadiusAll: 10.r,
                      borderColor: contentTheme.borderColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      child: Row(
                        children: [
                          Obx(() => Text.rich(TextSpan(children: [
                                // <-- WRAP WITH OBX
                                TextSpan(
                                    text: "Sort by : ",
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: contentTheme.k7E7E7E)),
                                TextSpan(
                                    text: controller
                                        .currentSortText, // <-- USE CONTROLLER VALUE
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: contentTheme.k142228)),
                              ]))),
                          5.horizontalSpace,
                          Icon(Icons.keyboard_arrow_down_sharp,
                              color: contentTheme.k3D3C42)
                        ],
                      ),
                    ),
                  )
                ],
              ),

              10.verticalSpace,

              // Conditional content for no students
              students.isEmpty
                  ? Container(
                      width: double.infinity,
                      height: 400.h,
                      alignment: Alignment.center,
                      child: MyText.bodyMedium(
                        "No students found",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.k142228,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dividerThickness: 1,
                        dataRowMinHeight: 65.h,
                        dataRowMaxHeight: 65.h,
                        checkboxHorizontalMargin: 0,
                        horizontalMargin: 0,
                        columnSpacing: MySpacing.fullWidth(context) * 0.045,
                        columns: _buildColumns(),
                        rows: students.map((student) {
                          final learnerStatus =
                              (student.learnerStatus ?? '').toLowerCase();
                          final status =
                              (student.taskStatus ?? '').toLowerCase();

                          return DataRow(cells: [
                            // Student Name
                            DataCell(SizedBox(
                              width: MySpacing.fullWidth(context) * 0.10,
                              child: MyText.titleMedium(
                                "${student.firstName} ${student.lastName}",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            )),
                            // Fingerprint Icon or Dash
                            DataCell(Align(
                              child: SizedBox(
                                width: MySpacing.fullWidth(context) * 0.12,
                                child: Align(
                                  child: student.hasFingerprintSubmitted == 'Y'
                                      ? Image.asset(
                                          Images.fingerprint,
                                          width: 28.w,
                                          height: 28.h,
                                        )
                                      : Text(
                                          '-',
                                          style: GoogleFonts.inter(
                                            fontSize: 24.sp,
                                            fontWeight: FontWeight.w600,
                                            color: contentTheme.k142228,
                                          ),
                                        ),
                                ),
                              ),
                            )),
                            // Email
                            DataCell(Align(
                              child: SizedBox(
                                width: MySpacing.fullWidth(context) * 0.12,
                                child: MyText.titleMedium(
                                  student.email,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: contentTheme.k142228,
                                  ),
                                ),
                              ),
                            )),
                            DataCell(
                              Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color:
                                        student.learnerStatus.toLowerCase() ==
                                                'active'
                                            ? Colors.white
                                            : const Color(0xFFE1E1E1),
                                    border:
                                        student.learnerStatus.toLowerCase() ==
                                                'active'
                                            ? Border.all(
                                                color: const Color(0xFF16A34A),
                                                width: 2)
                                            : null,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    student.learnerStatus
                                        .toLowerCase(), // Shows as received from API
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          student.learnerStatus.toLowerCase() ==
                                                  'active'
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFF232323),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Action Cell
                            DataCell(
                              Center(
                                child: status == 'submitted'
                                    ? InkWell(
                                        onTap: () {
                                          // Build the navigation list and index here
                                          final allSubmitted = students
                                              .where((stu) =>
                                                  (stu.taskStatus
                                                          .toLowerCase() ==
                                                      'submitted') &&
                                                  stu.hasFingerprintSubmitted ==
                                                      'Y')
                                              .map((stu) => {
                                                    'learnerId': stu.learnerId,
                                                    'taskId': stu.taskId,
                                                  })
                                              .toList();

                                          final currentIndex =
                                              allSubmitted.indexWhere((e) =>
                                                  e['learnerId'] ==
                                                      student.learnerId &&
                                                  e['taskId'] ==
                                                      student.taskId);

                                          Get.toNamed(
                                              "/teacher/fingerprintreview",
                                              arguments: {
                                                "taskId": student.taskId,
                                                "learnerId": student.learnerId,
                                                "submittedLearners":
                                                    allSubmitted,
                                                "currentIndex": currentIndex,
                                              });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14.w, vertical: 6.h),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Colors.white,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: 18.w,
                                                  color: Colors.black87),
                                              SizedBox(width: 8.w),
                                              Text(
                                                "View Details",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "-",
                                        style: GoogleFonts.inter(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),

              if (students.isNotEmpty) ...[
                20.verticalSpace,
                Row(
                  children: [
                    MyText.bodySmall(
                      "Showing ${students.length} of $totalStudents students",
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        color: contentTheme.k142228,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _paginationArrow(
                          Icons.keyboard_arrow_left_sharp,
                          controller.previousPage,
                        ),
                        Row(
                          children: List.generate(
                            totalPages,
                            (index) => paginationCard(
                              count: "${index + 1}",
                              isSelected:
                                  controller.currentPage.value == index + 1,
                              onTap: () => controller.goToPage(index + 1),
                            ),
                          ),
                        ).paddingSymmetric(horizontal: 12.w),
                        _paginationArrow(
                          Icons.keyboard_arrow_right_outlined,
                          controller.nextPage,
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  OutlineInputBorder _borderStyle() => OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1.w, color: const Color(0xffE1E1E1)),
      );

  List<DataColumn> _buildColumns() => [
        _col('Student'),
        _col('Writing Fingerprint'),
        _col('Email'),
        _col('Status'),
        _col('Action'),
      ];

  DataColumn _col(String label) => DataColumn(
        headingRowAlignment: MainAxisAlignment.center,
        label: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0), // margin you want
          child: MyText.titleMedium(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: contentTheme.k142228,
            ),
          ),
        ),
      );

  Widget paginationCard(
      {required String count, bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 32.h,
        margin: EdgeInsets.symmetric(horizontal: 6.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xffCB6CE6), Color(0xff004AAD)])
              : null,
          borderRadius: BorderRadius.circular(4),
          color: isSelected ? contentTheme.k5932EA : contentTheme.kF5F5F5,
          border: Border.all(
              color:
                  isSelected ? contentTheme.k5932EA : contentTheme.borderColor),
        ),
        child: Text(
          count,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? contentTheme.kFEFDFF : contentTheme.k142228,
          ),
        ),
      ),
    );
  }

  Widget _paginationArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28.w,
        height: 32.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: contentTheme.kF5F5F5,
          border: Border.all(color: contentTheme.borderColor),
        ),
        child: Icon(icon, size: 18.r),
      ),
    );
  }
}
