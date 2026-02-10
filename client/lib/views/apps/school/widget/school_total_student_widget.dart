import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/apps/school/school_classes_controller.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/helpers/widgets/my_text_style.dart';
import 'package:binary_success/images.dart';

class SchoolTotalStudentWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  final int totalStudents;
  final List<dynamic> students;

  static final double studentMinWidth = 250.w;
  static final double studentMaxWidth = 270.w;
  static final double fingerprintMinWidth = 140.w;
  static final double fingerprintMaxWidth = 160.w;
  static final double emailMinWidth = 270.w;
  static final double emailMaxWidth = 290.w;
  static final double statusMinWidth = 140.w;
  static final double statusMaxWidth = 160.w;

  const SchoolTotalStudentWidget({
    super.key,
    required this.contentTheme,
    required this.totalStudents,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SchoolClassesController>();

    return MyCard.circular(
      margin: EdgeInsets.only(left: 5.w, top: 15.h),
      borderRadiusAll: 25.r,
      bordered: true,
      padding: EdgeInsets.only(left: 40.w, top: 30.h, right: 40.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => MyText.bodySmall(
                    "All Students (${controller.filteredStudents.length})",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.black,
                    ),
                  )),
              const Spacer(),
              _buildSearchField(controller),
              SizedBox(width: 15.w),
              Obx(() {
                String displaySort;
                switch (controller.sortBy.value) {
                  case 'Student (A - Z)':
                    displaySort = 'Student (A - Z)';
                    break;
                  case 'Student (Z - A)':
                    displaySort = 'Student (Z - A)';
                    break;
                  case 'Active':
                    displaySort = 'Active';
                    break;
                  case 'Inactive':
                    displaySort = 'Inactive';
                    break;
                  default:
                    displaySort = controller.sortBy.value;
                }
                final sortOptions = [
                  'Active',
                  'Inactive',
                  'Student (A - Z)',
                  'Student (Z - A)'
                ];

                return PopupMenuButton<String>(
                  onSelected: (value) {
                    controller.sortStudents(value);
                  },
                  itemBuilder: (BuildContext context) {
                    return sortOptions.map((option) {
                      return PopupMenuItem<String>(
                        value: option,
                        height: 32.h,
                        child: MyText.bodySmall(
                          option,
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: contentTheme.k142228,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  color: contentTheme.background,
                  child: MyContainer.bordered(
                    borderRadiusAll: 10.r,
                    borderColor: contentTheme.borderColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    child: Row(
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                            text: "Sort by : ",
                            style: MyTextStyle.bodySmall(
                                fontSize: 12.sp,
                                fontWeight: 400,
                                color: contentTheme.k7E7E7E),
                          ),
                          TextSpan(
                            text: displaySort,
                            style: MyTextStyle.bodyLarge(
                                fontSize: 12.sp,
                                fontWeight: 600,
                                color: contentTheme.k142228),
                          ),
                        ])),
                        SizedBox(width: 5.w),
                        Icon(Icons.keyboard_arrow_down_sharp,
                            color: contentTheme.k3D3C42),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 40.h),
          Expanded(
            child: Obx(() {
              final filteredStudents = controller.filteredStudents;
              if (filteredStudents.isEmpty) {
                return Center(
                  child: MyText.bodyMedium(
                    "No students found",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: contentTheme.k7E7E7E,
                    ),
                  ),
                );
              }

              final verticalCtrl = ScrollController();

              return Scrollbar(
                controller: verticalCtrl,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: verticalCtrl,
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    dividerThickness: 1,
                    headingRowHeight: 50.h,
                    dataRowMinHeight: 60.h,
                    dataRowMaxHeight: 70.h,
                    horizontalMargin: 12,
                    checkboxHorizontalMargin: 12,
                    columns: [
                      _dataColumn("Student", center: true),
                      _dataColumn("Writing Fingerprint", center: true),
                      _dataColumn("Email", center: true),
                      _dataColumn("Status", center: false),
                    ],
                    rows: filteredStudents.map((student) {
                      final firstName = student['first_name'] ?? '';
                      final lastName = student['last_name'] ?? '';
                      final name = [firstName, lastName]
                          .where((s) => s.isNotEmpty)
                          .join(' ')
                          .trim();

                      final email = student['email'] ?? '-';
                      final status = student['learner_status'] ?? 'ACTIVE';
                      final hasFp =
                          (student['has_fingerprint_submitted'] ?? 'N')
                              .toUpperCase();

                      final fingerWidget = hasFp == 'Y'
                          ? Image.asset(Images.fingerprint,
                              width: 24.w, height: 24.h)
                          : Text(
                              '-',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                color: contentTheme.k7E7E7E,
                              ),
                            );

                      return DataRow(cells: [
                        DataCell(Container(
                          constraints: BoxConstraints(
                              minWidth: studentMinWidth,
                              maxWidth: studentMaxWidth),
                          alignment: Alignment.center,
                          child: MyText.titleMedium(
                            name.isNotEmpty ? name : '-',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: contentTheme.k142228,
                            ),
                          ),
                        )),
                        DataCell(Container(
                          constraints: BoxConstraints(
                              minWidth: fingerprintMinWidth,
                              maxWidth: fingerprintMaxWidth),
                          alignment: Alignment.center,
                          child: fingerWidget,
                        )),
                        DataCell(Container(
                          constraints: BoxConstraints(
                              minWidth: emailMinWidth, maxWidth: emailMaxWidth),
                          alignment: Alignment.center,
                          child: MyText.titleMedium(
                            email,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: contentTheme.k142228,
                            ),
                          ),
                        )),
                        DataCell(Container(
                          constraints: BoxConstraints(
                              minWidth: statusMinWidth,
                              maxWidth: statusMaxWidth),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 2.h)
                                .copyWith(bottom: 4.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: status.trim().toUpperCase() == 'INACTIVE'
                                  ? const Color(0xFFE1E1E1)
                                  : Colors.transparent,
                              border: status.trim().toUpperCase() == 'INACTIVE'
                                  ? null
                                  : Border.all(
                                      width: 2.w,
                                      color:
                                          contentTheme.k0A8041.withAlpha(128),
                                    ),
                            ),
                            child: MyText.bodyMedium(
                              status.toString().toLowerCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: status.trim().toUpperCase() == 'INACTIVE'
                                    ? const Color(0xFF232323)
                                    : contentTheme.k0A8041,
                              ),
                            ),
                          ),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Search field builder
  Widget _buildSearchField(SchoolClassesController controller) {
    return SizedBox(
      width: 280.w,
      child: TextFormField(
        onChanged: (value) => controller.updateSearch(value),
        maxLines: 1,
        style: MyTextStyle.bodyMedium(),
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: MyTextStyle.bodySmall(
            fontSize: 12.sp,
            xMuted: true,
            color: const Color(0xff9A9A9B),
          ),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(),
          prefixIcon: Align(
            alignment: Alignment.center,
            child: Icon(FeatherIcons.search, size: 14.r),
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
    );
  }

  OutlineInputBorder _border() => const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: Color(0xffE1E1E1)),
      );

  DataColumn _dataColumn(String title, {bool center = false}) {
    return DataColumn(
      headingRowAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      label: MyText.titleMedium(
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
