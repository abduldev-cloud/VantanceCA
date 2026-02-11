import 'package:vantanceCA/controller/apps/school/school_class_view_controller.dart';

import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';

import 'package:vantanceCA/views/layouts/layout.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vantanceCA/images.dart';
import 'package:feather_icons/feather_icons.dart';

import 'package:vantanceCA/helpers/widgets/my_container.dart';

import 'package:vantanceCA/helpers/widgets/my_text_style.dart';

class SchoolClassDetailPage extends StatefulWidget {
  const SchoolClassDetailPage({super.key});

  @override
  SchoolClassDetailPageState createState() => SchoolClassDetailPageState();
}

class SchoolClassDetailPageState extends State<SchoolClassDetailPage>
    with UIMixin {
  final detailController = Get.find<SchoolClassViewController>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      detailController.setSearchQuery(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final className = args['className'] ?? "-";
    final teacherFullName = args['teacherFullName'] ?? "-";

    return Layout(
      selectedPage: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: contentTheme.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  teacherFullName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: MyCard.circular(
              margin: EdgeInsets.only(
                bottom: 10.h,
                left: 5.w,
                top: 15.h,
                right: MySpacing.fullWidth(context) * 0.04,
              ),
              borderRadiusAll: 25.r,
              bordered: true,
              padding: EdgeInsets.only(
                left: 40.w,
                top: 40.h,
                bottom: 18.h,
                right: 40.w,
              ),
              child: Obx(() {
                if (detailController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
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
                            controller: searchController,
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.r)),
                                borderSide: const BorderSide(
                                    width: 1, color: Color(0xffE1E1E1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.r)),
                                borderSide: const BorderSide(
                                    width: 1, color: Color(0xffE1E1E1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.r)),
                                borderSide: const BorderSide(
                                    width: 1, color: Color(0xffE1E1E1)),
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
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                            ),
                          ),
                        ),
                        15.horizontalSpace,
                        Obx(() {
                          return PopupMenuButton<String>(
                            onSelected: (value) {
                              detailController.setSortOption(value);
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                "Active",
                                "Inactive",
                                "Student (A - Z)",
                                "Student (Z - A)",
                              ].map((behavior) {
                                return PopupMenuItem(
                                  value: behavior,
                                  height: 32.h,
                                  child: MyText.bodySmall(
                                    behavior,
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
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 6.h),
                              child: Row(
                                children: [
                                  Text.rich(
                                    TextSpan(children: [
                                      TextSpan(
                                        text: "Sort by : ",
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: contentTheme.k7E7E7E,
                                        ),
                                      ),
                                      TextSpan(
                                        text: detailController.sortOption.value,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: contentTheme.k142228,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  5.horizontalSpace,
                                  Icon(
                                    Icons.keyboard_arrow_down_sharp,
                                    color: contentTheme.k3D3C42,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    25.verticalSpace,
                    Expanded(
                      child: detailController.students.isEmpty
                          ? Center(
                              child: Text(
                                "No Students Found",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                return SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minWidth: constraints.maxWidth),
                                    child: DataTable(
                                      dividerThickness: 1,
                                      dataRowMinHeight: 70.h,
                                      dataRowMaxHeight: 70.h,
                                      columnSpacing:
                                          MySpacing.fullWidth(context) * 0.06,
                                      checkboxHorizontalMargin: 0,
                                      horizontalMargin: 0,
                                      columns: [
                                        DataColumn(
                                          label: Container(
                                            margin: EdgeInsets.only(left: 30),
                                            alignment: Alignment.center,
                                            child: MyText.titleMedium(
                                              'Student',
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
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
                                          label: Container(
                                            margin: EdgeInsets.only(left: 100),
                                            alignment: Alignment.center,
                                            child: MyText.titleMedium(
                                              'Email',
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: contentTheme.k142228,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataColumn(
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
                                      rows: detailController.students
                                          .map((student) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              SizedBox(
                                                width: MySpacing.fullWidth(
                                                        context) *
                                                    0.15,
                                                child: MyText.titleMedium(
                                                  "${student.firstName ?? ""} ${student.lastName ?? ""}"
                                                      .trim(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: contentTheme.k142228,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Align(
                                                alignment: Alignment.center,
                                                child: SizedBox(
                                                  width: 28.w,
                                                  height: 28.h,
                                                  child: Image.asset(
                                                    Images.fingerprint,
                                                    width: 28.w,
                                                    height: 28.h,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              SizedBox(
                                                width: MySpacing.fullWidth(
                                                        context) *
                                                    0.15,
                                                child: MyText.titleMedium(
                                                  student.email ?? "-",
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: contentTheme.k142228,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Align(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 4.h),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            25.r),
                                                    border: Border.all(
                                                      width: 2.w,
                                                      color: contentTheme
                                                          .k0A8041
                                                          .withAlpha(128),
                                                    ),
                                                    color: Colors.transparent,
                                                  ),
                                                  child: MyText.bodyMedium(
                                                    student.learnerStatus
                                                                .toLowerCase() ==
                                                            'active'
                                                        ? "active"
                                                        : "inactive",
                                                    style: GoogleFonts.inter(
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          contentTheme.k0A8041,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
