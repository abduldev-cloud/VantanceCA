import 'package:vantanceCA/controller/auth/create_new_password_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_responsiv.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({super.key});

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late CreateNewPasswordController controller;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // ✅ Using the new controller (no addField needed because controller initializes validator with fields)
    controller = Get.put(CreateNewPasswordController());
  }

  @override
  Widget build(BuildContext context) {
    final newPassCtrl = controller.newPasswordCtrl;
    final confirmPassCtrl = controller.confirmPasswordCtrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: MyResponsive(
        builder: (BuildContext context, _, screenMT) {
          bool isMobile = screenMT.isMobile || screenMT.isTablet;

          return Center(
            child: SingleChildScrollView(
              child: Align(
                child: Form(
                  key: controller.basicValidator.formKey,
                  child: Container(
                    width: isMobile
                        ? MySpacing.fullWidth(context) * 0.90
                        : 1080, // Fixed Width as per reference
                    // Minimum height for desktop to look good
                    constraints: BoxConstraints(minHeight: isMobile ? 0 : 650),
                    padding: MySpacing.symmetric(
                        horizontal:
                            isMobile ? 24 : MySpacing.fullWidth(context) * 0.04,
                        vertical: isMobile
                            ? 32
                            : MySpacing.fullHeight(context) * 0.08),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: isMobile
                        ? _buildFormContent(
                            context, newPassCtrl, confirmPassCtrl,
                            isMobile: true)
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 40),
                              // Header "Binary Success" Logo + Text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(Images.shape,
                                      height: 32), // Mini logo
                                  const SizedBox(width: 8),
                                  MyText.titleLarge(
                                    "Binary Success",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Content Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Center vertically
                                children: [
                                  // Image Section (Left) - Bigger Icon
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: Container(
                                        width: 400,
                                        height: 400,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: const BoxDecoration(
                                            // No decoration/circle as requested
                                            ),
                                        child: Image.asset(
                                          Images.loginLogo,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.lock,
                                                size: 70);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 80), // Increased spacing
                                  // Form Section (Right) - Constrained Width
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: SizedBox(
                                        width:
                                            380, // Increased width slightly to fit single line text
                                        child: _buildFormContent(context,
                                            newPassCtrl, confirmPassCtrl,
                                            isMobile: false),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormContent(BuildContext context,
      TextEditingController newPassCtrl, TextEditingController confirmPassCtrl,
      {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              MyText.displaySmall(
                "CREATE NEW PASSWORD",
                style: GoogleFonts.inter(
                    fontSize: isMobile
                        ? 24
                        : 28, // Slightly reduced to ensure single line
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0, // Reduced letter spacing
                    color: Colors.black),
                textAlign: TextAlign.center,
                maxLines: 1, // Force single line
              ),
              const SizedBox(height: 8),
              MyText.bodyMedium(
                "Create a password to keep your account safe.",
                style: GoogleFonts.inter(
                    fontSize: isMobile ? 14 : 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff667085)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 32 : 40),

        /// New Password
        _buildPasswordField(
          controller: newPassCtrl,
          label: "New Password",
          obscureText: _obscureNew,
          validator: controller.basicValidator.getValidation("newPassword"),
          onToggle: () => setState(() {
            _obscureNew = !_obscureNew;
          }),
        ),
        const SizedBox(height: 20),

        /// Confirm Password
        _buildPasswordField(
          controller: confirmPassCtrl,
          label: "Confirm Password",
          obscureText: _obscureConfirm,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please confirm your password';
            }
            if (val != newPassCtrl.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          onToggle: () => setState(() {
            _obscureConfirm = !_obscureConfirm;
          }),
        ),
        const SizedBox(height: 32),

        // Confirm Button
        SizedBox(
          width: double.infinity,
          height: 52, // Matching login button height
          child: ElevatedButton(
            onPressed: () {
              if (controller.basicValidator.formKey.currentState!.validate()) {
                final token =
                    Get.parameters['token'] ?? Get.arguments?['token'] ?? '';
                controller.onCreateNewPassword(resetToken: token);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white, // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              elevation: 0,
            ),
            child: Text(
              "Confirm Password",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: label,
                style: GoogleFonts.inter(
                  fontSize: 14, // Standard font size
                  fontWeight: FontWeight.w500,
                  color: Colors.black, // Darker label
                ),
              ),
              TextSpan(
                text: ' *',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: label == "New Password"
                ? "Enter your new password"
                : "Re-enter your new password",
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey.shade600),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: onToggle,
                child: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey.shade500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
