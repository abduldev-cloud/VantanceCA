import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/controller/layouts/dynamic_auth_layout_controller.dart';
import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/theme/app_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_container.dart';
import 'package:vantanceCA/helpers/widgets/my_flex.dart';
import 'package:vantanceCA/helpers/widgets/my_flex_item.dart';
import 'package:vantanceCA/helpers/widgets/my_responsiv.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/images.dart';

class AuthLayout2 extends StatelessWidget {
  final Widget? child;

  final DynamicAuthLayoutController controller = DynamicAuthLayoutController();

  AuthLayout2({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return GetBuilder(
          init: controller,
          builder: (controller) {
            return screenMT.isMobile
                ? mobileScreen(context)
                : largeScreen(context);
          });
    });
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: Container(
        padding: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
        height: MediaQuery.of(context).size.height,
        color: theme.cardTheme.color,
        child: SingleChildScrollView(
          key: controller.scrollKey,
          child: child,
        ),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    return Scaffold(
        key: controller.scaffoldKey,
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            MyContainer(
              paddingAll: 0,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                Images.login[0],
                fit: BoxFit.cover,
              ),
            ),
            Container(
              margin: MySpacing.top(100),
              width: MediaQuery.of(context).size.width,
              child: MyFlex(
                wrapAlignment: WrapAlignment.center,
                wrapCrossAlignment: WrapCrossAlignment.start,
                runAlignment: WrapAlignment.center,
                spacing: 0,
                runSpacing: 0,
                children: [
                  MyFlexItem(
                    sizes: "xxl-3 lg-4 md-6 sm-8",
                    child: MyContainer(
                      paddingAll: 0,
                      color: AdminTheme.theme.contentTheme.background
                          .withAlpha(230),
                      child: child ?? Container(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
