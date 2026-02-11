import 'package:vantanceCA/controller/apps/school/lms_integration_controller.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/utils/utils.dart';
import 'package:vantanceCA/helpers/widgets/app_button.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/views/apps/school/integrations/excel/widgets/upload_option.dart';
import 'package:vantanceCA/views/apps/school/integrations/widgets/upload_file_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadTab extends StatefulWidget {
  const UploadTab({super.key});

  @override
  State<UploadTab> createState() => _UploadTabState();
}

class _UploadTabState extends State<UploadTab> {
  int _selectedOption = 0;
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  bool get _isUploadAllowed {
    if (lmsController.integrationMode.value == null) {
      return true;
    }

    final lastUpload =
        lmsController.integrationMode.value!.lastIntegrationTimestamp;
    if (lastUpload == null) return true;

    final lastUploadTime = DateTime.tryParse(lastUpload.toString());
    if (lastUploadTime == null) return true;

    final difference = DateTime.now().difference(lastUploadTime);
    return difference.inHours >= 24;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UploadOptionWidget(
                optionNumber: 1,
                groupValue: _selectedOption,
                title: "Import Excel File",
                onDownloadTemplate: () async {
                  await Utils.downloadTemplate(
                      AppConstant.excelTemplateDownloadUrl);
                },
                description:
                    "Import one Excel file with 5 sheets — Classes, Teachers, Learners, Teacher Enrollment, and Learner Enrollment.",
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              UploadOptionWidget(
                optionNumber: 2,
                groupValue: _selectedOption,
                title: "Import CSV File",
                onDownloadTemplate: () async {
                  await Utils.downloadTemplate(
                      AppConstant.csvTemplateDownloadUrl);
                },
                description:
                    "Import 5 separate CSV files — Classes, Teachers, Learners, Teacher Enrollment, and Learner Enrollment — and download the sample templates for the correct format.",
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              ),
              SizedBox(height: 40),
              SizedBox(
                width: 120.w,
                child: AppButton(
                  onTap: (_selectedOption == 1 || _selectedOption == 2) &&
                          _isUploadAllowed
                      ? () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return UploadFileDialog(
                                uploadOption: _selectedOption == 1
                                    ? UploadOption.EXCEL
                                    : UploadOption.CSV,
                              );
                            },
                          );
                        }
                      : null, // Disabled if no option or not allowed
                  title: "Upload",
                  prefixIconPath: Images.upload,
                  prefixIconSize: 25,
                ),
              ),
              if (!_isUploadAllowed)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "You can upload again only after 24 hours from the last upload.",
                    style: GoogleFonts.inter(
                      color: Colors.red,
                      fontSize: 12.sp,
                    ),
                  ),
                )
            ],
          );
        }),
      ),
    );
  }
}
