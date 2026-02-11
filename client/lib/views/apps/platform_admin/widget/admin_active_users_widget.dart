import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/controller/apps/admin/admin_users_controller.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/widgets/custom_pop_menu.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';

class AdminActiveUsersWidget extends StatefulWidget {
  final ContentTheme contentTheme;
  final String status;

  const AdminActiveUsersWidget({
    super.key,
    required this.contentTheme,
    required this.status,
  });

  @override
  State<AdminActiveUsersWidget> createState() => _AdminActiveUsersWidgetState();
}

class _AdminActiveUsersWidgetState extends State<AdminActiveUsersWidget> {
  String searchQuery = '';
  String sortOption = 'Newest';
  int currentPage = 1;
  bool isSaving = false;

  final TextEditingController searchController = TextEditingController();

  // Column widths
  // final double wUser = 120;
  // final double wRole = 240;
  // final double wEmail = 300;
  // final double wStatus = 260;
  // final double wAction = 100;
  final double wUser = 170; // was 120
  final double wEmail = 280; // was 300
  final double wRole = 200; // was 240
  final double wStatus = 170; // was 260
  final double wAction = 100;

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    final controller = Get.find<AdminUsersController>();
    controller.fetchUsers(
      status: widget.status,
      pageNumber: 1,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminUsersController>();

    return MyCard.circular(
      margin: EdgeInsets.only(
        bottom: 60.h,
        left: 5.w,
        top: 25.h,
        right: MySpacing.fullWidth(context) * 0.04,
      ),
      borderRadiusAll: 25.r,
      bordered: false,
      padding:
          EdgeInsets.only(left: 40.w, top: 30.h, bottom: 10.h, right: 30.w),
      child: Column(
        children: [
          // ==== HEADER ====
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Users",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: widget.contentTheme.black,
                  ),
                ),
                Obx(() {
                  List usersList = _getUsersList(controller);
                  if (usersList.isEmpty && !controller.isLoading.value) {
                    return const SizedBox();
                  }

                  return Row(
                    children: [
                      // Search Box
                      SizedBox(
                        width: 180.w,
                        height: 36.h,
                        child: TextField(
                          controller: searchController,
                          onChanged: (v) {
                            setState(() {
                              searchQuery = v;
                              currentPage = 1;
                            });
                          },
                          style: GoogleFonts.inter(fontSize: 12.sp),
                          decoration: InputDecoration(
                            hintText: "Search",
                            hintStyle: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xff9A9A9B),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Color(0xff6B7280),
                            ),
                            filled: true,
                            fillColor: const Color(0xffF9FAFB),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      16.horizontalSpace,

                      // Sort Dropdown
                      CustomPopupMenu(
                        backdrop: true,
                        onChange: (_) {},
                        menu: MyContainer.bordered(
                          borderRadiusAll: 8.r,
                          borderColor: widget.contentTheme.borderColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 6.h,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Sort by : ",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: widget.contentTheme.k7E7E7E,
                                ),
                              ),
                              Text(
                                sortOption,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: widget.contentTheme.k142228,
                                ),
                              ),
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
                            children: _getSortOptions().map((option) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    sortOption = option;
                                    currentPage = 1;
                                  });
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  child: Text(
                                    option,
                                    style: GoogleFonts.inter(fontSize: 12.sp),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          16.verticalSpace,

          // ==== BODY WITH FULL PAGE LOADER ====
          Expanded(
            child: Obx(() {
              // ✅ FULL PAGE LOADER - Shows during data fetching
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xff004AAD),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                );
              }

              List<dynamic> allUsers = _getUsersList(controller);
              final query = searchQuery.trim().toLowerCase();

              // local search
              List<dynamic> filtered = allUsers.where((u) {
                if (query.isEmpty) return true;
                return (u.firstName ?? '').toLowerCase().contains(query) ||
                    (u.lastName ?? '').toLowerCase().contains(query) ||
                    (u.email ?? '').toLowerCase().contains(query);
              }).toList();

              // local sort
              filtered.sort((a, b) {
                switch (sortOption) {
                  case 'User A → Z':
                    return (a.firstName ?? '').compareTo(b.firstName ?? '');
                  case 'User Z → A':
                    return (b.firstName ?? '').compareTo(a.firstName ?? '');
                  case 'Newest':
                    final aTime = a.createdAt ?? DateTime(1970);
                    final bTime = b.createdAt ?? DateTime(1970);
                    return bTime.compareTo(aTime);
                  case 'Oldest':
                    final aTime = a.createdAt ?? DateTime(1970);
                    final bTime = b.createdAt ?? DateTime(1970);
                    return aTime.compareTo(bTime);
                  case 'Active':
                    return (a.status ?? '').toLowerCase() == 'active' ? -1 : 1;
                  case 'Inactive':
                    return (a.status ?? '').toLowerCase() == 'inactive'
                        ? -1
                        : 1;
                  default:
                    return 0;
                }
              });

              // ✅ EMPTY STATE
              if (filtered.isEmpty) {
                String emptyMessage;

                if (searchQuery.isNotEmpty) {
                  emptyMessage = widget.status == "active"
                      ? "No active users found"
                      : widget.status == "inactive"
                          ? "No inactive users found"
                          : "No users found";
                } else {
                  emptyMessage = widget.status == "active"
                      ? "No active users found"
                      : widget.status == "inactive"
                          ? "No inactive users found"
                          : "No users found";
                }

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
                        emptyMessage,
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (searchQuery.isEmpty) ...[
                        SizedBox(height: 8.h),
                        Text(
                          "Users will appear here once added",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              // ==== PAGINATION COUNTERS ====
              int totalItems = _getTotalCount(controller, filtered.length);
              final startIndex =
                  ((controller.currentPage.value - 1) * controller.pageSize) +
                      1;
              final endIndex =
                  (startIndex + filtered.length - 1).clamp(0, totalItems);

              return Column(
                children: [
                  // ==== TABLE HEADER ====
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    child: Row(
                      children: [
                        _headerCell(text: "User", width: wUser),
                        _headerCell(text: "Role", width: wRole),
                        _headerCell(text: "Email", width: wEmail),
                        _headerCell(text: "Status", width: wStatus),
                        _headerCell(text: "", width: wAction),
                      ],
                    ),
                  ),
                  Divider(color: const Color(0xffE5E7EB), thickness: 1),

                  // ==== TABLE BODY ====
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        color: const Color(0xffE5E7EB),
                        thickness: 1,
                        indent: 24.w,
                        endIndent: 24.w,
                      ),
                      itemBuilder: (context, index) {
                        final u = filtered[index];
                        final normalizedStatus = (u.status ?? "").toLowerCase();
                        final isActive = normalizedStatus == "active";

                        // CHECK IF THIS USER IS THE PLATFORM ADMIN
                        final isSelf = (u.roleName?.toLowerCase().trim() ==
                            "platform admin");

                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            children: [
                              _centerCell(
                                child: Text(
                                  "${u.firstName ?? ''} ${u.lastName ?? ''}",
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp, color: Colors.black),
                                ),
                                width: wUser,
                              ),
                              _centerCell(
                                child: Text(
                                  u.roleName ?? "-",
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp, color: Colors.black),
                                ),
                                width: wRole,
                              ),
                              _centerCell(
                                child: Text(
                                  u.email ?? "-",
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp, color: Colors.black),
                                ),
                                width: wEmail,
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

                              // ---------------------------
                              // UPDATED EDIT BUTTON SECTION
                              // ---------------------------
                              _centerCell(
                                child: InkWell(
                                  onTap: isSelf
                                      ? null
                                      : () => _showEditUserPopup(u),
                                  child: Container(
                                    height: 30.h,
                                    width: 65.w,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25.r),
                                      border: Border.all(
                                        color: isSelf
                                            ? Colors.grey
                                            : widget.contentTheme.kC6C3C3,
                                      ),
                                      color: isSelf
                                          ? Colors.grey.withOpacity(0.3)
                                          : Colors.transparent,
                                    ),
                                    child: Text(
                                      "Edit",
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            isSelf ? Colors.grey : Colors.black,
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

                  // ==== PAGINATION FOOTER ====
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Text(
                          "Showing $endIndex of $totalItems users",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xff6B7280),
                          ),
                        ),
                        const Spacer(),
                        _pagination(
                          totalPages: controller.totalPages.value,
                          current: controller.currentPage.value,
                          onJump: (p) => controller.fetchUsers(
                            status: widget.status,
                            pageNumber: p,
                          ),
                          onPrev: controller.currentPage.value > 1
                              ? () => controller.fetchUsers(
                                    status: widget.status,
                                    pageNumber:
                                        controller.currentPage.value - 1,
                                  )
                              : null,
                          onNext: controller.currentPage.value <
                                  controller.totalPages.value
                              ? () => controller.fetchUsers(
                                    status: widget.status,
                                    pageNumber:
                                        controller.currentPage.value + 1,
                                  )
                              : null,
                        ),
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

  void _showEditUserPopup(dynamic user) {
    String status = (user.status ?? "active").toLowerCase();
    bool isSubmitting = false;

    print("Edit user: Username = ${user.username}, Email = ${user.email}");

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Column(
              children: [
                Text(
                  "Edit User",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
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
                      controller: TextEditingController(text: user.roleName),
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
                          groupValue: status,
                          activeColor: const Color(0xff0A8041),
                          onChanged: isSubmitting
                              ? null
                              : (value) {
                                  // ✅ Disable during loading
                                  setState(() => status = value!);
                                },
                        ),
                        const Text("Active"),
                        20.horizontalSpace,
                        Radio<String>(
                          value: "inactive",
                          groupValue: status,
                          activeColor: const Color(0xff0A8041),
                          onChanged: isSubmitting
                              ? null
                              : (value) {
                                  // ✅ Disable during loading
                                  setState(() => status = value!);
                                },
                        ),
                        const Text("Inactive"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              GestureDetector(
                onTap: isSubmitting
                    ? null
                    : () async {
                        // ✅ Disable tap during loading
                        setState(() => isSubmitting = true);

                        final updatedBy = LocalStorage.getDBUserID() ?? '';
                        final controller = Get.find<AdminUsersController>();

                        bool success =
                            await controller.updateUserStatusOnServer(
                          keycloakUserId: user.keycloakUserId ?? '',
                          userId: user.userId ?? '',
                          status: status,
                          updatedBy: updatedBy,
                        );

                        setState(() => isSubmitting = false);

                        if (success) {
                          controller.updateUserStatus(
                              user.userId ?? '', status);
                          Navigator.pop(
                              context); // ✅ Close dialog after success

                          // ✅ Refetch users to update counts
                          controller.fetchUsers(
                            status: widget.status,
                            pageNumber: controller.currentPage.value,
                          );

                          Get.snackbar(
                            "Success",
                            "User status updated successfully",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            "Error",
                            "Failed to update user status",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            duration: Duration(seconds: 3),
                          );
                        }
                      },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.r),
                    gradient: isSubmitting
                        ? LinearGradient(
                            // ✅ Dimmed gradient during loading
                            colors: [
                              Color(0xff004AAD).withOpacity(0.6),
                              Color(0xffCB6CE6).withOpacity(0.6),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : const LinearGradient(
                            colors: [
                              Color(0xff004AAD),
                              Color(0xffCB6CE6),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          // ✅ Show loader when submitting
                          width: 56.w, // Match "Submit" text width
                          height: 20.h,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : Text(
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

// Row with label on left
  Widget _buildFormRow(String label, Widget field) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: field),
      ],
    );
  }

// Reusable read-only container (used for role, username, email)
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
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  List<String> _getSortOptions() {
    return [
      'Newest',
      'Oldest',
      'User A → Z',
      'User Z → A',
      'Active',
      'Inactive'
    ];
  }

  List<dynamic> _getUsersList(AdminUsersController controller) {
    switch (widget.status) {
      case "active":
        return controller.activeUsers;
      case "inactive":
        return controller.inactiveUsers;
      default:
        return controller.allUsers;
    }
  }

  int _getTotalCount(AdminUsersController controller, int fallback) {
    switch (widget.status) {
      case "active":
        return controller.activeCount.value;
      case "inactive":
        return controller.inactiveCount.value;
      default:
        return controller.totalCount.value;
    }
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
                    colors: [Color(0xff6441EF), Color(0xff0D63E0)])
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
      box(child: const Icon(Icons.chevron_left, size: 16), onTap: onPrev)
    ];

    for (int i = 0; i < nums.length; i++) {
      final n = nums[i];
      final prev = i == 0 ? null : nums[i - 1];
      if (prev != null && n - prev > 1) {
        children.add(Text("…",
            style: GoogleFonts.inter(color: const Color(0xff6B7280))));
      }
      children.add(
          box(child: Text("$n"), active: n == current, onTap: () => onJump(n)));
    }

    children.add(
        box(child: const Icon(Icons.chevron_right, size: 16), onTap: onNext));
    return Row(children: children);
  }
}
