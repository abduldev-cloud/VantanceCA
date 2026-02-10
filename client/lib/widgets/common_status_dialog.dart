import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusDialog {
  static void show({
    required bool isSuccess,
    required String message,
    int autoCloseSeconds = 0,
    VoidCallback? onClose, // ✅ callback after close
  }) {
    // If autoCloseSeconds > 0, schedule dialog close
    if (autoCloseSeconds > 0) {
      Future.delayed(Duration(seconds: autoCloseSeconds), () {
        if (Get.isDialogOpen == true) {
          Get.back();
          if (onClose != null) onClose();
        }
      });
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              child: Icon(
                isSuccess ? Icons.check : Icons.close,
                color: Colors.white,
                size: 35,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isSuccess ? "Success" : "Failed",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Get.back();
                if (onClose != null) onClose(); // ✅ trigger callback if closed manually
              },
              child: const Text("OK"),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
