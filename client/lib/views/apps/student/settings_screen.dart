import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:binary_success/controller/apps/student/student_settings_controller.dart';
import 'package:binary_success/views/apps/student/widget/student_change_password_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenSecurity;

  const SettingsScreen({
    super.key,
    this.onOpenSubscription,
    this.onOpenSecurity,
  });

  void _showChangePasswordDialog(BuildContext context, StudentSettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onConfirm: (newPassword) async {
          // Capture messenger before async gap
          final messenger = ScaffoldMessenger.of(context);
          
          // Check history
          bool inHistory = await controller.checkPasswordHistory(newPassword);
          if (inHistory) {
             messenger.showSnackBar(
              const SnackBar(
                content: Text("You cannot use your last used password."),
                backgroundColor: Colors.red,
              ),
            );
            return false; // Validation failed
          }

          // Call service to update
          await controller.updatePassword(newPassword);
          
          // Show success snackbar
          messenger.showSnackBar(
            const SnackBar(content: Text("Password updated successfully!")),
          );
          return true; // Success
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final StudentSettingsController controller = Get.put(StudentSettingsController());

    return Container(
      color: Colors.white, // Page background is now white
      child: Obx(() {
        final profile = controller.userProfile.value;
        
        return ListView(
          // Page padding: 32px left and right
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, top: 24.0, bottom: 24.0),
          children: [
            // Page Title
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF000000), // Pure black
                fontFamily: 'Inter',
                letterSpacing: 0,
                height: 1.2, // Line height 120%
              ),
            ),
            const SizedBox(height: 20), // 20px spacing below title

            // 1. Your Profile (Only title)
            const _SettingsCard(
              title: 'Your Profile',
            ),
            const SizedBox(height: 18),

            // 2. Name
            _SettingsCard(
              title: 'Name',
              subtitle: profile?.name ?? 'Loading...',
            ),
            const SizedBox(height: 18),

            // 3. Email
            _SettingsCard(
              title: 'Email',
              subtitle: profile?.email ?? 'Loading...',
            ),
            const SizedBox(height: 18),

            // 4. Password
            _SettingsCard(
              title: 'Password',
              // No subtitle
              buttonText: 'Change',
              onButtonPressed: () => _showChangePasswordDialog(context, controller),
            ),
            const SizedBox(height: 18),

            // 5. Plan & Subscription
            _SettingsCard(
              title: 'Plan & Subscription',
              subtitle: "Lorem Ipsum has been the industry's standard dummy text",
              buttonText: 'View',
              onButtonPressed: onOpenSubscription,
            ),
            const SizedBox(height: 18),

            // 6. Security & Privacy
            _SettingsCard(
              title: 'Security & Privacy',
              subtitle: "Lorem Ipsum has been the industry's standard dummy text",
              buttonText: 'View',
              onButtonPressed: onOpenSecurity,
            ),
            const SizedBox(height: 18),

            // 7. Logout
            const _SettingsCard(
              title: 'Logout',
            ),
          ],
        );
      }),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const _SettingsCard({
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), // Card background is now light grey
        borderRadius: BorderRadius.circular(12), // Rounded corners 12px
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000), // #0000000D
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // Padding 22px vertical
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top if multiline
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title in bold, size 14
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold, // Bold
                    color: Colors.black,
                    fontFamily: 'Inter',
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8), // Proper spacing 8px
                  // Subtitle in regular weight, size 14, color #555555
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal, // Regular
                      color: Color(0xFF555555),
                      fontFamily: 'Inter',
                      height: 1.4, // Good line height for text
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (buttonText != null) ...[
            const SizedBox(width: 16),
            // Black rounded button
            Padding(
              padding:
                  const EdgeInsets.only(top: 0), // Adjust alignment if needed
              child: SizedBox(
                width: 70, // Button size: 70x30
                height: 30,
                child: ElevatedButton(
                  onPressed: onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background #000
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Corner radius 20
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontSize: 12, // Font size 12
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
