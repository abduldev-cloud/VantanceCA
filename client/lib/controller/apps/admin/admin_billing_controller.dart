import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/my_controller.dart';

class AdminBillingController extends MyController {
  RxInt selectedIndex = 1.obs;
  PageController pageController = PageController();
}
