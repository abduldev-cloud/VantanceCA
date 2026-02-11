import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:vantanceCA/models/add_school_model.dart';
import 'package:vantanceCA/models/create_class_model.dart';
import 'package:dio/dio.dart';

class SchoolService {
  static final Dio _dio = Dio();

  Future<dynamic> submitSchool(AddSchoolModel model) async {
    try {
      final data = {
        "email": model.adminEmail,
        "role": model.role,
        "created_by": model.createdBy,
        "additional_details": {
          "school_name": model.schoolName,
          "school_type": model.schoolType,
          "school_district": model.schoolDistrict,
          "email_domain": model.emailDomain,
          "invite_persona": model.role,
          "is_demo_school" : model.isDemoSchool ? "Y" : "N" 
        }
      };

      final response = await APIService.post(
        path: "/users/invite-user",
        mapData: data,
      );

      return response;
    } catch (e) {
      logE("Error submitting school: $e");
      return false;
    }
  }


  Future<dynamic> fetchClasses(String instituteId, String classStatus) async {
    try {
      final response = await APIService.get(
        path:
            "/db/institute/get_school_class_summary/?institute_id=$instituteId&class_status=$classStatus",
      );
      return response;
    } catch (e) {
      logE("Error fetching classes [$classStatus]: $e");
      return null;
    }
  }

    static Future<dynamic> getTeacherViewClassAPI({
    required String teacherId,
    required String classId,
  }) async {
    try {
      final response = await APIService.get(
        path: "/db/teacher/get_class_tasks_stats_and_learners/?teacher_id=$teacherId&class_id=$classId",
        
      );

      return response;
    } catch (e) {
      logE("Error fetching classes [$classId]: $e");
      return null;
    }
  }

  // Fetch All Learners (Total Students Tab)
  Future<Map<String, dynamic>?> fetchAllLearners(String instituteId) async {
    try {
      final response = await APIService.get(
        path:
            "/db/institute/get_school_admin_all_learners/?institute_id=$instituteId",
      );

      if (response != null && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      logE("Error fetching all learners: $e");
      return null;
    }
  }

  static Future<CreateClassResponse?> createClassAPI(CreateClassRequest request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        forcedBaseUrl: API.apiURL,
        path: "admin/teacher/create_class/",
      );
      
      print("Create Class Response==${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CreateClassResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      logE("Error creating class: ${e.message}");
      return null;
    }
  }

  //   static Future<dynamic> getStateDistricts(CreateSchoolRequest request) async {
  //   try {
  //     final response = await APIService.get(
  //       forcedBaseUrl: API.apiURL,
  //       path: "admin/platform_admin/get_institute_state_district/",
  //     );
      
  //     print("Create School Response==${response.data}");
      
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       return CreateSchoolResponse.fromJson(response.data);
  //     }
  //     return null;
  //   } on DioException catch (e) {
  //     logE("Error creating School: ${e.message}");
  //     return null;
  //   }
  // }
  // static Future<Map<String, dynamic>?> getStatesAndDistricts() async {
  //   return await APIService.get(
  //       forcedBaseUrl: API.apiURL,
  //       path: "admin/platform_admin/get_institute_state_district/",); 
  // }
  static Future<Map<String, dynamic>?> getStatesAndDistricts() async {
    try {
      final response = await _dio.get("${API.apiURL}admin/platform_admin/get_institute_state_district/");
      if (response.statusCode == 200) {
        // response.data is already a decoded Map
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error in getStatesAndDistricts: $e");
    }
    return null;
  }
  static Future<Map<String, dynamic>?> getInstituteTypes() async {
    try {
      final response = await _dio.get("${API.apiURL}admin/institute/get_institute_types/");
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error in getInstituteTypes: $e");
    }
    return null;
  }
}
