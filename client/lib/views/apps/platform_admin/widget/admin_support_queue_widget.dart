import 'package:binary_success/controller/apps/admin/admin_support_controller.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/widgets/custom_pop_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:binary_success/models/platform_support_model.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/images.dart';

class AdminSupportWidget extends StatefulWidget {
  final List<SupportModel> tickets;
  final String filter;
  final String status;
  final ContentTheme contentTheme;

  const AdminSupportWidget({
    super.key,
    required this.tickets,
    required this.filter,
    required this.status,
    required this.contentTheme,
  });

  @override
  State<AdminSupportWidget> createState() => _AdminSupportWidgetState();
}

class _AdminSupportWidgetState extends State<AdminSupportWidget> {
  String searchQuery = '';
  String sortOption = 'Newest';
  final TextEditingController searchController = TextEditingController();

  // Column widths
  final double wTicket = 140;
  final double wInstitute = 180;
  final double wUser = 160;
  final double wTopic = 200;
  final double wPriority = 100;
  final double wStatus = 140;
  final double wAction = 100;

  final TextStyle _cellStyle = GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

void _loadPage(int pageNumber) async {
  final controller = Get.find<AdminSupportController>();

  // If this is the first load, fetch all once
  if (controller.allTickets.isEmpty) {
    await controller.fetchAllTabs(); // single API call
  }

  controller.currentPage.value = pageNumber;

  // ====== Select correct source based on tab ======
  List<SupportModel> source;
  switch (widget.status.toUpperCase()) {
    case "OPEN":
      source = controller.openTickets;
      break;
    case "CLOSED":
      source = controller.closedTickets;
      break;
    default:
      source = controller.allTickets;
  }

  // ====== Apply local pagination ======
  final startIndex = (pageNumber - 1) * controller.pageSize;
  final endIndex = startIndex + controller.pageSize;

  // Assign only 10 records (or fewer if last page)
  controller.tickets.assignAll(
    source.sublist(
      startIndex,
      endIndex > source.length ? source.length : endIndex,
    ),
  );

  controller.totalPages.value =
      (source.length / controller.pageSize).ceil().clamp(1, 9999);

  controller.isLoading.value = false;
}




  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminSupportController>();

    return MyCard.circular(
      margin: EdgeInsets.only(
        bottom: 60.h,
        left: 5.w,
        top: 25.h,
        right: MySpacing.fullWidth(context) * 0.04,
      ),
      borderRadiusAll: 25.r,
      bordered: false,
      padding: EdgeInsets.only(left: 0, top: 30.h, bottom: 0, right: 0),
      child: Column(
        children: [
          // ==== HEADER ====
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "All Tickets",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    // Search Box
                    SizedBox(
                      width: 180.w,
                      height: 36.h,
                      child: TextField(
                        controller: searchController,
                        onChanged: (v) => setState(() => searchQuery = v),
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
                                setState(() => sortOption = option);
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
                ),
              ],
            ),
          ),
          16.verticalSpace,

          // ==== BODY ====
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              // Apply local search filter on current page tickets
              // Apply local search filter on current page tickets
List<SupportModel> tickets = List<SupportModel>.from(controller.tickets);
final query = searchQuery.trim().toLowerCase();

if (query.isNotEmpty) {
  // split into terms so "john doe" searches for both words
  final terms = query.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();

  tickets = tickets.where((t) {
    final caseNum = (t.caseNumber ?? '').toLowerCase();
    final status = (t.status ?? '').toLowerCase();
    final account = (t.accountName ?? '').toLowerCase(); // institute
    // combine contactName + suppliedName so firstname and lastname are both searchable
    final contactCombined = ('${t.contactName ?? ''} ${t.suppliedName ?? ''}').toLowerCase();
    final subject = (t.subject ?? '').toLowerCase();
    final topic = (t.topic ?? '').toLowerCase();

    // require every search term to exist in at least one of the fields
    return terms.every((term) =>
      caseNum.contains(term) ||
      status.contains(term) ||
      account.contains(term) ||
      contactCombined.contains(term) ||
      subject.contains(term) ||
      topic.contains(term)
    );
  }).toList();
}

              // Pagination indices
              int totalItems = _getTotalCount(controller);
              final startIndex =
                  ((controller.currentPage.value - 1) * controller.pageSize) + 1;
              final endIndex =
                  (startIndex + tickets.length - 1).clamp(0, totalItems);

              // Sort local tickets
              tickets.sort((a, b) {
  switch (sortOption) {
    case 'Newest':
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);

    case 'Oldest':
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aDate.compareTo(bDate);

    case 'User A → Z':
      return (a.caseNumber ?? '').compareTo(b.caseNumber ?? '');
    case 'User Z → A':
      return (b.caseNumber ?? '').compareTo(a.caseNumber ?? '');

    case 'Open':
      return (a.status ?? '').toLowerCase() == 'open' ? -1 : 1;
    case 'Closed':
      return (a.status ?? '').toLowerCase() == 'closed' ? -1 : 1;

    default:
      return 0;
  }
});


