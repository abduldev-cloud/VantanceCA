import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/connection_tab.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/data_tab.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/guide_tab.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/log_tab.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/custom_tab_bar.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/integration_tabs_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:binary_success/images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LmsConnectionScreen extends StatefulWidget {
  const LmsConnectionScreen({super.key});

  @override
  State<LmsConnectionScreen> createState() => _LmsConnectionScreenState();
}

class _LmsConnectionScreenState extends State<LmsConnectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _tokenController = TextEditingController();
  int _selectedTabIndex = 0;
  final LmsIntegrationController lmsController =
  Get.put(LmsIntegrationController());

  @override
  void initState() {
    final int initialIndex =
    Get.arguments != null && Get.arguments['tabIndex'] != null
        ? Get.arguments['tabIndex']
        : 0;

    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: initialIndex,
    );
    _selectedTabIndex = initialIndex;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 3,
      child: Obx(() {
        final bool integrationOff =
            lmsController.integrationMode.value?.integrationMode == "OFF";

        final List<TabItem> tabs = [
          TabItem(
              label: 'Connection',
              icon: Images.connect,
              size: 25.w,
              isDisabled: integrationOff),
          TabItem(label: 'Guide', icon: Images.guide, size: 25.w),
          TabItem(
              label: 'Data',
              icon: Images.data,
              size: 25.w,
              isDisabled: integrationOff),
          TabItem(
              label: 'Log',
              icon: Images.log,
              size: 25.w,
              isDisabled: integrationOff),
        ];

        return IntegrationTabsWidget(
          title: "Canvas",
          tabController: _tabController,
          selectedTabIndex: _selectedTabIndex,
          tabs: tabs,
          tabScreens: [
            ConnectionTab(),
            GuideTab(),
            DataTab(),
            LogTab(),
          ],
        );
      }),
    );
  }
}