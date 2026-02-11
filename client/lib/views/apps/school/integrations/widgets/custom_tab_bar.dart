import 'package:flutter/material.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/asset_icon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TabItem {
  final String label;
  final String icon;
  final double? size;
  final bool isDisabled;

  const TabItem(
      {required this.label,
      required this.icon,
      this.size,
      this.isDisabled = false});
}

class CustomTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final TabController controller;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool centerAlign;
  final Color? indicatorColor;

  const CustomTabBar(
      {super.key,
      required this.tabs,
      required this.controller,
      required this.selectedIndex,
      required this.onTabSelected,
      this.centerAlign = true,
      this.indicatorColor});

  @override
  Widget build(BuildContext context) {
    return Theme(
  data: Theme.of(context).copyWith(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  ),
 
    
    child: TabBar(
      controller: controller,
      labelColor: indicatorColor != null ? Colors.black : const Color(0xff004AAD),
      unselectedLabelColor: Colors.black,
      isScrollable: true,
        tabAlignment: TabAlignment.start,

      indicator: indicatorColor != null
          ? UnderlineTabIndicator(
              borderSide: BorderSide(color: indicatorColor ?? Colors.black, width: 3),
              insets: EdgeInsets.zero,
            )
          : BoxDecoration(
              color: Color(0xff004AAD).withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff004AAD),
                  width: 2,
                ),
              ),
            ),
      tabs: List.generate(
        tabs.length,
        (index) => Opacity(
          opacity: tabs[index].isDisabled ? 0.4 : 1.0,
          child: _buildExpandedTab(index),
        ),
      ),
      onTap: (index) {
        if (tabs[index].isDisabled) {
          controller.animateTo(selectedIndex);
          return;
        }
        onTabSelected(index);
      },
    ),
  
);

  }

  Widget _buildExpandedTab(int index) {
  final tab = tabs[index];

  final Widget text = Text(
    tab.label,
    style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w400),
  );

  return Tab(
    child: Container(
      padding: EdgeInsets.only(
        left: index == 0 ? 0 : 20,  
        right: 20,
        top: 6,
        bottom: 6,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssetIcon(
            icon: tab.icon,
            color: selectedIndex == index
                ? indicatorColor != null
                    ? Colors.black
                    : const Color(0xff004AAD)
                : Colors.black,
            size: tab.size ?? 20,
          ),
          const SizedBox(width: 6),
          text,
        ],
      ),
    ),
  );
}
}