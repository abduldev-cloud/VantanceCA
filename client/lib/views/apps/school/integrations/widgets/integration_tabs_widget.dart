import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/custom_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class IntegrationTabsWidget extends StatelessWidget {
  final String title;
  final TabController tabController;
  final int selectedTabIndex;
  final List<TabItem> tabs;
  final List<Widget> tabScreens;
  const IntegrationTabsWidget({super.key, required this.tabController, required this.selectedTabIndex, required this.tabs, required this.tabScreens, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 0.0, bottom: 10, left: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Text(
                'Integrations - $title',
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: MyCard.circular(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  Center(
                    child: CustomTabBar(
                      tabs: tabs,
                      controller: tabController,
                      selectedIndex: selectedTabIndex,
                      onTabSelected: (index) {
                        tabController.animateTo(index);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: tabScreens,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