              if (tickets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Images.analytics,
                        height: 64.sp,
                        width: 64.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        query.isNotEmpty
                            ? "No tickets found"
                            : "No tickets available",
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        query.isNotEmpty
                            ? ""
                            : "Tickets will appear here once available",
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

              // ==== TABLE ====
              return Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    child: Row(
                      children: [
                        _headerCell("Ticket #", wTicket),
                        _headerCell("Institute Name", wInstitute),
                        _headerCell("User", wUser),
                        _headerCell("Topic", wTopic),
                        _headerCell("Priority", wPriority),
                        _headerCell("Status", wStatus),
                        _headerCell("Action", wAction),
                      ],
                    ),
                  ),
                  Divider(color: const Color(0xffE5E7EB), thickness: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => Divider(
                        color: const Color(0xffE5E7EB),
                        thickness: 1,
                        indent: 24.w,
                        endIndent: 24.w,
                      ),
                      itemBuilder: (context, index) {
  final t = tickets[index];
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
    child: Row(
      children: [
        _centerCell(
          Text(
            t.caseNumber ?? t.recordID, // fallback to recordID
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9C27B0),
            ),
          ),
          wTicket,
        ),
_centerCell(
  Text(t.accountName ?? "-", style: _cellStyle), // ✅ FIXED
  wInstitute,
),
_centerCell(
  Text(t.contactName ?? "-", style: _cellStyle), // ✅ FIXED
  wUser,
),

        _centerCell(
          Text(t.topic ?? t.subject ?? "-", style: _cellStyle),
          wTopic,
        ),
        _centerCell(
          Text(t.priorityCode, style: _cellStyle),
          wPriority,
        ),
        _centerCell(
          _statusChip(t.status),
          wStatus,
        ),
        _centerCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton(() => controller.openTicket(t)),
              if ((t.attachments ?? []).isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: Icon(
                    Icons.attachment,
                    size: 18.sp,
                    color: Colors.grey[700],
                  ),
                ),
            ],
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
                          "Showing $startIndex–$endIndex of $totalItems tickets",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: const Color(0xff6B7280),
                          ),
                        ),
                        const Spacer(),
                        _pagination(
                          totalPages: controller.totalPages.value,
                          current: controller.currentPage.value,
                          onJump: (p) => _loadPage(p),
                          onPrev: controller.currentPage.value > 1
                              ? () =>
                                  _loadPage(controller.currentPage.value - 1)
                              : null,
                          onNext: controller.currentPage.value <
                                  controller.totalPages.value
                              ? () =>
                                  _loadPage(controller.currentPage.value + 1)
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

  // ======= Helpers =======
  Widget _headerCell(String text, double width) =>
      SizedBox(width: width.w, child: Center(child: Text(text, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.black))));

  Widget _centerCell(Widget child, double width) =>
      SizedBox(width: width.w, child: Center(child: child));

  Widget _actionButton(VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 25,
        height: 25,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xff3B82F6), Color(0xffA855F7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _statusChip(String? status) {
    switch ((status ?? "").toUpperCase()) {
      case "OPEN":
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.r),
            color: const Color(0xffE6F4EA),
            border: Border.all(color: const Color(0xff0A8041), width: 2),
          ),
          child: Text("open", style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xff0A8041))),
        );
      case "IN PROGRESS":
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
          decoration: BoxDecoration(color: const Color(0xffFEF3C7), borderRadius: BorderRadius.circular(30.r)),
          child: Text("in progress", style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xff92400E))),
        );
      case "CLOSED":
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
          decoration: BoxDecoration(color: const Color(0xffD1D5DB), borderRadius: BorderRadius.circular(30.r)),
          child: Text("closed", style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xff111827))),
        );
      default:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
          decoration: BoxDecoration(color: const Color(0xffF3F4F6), borderRadius: BorderRadius.circular(30.r)),
          child: Text((status ?? "-").toLowerCase(), style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xff374151))),
        );
    }
  }

  List<String> _getSortOptions() {
    return ['Newest', 'Oldest', 'User A → Z', 'User Z → A', 'Open', 'Closed'];
  }


int _getTotalCount(AdminSupportController controller) {
  switch (widget.status.toLowerCase()) {
    case "open":
      return controller.openTickets.length;
    case "closed":
      return controller.closedTickets.length;
    default:
      return controller.allTickets.length;
  }
}


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

    Widget box({required Widget child, required VoidCallback? onTap, bool active = false}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: active ? const LinearGradient(colors: [Color(0xff6441EF), Color(0xff0D63E0)]) : null,
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
    final children = <Widget>[box(child: const Icon(Icons.chevron_left, size: 16), onTap: onPrev)];
    for (int i = 0; i < nums.length; i++) {
      final n = nums[i];
      final prev = i == 0 ? null : nums[i - 1];
      if (prev != null && n - prev > 1) {
        children.add(Text("…", style: GoogleFonts.inter(color: const Color(0xff6B7280))));
      }
      children.add(box(child: Text("$n"), active: n == current, onTap: () => onJump(n)));
    }
    children.add(box(child: const Icon(Icons.chevron_right, size: 16), onTap: onNext));
    return Row(children: children);
  }
}
