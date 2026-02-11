import 'package:vantanceCA/controller/extra_pages/faqs_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/views/extra_pages/widgets/faqs_content.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  State<FAQPage> createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late FaqsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(FaqsController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return FAQPageContent();
        },
      ),
    );
  }
}
