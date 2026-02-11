import 'package:vantanceCA/helpers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:vantanceCA/helpers/services/url_service.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/theme/theme_customizer.dart';
import 'package:vantanceCA/helpers/utils/my_shadow.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/widgets/custom_pop_menu.dart';
import 'package:vantanceCA/controller/apps/school/add_school_controller.dart';

// -----------------------------------------------------------------------------
// 1. Observer Class
// -----------------------------------------------------------------------------
typedef LeftbarMenuFunction = void Function(String key);

class LeftbarObserver {
  static Map<String, LeftbarMenuFunction> observers = {};

  static attachListener(String key, LeftbarMenuFunction fn) {
    observers[key] = fn;
  }

  static detachListener(String key) {
    observers.remove(key);
  }

  static notifyAll(String key) {
    for (var fn in observers.values) {
      fn(key);
    }
  }
}

// -----------------------------------------------------------------------------
// 2. LeftBar Main Widget
// -----------------------------------------------------------------------------
class LeftBar extends StatefulWidget {
  final bool isCondensed;
  final int selectedIndex;
  final void Function(int)? onItemSelected;
  const LeftBar({
    super.key,
    this.isCondensed = false,
    this.selectedIndex = 0,
    this.onItemSelected,
  });

  @override
  _LeftBarState createState() => _LeftBarState();
}

