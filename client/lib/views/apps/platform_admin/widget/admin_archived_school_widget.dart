import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';

import 'package:binary_success/controller/apps/admin/admin_school_controller.dart';
import 'package:binary_success/models/platform_admin_school_model.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:binary_success/helpers/widgets/my_text_style.dart';

class AdminArchivedSchoolWidget extends StatelessWidget {
  final ContentTheme contentTheme;
  const AdminArchivedSchoolWidget({super.key, required this.contentTheme});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSchoolController>();

    return Column(
      children: [
        // ---------- HEADER ----------
        Row(
          children: [
            MyText.bodySmall(
              "All Archived Schools",
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: contentTheme.black,
              ),
            ),
            const Spacer(),
            // search box
            // SizedBox(
            //   width: 280.w,
            //   child: TextFormField(
            //     maxLines: 1,
            //     style: MyTextStyle.bodyMedium(),
            //     decoration: InputDecoration(
            //       hintText: "Search",
            //       hintStyle: MyTextStyle.bodySmall(
            //         fontSize: 12,
            //         xMuted: true,
            //         color: const Color(0xff9A9A9B),
            //       ),
            //       border: OutlineInputBorder(
            //         borderRadius: const BorderRadius.all(Radius.circular(10)),
            //         borderSide: BorderSide(
            //             width: 1,
            //             strokeAlign: 0,
            //             color: const Color(0xffE1E1E1)),
            //       ),
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: const BorderRadius.all(Radius.circular(10)),
            //         borderSide: BorderSide(
            //             width: 1,
            //             strokeAlign: 0,
            //             color: const Color(0xffE1E1E1)),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: const BorderRadius.all(Radius.circular(10)),
            //         borderSide: BorderSide(
            //             width: 1,
            //             strokeAlign: 0,
            //             color: const Color(0xffE1E1E1)),
            //       ),
            //       prefixIcon: const Align(
            //         alignment: Alignment.center,
            //         child: Icon(
            //           FeatherIcons.search,
            //           size: 14,
            //         ),
            //       ),
            //       prefixIconConstraints: const BoxConstraints(
            //           minWidth: 30,
            //           maxWidth: 30,
            //           minHeight: 32,
            //           maxHeight: 32),
            //       contentPadding: MySpacing.xy(16, 12),
            //       isCollapsed: true,
            //       floatingLabelBehavior: FloatingLabelBehavior.never,
            //     ),
            //   ),
            // ),

            SizedBox(
              width: 280.w,
              child: TextFormField(
                maxLines: 1,
                style: MyTextStyle.bodyMedium(),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: MyTextStyle.bodySmall(
                    fontSize: 12,
                    xMuted: true,
                    color: const Color(0xff9A9A9B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                        width: 1,
                        strokeAlign: 0,
                        color: const Color(0xffE1E1E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                        width: 1,
                        strokeAlign: 0,
                        color: const Color(0xffE1E1E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                        width: 1,
                        strokeAlign: 0,
                        color: const Color(0xffE1E1E1)),
                  ),
                  prefixIcon: const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      FeatherIcons.search,
                      size: 14,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                      minWidth: 30, maxWidth: 30, minHeight: 32, maxHeight: 32),
                  contentPadding: MySpacing.xy(16, 12),
                  isCollapsed: true,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
                onChanged: (val) {
                  controller.onSearchTextChanged(val);
                },
              ),
            ),
            SizedBox(width: 12),
            //     CustomPopupMenu(
            //       backdrop: true,
            //       onChange: (_) {},
            //       menu: MyContainer.bordered(
            //         borderRadiusAll: 10.r,
            //         borderColor: contentTheme.borderColor,
            //         padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            //         child: Row(
            //           children: [
            //             Text.rich(TextSpan(children: [
            //               TextSpan(
            //                   text: "Sort by : ",
            //                   style: MyTextStyle.bodySmall(
            //                       fontSize: 12.sp,
            //                       fontWeight: 400,
            //                       color: contentTheme.k7E7E7E)),
            //               TextSpan(
            //                   text: "Due Dates",
            //                   style: MyTextStyle.bodyLarge(
            //                       fontSize: 12.sp,
            //                       fontWeight: 600,
            //                       color: contentTheme.k142228))
            //             ])),
            //             5.horizontalSpace,
            //             Icon(
            //               Icons.keyboard_arrow_down_sharp,
            //               color: contentTheme.k3D3C42,
            //             )
            //           ],
            //         ),
            //       ),
            //       menuBuilder: (_) => buildSorting("Sort by : ", "Due Dates"),
            //     ),
            //   ],
            // ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),

            // PopupMenuButton<String>(
            //       initialValue: controller.sortOrder.value == "A-Z" ? "A to Z" : "Z to A",
            //       onSelected: (value) {
            //         if (value == "A to Z") {
            //           controller.onSortOrderChanged("A-Z");
            //         } else if (value == "Z to A") {
            //           controller.onSortOrderChanged("Z-A");
            //         }
            //       },
            //       itemBuilder: (context) {
            //         final options = ["A to Z", "Z to A"];
            //         return options.map((option) {
            //           return PopupMenuItem<String>(
            //             value: option,
            //             height: 32.h,
            //             child: Text(
            //               option,
            //               style: GoogleFonts.inter(
            //                 fontSize: 14.sp,
            //                 fontWeight: FontWeight.w500,
            //                 color: contentTheme.k142228,
            //               ),
            //             ),
            //           );
            //         }).toList();
            //       },
            //       color: contentTheme.background,
            //       child: Obx(() => MyContainer.bordered(
            //             borderRadiusAll: 10.r,
            //             borderColor: contentTheme.borderColor,
            //             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            //             child: Row(
            //               children: [
            //                 Text.rich(
            //                   TextSpan(
            //                     children: [
            //                       TextSpan(
            //                         text: "Sort by : ",
            //                         style: GoogleFonts.inter(
            //                           fontSize: 12.sp,
            //                           fontWeight: FontWeight.w400,
            //                           color: contentTheme.k7E7E7E,
            //                         ),
            //                       ),
            //                       TextSpan(
            //                         text: controller.sortOrder.value == "A-Z" ? "A to Z" : "Z to A",
            //                         style: GoogleFonts.inter(
            //                           fontSize: 12.sp,
            //                           fontWeight: FontWeight.w600,
            //                           color: contentTheme.k142228,
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //                 5.horizontalSpace,
            //                 Icon(Icons.keyboard_arrow_down_sharp, color: contentTheme.k3D3C42),
            //               ],
            //             ),
            //           )),
            //     ),
            PopupMenuButton<String>(
              initialValue: controller.sortOrder.value == "A-Z"
                  ? "Institute (A - Z)"
                  : "Institute (Z - A)",
              onSelected: (value) {
                if (value == "Institute (A - Z)") {
                  controller.onSortOrderChanged("A-Z");
                } else if (value == "Institute (Z - A)") {
                  controller.onSortOrderChanged("Z-A");
                }
              },
              itemBuilder: (context) {
                final options = ["Institute (A - Z)", "Institute (Z - A)"];
                return options.map((option) {
                  return PopupMenuItem<String>(
                    value: option,
                    height: 32.h,
                    child: Text(
                      option,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: contentTheme.k142228,
                      ),
                    ),
                  );
                }).toList();
              },
              color: contentTheme.background,
              child: Obx(() => MyContainer.bordered(
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
                                text: controller.sortOrder.value == "A-Z"
                                    ? "Institute (A - Z)"
                                    : "Institute (Z - A)",
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
                    ),
                  )),
            )
          ],
        ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),

