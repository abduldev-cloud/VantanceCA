import 'package:binary_success/controller/apps/admin/admin_school_controller.dart';
import 'package:binary_success/controller/apps/school/add_school_controller.dart';
import 'package:binary_success/helpers/utils/my_shadow.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/views/apps/platform_admin/widget/admin_active_school_widget.dart';
import 'package:binary_success/views/apps/platform_admin/widget/admin_archived_school_widget.dart';
import 'package:binary_success/views/apps/platform_admin/widget/admin_total_school_user_widget.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/widgets/comman_dialog_dropdown.dart';
import 'package:binary_success/widgets/comman_dialog_texfield.dart';
import 'package:binary_success/widgets/comman_titlebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

import 'package:binary_success/controller/apps/admin/admin_school_controller.dart';
import 'package:binary_success/models/platform_admin_school_model.dart';

import 'package:binary_success/controller/apps/admin/admin_school_archived_controller.dart';
import 'package:binary_success/models/platform_school_archived_model.dart'
    as archived;

class AdminSchoolPage extends StatefulWidget {
  const AdminSchoolPage({super.key});

  @override
  AdminSchoolPageState createState() => AdminSchoolPageState();
}

class AdminSchoolPageState extends State<AdminSchoolPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late AdminSchoolController controller;
  // late AdminArchivedSchoolController archivedController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AdminSchoolController());
    // archivedController = Get.put(AdminArchivedSchoolController());
  }

  @override
  Widget build(BuildContext context) {
    final summary = controller.summaryCounts.value;
    return Layout(
      selectedPage: 1,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommanTitlebar(
                contentTheme: contentTheme,
                title: "Schools",
                subTitle: "View and manage all schools",
                buttonTitle: "Add School",
                onTap: () {
                  final addSchoolController =
                      Get.put(AddSchoolController(), tag: "add_school");
                  addSchoolController.fetchDistricts();
                  addSchoolController.fetchInstituteTypes();
                  print("addSchoolController $addSchoolController");
                  Get.dialog(
                    AlertDialog(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                      backgroundColor: contentTheme.kFEFDFF,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      content: Stack(
                        children: [
                          // Main content
                          SizedBox(
                            width: MySpacing.fullWidth(context) * 0.35,
                            child: GetBuilder<AddSchoolController>(
                              tag: "add_school",
                              builder: (ctrl) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Add School",
                                    style: GoogleFonts.inter(
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.w600,
                                      color: contentTheme.k1C244B,
                                    ),
                                  ),
                                  MyText.bodySmall(
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      color: contentTheme.k172640,
                                    ),
                                    "Please fill out this form to add school.",
                                  ),
                                  40.verticalSpace,
                                  CommonDialogTextfield(
                                    title: "School Name",
                                    controller: ctrl.nameController,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(50),
                                    ],
                                  ),
                                  15.verticalSpace,
                                  Obx(() => CommonDialogDropdown(
                                        itemList: ctrl.instituteTypes,
                                        selectedValue: ctrl.selectedType.value,
                                        onChanged: (val) {
                                          if (val != null) {
                                            ctrl.selectedType.value = val;
                                            ctrl.selectedTypeId.value =
                                                ctrl.instituteTypeIdByName[
                                                        val] ??
                                                    "";
                                          }
                                        },
                                        contentTheme: contentTheme,
                                        title: "Institute Type",
                                      )),
                                  15.verticalSpace,
                                  Obx(() => CommonDialogDropdown(
                                        itemList: ctrl.schoolStates,
                                        selectedValue: ctrl.selectedState.value,
                                        onChanged: (val) {
                                          ctrl.selectedState.value = val ?? "";
                                          ctrl.filterDistrictsByState(
                                              ctrl.selectedState.value);
                                        },
                                        contentTheme: contentTheme,
                                        title: "School State",
                                      )),
                                  15.verticalSpace,
                                  Obx(() => CommonDialogDropdown(
                                        itemList: ctrl.schoolDistricts,
                                        selectedValue:
                                            ctrl.selectedDistrict.value,
                                        onChanged: (val) => ctrl
                                            .selectedDistrict.value = val ?? "",
                                        contentTheme: contentTheme,
                                        title: "School District",
                                      )),
                                  15.verticalSpace,
                                  CommonDialogTextfield(
                                    title: "School Admin Email",
                                    controller: ctrl.emailController,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(255),
                                    ],
                                  ),
                                  15.verticalSpace,
                                  CommonDialogTextfield(
                                    title: "School Domain",
                                    controller: ctrl.domainController,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Close button
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Switch for Demo School
                            Row(
                              children: [
                                Obx(() => Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: addSchoolController
                                            .isDemoSchool.value,
                                        onChanged: (val) {
                                          addSchoolController
                                              .isDemoSchool.value = val;
                                        },
                                        overlayColor: WidgetStateProperty.all(
                                            Colors.transparent),
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: Color(0xFF004AAD),
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: Colors.grey,
                                        trackOutlineColor:
                                            WidgetStateProperty.all(
                                                Colors.transparent),
                                      ),
                                    )),
                                Obx(() => Text(
                                      "Demo School",
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: addSchoolController
                                                .isDemoSchool.value
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    )),
                              ],
                            ),

                            // Add button
                            Obx(
                              () => addSchoolController.isLoading.value
                                  ? SizedBox(
                                      height: 50.h,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () async {
                                        final ctrl =
                                            Get.find<AddSchoolController>(
                                                tag: "add_school");

                                        if (ctrl.nameController.text.length >
                                            50) {
                                          Get.snackbar(
                                            "Error",
                                            "School name cannot exceed 50 characters",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        if (ctrl.emailController.text.length >
                                            255) {
                                          Get.snackbar(
                                            "Error",
                                            "Admin Email cannot exceed 255 characters",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        if (ctrl.domainController.text.length >
                                            100) {
                                          Get.snackbar(
                                            "Error",
                                            "Email Domain cannot exceed 100 characters",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                          return;
                                        }

                                        await ctrl.addSchool();
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 45.w, vertical: 7.h),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50.r),
                                          gradient: LinearGradient(
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
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: contentTheme.kFEFDFF,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ).paddingOnly(left: 5.0, right: 12.0),
                      ],
                    ),
                  );
                },
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
                              controller.selectedIndex(1);
                              controller.instituteStatus.value =
                                  "ACTIVE"; //Set status
                              controller.fetchInstitutes(page: 1); //Reload list
                              controller.pageController.jumpToPage(0);
                            },
                            child: buildCard(
                                controller.summaryCounts.value != null
                                    ? '${controller.summaryCounts.value!.activeInstitutes}'
                                    : '—',
                                "Active Schools",
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
                              // controller.selectedIndex(2);
                              // controller.pageController.jumpToPage(1);
                              controller.selectedIndex(2);
                              controller.instituteStatus.value = "ARCHIVED";
                              controller.fetchInstitutes(page: 1);
                              controller.pageController.jumpToPage(1);
                            },
                            child: buildCard(
                                controller.summaryCounts.value != null
                                    ? '${controller.summaryCounts.value!.archivedInstitutes}'
                                    : '—',
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
                              // ! must needed code
                              controller.selectedIndex(3);
                              controller.pageController.jumpToPage(2);
                            },
                            child: buildCard(
                                controller.summaryCounts.value != null
                                    ? '${controller.summaryCounts.value!.totalUsers}'
                                    : '—',
                                "Total Current Users",
                                controller.selectedIndex.value == 3
                                    ? true
                                    : false,
                                contentTheme.darkPurple),
                          ))),
                ],
              ).paddingOnly(
                  bottom: 30.h,
                  left: 5.w,
                  top: 17,
                  right: MySpacing.fullWidth(context) * 0.04),
              Expanded(
                child: SizedBox(
                    // height: MySpacing.fullHeight(context) * 0.65,
                    child: PageView(
                  controller: controller.pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    AdminActiveSchoolWidget(contentTheme: contentTheme),
                    AdminArchivedSchoolWidget(contentTheme: contentTheme),
                    AdminTotalCurrentUsersWidget(contentTheme: contentTheme)
                  ],
                )),
              )
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
      borderRadius: BorderRadius.circular(25),
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
          MyText.bodySmall(
            percentage,
            style: GoogleFonts.inter(
              fontSize: 35.sp,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
