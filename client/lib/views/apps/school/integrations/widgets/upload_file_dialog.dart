import 'dart:typed_data';
import 'package:binary_success/app_colors.dart';
import 'package:binary_success/controller/apps/school/excel_integration_controller.dart';
import 'package:binary_success/helpers/utils/app_snakbar.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/views/apps/school/integrations/widgets/asset_icon.dart';
import 'package:file_picker/file_picker.dart';
import 'package:binary_success/helpers/widgets/app_button.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/widgets/header_text.dart';
import 'package:binary_success/views/apps/school/widget/asset_icon_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum UploadOption { CSV, EXCEL }

class UploadFileDialog extends StatefulWidget {
  final UploadOption uploadOption;
  const UploadFileDialog({super.key, required this.uploadOption});

  @override
  State<UploadFileDialog> createState() => _UploadFileDialogState();
}

class _UploadFileDialogState extends State<UploadFileDialog> with UIMixin {
  final ExcelIntegrationController excelIntegrationController =
      Get.put(ExcelIntegrationController());
  final Map<String, Uint8List?> pickedCsvFiles = {
    "Classes": null,
    "Teachers": null,
    "Teacher Enrollments": null,
    "Learners": null,
    "Learner Enrollments": null,
  };

  Uint8List? pickedExcelFile;
  String? filename;
  Map<String, String?> csvFileNames = {
    "Classes": null,
    "Teachers": null,
    "Teacher Enrollments": null,
    "Learners": null,
    "Learner Enrollments": null,
  };

  Future<void> _pickCsvFile(String key) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final fileSize = result.files.single.size; // in bytes
      final maxSize = 10 * 1024 * 1024; // 10 MB

      if (fileSize > maxSize) {
        appSnackbar(
          message:
              "File size exceeds 10MB limit. Please upload a smaller file.",
          snackbarState: SnackbarState.danger,
        );
        return;
      }

      final pickedName = result.files.single.name;

      // ✅ expected filename based on the slot key
      final expectedName = "$key.csv";

      if (pickedName.toLowerCase() != expectedName.toLowerCase()) {
        // show validation error
        appSnackbar(
            message: "Please upload the correct file: $expectedName",
            snackbarState: SnackbarState.danger);
        return; // 🚫 don't save this file
      }

