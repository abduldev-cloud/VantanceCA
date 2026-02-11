import 'dart:typed_data';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:dio/dio.dart';

class ExcelIntegrationService {
  static Future<Response?> uploadExcelFile({
    required String siteId,
    required String userId,
    required Uint8List bytes,
    required String filename,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType(
            "application",
            "vnd.openxmlformats-officedocument.spreadsheetml.sheet",
          ),
        ),
      });

      final Response response = await APIService.postWithoutAth(
        path: "/alfresco/upload",
        params: {
          "site_id": siteId,
          "user_id": userId,
          "folder_path": "bulk_upload",
        },
        headers: {
          "accept": "application/json",
          "Content-Type": "multipart/form-data",
        },
        data: formData,
      );

      return response;
    } catch (e) {
      print("Excel upload failed (web): $e");
      return null;
    }
  }
}
