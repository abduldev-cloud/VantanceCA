import 'package:binary_success/controller/apps/student/student_dashboard_controller.dart';
import 'package:binary_success/controller/apps/teacher/teacher_classes_controller.dart';
import 'package:binary_success/helpers/localizations/language.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/theme/app_notifier.dart';
import 'package:binary_success/helpers/theme/app_style.dart';
import 'package:binary_success/helpers/theme/app_theme.dart';
import 'package:binary_success/helpers/theme/theme_customizer.dart';
import 'package:binary_success/helpers/utils/my_shadow.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/utils/utils.dart';
import 'package:binary_success/helpers/widgets/my_button.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_container.dart';
import 'package:binary_success/helpers/widgets/my_dashed_divider.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/auth/login.dart';
import 'package:binary_success/views/extra_pages/notification_page.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_borders/input_borders/gradient_outline_input_border.dart';
import 'package:provider/provider.dart';
import 'package:binary_success/controller/global_search_controller.dart';
import 'package:binary_success/models/global_search_model.dart';
import 'package:binary_success/controller/extra_pages/notification_controller.dart';
//import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:developer';
import '../../controller/apps/school/school_class_view_controller.dart';
import '../../controller/apps/teacher/teacher_view_class_controller.dart';
import '../../helpers/services/teacher_service.dart';
import '../../models/teacher_classes_model.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar>
    with SingleTickerProviderStateMixin, UIMixin {
  Function? languageHideFn;

  late final GlobalSearchController searchController;
  final TextEditingController textController = TextEditingController();
  final NotificationController controller = Get.put(NotificationController());
  final FocusNode focusNode = FocusNode();
  final GlobalKey textFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Initialize search controller
    searchController = Get.put(GlobalSearchController());
    // Load notifications if not in grading review
    final userId = LocalStorage.getDBUserID() ?? "test";
    final currentRoute = Get.currentRoute;
    if (currentRoute != '/teacher/gradingreview') {
      controller.loadNotifications(userId: userId, read: null);
    }
    // Listen to search results changes
    ever<List<dynamic>>(searchController.results, (results) {
      if (results.isNotEmpty && focusNode.hasFocus) {
        _showDropdown();
      } else {
        _removeDropdown();
      }
    });
  }

  @override
  void dispose() {
    _removeDropdown();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    final names = name.trim().split(RegExp(r"\s+"));
    if (names.length >= 2) {
      return names[0][0].toUpperCase() + names[1][0].toUpperCase();
    } else {
      return names[0].substring(0, names[0].length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropdown() {
    _removeDropdown();
    if (searchController.results.isEmpty) return;
    final overlay = Overlay.of(context);
    final renderBox =
        textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        width: size.width,
        child: Material(
          color: Colors.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(10.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 1000.h),
            child: Obx(() {
              if (searchController.results.isEmpty) {
                return const SizedBox.shrink();
              }
              return ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchController.results.length,
                  itemBuilder: (context, index) {
                    final item = searchController.results[index];
                    return InkWell(
                      onTap: () {
                        handleSearchItemTap(context, item.entityId ?? "");
                        _removeDropdown();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 12.w),
                        child: Row(
                          children: [
                            if (item.entityType == "CLASS")
                              Image.asset(Images.classes,
                                  width: 20.w, height: 20.h)
                            else if (item.entityType == "ASSIGNMENT" ||
                                item.entityType == "WF")
                              Image.asset(Images.assignments,
                                  width: 20.w, height: 20.h),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.entityName ?? "-",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    item.entityType ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return MyCard(
      shadow: MyShadow(position: MyShadowPosition.bottomRight, elevation: 0),
      borderRadiusAll: 0,
      padding: EdgeInsets.only(left: 24.w, right: 24.r, top: 20.h),
      margin: EdgeInsets.only(right: 45.w),
      color: topBarTheme.background.withAlpha(246),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Search Box
          SizedBox(
            width: 250.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextField
                TextField(
                  key: textFieldKey,
                  controller: textController,
                  focusNode: focusNode,
                  style: TextStyle(fontSize: 13.sp),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "search students, assignments...",
                    prefixIcon:
                        Icon(Icons.search, size: 18.sp, color: Colors.grey),
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 13.sp),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: GradientOutlineInputBorder(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF014AAD),
                          Color(0xFFCB6CE6)
                        ], // your gradient colors
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      width: 2, // thickness of border
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (query) {
                    searchController.search(query);
                  },
                ),
                Obx(() {
                  if (searchController.isLoading.value) {
                    return Padding(
                      padding: EdgeInsets.only(top: 0.1.h),
                      child: LinearProgressIndicator(
                        minHeight: 3.h,
                        // color: Colors.blue,
                        // backgroundColor: Colors.grey.shade200,
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
              ],
            ),
          ),
          20.horizontalSpace,
          // Calendar Icon
          InkWell(
            onTap: () {
              _removeDropdown();
              if (RoleUtils.isLearner) {
                Get.toNamed("/student/calendar");
              } else {
                Get.toNamed("/teacher/calendar");
              }
            },
            child: Image.asset(Images.calendar, width: 27.w, height: 27.h),
          ),
          12.horizontalSpace,
          // Notification Icon
          InkWell(
            onTap: () {
              _removeDropdown();
              showDialog(
                  context: context, builder: (_) => const NotificationDialog());
            },
            child: Obx(() {
              final hasUnread = controller.isUnread.value &&
                  controller.notifications.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Image.asset(
                  hasUnread ? Images.unread : Images.notification,
                  width: 30.w,
                  height: 30.h,
                  fit: BoxFit.contain,
                ),
              );
            }),
          ),
          10.horizontalSpace,
          // Settings Icon
          InkWell(
            onTap: () {
              _removeDropdown();
              Get.toNamed("/school/setting");
            },
            child: Image.asset(Images.setting, width: 27.w, height: 27.h),
          ),
          40.horizontalSpace,
          // User info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                LocalStorage.getUserName() ?? "",
                style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: contentTheme.k142228),
              ),
              Text(
                LocalStorage.getDBDisplayRoleName() ?? "",
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: contentTheme.k142228),
              ),
            ],
          ),
          15.horizontalSpace,
          // Avatar
          Container(
            width: 50.w,
            height: 50.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 244, 245, 246),
                  Color.fromARGB(255, 201, 225, 244),
                ],
              ),
            ),
            child: Text(
              getInitials(LocalStorage.getUserName()),
              style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: contentTheme.black),
            ),
          ),
        ],
      ),
    );
  }

  void handleSearchItemTap(BuildContext context, String selectedId) async {
    final item =
        searchController.results.firstWhere((e) => e.entityId == selectedId);
    if (item.entityType == "LEARNER" || item.entityType == "TEACHER") {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.entityType == "LEARNER" ? "View Student" : "View Teacher",
                style: GoogleFonts.inter(
                    fontSize: 20.sp, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Text(
                "Details of ${item.entityType.toLowerCase()}",
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
                  "First Name",
                  Text(
                    item.entityName.split(" ").first ?? "Unknown",
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ),
                22.verticalSpace,
                _buildFormRow(
                  "Last Name",
                  Text(
                    item.entityName.trim().contains(" ")
                        ? item.entityName.trim().split(" ").last
                        : "-",
                    style: GoogleFonts.inter(
                        fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ),
                // 22.verticalSpace,
                // _buildFormRow(
                //   "Email",
                //   Text(
                //     "gregorminh@westlake.edu",
                //     style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500),
                //   ),
                // ),
                22.verticalSpace,
                _buildFormRow(
                  "Status",
                  Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.radio_button_checked,
                              size: 20.sp, color: Colors.black),
                          SizedBox(width: 8.w),
                          Text(
                            "Active",
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(width: 24.w),
                      Row(
                        children: [
                          Icon(Icons.radio_button_unchecked,
                              size: 20.sp, color: Colors.grey.shade400),
                          SizedBox(width: 8.w),
                          Text(
                            "Inactive",
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                35.verticalSpace,
              ],
            ),
          ),
        ),
      );
    } else {
      // Navigate based on role and entity type
      if (RoleUtils.isLearner) {
        if (item.entityType == "CLASS") {
          final controller = Get.find<StudentDashboardController>();
          controller.classID.value = item.entityId ?? "";
          controller.className.value = item.entityName ?? "";
          controller.getStudentViewClassData(classId: item.entityId ?? "");
          Get.offNamed("/student/classdetail");
        } else if (item.entityType == "ASSIGNMENT" ||
            item.entityType == "FINGERPRINT") {
          Get.toNamed("/student/writingpad", arguments: item.entityId);
        }
      } else if (RoleUtils.isTeacher) {
        if (item.entityType == "CLASS") {
          final detailController =
              Get.isRegistered<TeacherClassViewController>()
                  ? Get.find<TeacherClassViewController>()
                  : Get.put(TeacherClassViewController());
          detailController.fetchClassStudents(selectedId, item.entityId);
          final selectedClass = ClassInfo(
            classId: item.entityId,
            className: item.entityName,
          );
          Get.toNamed("/teacher/classesdetail", arguments: selectedClass);
        } else if (item.entityType == "ASSIGNMENT") {
          Get.toNamed("/teacher/assignmentdetail",
              arguments: {"taskId": item.entityId});
        } else if (item.entityType == "FINGERPRINT") {
          Get.toNamed("/teacher/fingerprintdetail",
              arguments: {"taskId": item.entityId});
        }
      } else if (RoleUtils.isInstituteAdmin) {
        if (item.entityType == "CLASS") {
          // final response = await TeacherService.getTeacherViewClassAPI(
          //       teacherId: item.entityId,
          //       classId: item.entityId,
          //     );
          // final classId =  item.entityId;
          //  final teacherId = "";
          //  final className = item.entityId ?? '';
          //  final teacherSalutation = RoleUtils.currentRole ?? '';
          //  final teacherFirstName = data['teacher_first_name'] ?? '';
          //  final teacherLastName = data['teacher_last_name'] ?? '';
          // final detailController = Get.isRegistered<SchoolClassViewController>()
          //     ? Get.find<SchoolClassViewController>()
          //      : Get.put(SchoolClassViewController());
          // await detailController.fetchClassStudents(item.entityId, item.entityId);
          // Get.toNamed("/school/classesdetail", arguments: {
          //   "classId": item.entityId,
          //   "teacherId": item.entityId,
          //   "className": item.entityName.toString(),
          //   "teacherFullName": "",
          // });
          // Get.toNamed("/admin/classdetail", arguments: item.entityId);
        } else if (item.entityType == "ASSIGNMENT" || item.entityType == "WF") {
          // Get.toNamed("/admin/assignment", arguments: item.entityId);
        } else if (item.entityType == "TEACHER") {
          // Get.toNamed("/admin/teacherdetail", arguments: item.entityId);
        } else if (item.entityType == "STUDENT") {
          //  Get.toNamed("/admin/studentdetail", arguments: item.entityId);
        }
      } else if (RoleUtils.isPlatformAdmin) {
        if (item.entityType == "INSTITUTE") {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),

              // ---------- UPDATED TITLE WITH CLOSE BUTTON ----------
              title: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.entityType == "LEARNER"
                              ? "View Student"
                              : "View School",
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Details of ${item.entityType.toLowerCase()}",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // ---------------- CLOSE BUTTON ----------------
                  Positioned(
                    right: 0,
                    top: 0,
                    child: InkWell(
                      onTap: () => Get.back(),
                      child: Icon(
                        Icons.close,
                        size: 22.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),

              // ------------------- CONTENT -------------------
              content: SizedBox(
                width: 420.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFormRow(
                      "Name",
                      Text(
                        item.entityName ?? "-",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    22.verticalSpace,
                    _buildFormRow(
                      "Status",
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.radio_button_checked,
                                  size: 20.sp, color: Colors.black),
                              SizedBox(width: 8.w),
                              Text(
                                "Active",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 24.w),
                          Row(
                            children: [
                              Icon(Icons.radio_button_unchecked,
                                  size: 20.sp, color: Colors.grey.shade400),
                              SizedBox(width: 8.w),
                              Text(
                                "Inactive",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    35.verticalSpace,
                  ],
                ),
              ),
            ),
          );

          //Get.toNamed("/platform/schooldetail", arguments: item.entityId);
        } else if (item.entityType == "TEACHER") {
          // Get.toNamed("/platform/teacherdetail", arguments: item.entityId);
        } else if (item.entityType == "STUDENT") {
          // Get.toNamed("/platform/studentdetail", arguments: item.entityId);
        } else if (item.entityType == "CLASS") {
          // Get.toNamed("/platform/classdetail", arguments: item.entityId);
        } else if (item.entityType == "ASSIGNMENT" || item.entityType == "WF") {
          // Get.toNamed("/platform/assignment", arguments: item.entityId);
        }
      }
    }
    // Clear search
    textController.clear();
    searchController.results.clear();
  }

  Widget _buildFormRow(String label, Widget field) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(":", style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
        SizedBox(width: 8.w),
        Expanded(child: field),
      ],
    );
  }

  Widget buildLanguageSelector() {
    return MyContainer.bordered(
      padding: MySpacing.xy(8, 8),
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: Language.languages
            .map((language) => MyButton.text(
                  padding: MySpacing.xy(8, 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashColor: contentTheme.onBackground.withAlpha(20),
                  onPressed: () async {
                    languageHideFn?.call();
                    await Provider.of<AppNotifier>(context, listen: false)
                        .changeLanguage(language, notify: true);
                    ThemeCustomizer.notify();
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.circular(2),
                          child: Image.asset(
                            "assets/lang/${language.locale.languageCode}.jpg",
                            width: 18,
                            height: 14,
                            fit: BoxFit.cover,
                          )),
                      MySpacing.width(8),
                      MyText.labelMedium(language.languageName)
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildNotifications() {
    Widget buildNotification(String title, String description) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.labelLarge(title),
          MySpacing.height(4),
          MyText.bodySmall(description)
        ],
      );
    }

    return MyContainer.bordered(
      paddingAll: 0,
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(16, 12),
            child: MyText.titleMedium("Notification", fontWeight: 600),
          ),
          MyDashedDivider(
              height: 1, color: theme.dividerColor, dashSpace: 4, dashWidth: 6),
          Padding(
            padding: MySpacing.xy(16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildNotification("Your order is received",
                    "Order #1232 is ready to deliver"),
                MySpacing.height(12),
                buildNotification("Account Security ",
                    "Your account password changed 1 hour ago"),
              ],
            ),
          ),
          MyDashedDivider(
              height: 1, color: theme.dividerColor, dashSpace: 4, dashWidth: 6),
          Padding(
            padding: MySpacing.xy(16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButton.text(
                  onPressed: () {},
                  splashColor: contentTheme.primary.withAlpha(28),
                  child: MyText.labelSmall(
                    "View All",
                    color: contentTheme.primary,
                  ),
                ),
                MyButton.text(
                  onPressed: () {},
                  splashColor: contentTheme.danger.withAlpha(28),
                  child: MyText.labelSmall(
                    "Clear",
                    color: contentTheme.danger,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildAccountMenu() {
    return MyContainer.bordered(
      paddingAll: 0,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyButton(
                  onPressed: () {
                    Get.toNamed('/contacts/profile');
                    setState(() {});
                  },
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  borderRadiusAll: AppStyle.buttonRadius.medium,
                  padding: MySpacing.xy(8, 4),
                  splashColor: theme.colorScheme.onSurface.withAlpha(20),
                  backgroundColor: Colors.transparent,
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.user,
                        size: 14,
                        color: contentTheme.onBackground,
                      ),
                      MySpacing.width(8),
                      MyText.labelMedium(
                        "My Profile",
                        fontWeight: 600,
                      )
                    ],
                  ),
                ),
                MySpacing.height(4),
                MyButton(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    Get.toNamed('/contacts/edit-profile');
                    setState(() {});
                  },
                  borderRadiusAll: AppStyle.buttonRadius.medium,
                  padding: MySpacing.xy(8, 4),
                  splashColor: theme.colorScheme.onSurface.withAlpha(20),
                  backgroundColor: Colors.transparent,
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.edit,
                        size: 14,
                        color: contentTheme.onBackground,
                      ),
                      MySpacing.width(8),
                      MyText.labelMedium(
                        "Edit Profile",
                        fontWeight: 600,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: MySpacing.xy(8, 8),
            child: MyButton(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Get.off(LoginPage());
              },
              borderRadiusAll: AppStyle.buttonRadius.medium,
              padding: MySpacing.xy(8, 4),
              splashColor: contentTheme.danger.withAlpha(28),
              backgroundColor: Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    FeatherIcons.logOut,
                    size: 14,
                    color: contentTheme.danger,
                  ),
                  MySpacing.width(8),
                  MyText.labelMedium(
                    "Log out",
                    fontWeight: 600,
                    color: contentTheme.danger,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
