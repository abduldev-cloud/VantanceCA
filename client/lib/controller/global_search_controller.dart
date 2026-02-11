
import 'dart:async';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/utils/utils.dart';
import 'package:vantanceCA/models/global_search_model.dart';

class GlobalSearchController extends GetxController {
  var results = <GlobalSearchModel>[].obs;
  var isLoading = false.obs;

  Timer? _debounce;

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().length < 3) {
        results.clear();
        return;
      }

      isLoading.value = true;

      try {
        // Pick correct id based on persona
        final String id = RoleUtils.isPlatformAdmin
            ? (LocalStorage.getDBUserID() ?? '')
            : RoleUtils.isInstituteAdmin
                ? (LocalStorage.getDBUserID() ?? '')
                : RoleUtils.isTeacher
                    ? (LocalStorage.getDBEntityID() ?? '')
                    : (LocalStorage.getDBEntityID() ?? '');

        final String role = RoleUtils.currentRole ?? '';

         final response = await Dio().get(
          "${API.baseURl}/db/users/search_global_role_based/",
          queryParameters: {
            "id": id,
            "role": role,
            "search_text": query,
          },
        );

        print("Search query: $query");
        print("User ID: $id");
        print("Role: $role");

      print("Response status code: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.data != null && response.data["out_status"] == "SUCCESS") {
        final List<dynamic> data = response.data["search_result"] ?? [];
        results.value = GlobalSearchModel.listFromJson(data);
      } else {
        results.clear();
      }
    } catch (e) {
      print("Search error: $e");
      results.clear();
    } finally {
      isLoading.value = false;
    }
  });
}

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}