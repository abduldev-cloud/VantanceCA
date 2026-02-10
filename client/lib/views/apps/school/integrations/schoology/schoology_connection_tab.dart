import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/views/apps/school/integrations/schoology/schoology_new_connection.dart';
import 'package:binary_success/views/apps/school/integrations/schoology/schoology_view_access_token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SchoologyConnectionTab extends StatefulWidget {
  SchoologyConnectionTab({super.key});

  @override
  State<SchoologyConnectionTab> createState() => _SchoologyConnectionTabState();
}

class _SchoologyConnectionTabState extends State<SchoologyConnectionTab>
    with UIMixin {
  bool isTokenSubmit = false;
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show new connection input screen if no token exists for Schoology
      if (lmsController.integrationData.value == null) {
        return SchoologyNewConnectionScreen();
      } else {
        // Show token view screen if token exists
        return SchoologyViewAccessToken();
      }
    });
  }
}
