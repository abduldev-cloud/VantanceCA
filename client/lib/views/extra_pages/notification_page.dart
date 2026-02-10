import 'package:binary_success/controller/extra_pages/notification_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  late NotificationController controller;
  String userId = "";

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());

    final fetchedUserId = LocalStorage.getDBUserID() ?? "test";
    setState(() {
      userId = fetchedUserId;
    });

    controller.loadNotifications(
        userId: fetchedUserId, read: false); // Use fetchedUserId
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GetBuilder<NotificationController>(
            init: controller,
            builder: (_) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Obx(() {
                            if (controller.isUnread.value &&
                                controller.notifications.isNotEmpty) {
                              return TextButton.icon(
                                onPressed: () =>
                                    controller.markAllAsRead(userId),
                                icon: const Icon(Icons.mark_email_read_outlined,
                                    size: 18),
                                label: const Text("Mark All as Read"),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                ),
                              );
                            }
                            return const SizedBox();
                          }),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Get.back(),
                            tooltip: "Close",
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _filterButton("Unread", controller.isUnread.value,
                              () {
                            controller.isUnread.value = true;
                            controller.loadNotifications(
                                userId: userId, read: false);
                          }),
                          const SizedBox(width: 8),
                          _filterButton("Read", !controller.isUnread.value, () {
                            controller.isUnread.value = false;
                            controller.loadNotifications(
                                userId: userId, read: true);
                          }),
                        ],
                      )),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.notifications.isEmpty) {
                        return const Center(child: Text("No notifications"));
                      }

                      return ListView.builder(
                        itemCount: controller.notifications.length,
                        itemBuilder: (context, index) {
                          final notif = controller.notifications[index];
                          return ListTile(
                            title: Text(notif.title,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w600)),
                            subtitle: Text(notif.message),
                            trailing: notif.read
                                ? const Icon(Icons.check, color: Colors.green)
                                : IconButton(
                                    icon: const Icon(
                                        Icons.mark_email_read_outlined),
                                    onPressed: () =>
                                        controller.markAsRead(userId, notif.id),
                                  ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(100),
        gradient: isSelected
            ? const LinearGradient(
                colors: [
                  Color(0xFFEEECFF),
                  Color(0xFFEEECFF),
                  Color(0xFFDBEBFF),
                ],
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(40, 44, 62, 80),
            blurRadius: 24,
            spreadRadius: 1,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color.fromARGB(13, 44, 62, 80),
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(6, 0),
          ),
          BoxShadow(
            color: Color.fromARGB(10, 44, 62, 80),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(-6, 0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
