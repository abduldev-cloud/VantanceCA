import 'package:binary_success/views/apps/student/widget/block_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:binary_success/controller/apps/admin/admin_total_current_users_controller.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/helpers/widgets/my_text_style.dart';
import 'package:binary_success/widgets/custom_pop_menu.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:binary_success/models/platform_total_users_model.dart';
import 'package:binary_success/widgets/custom_pop_menu.dart';
import 'package:binary_success/helpers/theme/app_theme.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';

class AdminTotalCurrentUsersWidget extends StatefulWidget {
  final ContentTheme contentTheme;
  const AdminTotalCurrentUsersWidget({super.key, required this.contentTheme});

  @override
  State<AdminTotalCurrentUsersWidget> createState() =>
      _AdminTotalCurrentUsersWidgetState();
}

class _AdminTotalCurrentUsersWidgetState
    extends State<AdminTotalCurrentUsersWidget> {
  late final PlatformUserController controller;

  final double wUser = 170; //140;
  final double wEmail = 280;
  final double wRole = 200;
  final double wStatus = 170;
  final double wAction = 100;

  final TextEditingController searchController = TextEditingController();

  final List<String> sortOptions = [
    'active',
    'inactive',
    'Students (A - Z)',
    'Students (Z - A)',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(PlatformUserController());
    searchController.addListener(() {
      controller.searchQuery.value = searchController.text;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    Get.delete<PlatformUserController>();
    super.dispose();
  }

  void _showEditUserPopup(PlatformUser user) {
    String status = user.statusCode.toLowerCase();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit User",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Text(
                  "Please fill out the form to edit role",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: SizedBox(
              width: 420.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFormRow(
                    "User Name",
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: "${user.firstName} ${user.lastName}"),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  12.verticalSpace,
                  _buildFormRow(
                    "Role",
                    TextField(
                      readOnly: true,
                      controller:
                          TextEditingController(text: user.roleDisplayName),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  12.verticalSpace,
                  _buildFormRow(
                    "Email",
                    TextField(
                      readOnly: true,
                      controller: TextEditingController(text: user.email),
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          Icons.mail_outline,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  12.verticalSpace,
                  _buildFormRow(
                    "Status",
                    Row(
                      children: [
                        Radio<String>(
                          value: "active",
                          groupValue: status.toLowerCase(),
                          activeColor: const Color(0xff0A8041),
                          onChanged: (value) {
                            setState(() => status = value!);
                          },
                        ),

                        Text(
                          "active",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff142228),
                          ),
                        ),

                        20.horizontalSpace,
                        Radio<String>(
                          value: "inactive",
                          groupValue: status,
                          activeColor: const Color(0xff0A8041),
                          onChanged: (value) {
                            setState(() => status = value!);
                          },
                        ),
                        // const Text("Inactive",),
                        Text(
                          "Inactive",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xff142228),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              GestureDetector(
                onTap: () {
                  // TODO: Implement status update logic or callback here
                  Navigator.pop(context);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff004AAD),
                        Color(0xffCB6CE6),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Text(
                    "Submit",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormRow(String label, Widget field) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            // style: const TextStyle(fontWeight: FontWeight.w500)
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xff142228),
            ),
          ),
        ),
        Expanded(child: field),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(
        value,
        //  style: const TextStyle(fontSize: 14, color: Colors.black87)
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Color(0xff142228),
        ),
      ),
    );
  }

  Widget _headerCell({
    required String text,
    required double width,
    TextAlign align = TextAlign.center,
  }) =>
      SizedBox(
        width: width.w,
        child: Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: align,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xff142228),
          ),
        ),
      );

  Widget _centerCell({required Widget child, required double width}) =>
      SizedBox(width: width.w, child: Center(child: child));

  Widget _pagination() {
    return Obx(() {
      final totalPages = controller.totalPages.value;
      final currentPage = controller.currentPage.value;

      List<int> numbersToShow() {
        final set = <int>{1, totalPages};
        for (var p = currentPage - 1; p <= currentPage + 1; p++) {
          if (p >= 1 && p <= totalPages) set.add(p);
        }
        if (totalPages >= 4) set.add(2);
        final list = set.toList()..sort();
        return list;
      }

      Widget box(
          {required Widget child,
          required VoidCallback? onTap,
          bool active = false}) {
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
                      colors: [Color(0xffCB6CE6), Color(0xff004AAD)])
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
        box(
          child: const Icon(Icons.chevron_left, size: 16),
          onTap: currentPage > 1
              ? () => controller.fetchUsers(page: currentPage - 1)
              : null,
        )
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
          active: n == currentPage,
          onTap: () => controller.fetchUsers(page: n),
        ));
      }

      children.add(box(
        child: const Icon(Icons.chevron_right, size: 16),
        onTap: currentPage < totalPages
            ? () => controller.fetchUsers(page: currentPage + 1)
            : null,
      ));

      return Row(children: children);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          EdgeInsets.only(left: 40.w, top: 30.h, bottom: 10.h, right: 30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title, Search & Sort
          Row(
            children: [
              Text(
                "All Users",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: widget.contentTheme.black,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 180.w,
                height: 36.h,
                child: TextField(
                  controller: searchController,
                  style: GoogleFonts.inter(fontSize: 12.sp),
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: GoogleFonts.inter(
                        fontSize: 12.sp, color: const Color(0xff9A9A9B)),
                    prefixIcon: Icon(
                      FeatherIcons.search,
                      size: 18,
                      color: const Color(0xff6B7280),
                    ),
                    filled: true,
                    fillColor: const Color(0xffF9FAFB),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
              16.horizontalSpace,
              CustomPopupMenu(
                backdrop: true,
                onChange: (value) => controller.sortOption.value,
                menu: MyContainer.bordered(
                  borderRadiusAll: 8.r,
                  borderColor: widget.contentTheme.borderColor,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  child: Row(
                    children: [
                      Text(
                        "Sort by : ",
                        style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: widget.contentTheme.k7E7E7E),
                      ),
                      Obx(() => Text(
                            controller.sortOption.value,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: widget.contentTheme.k142228,
                            ),
                          )),
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
                    children: sortOptions.map((option) {
                      return InkWell(
                        onTap: () {
                          controller.sortOption.value = option;
                          Get.back();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          child: Text(option,
                              style: GoogleFonts.inter(fontSize: 12.sp)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          16.verticalSpace,

          // Table and data display
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.filteredUsers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Text(
                    "No users found",
                    style: GoogleFonts.inter(
                        fontSize: 16.sp, color: widget.contentTheme.k7E7E7E),
                  ),
                );
              }

              return Column(
                children: [
                  // Table Header
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    child: Row(
                      children: [
                        _headerCell(text: "User", width: wUser),
                        _headerCell(text: "Email", width: wEmail),
                        _headerCell(text: "Role", width: wRole),
                        _headerCell(text: "Status", width: wStatus),
                        _headerCell(text: "", width: wAction),
                      ],
                    ),
                  ),
                  Divider(color: const Color(0xffE5E7EB), thickness: 1),

                  // Table Rows with user data and edit button
                  Expanded(
                    child: ListView.separated(
                      itemCount: controller.filteredUsers.length,
                      separatorBuilder: (_, __) => Divider(
                        color: const Color(0xffE5E7EB),
                        thickness: 1,
                        indent: 24.w,
                        endIndent: 24.w,
                      ),
                      itemBuilder: (context, index) {
                        final user = controller.filteredUsers[index];
                        final isActive =
                            user.statusCode.toLowerCase() == "active";

                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          child: Row(
                            children: [
                              _centerCell(
                                child: Text(
                                  "${user.firstName} ${user.lastName}",
                                  style: GoogleFonts.inter(fontSize: 12.sp),
                                ),
                                width: wUser,
                              ),
                              _centerCell(
                                child: Text(
                                  user.email,
                                  style: GoogleFonts.inter(fontSize: 12.sp),
                                ),
                                width: wEmail,
                              ),
                              _centerCell(
                                child: Text(
                                  user.roleDisplayName,
                                  style: GoogleFonts.inter(fontSize: 12.sp),
                                ),
                                width: wRole,
                              ),
                              _centerCell(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.r),
                                    color: isActive
                                        ? Colors.transparent
                                        : const Color(0xffF3F4F6),
                                    border: Border.all(
                                      color: isActive
                                          ? const Color(0xff0A8041)
                                          : const Color(0xff9CA3AF),
                                      // width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? "active" : "inactive",
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? const Color(0xff0A8041)
                                          : const Color(0xff374151),
                                    ),
                                  ),
                                ),
                                width: wStatus,
                              ),
                              _centerCell(
                                child: InkWell(
                                  onTap: () => _showEditUserPopup(user),
                                  child: Container(
                                    // height: 30.h,
                                    // width: 65.w,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 6.h),

                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.r),
                                      border: Border.all(
                                          color: widget.contentTheme.kC6C3C3),
                                    ),
                                    child: Text(
                                      "Edit",
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: widget.contentTheme.k142228,
                                      ),
                                    ),
                                  ),
                                ),
                                width: wAction,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Pagination footer
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  //   child: Row(
                  //     children: [
                  //       Obx(() => Text(
                  //             "Showing page ${controller.currentPage.value} of ${controller.totalPages.value} (${controller.totalCount.value} users)",
                  //             style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xff6B7280)),
                  //           )),
                  //       const Spacer(),
                  //       _pagination(),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Obx(() {
                          final totalItems = controller.filteredUsers.length;
                          final startIndex =
                              ((controller.currentPage.value - 1) *
                                      controller.pageSize) +
                                  1;
                          final endIndex = (startIndex + totalItems - 1)
                              .clamp(0, controller.totalCount.value);

                          return Text(
                            "Showing $startIndex–$endIndex of ${controller.totalCount.value} users",
                            style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: const Color(0xff6B7280)),
                          );
                        }),
                        const Spacer(),
                        _pagination(),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
