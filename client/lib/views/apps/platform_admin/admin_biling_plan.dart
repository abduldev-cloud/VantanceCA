import 'package:vantanceCA/controller/apps/admin/admin_billing_controller.dart';
import 'package:vantanceCA/helpers/utils/my_shadow.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/apps/platform_admin/widget/admin_billing_user_widget.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminBilingPlanPage extends StatefulWidget {
  const AdminBilingPlanPage({super.key});

  @override
  AdminBilingPlanPageState createState() => AdminBilingPlanPageState();
}

class AdminBilingPlanPageState extends State<AdminBilingPlanPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late AdminBillingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminBillingController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 5,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommanTitlebar(
                contentTheme: contentTheme,
                title: "Billing & Plans",
                subTitle: "Manage customer billing and plans.",
                buttonTitle: "",
              ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),
              Row(
                children: [
                  Expanded(
                      child: Obx(() => InkWell(
                            splashFactory: NoSplash.splashFactory,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              controller.selectedIndex(1);
                              controller.pageController.jumpToPage(0);
                            },
                            child: buildCard(
                                "15,834",
                                "Active Users",
                                controller.selectedIndex.value == 1
                                    ? true
                                    : false,
                                contentTheme.k0A8041),
                          ).paddingOnly(right: 40.w))),
                  Expanded(
                      child: Obx(() => InkWell(
                            splashFactory: NoSplash.splashFactory,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              controller.selectedIndex(2);
                              controller.pageController.jumpToPage(1);
                            },
                            child: buildCard(
                                "22",
                                "Archived Schools",
                                controller.selectedIndex.value == 2
                                    ? true
                                    : false,
                                contentTheme.orange),
                          ).paddingOnly(right: 40.w))),
                  Expanded(
                      child: Obx(() => InkWell(
                            splashFactory: NoSplash.splashFactory,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            onTap: () {
                              controller.selectedIndex(3);
                              controller.pageController.jumpToPage(2);
                            },
                            child: buildCard(
                                "21,364 ",
                                "Total Users",
                                controller.selectedIndex.value == 3
                                    ? true
                                    : false,
                                contentTheme.darkPurple),
                          ))),
                ],
              ).paddingOnly(
                  left: 5.w,
                  top: 17.h,
                  right: MySpacing.fullWidth(context) * 0.04),
              SizedBox(
                  height: MySpacing.fullHeight(context) * 0.67,
                  child: PageView(
                    controller: controller.pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      AdminBillingUserWidget(contentTheme: contentTheme),
                      AdminBillingUserWidget(contentTheme: contentTheme),
                      AdminBillingUserWidget(contentTheme: contentTheme),
                    ],
                  ))
            ],
          );
        },
      ),
    );
  }

  Widget buildCard(
      String percentage, String title, bool isGradiant, Color textColor) {
    return MyCard(
      shadow: isGradiant ? MyShadow(color: Colors.transparent) : null,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      color: isGradiant ? null : Colors.white,
      borderRadius: BorderRadius.circular(25.r),
      gradient: isGradiant
          ? LinearGradient(colors: [
              Color(0xffEEECFF),
              Color(0xffEEECFF),
              Color(0xffDBEBFF),
            ])
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium(
            title,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          MyText.bodySmall(percentage,
              style: GoogleFonts.inter(
                fontSize: 36.sp,
                color: textColor,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
