import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/logger/logger.dart';
import 'package:vantanceCA/helpers/network/api_service.dart';
import 'package:vantanceCA/models/notification_model.dart';
import 'package:vantanceCA/models/submit_draft_model.dart';
import 'package:dio/dio.dart';

class NotificationService {
  static final String _base = "${API.baseNotificationURL}/notifications";

  Future<List<NotificationItem>> fetchNotifications({
    required String userId,
    bool? read,
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 20,
    bool sortDesc = true,
  }) async {
    final body = {
      "user_id": userId,
      if (read != null) "read": read,
      if (type != null) "notif_type": type,
      "limit": limit,
      "sort_desc": sortDesc,
      if (fromDate != null) "from_date": fromDate.toIso8601String(),
      if (toDate != null) "to_date": toDate.toIso8601String(),
    };

    final response = await APIService.post(
      path: "/fetch",
      mapData: body,
      forcedBaseUrl: _base,
    );

    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => NotificationItem.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  Future<List<NotificationItem>> fetchNotificationsByEmail({
    required String email,
  }) async {
    final body = {
      "email": email,
    };

    final response = await APIService.post(
      path: "/notifications/fetch-by-email",
      mapData: body,
      forcedBaseUrl: API.baseURl,
    );

    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => NotificationItem.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load notifications");
    }
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    final body = {
      "user_id": userId,
      "notification_id": notificationId,
    };

    final response = await APIService.post(
      path: "/mark-read",
      mapData: body,
      forcedBaseUrl: _base,
    );

    if (response.statusCode != 200) {
      throw Exception("Mark as read failed");
    }
  }

  Future<void> markAllAsRead(
      String userId, List<String> notificationIds) async {
    final body = {
      "user_id": userId,
      "notification_ids": notificationIds,
    };

    final response = await APIService.post(
      path: "/bulk-mark-read",
      mapData: body,
      forcedBaseUrl: _base,
    );

    if (response.statusCode != 200) {
      throw Exception("Mark all as read failed");
    }
  }

  static Future<dynamic> sendNotificationAllLeaners({
    required String classId,
    required String teacherId,
    required String type,
  }) async {
    final String paramsInput =
        "class_id=$classId&teacher_id=$teacherId&task_type=$type";
    final response = await APIService.post(
      path: "/notification/notify_all_learners_in_class?$paramsInput",
      forcedBaseUrl: API.baseURl,
    );

    if (response.statusCode != 200) {
      throw Exception("Send notification to all learners failed");
      throw Exception("Send notification to all learners failed");
    }
  }

  static Future<dynamic> assigmentnotification(
      DraftAssignmentNotificationRequest request) async {
    try {
      final response = await APIService.post(
        mapData: request.toJson(),
        path: "/notifications/send",
        forcedBaseUrl: API.baseNotificationURL,
      );

      print("Create Task Response==${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return DraftAssignmentNotificationResponse.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      logE("Error creating task: ${e.message}");
      return null;
    }
  }

  /// New method to send reminder notification to a single user
  static Future<void> sendRemindNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    final body = {
      "user_id": userId,
      "title": title,
      "message": message,
    };

    final response = await APIService.post(
      path: "/notifications/send",
      forcedBaseUrl: API.baseNotificationURL,
      mapData: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Sending reminder notification failed");
    }
  }
}
