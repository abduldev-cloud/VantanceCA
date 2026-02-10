import 'package:binary_success/helpers/widgets/app_button.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/views/apps/school/widget/asset_icon_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final String token;
  const ConfirmDeleteDialog({super.key, required this.onConfirm, required this.token});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding:
          EdgeInsets.symmetric(horizontal: 24), // keeps it from touching edges
      contentPadding: EdgeInsets.all(20),
      content: SizedBox(
        width: 360, // ✅ fixed width for compact look
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button in top right
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close, size: 20, color: Colors.grey[600]),
              ),
            ),
            // Icon
            AssetIconBox(iconPath: Images.delete),
            const SizedBox(height: 16),
            // Title
            MyText.titleLarge(
              "Confirm Deletion",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Token truncated
            Text(
              token,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Subtitle
            MyText(
              "Are you sure you want to delete this access key?",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                      title: "Confirm Delete", onTap: onConfirm),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Get.back(),
                    child: MyText("Cancel"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
