import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/controller/my_controller.dart';

class AdminBillingController extends MyController {
  RxInt selectedIndex = 1.obs;
  PageController pageController = PageController();
}
