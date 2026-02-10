import 'package:binary_success/controller/apps/admin/admin_users_controller.dart';
import 'package:binary_success/helpers/utils/my_shadow.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/views/apps/platform_admin/widget/admin_active_users_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_dialog_dropdown.dart';
import 'package:binary_success/widgets/comman_dialog_texfield.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  AdminUsersPageState createState() => AdminUsersPageState();
}

class AdminUsersPageState extends State<AdminUsersPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late AdminUsersController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminUsersController(), permanent: true);

    /// ✅ Default tab = Active
    controller.selectedTabIndex.value = 0;
    controller.fetchUsers(status: "active", pageNumber: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 2,
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Titlebar =====
            CommanTitlebar(
              contentTheme: contentTheme,
              title: "Users",
              subTitle: "View and manage all users across schools",
              buttonTitle: "Add School",
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    insetPadding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 60.h,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 25),
                    backgroundColor: contentTheme.kFEFDFF,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    content: SizedBox(
                      width: MySpacing.fullWidth(context) * 0.35,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Add School",
                              style: GoogleFonts.inter(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.k1C244B,
                              ),
                            ),
                            MySpacing.height(10),
                            MyText.bodySmall(
                              "Please fill out this form to add school.",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: contentTheme.k172640,
                              ),
                            ),
                            MySpacing.height(40),
                            CommonDialogTextfield(
                                title: "School Name",
                                controller: TextEditingController()),
                            MySpacing.height(15),
                            CommonDialogDropdown(
                              itemList: const [
                                "Public",
                                "Private",
                                "Chartered",
                                "Boarding",
                                "Others"
                              ],
                              selectedValue: "Public",
                              contentTheme: contentTheme,
                              title: "School Type",
                            ),
                            MySpacing.height(15),
                            CommonDialogTextfield(
                                title: "School District",
                                controller: TextEditingController()),
                            MySpacing.height(15),
                            CommonDialogTextfield(
                                title: "Admin Email",
                                controller: TextEditingController()),
                            MySpacing.height(15),
                            CommonDialogTextfield(
                                title: "Email Domain",
                                controller: TextEditingController()),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Align(
                        child: InkWell(
                          onTap: () {
                            // TODO: Add API call to create school
                            Get.back();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10, bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 45, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xff004AAD),
                                  Color(0xffCB6CE6),
                                ],
                              ),
                            ),
                            child: Text(
                              "Add",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: contentTheme.kFEFDFF,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).paddingOnly(right: MySpacing.fullWidth(context) * 0.04),

            // ====== Tabs ======
            Row(
              children: [
                Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => controller.switchTab(0),
                      child: buildCard(
                        controller.activeCount.value.toString(),
                        "Active Users",
                        controller.selectedTabIndex.value == 0,
                        contentTheme.k0A8041,
                      ),
                    ),
                  ).paddingOnly(right: 40.w),
                ),
                Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => controller.switchTab(1),
                      child: buildCard(
                        controller.inactiveCount.value.toString(),
                        "Inactive Users",
                        controller.selectedTabIndex.value == 1,
                        contentTheme.orange,
                      ),
                    ),
                  ).paddingOnly(right: 40.w),
                ),
                Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => controller.switchTab(2),
                      child: buildCard(
                        controller.totalCount.value.toString(),
                        "Total Users",
                        controller.selectedTabIndex.value == 2,
                        contentTheme.darkPurple,
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(
              bottom: 20.h,
              left: 5.w,
              top: 17.h,
              right: MySpacing.fullWidth(context) * 0.04,
            ),

            // ====== PageView ======
            Expanded(
              child: PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  AdminActiveUsersWidget(
                    status: "active",
                    contentTheme: contentTheme,
                  ),
                  AdminActiveUsersWidget(
                    status: "inactive",
                    contentTheme: contentTheme,
                  ),
                  AdminActiveUsersWidget(
                    status: "",
                    contentTheme: contentTheme,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget buildCard(
      String count, String title, bool isSelected, Color textColor) {
    return MyCard(
      shadow: isSelected ? MyShadow(color: Colors.transparent) : null,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 25.w),
      color: isSelected ? null : Colors.white,
      borderRadius: BorderRadius.circular(25),
      gradient: isSelected
          ? const LinearGradient(colors: [
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
              color: contentTheme.k142228,
            ),
          ),
          MyText.bodySmall(
            count,
            style: GoogleFonts.inter(
              fontSize: 35.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
