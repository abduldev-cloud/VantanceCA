import 'package:binary_success/images.dart';
import 'package:binary_success/views/apps/school/integrations/excel/excel_log_tab.dart';
import 'package:binary_success/views/apps/school/integrations/excel/upload_tab.dart';
import 'package:binary_success/views/apps/school/integrations/platforms.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/custom_tab_bar.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/integration_tabs_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExcelConnectionScreen extends StatefulWidget {
  const ExcelConnectionScreen({super.key});

  @override
  State<ExcelConnectionScreen> createState() => _ExcelConnectionScreenState();
}

class _ExcelConnectionScreenState extends State<ExcelConnectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final List<TabItem> _tabs = [
    TabItem(label: 'Upload', icon: Images.upload),
    TabItem(label: 'Log', icon: Images.log),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    _selectedTabIndex = args?['tabIndex'] ?? 0;

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _selectedTabIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 3,
      child: IntegrationTabsWidget(
        title: Platforms.bulkUpload,
        tabController: _tabController,
        selectedTabIndex: _selectedTabIndex,
        tabs: _tabs,
        tabScreens: [
          UploadTab(),
          ExcelLogTab(),
        ],
      ),
    );
  }
}