        // ---------- LIST ----------
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            // ✅ EMPTY STATE (Updated UI)
            if (controller.institutes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.classes,
                      height: 64.sp,
                      width: 64.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "No Archived Institutes",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Institutes will appear here once archived",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            // ✅ LIST VIEW
            return ListView.separated(
              padding: EdgeInsets.only(
                left: 5,
                top: 15,
                right: MySpacing.fullWidth(context) * 0.04,
              ),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final institute = controller.institutes[index];
                return classesCard(institute);
              },
              separatorBuilder: (context, index) => MySpacing.height(25),
              itemCount: controller.institutes.length,
            );
          }),
        ),

        // ---------- PAGINATION ----------
        Obx(() {
          final totalCount =
              controller.summaryCounts.value?.archivedInstitutes ?? 0;

          // If no data → hide pagination completely
          if (totalCount == 0) return const SizedBox.shrink();

          final totalPages =
              (totalCount / controller.pageSize).ceil().clamp(1, 9999);

          // Hide pagination if only one page
          if (totalPages <= 1) return const SizedBox.shrink();

          final startIndex =
              ((controller.currentPage.value - 1) * controller.pageSize) + 1;

          final endIndex = (controller.currentPage.value * controller.pageSize)
              .clamp(0, totalCount);

          return Row(
            children: [
              MyText.bodySmall(
                "Showing $endIndex of $totalCount schools",
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w300,
                  color: contentTheme.k142228,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  // prev
                  InkWell(
                    onTap: () {
                      if (controller.currentPage.value > 1) {
                        controller.fetchInstitutes(
                            page: controller.currentPage.value - 1);
                      }
                    },
                    child: Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: contentTheme.kF5F5F5,
                        border: Border.all(color: contentTheme.borderColor),
                      ),
                      child: Icon(Icons.keyboard_arrow_left_sharp, size: 18.r),
                    ),
                  ),

                  // page numbers (dynamic)
                  Row(
                    children:
                        buildPageNumbers(controller, totalPages, contentTheme),
                  ).paddingSymmetric(horizontal: 12.w),

                  // next
                  InkWell(
                    onTap: () {
                      if (controller.currentPage.value < totalPages) {
                        controller.fetchInstitutes(
                            page: controller.currentPage.value + 1);
                      }
                    },
                    child: Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: contentTheme.kF5F5F5,
                        border: Border.all(color: contentTheme.borderColor),
                      ),
                      child:
                          Icon(Icons.keyboard_arrow_right_outlined, size: 18.r),
                    ),
                  )
                ],
              )
            ],
          ).paddingOnly(
              top: 20.h,
              right: MySpacing.fullWidth(context) * 0.04,
              bottom: 20);
        })
      ],
    );
  }

  // ---------- Dynamic Card ----------
  Widget classesCard(InstituteDetail institute) {
    return MyCard.circular(
      borderRadiusAll: 25,
      bordered: true,
      padding:
          EdgeInsets.only(left: 25.w, top: 18.h, bottom: 18.h, right: 40.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyText.bodyMedium(
                      institute.instituteName,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                    MySpacing.width(10),
                    Container(
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, bottom: 4.h, top: 2.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          width: 2,
                          color: contentTheme.orange.withValues(alpha: 0.50),
                        ),
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: MyText.bodyMedium(
                        "archived",
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: contentTheme.orange,
                        ),
                      ),
                    )
                  ],
                ),
                25.verticalSpace,
                Row(
                  children: [
                    Row(
                      children: [
                        Image.asset(Images.students, width: 19.w, height: 21.h),
                        MySpacing.width(9),
                        MyText.bodySmall(
                          "${institute.totalLearners} students",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(Images.activeAssignment,
                            width: 24, height: 24),
                        MySpacing.width(9),
                        MyText.bodySmall(
                          "${institute.assignmentCount} active assignments",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20.w),
                    Row(
                      children: [
                        Image.asset(Images.calendar, width: 22.w, height: 22.w),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          institute.term ?? "-",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(Images.fingerprint,
                            width: 18.w, height: 18.h),
                        9.horizontalSpace,
                        MyText.bodySmall(
                          "${institute.fingerprintSubmittedCount} Writing Fingerprints submitted",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 20),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {},
            child: MyContainer.bordered(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 7.h),
              borderColor: contentTheme.borderColor,
              borderRadiusAll: 25.r,
              bordered: true,
              child: Row(
                children: [
                  Image.asset(Images.eye, width: 20.w, height: 20.h),
                  MySpacing.width(8),
                  Text(
                    "Edit Access",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.k142228,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget paginationCard(
      {required String count,
      required ContentTheme contentTheme,
      bool isSelected = false}) {
    return Container(
      width: 28.w,
      height: 28.h,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffCB6CE6),
                  Color(0xff004AAD),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(4),
        color: isSelected ? contentTheme.k5932EA : contentTheme.kF5F5F5,
        border: Border.all(
          color: isSelected ? contentTheme.k5932EA : contentTheme.borderColor,
        ),
      ),
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

  List<Widget> buildPageNumbers(
      AdminSchoolController controller, int totalPages, ContentTheme theme) {
    final currentPage = controller.currentPage.value;
    List<int> pages = [];

    if (totalPages <= 6) {
      pages = List.generate(totalPages, (i) => i + 1);
    } else {
      if (currentPage <= 3) {
        pages = [1, 2, 3, 4, -1, totalPages];
      } else if (currentPage >= totalPages - 2) {
        pages = [
          1,
          -1,
          totalPages - 3,
          totalPages - 2,
          totalPages - 1,
          totalPages
        ];
      } else {
        pages = [
          1,
          -1,
          currentPage - 1,
          currentPage,
          currentPage + 1,
          -1,
          totalPages
        ];
      }
    }

    return pages.map((pageNum) {
      if (pageNum == -1) {
        return MyText.bodySmall(
          "...",
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: theme.k142228,
          ),
        ).paddingSymmetric(horizontal: 6);
      }
      return GestureDetector(
        onTap: () {
          controller.fetchInstitutes(page: pageNum);
        },
        child: paginationCard(
          count: "$pageNum",
          isSelected: pageNum == controller.currentPage.value,
          contentTheme: theme,
        ),
      );
    }).toList();
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
