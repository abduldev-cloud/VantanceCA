import 'package:get/get.dart';
import 'package:vantanceCA/models/notification_model.dart';
import 'package:vantanceCA/helpers/services/notification_service.dart';

class NotificationController extends GetxController {
  final _service = NotificationService();

  var notifications = <NotificationItem>[].obs;
  var isLoading = false.obs;
  var isUnread = true.obs;

  // Load notifications for a student
  Future<void> loadNotifications({
    required String userId,
    bool? read = false, // Default: fetch only unread
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    isLoading.value = true;
    try {
      final data = await _service.fetchNotifications(
        userId: userId,
        read: read,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
      );

      notifications.value = data;
      isUnread.value = notifications.isNotEmpty;
    } catch (e) {
      print("Error loading notifications: $e");
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  // Mark single notification as read
  Future<void> markAsRead(String userId, String id) async {
    try {
      await _service.markAsRead(userId, id);
      notifications.value = notifications.map((n) {
        return n.id == id ? n.copyWith(read: true) : n;
      }).toList();
      notifications.refresh();
      isUnread.value = notifications.any((n) => !n.read);
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as read');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    final unreadIds = notifications.where((n) => !n.read).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    isLoading.value = true;
    try {
      await _service.markAllAsRead(userId, unreadIds);
      notifications.value = notifications.map((n) => n.copyWith(read: true)).toList();
      isUnread.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark all as read');
    } finally {
      isLoading.value = false;
    }
  }
}
