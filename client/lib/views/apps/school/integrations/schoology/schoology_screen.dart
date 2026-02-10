import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/connection_tab.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/data_tab.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/guide_tab.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/log_tab.dart';
import 'package:binary_success/views/apps/school/integrations/schoology/schoology_data_tab.dart';
import 'package:binary_success/views/apps/school/integrations/schoology/schoology_guide_tab.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/custom_tab_bar.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/integration_tabs_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:binary_success/images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'Schoology_Connection_tab.dart';
import 'Schoology_log_tab.dart';

class SchoologyScreen extends StatefulWidget {
  const SchoologyScreen({super.key});

  @override
  State<SchoologyScreen> createState() => _SchoologyConnectionScreenState();
}

class _SchoologyConnectionScreenState extends State<SchoologyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _consumerKeyController = TextEditingController();
  final TextEditingController _consumerSecretController =
      TextEditingController();
  final int _selectedTabIndex = 0;
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  @override
  void initState() {
    final args = Get.arguments as Map<String, dynamic>?;
    final int initialTab = args?['tabIndex'] ?? 0;
    _tabController =
        TabController(length: 4, vsync: this, initialIndex: initialTab);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _consumerKeyController.dispose();
    _consumerSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 3,
      child: IntegrationTabsWidget(
        title: "Schoology",
        tabController: _tabController,
        selectedTabIndex: _selectedTabIndex,
        tabs: [
          TabItem(label: 'Connection', icon: Images.connect, size: 25.w),
          TabItem(label: 'Guide', icon: Images.guide, size: 25.w),
          TabItem(label: 'Data', icon: Images.data, size: 25.w),
          TabItem(label: 'Log', icon: Images.log, size: 25.w),
        ],
        tabScreens: [
          SchoologyConnectionTab(),
          SchoologyGuideTab(),
          SchoologyDataTab(),
          SchoologyLogTab(),
        ],
      ),
    );
  }
}
