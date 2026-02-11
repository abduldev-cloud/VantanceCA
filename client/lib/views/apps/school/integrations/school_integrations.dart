import 'package:vantanceCA/controller/apps/school/lms_integration_controller.dart';
import 'package:vantanceCA/helpers/utils/datetime_utils.dart';
import 'package:vantanceCA/helpers/widgets/my_card.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/models/integration_mode_model.dart';
import 'package:vantanceCA/views/apps/school/integrations/data.dart';
import 'package:vantanceCA/views/apps/school/integrations/platforms.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/integration_platform_container.dart';
import 'package:vantanceCA/views/apps/school/widget/confirm_delete_dialog.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SchoolIntegrationsPage extends StatefulWidget {
  SchoolIntegrationsPage({super.key});

  @override
  State<SchoolIntegrationsPage> createState() => _SchoolIntegrationsPageState();
}

class _SchoolIntegrationsPageState extends State<SchoolIntegrationsPage>
    with UIMixin {
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 3,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium(
                      "Integrations",
                      style: GoogleFonts.inter(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                    MyText.titleMedium(
                      "${lmsController.isIntegrationModeOn.value ? "Integration" : "Standard"} Mode",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() {
                      final isDisabled = lmsController.isSyncingData.value ||
                          lmsController
                                  .integrationMode.value?.integrationStatus ==
                              "STARTED";

                      return Switch(
                        value: lmsController.isIntegrationModeOn.value,
                        activeThumbColor:
                            isDisabled ? Colors.grey : Colors.white,
                        activeTrackColor: isDisabled
                            ? Colors.grey.shade400
                            : contentTheme.onPrimary,
                        inactiveThumbColor: Colors.white,
                        onChanged: isDisabled
                            ? null
                            : (bool _) {
                                lmsController.toggleIntegrationMode();
                              },
                      );
                    }),
                    // MyText.titleMedium(
                    //   "NOTE: If you are enabling this feature, Binary Success not allow to create class, school",
                    //   style: GoogleFonts.inter(
                    //     fontSize: 13.sp,
                    //     fontWeight: FontWeight.w600,
                    //     color: contentTheme.k142228,
                    //   ),
                    // ),
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
            MyCard.circular(
              borderRadiusAll: 25.r,
              bordered: true,
              padding: EdgeInsets.all(0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Obx(() {
                    if (lmsController.isCheckingIntegrationMode.value) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: LoadingAnimationWidget.staggeredDotsWave(
                              color: contentTheme.onPrimary, size: 50),
                        ),
                      );
                    }
                    if (lmsController.integrationMode.value == null) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Text('No Data'),
                        ),
                      );
                    }
                    return GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      childAspectRatio: 1.6,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children:
                          List.generate(LmsData.platformsData.length, (index) {
                        final platformName =
                            LmsData.platformsData[index]['title'] ?? "";
                        final platformNameDb =
                            LmsData.platformsData[index]['platform'] ?? "";
                        final IntegrationMode integrationMode =
                            lmsController.integrationMode.value!;

                        final bool connected = integrationMode
                                    .integrationMode ==
                                "ON" &&
                            integrationMode.integrationType == platformNameDb &&
                            (platformNameDb == "Excel" ||
                                lmsController.integrationData.value != null);

                        // ✅ disable all other platforms if any one is connected
                        final bool anyPlatformConnected =
                            integrationMode.integrationMode == "ON" &&
                                (integrationMode.integrationType != null &&
                                    integrationMode
                                        .integrationType!.isNotEmpty &&
                                    (integrationMode.integrationType == "Excel"
                                        ? true
                                        : lmsController.integrationData.value !=
                                            null));

                        return GestureDetector(
                          onTap: () {
                            if (connected) {
                              // here need to handle the connected
                              lmsController.updatePlatform(platformName);
                              if (platformName == Platforms.bulkUpload) {
                                Get.toNamed(
                                    "/school/integrations/excel_connection");
                                return;
                              }
                              if (platformName == Platforms.schoology) {
                                lmsController.updatePlatform(platformName);
                                Get.toNamed(
                                    "/school/integrations/schoology_screen");
                                return;
                              }
                              lmsController.fetchConnectionStatus(platformName);
                              if (lmsController.integrationData.value ==
                                  Platforms.canvas) {
                                Get.toNamed(
                                    "/school/integrations/lms_connection");
                                return;
                              }
                            }
                          },
                          child: IntegrationPlatformContainer(
                            title: platformName,
                            hasButtons: true,
                            description: LmsData.platformsData[index]
                                    ['description'] ??
                                "",
                            imagePath: LmsData.platformsData[index]['image'],
                            allowIntegration:
                                lmsController.isIntegrationModeOn.value,
                            isConnected: connected,
                            disabled: anyPlatformConnected &&
                                !connected, //TODO: Remove the condition when schoology is integrated
                            isSyncingData: lmsController.isSyncingData.value ||
                                lmsController.integrationMode.value
                                        ?.integrationStatus ==
                                    "STARTED",
                            lastUsedDate: getLastUsedDate(),
                            onUpload: () {
                              lmsController.updatePlatform(platformName);
                              Get.toNamed(
                                  "/school/integrations/excel_connection");
                            },
                            onConnect: () {
                              if (!connected &&
                                  platformName != Platforms.schoology) {
                                if (lmsController.showTokenView.value) {
                                  lmsController.updateTokenView(false);
                                }
                                Get.toNamed(
                                    "/school/integrations/lms_connection");
                              } else if (lmsController.integrationData.value !=
                                  null) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return ConfirmDeleteDialog(
                                          onConfirm: () {
                                            lmsController.deleteToken(
                                                lmsController
                                                    .integrationData.value!.id);
                                            Get.back();
                                          },
                                          token: lmsController
                                              .integrationData.value!.token);
                                    });
                              }
                            },
                          ),
                        );
                      }),
                    );
                  });
                },
              ),
            ),
            SizedBox(height: 80.h)
          ],
        ),
      ),
    );
  }

  DateTime? getLastUsedDate() {
    final integration = lmsController.integrationMode.value;

    if (integration == null) return null;

    final ts = integration.lastIntegrationTimestamp;
    if (ts == null || ts.isEmpty) return null;

    try {
      return DateTimeUtils.utcIsoToLocalDateTime(ts);
    } catch (_) {
      return null; // or handle gracefully
    }
  }
}
