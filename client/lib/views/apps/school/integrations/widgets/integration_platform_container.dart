import 'package:vantanceCA/app_colors.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/views/apps/school/integrations/platforms.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/asset_icon.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/last_sync_datetime.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class IntegrationPlatformContainer extends StatelessWidget with UIMixin {
  final String title;
  final String description;
  final bool hasButtons;
  final String? imagePath;
  final bool allowIntegration;
  final bool isConnected;
  final VoidCallback onConnect;
  final VoidCallback onUpload;
  final bool disabled;
  final bool isSyncingData;
  final DateTime? lastUsedDate;

  IntegrationPlatformContainer(
      {super.key,
      required this.title,
      required this.hasButtons,
      required this.description,
      this.imagePath,
      required this.allowIntegration,
      required this.isConnected,
      required this.onConnect,
      required this.onUpload,
      this.lastUsedDate,
      this.isSyncingData = false,
      this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey, width: 0.2)),
      padding: EdgeInsets.only(left: 20, top: 15, right: 20),
      child: Column(
        mainAxisAlignment: imagePath != null
            ? MainAxisAlignment.spaceEvenly
            : MainAxisAlignment.center,
        crossAxisAlignment: imagePath != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (imagePath != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  imagePath!,
                  width: 40.w,
                  height: 40.w,
                ),
                Row(
                  children: [
                    AssetIcon(
                      icon:
                          isConnected ? Images.connected : Images.disconnected,
                      color: isConnected
                          ? AppColors.darkGreen
                          : AppColors.darkGrey,
                      size: 25.w,
                    ),
                    SizedBox(width: 5),
                    MyText(
                      isConnected ? "Connected" : "Not Connected",
                      style: GoogleFonts.inter(
                          color: isConnected
                              ? AppColors.darkGreen
                              : AppColors.darkGrey,
                          fontSize: 14.sp),
                    )
                  ],
                )
              ],
            ),
          Column(
            crossAxisAlignment: imagePath != null
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              MyText.titleMedium(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: contentTheme.k142228,
                ),
              ),
              // SizedBox(height: 5),
              MyText.titleSmall(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: contentTheme.k142228,
                ),
              ),
            ],
          ),
          // SizedBox(height: 10),
          if (imagePath != null)
            title == Platforms.bulkUpload
                ? Row(
                    children: [
                      buildButton(
                        icon: Images.upload,
                        title: "Upload",
                        onTap: onUpload,
                        disabled: !allowIntegration || disabled,
                      ),
                      SizedBox(width: 10.w),
                      buildButton(
                        icon: Images.log,
                        title: "Log",
                        onTap: () {
                          Get.toNamed(
                            "/school/integrations/excel_connection",
                            arguments: {'tabIndex': 1},
                          );
                        },
                        disabled: !allowIntegration || disabled,
                      ),
                    ],
                  )
                : title == Platforms.schoology
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildButton(
                            icon: Images.connect,
                            title: isConnected ? "Disconnect" : "Connect",
                            disabled:
                                !allowIntegration || disabled || isSyncingData,
                            onTap: () {
                              Get.toNamed(
                                "/school/integrations/schoology_screen",
                                arguments: {'tabIndex': 0},
                              );
                            },
                          ),
                          buildButton(
                            icon: Images.guide,
                            title: "Guide",
                            disabled: disabled,
                            onTap: () {
                              Get.toNamed(
                                "/school/integrations/schoology_screen",
                                arguments: {'tabIndex': 1},
                              );
                            },
                          ),
                          buildButton(
                            icon: Images.data,
                            title: "Data",
                            disabled: !allowIntegration || disabled,
                            onTap: () {
                              Get.toNamed(
                                "/school/integrations/schoology_screen",
                                arguments: {'tabIndex': 2},
                              );
                            },
                          ),
                          buildButton(
                            icon: Images.log,
                            title: "Log",
                            disabled: !allowIntegration || disabled,
                            onTap: () {
                              Get.toNamed(
                                "/school/integrations/schoology_screen",
                                arguments: {'tabIndex': 3},
                              );
                            },
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildButton(
                            icon: Images.connect,
                            title: isConnected ? "Disconnect" : "Connect",
                            disabled:
                                !allowIntegration || disabled || isSyncingData,
                            onTap: onConnect,
                          ),
                          buildButton(
                            icon: Images.guide,
                            title: "Guide",
                            disabled: disabled,
                            onTap: () {
                              Get.toNamed(
                                "/school/integrations/lms_connection",
                                arguments: {'tabIndex': 1},
                              );
                            },
                          ),
                          buildButton(
                            icon: Images.data,
                            title: "Data",
                            disabled: !allowIntegration || disabled,
                            onTap: () {
                              Get.toNamed(
                                "/school/integrations/lms_connection",
                                arguments: {'tabIndex': 2},
                              );
                            },
                          ),
                          buildButton(
                            icon: Images.log,
                            title: "Log",
                            disabled: !allowIntegration || disabled,
                            onTap: () {
                              Get.toNamed(
                                "/school/integrations/lms_connection",
                                arguments: {'tabIndex': 3},
                              );
                            },
                          ),
                        ],
                      ),
          if (lastUsedDate != null && isConnected)
            LastSyncDatetime(
              title: "Last Used Date: ",
              date: DateFormat('dd-MM-yyyy').format(lastUsedDate!),
              time: DateFormat('HH:mm:ss').format(lastUsedDate!),
            ),
        ],
      ),
    );
  }

  Widget buildButton({
    required String icon,
    required String title,
    bool disabled = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      child: Row(
        children: [
          AssetIcon(
            icon: icon,
            color: disabled ? Colors.grey : Colors.black,
            size: 40.w, // responsive icon height
          ),
          SizedBox(width: 4.w), // responsive spacing
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.sp, // responsive font size
              fontWeight: FontWeight.bold,
              color: disabled ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
