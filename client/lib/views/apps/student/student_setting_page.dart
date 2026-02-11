import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/services/user_service.dart';
import 'widget/student_change_password_dialog.dart';
import 'student_subscription_page.dart';
import 'student_security_privacy_page.dart'; // Added import

class SettingsPage extends StatefulWidget {
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenSecurity;

  const SettingsPage({super.key, this.onOpenSubscription, this.onOpenSecurity});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _userService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          
          _buildSectionHeader("Your Profile"),
          const SizedBox(height: 16),
          _buildInfoRow("Name", _userProfile?.name ?? ""),
          _buildInfoRow("Email", _userProfile?.email ?? ""),
          
          _buildActionRow("Password", "Change", _showChangePasswordDialog),
          _buildActionRow("Plan & Subscription", "View", () {
            if (widget.onOpenSubscription != null) {
              widget.onOpenSubscription!();
            } else {
              // Fallback for independent testing if needed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SubscriptionPage()),
              );
            }
          }, 
              description: "Lorem Ipsum has been the industry's standard dummy text"),
          _buildActionRow("Security & Privacy", "View", () {
            if (widget.onOpenSecurity != null) {
              widget.onOpenSecurity!();
            } else {
               // Fallback navigation
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const SecurityPrivacyPage()),
               );
            }
          },
              description: "Lorem Ipsum has been the industry's standard dummy text"),

          const SizedBox(height: 24),
          _buildSectionHeader("Logout", isAction: true, onTap: () => print("Logout Clicked")),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => ChangePasswordDialog(
        onConfirm: (newPassword) async {
          // Capture messenger before async gap to avoid 'unsafe ancestor lookup'
          final messenger = ScaffoldMessenger.of(context);
          
          // Check history
          bool inHistory = await _userService.checkPasswordHistory(newPassword);
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
          await _userService.updatePassword(newPassword);
          
          // Show success snackbar
          messenger.showSnackBar(
            const SnackBar(content: Text("Password updated successfully!")),
          );
          return true; // Success
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isAction = false, VoidCallback? onTap}) {
    if (isAction) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title, 
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600, 
              fontSize: 14, 
              color: Colors.black
            )
          ), // Assuming logout looks like a row but just text based on image? Or implies a section. 
             // Image shows "Logout" as a standalone row background.
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 24),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A1A), // Darker grey
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA), // Light grey background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, String buttonText, VoidCallback onAction, {String? description}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // If available width is too small or mobile breakpoint, stack vertically
          // Using a threshold like 350 allows Row on typical phones, Column on very narrow ones.
          // However, if the error says constraints w=97.4, that's extremely small.
          // That suggests the sidebar + padding is eating everything? 
          // Regardless, Column handles it.
          final bool useColumn = constraints.maxWidth < 400;

          if (useColumn) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      fixedSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    fixedSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