class _LeftBarState extends State<LeftBar>
    with SingleTickerProviderStateMixin, UIMixin {
  final ThemeCustomizer customizer = ThemeCustomizer.instance;

  bool isCondensed = false;
  String path = UrlService.getCurrentUrl();

  // --- CONFIGURATION CONSTANTS ---
  final double collapsedWidth = 68.0;
  final double expandedWidth = 260.0;
  final double itemMarginHorizontal = 12.0;
  final double iconSizeBox = 40.0;
  final double gapBetweenIconAndText = 16.0;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AddSchoolController>()) {
      Get.put(AddSchoolController());
    }
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

  // --- Helper: User Profile ---
  Widget _buildUserProfile(bool isCondensed) {
    return Container(
      width: expandedWidth,
      padding:
          EdgeInsets.symmetric(horizontal: itemMarginHorizontal, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCondensed ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isCondensed
              ? null
              : Border.all(color: const Color(0xFFF0F0F0), width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: iconSizeBox,
              child: Center(
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF2F2F2),
                  child: Text(
                    getInitials(LocalStorage.getUserName()),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: gapBetweenIconAndText),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocalStorage.getUserName() ?? "User",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF000000),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "S. R. No.: ${LocalStorage.getDBUserID() ?? 'CRO0868054'}",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Plan: ",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: "Monthly",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF000000),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    isCondensed = ThemeCustomizer.instance.leftBarCondensed;

    return AnimatedContainer(
      width: isCondensed ? collapsedWidth : expandedWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: expandedWidth,
          maxWidth: expandedWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Section
              SizedBox(height: 16.h),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    ThemeCustomizer.toggleLeftBarCondensed();
                    setState(() {});
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: itemMarginHorizontal),
                    child: Row(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: isCondensed
                                ? Container(
                                    key: const ValueKey('logoCircle'),
                                    alignment: Alignment.centerLeft,
                                    child: Image.asset(
                                      Images.logoCircle,
                                      width: 45,
                                      height: 45,
                                    ),
                                  )
                                : Container(
                                    key: const ValueKey('logoExpanded'),
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      Images
                                          .logoLeftBar, // "assets/images/logo/Logo.png"
                                      height: 40,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: RoleUtils.isInstituteAdmin
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  NavigationItem(
                                    index: 0,
                                    iconData: Images.dashboardIcon,
                                    isSelected: widget.selectedIndex == 0,
                                    title: "Dashboard",
                                    route: '/school/dashboard',
                                  ),
                                  NavigationItem(
                                    index: 1,
                                    isSelected: widget.selectedIndex == 1,
                                    iconData: Images.classes,
                                    title: "Classes",
                                    route: '/school/classes',
                                  ),
                                  NavigationItem(
                                    index: 2,
                                    isSelected: widget.selectedIndex == 2,
                                    iconData: Images.analytics,
                                    title: "Analytics",
                                    route: '/school/analytics',
                                  ),
                                  if (LocalStorage.getIsDemoSchool() != "Y")
                                    NavigationItem(
                                      index: 3,
                                      isSelected: widget.selectedIndex == 3,
                                      iconData: Images.integrations,
                                      title: "Integrations",
                                      route: '/school/integrations',
                                    ),
                                  NavigationItem(
                                    index: 4,
                                    isSelected: widget.selectedIndex == 4,
                                    iconData: Images.assignments,
                                    title: "Billing",
                                    route: '/school/billing',
                                  ),
                                  const SizedBox(height: 20),
                                  NavigationItem(
                                    index: 5,
                                    iconData: Images.setting,
                                    title: "Settings",
                                    isSelected: widget.selectedIndex == 5,
                                    route: '/school/setting',
                                  ),
                                  NavigationItem(
                                    index: 6,
                                    isSelected: widget.selectedIndex == 6,
                                    iconData: Images.help,
                                    title: "Help",
                                    route: '/school/help',
                                  ),
                                ],
                              )
                            : RoleUtils.isPlatformAdmin
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      NavigationItem(
                                        index: 0,
                                        iconData: Images.dashboardIcon,
                                        isSelected: widget.selectedIndex == 0,
                                        title: "Dashboard",
                                        route: '/admin/dashboard',
                                      ),
                                      NavigationItem(
                                        index: 1,
                                        isSelected: widget.selectedIndex == 1,
                                        iconData: Images.classes,
                                        title: "Schools",
                                        route: '/admin/schools',
                                      ),
                                      NavigationItem(
                                        index: 2,
                                        isSelected: widget.selectedIndex == 2,
                                        iconData: Images.classes,
                                        title: "Users",
                                        route: '/admin/users',
                                      ),
                                      NavigationItem(
                                        index: 3,
                                        isSelected: widget.selectedIndex == 3,
                                        iconData: Images.analytics,
                                        title: "Analytics",
                                        route: '/admin/analytics',
                                      ),
                                      NavigationItem(
                                        index: 7,
                                        isSelected: widget.selectedIndex == 7,
                                        iconData: Images.analytics,
                                        title: "Support Tickets",
                                        route: '/admin/support',
                                      ),
                                      const SizedBox(height: 20),
                                      NavigationItem(
                                        index: 8,
                                        iconData: Images.setting,
                                        title: "Settings",
                                        isSelected: widget.selectedIndex == 8,
                                        route: '/school/setting',
                                      ),
                                      NavigationItem(
                                        index: 9,
                                        isSelected: widget.selectedIndex == 9,
                                        iconData: Images.help,
                                        title: "Docs Site",
                                        route: '/admin/docs',
                                      ),
                                    ],
                                  )
                                : RoleUtils.isTeacher
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          NavigationItem(
                                            index: 0,
                                            iconData: Images.dashboardIcon,
                                            isSelected:
                                                widget.selectedIndex == 0,
                                            title: "Dashboard",
                                            route: '/teacher/dashboard',
                                          ),
                                          NavigationItem(
                                            index: 1,
                                            isSelected:
                                                widget.selectedIndex == 1,
                                            iconData: Images.classes,
                                            title: "Classes",
                                            route: '/teacher/classes',
                                          ),
                                          NavigationItem(
                                            index: 2,
                                            isSelected:
                                                widget.selectedIndex == 2,
                                            iconData: Images.fingerprint,
                                            title: "Writing Fingerprint",
                                            route: '/teacher/fingerprint',
                                          ),
                                          NavigationItem(
                                            index: 3,
                                            isSelected:
                                                widget.selectedIndex == 3,
                                            iconData: Images.assignments,
                                            title: "Assignments",
                                            route: '/teacher/assignments',
                                          ),
                                          NavigationItem(
                                            index: 4,
                                            isSelected:
                                                widget.selectedIndex == 4,
                                            iconData: Images.grading,
                                            title: "Grading",
                                            route: '/teacher/grading',
                                          ),
                                          NavigationItem(
                                            index: 5,
                                            isSelected:
                                                widget.selectedIndex == 5,
                                            iconData: Images.calendar,
                                            title: "Calendar",
                                            route: '/teacher/calendar',
                                          ),
                                          NavigationItem(
                                            index: 6,
                                            isSelected:
                                                widget.selectedIndex == 6,
                                            iconData: Images.analytics,
                                            title: "Analytics",
                                            route: '/teacher/analytics',
                                          ),
                                          140.verticalSpace,
                                          NavigationItem(
                                            index: 7,
                                            iconData: Images.setting,
                                            title: "Settings",
                                            isSelected:
                                                widget.selectedIndex == 7,
                                            route: '/school/setting',
                                          ),
                                          NavigationItem(
                                            index: 8,
                                            isSelected:
                                                widget.selectedIndex == 8,
                                            iconData: Images.help,
                                            title: "Help",
                                            route: '/teacher/faqs',
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          NavigationItem(
                                            index: 0,
                                            icon: Icons.article_outlined,
                                            isSelected:
                                                widget.selectedIndex == 0,
                                            title: "Papers",
                                            route: '/student/class',
                                          ),
                                          NavigationItem(
                                            index: 1,
                                            isSelected:
                                                widget.selectedIndex == 1,
                                            iconData: Images.performance_icon,
                                            title: "Practices",
                                            route: '/student/assignment',
                                          ),
                                          NavigationItem(
                                            index: 2,
                                            isSelected:
                                                widget.selectedIndex == 2,
                                            icon: Icons.emoji_events_outlined,
                                            title: "Result",
                                            route: '/student/result',
                                          ),
                                          NavigationItem(
                                            index: 3,
                                            isSelected:
                                                widget.selectedIndex == 3,
                                            icon: Icons.calendar_month_outlined,
                                            title: "Calendar",
                                            route: '/student/calendar',
                                          ),
                                          NavigationItem(
                                            index: 4,
                                            icon: Icons.settings_outlined,
                                            title: "Settings",
                                            isSelected:
                                                widget.selectedIndex == 4,
                                            route: '/school/setting',
                                          ),
                                          NavigationItem(
                                            index: 5,
                                            iconData: Images.help,
                                            title: "Help",
                                            route: '/student/faqs',
                                          ),
                                        ],
                                      ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildUserProfile(isCondensed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Label Widget is now correctly inside the State class
  Widget labelWidget(String label) {
    return isCondensed
        ? MySpacing.empty()
        : Container(
            padding: MySpacing.xy(24, 8),
            child: MyText.labelSmall(
              label.toUpperCase(),
              color: leftBarTheme.labelColor,
              muted: true,
              maxLines: 1,
              overflow: TextOverflow.clip,
              fontWeight: 700,
            ),
          );
  }
}

// -----------------------------------------------------------------------------
// 3. Menu Widget (Preserved)
// -----------------------------------------------------------------------------
class MenuWidget extends StatefulWidget {
  final IconData iconData;
  final String title;
  final bool isCondensed;
  final bool active;
  final List<MenuItem> children;

  const MenuWidget(
      {super.key,
      required this.iconData,
      required this.title,
      this.isCondensed = false,
      this.active = false,
      this.children = const []});

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget>
    with UIMixin, SingleTickerProviderStateMixin {
  bool isHover = false;
  bool isActive = false;
  late Animation<double> _iconTurns;
  late AnimationController _controller;
  bool popupShowing = true;
  Function? hideFn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(Tween<double>(begin: 0.0, end: 0.5)
        .chain(CurveTween(curve: Curves.easeIn)));
    LeftbarObserver.attachListener(widget.title, onChangeMenuActive);
  }

  void onChangeMenuActive(String key) {
    if (key != widget.title) {
      // onChangeExpansion(false);
    }
  }

  void onChangeExpansion(value) {
    isActive = value;
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var route = UrlService.getCurrentUrl();
    isActive = widget.children.any((element) => element.route == route);
    onChangeExpansion(isActive);
    if (hideFn != null) {
      hideFn!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCondensed) {
      return CustomPopupMenu(
        backdrop: true,
        show: popupShowing,
        hideFn: (_) => hideFn = _,
        onChange: (_) {},
        placement: CustomPopupMenuPlacement.right,
        menu: MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (event) {
            setState(() {
              isHover = true;
            });
          },
          onExit: (event) {
            setState(() {
              isHover = false;
            });
          },
          child: MyContainer.transparent(
            margin: MySpacing.fromLTRB(16, 0, 16, 8),
            color: isActive || isHover
                ? leftBarTheme.activeItemBackground
                : Colors.transparent,
            padding: MySpacing.xy(8, 8),
            child: Center(
              child: Icon(
                widget.iconData,
                color: (isHover || isActive)
                    ? leftBarTheme.activeItemColor
                    : leftBarTheme.onBackground,
                size: 20,
              ),
            ),
          ),
        ),
        menuBuilder: (_) => MyContainer.bordered(
          paddingAll: 8,
          width: 190,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: widget.children,
          ),
        ),
      );
    } else {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(24, 0, 16, 0),
          paddingAll: 0,
          child: ListTileTheme(
            contentPadding: const EdgeInsets.all(0),
            dense: true,
            horizontalTitleGap: 0.0,
            minLeadingWidth: 0,
            child: ExpansionTile(
                tilePadding: MySpacing.zero,
                initiallyExpanded: isActive,
                maintainState: true,
                onExpansionChanged: (_) {
                  LeftbarObserver.notifyAll(widget.title);
                  onChangeExpansion(_);
                },
                trailing: RotationTransition(
                  turns: _iconTurns,
                  child: Icon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: leftBarTheme.onBackground,
                  ),
                ),
                iconColor: leftBarTheme.activeItemColor,
                childrenPadding: MySpacing.x(12),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Icon(
                        widget.iconData,
                        size: 20,
                        color: isHover || isActive
                            ? leftBarTheme.activeItemColor
                            : leftBarTheme.onBackground,
                      ),
                    ),
                    MySpacing.width(18),
                    Expanded(
                      child: MyText.labelLarge(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        color: isHover || isActive
                            ? leftBarTheme.activeItemColor
                            : leftBarTheme.onBackground,
                      ),
                    ),
                  ],
                ),
                collapsedBackgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
                backgroundColor: Colors.transparent,
                children: widget.children),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// -----------------------------------------------------------------------------