      // ✅ valid file
      setState(() {
        pickedCsvFiles[key] = result.files.single.bytes;
        csvFileNames[key] = pickedName;
      });
    } else {
      setState(() {
        pickedCsvFiles[key] = null;
      });
    }
  }

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true, // ✅ ensures we get Uint8List
    );

    if (result != null && result.files.single.bytes != null) {
      final fileSize = result.files.single.size; // in bytes
      final maxSize = 10 * 1024 * 1024; // 10 MB

      if (fileSize > maxSize) {
        appSnackbar(
          message:
              "File size exceeds 10MB limit. Please upload a smaller file.",
          snackbarState: SnackbarState.danger,
        );
        return;
      }

      setState(() {
        pickedExcelFile = result.files.single.bytes;
        filename = result.files.single.name;
      });
    } else {
      setState(() {
        pickedExcelFile = null;
      });
    }
  }

  Future<void> _onUpload() async {
    if (widget.uploadOption == UploadOption.CSV) {
      final List<String> keys = pickedCsvFiles.keys
          .where((key) => pickedCsvFiles[key] != null)
          .toList();
      final List<Map<String, dynamic>> files = keys
          .map((key) =>
              {"filename": csvFileNames[key], "file": pickedCsvFiles[key]})
          .toList();
      excelIntegrationController.uploadCsvFiles(files: files);
      return;
    }
    excelIntegrationController.uploadExcelFile(
        bytes: pickedExcelFile!, filename: filename ?? "");
  }

  @override
  void dispose() {
    excelIntegrationController.isUploadSuccess.value = false;
    excelIntegrationController.isUploadFinished.value = false;
    excelIntegrationController.successfulFiles.value = [];
    excelIntegrationController.failedFiles.value = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUploadEnabled = widget.uploadOption == UploadOption.CSV
        ? pickedCsvFiles.values.any((file) => file != null)
        : pickedExcelFile != null;

    return Obx(() {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        content: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            excelIntegrationController.isUploadFinished.value
                ? _uploadFinishedView()
                : widget.uploadOption == UploadOption.CSV
                    ? _uploadCsvView(isUploadEnabled: isUploadEnabled)
                    : _uploadExcelView(isUploadEnabled: isUploadEnabled),
          ],
        ),
      );
    });
  }

  Widget _uploadCsvView({required bool isUploadEnabled}) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AssetIconBox(iconPath: Images.upload),
          const SizedBox(height: 20),
          HeaderText(
            title: "Upload - Import CSV Files",
            subtitle: "Select your CSV Files",
            alignment: CrossAxisAlignment.center,
          ),
          const SizedBox(height: 20),

          // Row of small buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: pickedCsvFiles.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildCsvFileButton(key),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),
          excelIntegrationController.isUploading.value
              ? LoadingAnimationWidget.staggeredDotsWave(
                  color: contentTheme.onPrimary,
                  size: 50,
                )
              : SizedBox(
                  width: 200,
                  child: AppButton(
                    onTap: isUploadEnabled ? _onUpload : null,
                    title: "Upload",
                    prefixIconPath: Images.upload,
                    prefixIconSize: 25,
                  ),
                )
        ],
      );
    });
  }

  Widget _buildCsvFileButton(String key) {
    return GestureDetector(
      onTap: excelIntegrationController.isUploading.value
          ? null
          : () async => await _pickCsvFile(key),
      child: Container(
        constraints: const BoxConstraints(minWidth: 90),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: pickedCsvFiles[key] != null
                  ? contentTheme.darkPurple
                  : Colors.black54,
              width: pickedCsvFiles[key] != null ? 2.0 : 1.2),
          borderRadius: BorderRadius.circular(20), // pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_copy_outlined,
                size: 16,
                color: pickedCsvFiles[key] != null
                    ? contentTheme.darkPurple
                    : Colors.black87),
            const SizedBox(width: 6),
            MyText(
              csvFileNames[key] ?? key,
              fontSize: 13,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              color: pickedCsvFiles[key] != null
                  ? contentTheme.darkPurple
                  : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadExcelView({required bool isUploadEnabled}) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AssetIconBox(iconPath: Images.upload),
          const SizedBox(height: 20),
          HeaderText(
            title: "Upload - Import XLSX Files",
            subtitle: "Select your XLSX File",
            alignment: CrossAxisAlignment.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: excelIntegrationController.isUploading.value
                ? null
                : _pickExcelFile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.file_copy_outlined, color: Colors.black),
                  const SizedBox(width: 8),
                  MyText(
                    filename ?? "Choose XLSX file",
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          excelIntegrationController.isUploading.value
              ? LoadingAnimationWidget.staggeredDotsWave(
                  color: contentTheme.onPrimary,
                  size: 50,
                )
              : AppButton(
                  onTap: isUploadEnabled ? _onUpload : null,
                  title: "Upload",
                  prefixIconPath: Images.upload,
                  prefixIconSize: 25,
                )
        ],
      );
    });
  }

  Widget _uploadFinishedView() {
  final bool allSuccess = excelIntegrationController.failedFiles.isEmpty &&
      excelIntegrationController.successfulFiles.isNotEmpty;
  final bool allFail = excelIntegrationController.successfulFiles.isEmpty &&
      excelIntegrationController.failedFiles.isNotEmpty;
  final bool partial =
      excelIntegrationController.successfulFiles.isNotEmpty &&
          excelIntegrationController.failedFiles.isNotEmpty;

  return SizedBox(
    width: 360.w,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HeaderText(
          title: widget.uploadOption == UploadOption.CSV
              ? "Import CSV Files"
              : "Import XLSX File",
          subtitle: allSuccess
              ? "Records validated and stored"
              : allFail
                  ? "Failed to upload files"
                  : "Some files uploaded successfully, some failed",
          alignment: CrossAxisAlignment.center,
        ),
        const SizedBox(height: 20),
        allSuccess
            ? AssetIcon(
                icon: Images.success,
                color: AppColors.darkGreen,
                size: 80,
              )
            : allFail
                ? Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 5)),
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 60,
                    ),
                  )
                : Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 60,
                  ),
        const SizedBox(height: 20),
        if (partial || allSuccess)
          Flexible(
            child: MyText.titleMedium(
              widget.uploadOption == UploadOption.CSV
                  ? "Your ${excelIntegrationController.successfulFiles.join(', ')} files have been successfully uploaded"
                  : "Your Excel file \"$filename\" has been successfully uploaded",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: contentTheme.k142228,
              ),
            ),
          ),
        if (partial) SizedBox(height: 5),
        if (partial || allFail)
          Flexible(
            child: MyText.titleMedium(
              widget.uploadOption == UploadOption.CSV
                  ? "Failed to upload files ${excelIntegrationController.failedFiles.join(', ')}"
                  : "Your Excel file \"$filename\" has been failed to upload",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: contentTheme.k142228,
              ),
            ),
          ),
      ],
    ),
  );
}


}
