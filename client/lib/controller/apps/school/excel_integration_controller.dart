import 'dart:typed_data';
import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/controller/my_controller.dart';
import 'package:binary_success/helpers/services/excel_integration_service.dart';
import 'package:binary_success/helpers/services/integration_service.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/utils/app_snakbar.dart';
import 'package:binary_success/models/integration_log_model.dart';
import 'package:binary_success/models/paginated_data_model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class ExcelIntegrationController extends MyController {
  Rx<PaginatedResponse<IntegrationLog>?> bulkUploadLogs = Rx<PaginatedResponse<IntegrationLog>?>(null);
  RxList<String> successfulFiles = <String>[].obs;
  RxList<String> failedFiles = <String>[].obs;

  //Loaders
  RxBool isUploading = false.obs;
  RxBool isUploadSuccess = false.obs;
  RxBool isUploadFinished = false.obs;
  RxBool isFetchingLogs = false.obs;

  // Controllers
  final LmsIntegrationController lmsIntegrationController = Get.put(LmsIntegrationController());

  @override
  void onReady() {
    super.onReady();
    fetchBulkUploadLogs(1);
  }

  Future<void> uploadExcelFile(
      {required Uint8List bytes,
      required String filename
      }) async {
    try {
      isUploading.value = true;
      update();

      final String siteId = LocalStorage.getAlfrescoSiteID() ?? "";
      final String userId = LocalStorage.getDBUserID() ?? "";

      dio.Response? response = await ExcelIntegrationService.uploadExcelFile(
          siteId: siteId, userId: userId, bytes: bytes, filename: filename);

      bool success = response != null && response.statusCode == 200;

      if (success) {
        LocalStorage.removeCsvBulkUploadIds();
        await lmsIntegrationController.updateIntegrationPlatform("Excel");
        successfulFiles.add(filename);
        await lmsIntegrationController.checkIntegrationMode();
        await fetchBulkUploadLogs(1);
        isUploadSuccess.value = true;
      } else {
        failedFiles.add(filename);
        appSnackbar(message: "Excel file upload failed ❌");
      }
    } catch (e) {
      failedFiles.add(filename);
      appSnackbar(message: "Something went wrong: $e");
    } finally {
      isUploading.value = false;
      isUploadFinished.value = true;
      update();
    }
  }

  Future<void> uploadCsvFiles({
    required List<Map<String, dynamic>> files,
  }) async {
    try {
      isUploading.value = true;
      update();

      if (files.isEmpty) {
        appSnackbar(message: "Files array can't be empty");
        return;
      }

      final String siteId = LocalStorage.getAlfrescoSiteID() ?? "";
      final String userId = LocalStorage.getDBUserID() ?? "";
      List<String> bulkUploadIds = [];

      bool allSuccess = true;

      for (final file in files) {
        dio.Response? response = await ExcelIntegrationService.uploadExcelFile(
          siteId: siteId,
          userId: userId,
          bytes: file['file'] as Uint8List,
          filename: file['filename'],
        );

        bool success = response != null && response.statusCode == 200;

        if (!success) {
          allSuccess = false;
          failedFiles.add(file['filename']);
          appSnackbar(message: "Failed to upload csv file ${file['filename']}");
        } else {
          final Map<String, dynamic> data = response.data;
          bulkUploadIds.add(data['bulk_upload_response']['bulk_upload_id']);
          successfulFiles.add(file['filename']);
        }
      }

      if(bulkUploadIds.isNotEmpty) {
        LocalStorage.setCsvBulkUploadIds(bulkUploadIds);
      }

      if (allSuccess) {
        isUploadSuccess.value = true;
        await lmsIntegrationController.updateIntegrationPlatform("Excel");
      }

      if(successfulFiles.isNotEmpty) {
        await lmsIntegrationController.checkIntegrationMode();
        fetchCsvFilesLogs();
      }
      update();
    } catch (e) {
      appSnackbar(message: "Something went wrong: $e");
    } finally {
      isUploading.value = false;
      isUploadFinished.value = true;
      update();
    }
  }

  Future<void> fetchBulkUploadLogs(int page, {String query = "", isPageChange = false}) async {
    String? bulkUploadId = LocalStorage.getBulkUploadID();
    List<String>? csvBulkUploadIds = LocalStorage.getCsvBulkUploadIds();

    if(csvBulkUploadIds != null && csvBulkUploadIds.isNotEmpty) {
      fetchCsvFilesLogs();
      return;
    }

    if(bulkUploadId == null) {
      return;
    }

    try {
      if(!isPageChange) {
        isFetchingLogs.value = true;
        update();
      }

      final result = await IntegrationService.getLogs(bulkUploadId, source: "alfresco", page: page, query: query);
      if (result.data.isNotEmpty) {
        bulkUploadLogs.value = result;
      } else {
        print("No logs found");
      }
    } catch (e) {
      print("Error fetching logs $e");
    } finally {
      if(!isPageChange) {
        isFetchingLogs.value = false;
      }
      update();
    }
  }

  Future<void> fetchCsvFilesLogs({String? query, int page = 1, bool isPageChange = false}) async {
    final List<String>? bulkUploadIds = LocalStorage.getCsvBulkUploadIds();

    if (bulkUploadIds == null || bulkUploadIds.isEmpty) {
      return;
    }
    try {
      if(!isPageChange) {
        isFetchingLogs.value = true;
        update();
      }

      List<IntegrationLog> allLogs = [];

      for (final id in bulkUploadIds) {
        // ✅ Fetch logs with a sensible page size
        final csvLog = await IntegrationService.getLogs(
          id,
          source: "alfresco",
          page: 1,
          pageLimit: 100, // fetch more logs at once, adjust as needed
        );

        if (csvLog.data.isNotEmpty) {
          for (final log in csvLog.data) {
            if (query == null || log.message.toLowerCase().contains(query.toLowerCase())) {
              allLogs.add(log);
            }
          }
        }
      }

      // ✅ Apply pagination locally (10 per page)
      const pageSize = 10;
      final total = allLogs.length;
      final totalPages = (total / pageSize).ceil();

      // prevent going out of range
      final start = (page - 1) * pageSize;
      final end = start + pageSize;
      final paginatedLogs = allLogs.sublist(
        start,
        end > total ? total : end,
      );

      bulkUploadLogs.value = PaginatedResponse(
        data: paginatedLogs,
        total: total,
        page: page,
        pageSize: pageSize,
        totalPages: totalPages,
      );
    } catch (e) {
      print("Error fetching logs $e");
    } finally {
      if(!isPageChange) {
        isFetchingLogs.value = false;
      }
      update();
    }
  }
}
