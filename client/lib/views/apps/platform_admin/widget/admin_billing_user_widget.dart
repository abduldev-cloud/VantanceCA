import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/helpers/widgets/my_text_style.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/utils.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminBillingUserWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  const AdminBillingUserWidget({super.key, required this.contentTheme});

  @override
  Widget build(BuildContext context) {
    return MyCard.circular(
      margin: EdgeInsets.only(
          bottom: 50.h,
          left: 5,
          top: 25,
          right: MySpacing.fullWidth(context) * 0.04),
      borderRadiusAll: 25.r,
      bordered: false,
      padding: EdgeInsets.only(
        left: 40.w,
        top: 30.h,
        bottom: 0.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                MyText.bodySmall(
                  "All Users",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: contentTheme.black,
                  ),
                ),
                Spacer(),
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
                            color: Color(0xff9A9A9B)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              width: 1,
                              strokeAlign: 0,
                              color: Color(0xffE1E1E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              width: 1,
                              strokeAlign: 0,
                              color: Color(0xffE1E1E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                              width: 1,
                              strokeAlign: 0,
                              color: Color(0xffE1E1E1)),
                        ),
                        prefixIcon: const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              FeatherIcons.search,
                              size: 14,
                            )),
                        prefixIconConstraints: const BoxConstraints(
                            minWidth: 30,
                            maxWidth: 30,
                            minHeight: 32,
                            maxHeight: 32),
                        contentPadding: MySpacing.xy(16.w, 12.h),
                        isCollapsed: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never),
                  ),
                ),
                15.horizontalSpace,
                PopupMenuButton(
                    onSelected: (value) {},
                    itemBuilder: (BuildContext context) {
                      return ["Plan Type", "Billing Status", "Region/District"]
                          .map((behavior) {
                        return PopupMenuItem(
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
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: contentTheme.k7E7E7E)),
                            TextSpan(
                                text: "Plan Type",
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: contentTheme.k142228))
                          ])),
                          5.horizontalSpace,
                          Icon(
                            Icons.keyboard_arrow_down_sharp,
                            color: contentTheme.k3D3C42,
                          )
                        ],
                      ),
                    ))
              ],
            ),
            10.verticalSpace,
            Scrollbar(
              trackVisibility: true,
              child: DataTable(
                  dividerThickness: 1,
                  dataRowMinHeight: 65.h,
                  dataRowMaxHeight: 65.h,
                  checkboxHorizontalMargin: 0,
                  horizontalMargin: 0,
                  columnSpacing: MySpacing.fullWidth(context) * 0.030,
                  columns: [
                    // Set the name of the column
                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.start,
                      label: MyText.titleMedium(
                        'School',
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
                        'Plan Type',
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
                        'User Count',
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

                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.center,
                      label: MyText.titleMedium(
                        'Next Invoice Date',
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
                        'Last Payment',
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
                        'Action',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: contentTheme.k142228,
                        ),
                      ),
                    ),
                  ],
                  rows: List.generate(
                      6,
                      (index) => DataRow(cells: [
                            DataCell(SizedBox(
                              width: MySpacing.fullWidth(context) * 0.08,
                              child: MyText.titleMedium(
                                "School ${index + 1}",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            )),
                            DataCell(Align(
                              child: SizedBox(
                                width: MySpacing.fullWidth(context) * 0.05,
                                child: Align(
                                  child: MyText.titleMedium(
                                    "Essentials",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: contentTheme.k142228,
                                    ),
                                  ),
                                ),
                              ),
                            )),
                            DataCell(Align(
                                child: SizedBox(
                              width: MySpacing.fullWidth(context) * 0.07,
                              child: MyText.titleMedium(
                                "12,552",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ))),
                            DataCell(Align(
                              child: Container(
                                height: 30.h,
                                width: 65.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.r),
                                  border: Border.all(
                                    width: 2,
                                    color: contentTheme.k0A8041
                                        .withValues(alpha: 0.50),
                                  ),
                                  color: Colors.transparent,
                                ),
                                padding: EdgeInsets.only(bottom: 3.h),
                                child: MyText.bodyMedium(
                                  "active",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: contentTheme.k0A8041,
                                  ),
                                ),
                              ),
                            )),
                            DataCell(Align(
                                child: SizedBox(
                              width: MySpacing.fullWidth(context) * 0.10,
                              child: MyText.titleMedium(
                                "October 12, 2025",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ))),
                            DataCell(Align(
                                child: SizedBox(
                              width: MySpacing.fullWidth(context) * 0.07,
                              child: MyText.titleMedium(
                                "\$4,000",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                              ),
                            ))),
                            DataCell(Align(
                                child: SizedBox(
                              width: MySpacing.fullWidth(context) * 0.08,
                              child: DropdownButtonFormField(
                                icon: Icon(Icons.keyboard_arrow_down_rounded),
                                iconSize: 15.r,
                                padding: EdgeInsets.zero,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: contentTheme.k142228,
                                ),
                                alignment: Alignment.center,
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        left: 15.w,
                                        right: 15.w,
                                        top: 0.h,
                                        bottom: 12.h),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: contentTheme.kC6C3C3)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: contentTheme.kC6C3C3)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(
                                            width: 1,
                                            color: contentTheme.kC6C3C3))),
                                items: [
                                  DropdownMenuItem(
                                    alignment: Alignment.center,
                                    child: MyText.titleMedium(
                                      "Upgrade",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: contentTheme.k142228,
                                      ),
                                    ),
                                  )
                                ],
                                onChanged: (value) {},
                              ),
                            ))),
                          ]))),
            ),
            Row(
              children: [
                MyText.bodySmall(
                  "Showing data 1 to 6 of 21,364 users",
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w300,
                    color: contentTheme.k142228,
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: contentTheme.kF5F5F5,
                          border: Border.all(color: contentTheme.borderColor)),
                      child: Icon(Icons.keyboard_arrow_left_sharp, size: 18.r),
                    ),
                    Row(
                      children: List.generate(
                          6,
                          (index) => index == 4
                              ? MyText.bodySmall(
                                  "...",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: contentTheme.k142228,
                                  ),
                                ).paddingSymmetric(horizontal: 6)
                              : paginationCard(
                                  count: index == 5 ? "99" : "${index + 1}",
                                  isSelected: index == 0 ? true : false)),
                    ).paddingSymmetric(horizontal: 12.w),
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: contentTheme.kF5F5F5,
                          border: Border.all(color: contentTheme.borderColor)),
                      child:
                          Icon(Icons.keyboard_arrow_right_outlined, size: 18.r),
                    )
                  ],
                )
              ],
            ).paddingOnly(bottom: 10.h, top: 10.h)
          ],
        ),
      ).paddingOnly(right: 20.w),
    );
  }

  Widget paginationCard({required String count, bool isSelected = false}) {
    return Container(
      width: 28.w,
      height: 28.w,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffCB6CE6),
                    Color(0xff004AAD),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(4.r),
          color: isSelected ? contentTheme.k5932EA : contentTheme.kF5F5F5,
          border: Border.all(
              color: isSelected
                  ? contentTheme.k5932EA
                  : contentTheme.borderColor)),
      child: Text(
        count,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: isSelected ? contentTheme.kFEFDFF : contentTheme.k142228,
        ),
      ),
    );
  }

  Widget buildSorting(String title, String description) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.labelLarge(title),
          MySpacing.height(4),
          MyText.bodySmall(description)
        ],
      ),
    );
  }
}
