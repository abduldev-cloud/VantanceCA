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
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get.dart';
import 'package:vantanceCA/controller/apps/teacher/teacher_view_class_controller.dart';
import 'package:vantanceCA/models/teacher_view_class_model.dart';

class TeacherClassesDetailWidget extends StatelessWidget {
  final ContentTheme contentTheme;

  const TeacherClassesDetailWidget({super.key, required this.contentTheme});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacherClassViewController>();

    return MyCard.circular(
      margin: EdgeInsets.only(
        bottom: 10.h,
        left: 5.w,
        top: 15.h,
        right: MySpacing.fullWidth(context) * 0.04,
      ),
      borderRadiusAll: 25.r,
      bordered: true,
      padding:
          EdgeInsets.only(left: 40.w, top: 40.h, bottom: 18.h, right: 40.w),
      child: Column(
        children: [
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
                  maxLines: 1,
                  style: MyTextStyle.bodyMedium(),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: MyTextStyle.bodySmall(
                      fontSize: 12.sp,
                      xMuted: true,
                      color: const Color(0xff9A9A9B),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      borderSide:
                          const BorderSide(color: Color(0xffE1E1E1), width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      borderSide:
                          const BorderSide(color: Color(0xffE1E1E1), width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.r)),
                      borderSide:
                          const BorderSide(color: Color(0xffE1E1E1), width: 1),
                    ),
                    prefixIcon: const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        FeatherIcons.search,
                        size: 14,
                      ),
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
                  // onChanged: (value) {
                  //   // TODO: Implement search filtering logic in your controller if needed
                  // },
                  onChanged: (value) => controller.searchStudents(value),
                ),
              ),
              15.horizontalSpace,
              PopupMenuButton<String>(
                initialValue: controller.selectedSort.value,
                onSelected: (value) =>
                    controller.sortStudents(value), // ✅ calls fixed fn
                itemBuilder: (context) {
                  final options = ["Active", "Inactive", "A to Z", "Z to A"];
                  return options.map((option) {
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
                child: Obx(
                  () => MyContainer.bordered(
                      borderRadiusAll: 10.r,
                      borderColor: contentTheme.borderColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      child: Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Sort by : ",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: contentTheme.k7E7E7E,
                                  ),
                                ),
                                TextSpan(
                                  text: controller
                                      .selectedSort.value, // ✅ live update
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: contentTheme.k142228,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          5.horizontalSpace,
                          Icon(Icons.keyboard_arrow_down_sharp,
                              color: contentTheme.k3D3C42),
                        ],
                      )),
                ),
              ),
            ],
          ),
          40.verticalSpace,
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                // return const Center(child: CircularProgressIndicator());
                return Center(child: CircularProgressIndicator());
              }

              if (controller.studentsList.isEmpty) {
                return Center(
                  child: MyText.bodyLarge(
                    "No Students Found",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  dividerThickness: 1,
                  dataRowMinHeight: 70.h,
                  dataRowMaxHeight: 70.h,
                  columnSpacing: MySpacing.fullWidth(context) * 0.06,
                  checkboxHorizontalMargin: 0,
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.center,
                      label: MyText.titleMedium(
                        'Student',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.k142228,
                        ),
                      ),
                    ),
                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.center,
                      label: MyText.titleMedium(
                        'Writing Fingerprint',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.k142228,
                        ),
                      ),
                    ),
                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.center,
                      label: MyText.titleMedium(
                        'Email',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.k142228,
                        ),
                      ),
                    ),
                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.center,
                      label: MyText.titleMedium(
                        'Status',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.k142228,
                        ),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    controller.studentsList.length,
                    (index) {
                      final student = controller.studentsList[index];
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: MySpacing.fullWidth(context) * 0.15,
                              // child : Center(
                              child: MyText.titleMedium(
                                "${student.firstName ?? ""} ${student.lastName ?? ""}"
                                    .trim(),
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                              // )
                            ),
                          ),
                          DataCell(
                            Align(
                              child: SizedBox(
                                width: MySpacing.fullWidth(context) * 0.15,
                                child: student.hasFingerprintSubmitted == "Y"
                                    ? Image.asset(
                                        Images.fingerprint,
                                        width: 28.w,
                                        height: 28.h,
                                      )
                                    // : const SizedBox.shrink(),
                                    : Center(
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          DataCell(
                            Align(
                              child: SizedBox(
                                width: MySpacing.fullWidth(context) * 0.15,
                                child: MyText.titleMedium(
                                  student.email ?? "",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: contentTheme.k142228,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: student.learnerStatus?.toLowerCase() ==
                                          'active'
                                      ? Colors.white
                                      : const Color(0xFFE1E1E1),
                                  border:
                                      student.learnerStatus?.toLowerCase() ==
                                              'active'
                                          ? Border.all(
                                              color: const Color(0xFF16A34A),
                                              width: 2)
                                          : null,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  student.learnerStatus!
                                      .toLowerCase(), // Shows as received from API
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        student.learnerStatus?.toLowerCase() ==
                                                'active'
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFF232323),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
