import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/widgets/connection_input_screen.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/widgets/view_access_token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectionTab extends StatefulWidget {
  ConnectionTab({super.key});

  @override
  State<ConnectionTab> createState() => _ConnectionTabState();
}

class _ConnectionTabState extends State<ConnectionTab> with UIMixin {
  bool isTokenSubmit = false;
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => lmsController.integrationData.value == null
        ? ConnectionInputScreen()
        : ViewAccessToken());
  }
}