// 4. Menu Item
// -----------------------------------------------------------------------------
class MenuItem extends StatefulWidget {
  final IconData? iconData;
  final String title;
  final bool isCondensed;
  final String? route;

  const MenuItem({
    super.key,
    this.iconData,
    required this.title,
    this.isCondensed = false,
    this.route,
  });

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> with UIMixin {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    bool isActive = UrlService.getCurrentUrl() == widget.route;
    return GestureDetector(
      onTap: () {
        if (widget.route != null) {
          Get.toNamed(widget.route!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: MyContainer.transparent(
          margin: MySpacing.fromLTRB(4, 0, 8, 4),
          color: isActive || isHover
              ? leftBarTheme.activeItemBackground
              : Colors.transparent,
          width: MediaQuery.of(context).size.width,
          padding: MySpacing.xy(18, 7),
          child: MyText.bodySmall(
            "${widget.isCondensed ? "" : "- "}  ${widget.title}",
            overflow: TextOverflow.clip,
            maxLines: 1,
            textAlign: TextAlign.left,
            fontSize: 12.5,
            color: isActive || isHover
                ? leftBarTheme.activeItemColor
                : leftBarTheme.onBackground,
            fontWeight: isActive || isHover ? 600 : 500,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. Navigation Item (Updated with Smooth Logic)
// -----------------------------------------------------------------------------
class NavigationItem extends StatefulWidget {
  final String? iconData;
  final IconData? icon;
  final String title;
  final bool isSelected;
  final String? route;
  final int index;
  final VoidCallback? onTap;

  const NavigationItem(
      {super.key,
      this.iconData,
      this.icon,
      required this.title,
      this.isSelected = false,
      this.route,
      required this.index,
      this.onTap});

  @override
  _NavigationItemState createState() => _NavigationItemState();
}

class _NavigationItemState extends State<NavigationItem> with UIMixin {
  bool isHover = false;

  // Configuration constants matching LeftBar
  final double itemMarginHorizontal = 12.0;
  final double iconSizeBox = 40.0;
  final double gapBetweenIconAndText = 16.0;

  @override
  Widget build(BuildContext context) {
    bool isTeacher = RoleUtils.isTeacher;

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else if (widget.route != null) {
          LeftbarObserver.notifyAll(widget.index.toString());
          Get.offNamed(widget.route!);
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) {
          setState(() {
            isHover = true;
          });
        },
        onExit: (event) {
          setState(() {
            isHover = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(
              horizontal: itemMarginHorizontal, vertical: 6.h),
          padding: EdgeInsets.symmetric(
              vertical: 8.h, horizontal: isTeacher ? 12.w : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTeacher ? 12.r : 10.r),
            color: isTeacher && (widget.isSelected || isHover)
                ? const Color(0xFFFAFAFA)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // 1. Fixed Container for Icon
              Container(
                width: iconSizeBox,
                height: iconSizeBox,
                decoration: isTeacher
                    ? null
                    : BoxDecoration(
                        color: widget.isSelected || isHover
                            ? const Color(0xFFF0F0F0)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                child: Center(
                  child: widget.icon != null
                      ? Icon(
                          widget.icon,
                          size: 26,
                          color: (widget.isSelected || isHover)
                              ? Colors.black
                              : const Color(0xFF8A8A8A),
                        )
                      : Image.asset(
                          widget.iconData.toString(),
                          width: 26.w,
                          height: 26.h,
                          fit: BoxFit.contain,
                          color: (widget.isSelected || isHover)
                              ? Colors.black
                              : const Color(0xFF8A8A8A),
                        ),
                ),
              ),
              // Increased spacing to ensure text starts AFTER the collapsed width
              SizedBox(width: gapBetweenIconAndText),

              // 2. Text Area
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: isTeacher
                      ? GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: (widget.isSelected || isHover)
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: Colors.black)
                      : GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: (widget.isSelected || isHover)
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
