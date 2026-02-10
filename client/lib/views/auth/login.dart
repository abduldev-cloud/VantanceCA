import 'package:binary_success/controller/auth/login_controller.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/app_button.dart';
import 'package:binary_success/helpers/widgets/my_button.dart';
import 'package:binary_success/helpers/widgets/my_responsiv.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/widgets/custom_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LoginController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload images to prevent "pop-in" or loading delay
    precacheImage(AssetImage(Images.loginLogo), context);
    precacheImage(AssetImage(Images.googleLogo), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed from gray to white
      body: MyResponsive(
        builder: (BuildContext context, _, screenMT) {
          bool isMobile = screenMT.isMobile || screenMT.isTablet;

          return Center(
            child: GetBuilder<LoginController>(
              init: controller,
              builder: (controller) {
                return SingleChildScrollView(
                  child: Align(
                    child: AutofillGroup(
                      child: Form(
                        key: controller.formKey,
                        child: Container(
                          width: isMobile
                              ? MySpacing.fullWidth(context) * 0.90
                              : 1080, // Fixed Width as per design spec
                          // Minimum height for desktop to look good
                          constraints:
                              BoxConstraints(minHeight: isMobile ? 0 : 650),
                          padding: MySpacing.symmetric(
                              horizontal: isMobile
                                  ? 24
                                  : MySpacing.fullWidth(context) * 0.04,
                              vertical: isMobile
                                  ? 32
                                  : MySpacing.fullHeight(context) * 0.08),
                          decoration: BoxDecoration(
                            // Removed borderRadius and boxShadow for white-on-white look
                            color: Colors.white,
                          ),
                          child: isMobile
                              ? _buildFormContent(context, controller,
                                  isMobile: true)
                              : Row(
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
                                              // Fallback
                                              return Image.asset(
                                                  Images.elephant,
                                                  fit: BoxFit.contain);
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
                                          width: 320,
                                          child: _buildFormContent(
                                              context, controller,
                                              isMobile: false),
                                        ),
                                      ),
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
        },
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, LoginController controller,
      {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Column(
            children: [
              MyText.displaySmall(
                "WELCOME BACK",
                style: GoogleFonts.inter(
                    fontSize: isMobile ? 24 : 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              MyText.bodyMedium(
                "Please enter your details.",
                style: GoogleFonts.inter(
                    fontSize: isMobile ? 14 : 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff667085)),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 32 : 40),

        // Email Field (Label handled by TextInputFields now)
        TextInputFields(
          autofillHints: const [AutofillHints.username],
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter email";
            } else if (!value.isEmail) {
              return "Please enter valid email";
            }
            return null;
          },
          controller: controller.email,
          name: "Email",
          filled: true,
          fillColor: Colors.white,
          hintText: "Enter your email",
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          // Restored visible border as requested but darker
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
          titleTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black, // Darker, accurate label color
          ),
          hintTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
        ),

        const SizedBox(height: 20),

        // Password Field
        TextInputFields(
          autofillHints: const [AutofillHints.password],
          validator: (value) {
            if (value!.isEmpty) {
              return "Please enter password";
            }
            return null;
          },
          controller: controller.password,
          name: "Password",
          filled: true,
          fillColor: Colors.white,
          obSecureText: !controller.showPassword,
          hintText: "**********",
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          // Restored visible border as requested
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade600),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black),
          ),
          suffixWidget: InkWell(
            onTap: () {
              controller.onChangeShowPassword();
            },
            child: Icon(
              controller.showPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey.shade500,
              size: 20,
            ).paddingOnly(right: 20),
          ),
          hintTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),

        // Remember Me & Forgot Password
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => controller.onChangeCheckBox(!controller.isChecked),
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        onChanged: controller.onChangeCheckBox,
                        value: controller.isChecked,
                        // Strong color override
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.black; // Black when checked
                            }
                            return Colors.white; // White when unchecked
                          },
                        ),
                        checkColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 4), // Reduced gap
                    MyText.bodySmall(
                      "Remember me",
                      style: GoogleFonts.inter(
                          fontSize: 12, // Reduced font size
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed("/auth/forgot_password");
                },
                child: MyText.bodyMedium(
                  'Forgot password?',
                  style: GoogleFonts.inter(
                      fontSize: 12, // Reduced font size
                      fontWeight: FontWeight.w600,
                      color: Colors.black),
                ),
              ),
            ],
          ),
        ),

        // Sign In Button
        Obx(() => controller.isLoginLoading.value
            ? SizedBox(
                height: 50,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                ),
              )
            : SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.formKey.currentState!.validate()) {
                      controller.isLoginLoading(true);
                      try {
                        await controller.login(
                          controller.email.text,
                          controller.password.text,
                        );
                      } catch (e) {
                        Get.snackbar(
                          "Login Failed",
                          "Invalid credentials",
                          backgroundColor: Colors.black87,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  Get.width > 600 ? Get.width * 0.35 : 20,
                              vertical: 20),
                          borderRadius: 10,
                          icon: const Icon(Icons.error, color: Colors.white),
                        );
                      } finally {
                        controller.isLoginLoading(false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Sign in",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )),

        const SizedBox(height: 16),

        // Google Sign In (Visual Only)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              // Placeholder for Google Sign In
              print("Google Sign In Clicked");
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Original Google Logo
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(Images.googleLogo),
                ),
                const SizedBox(width: 12),
                Text(
                  "Sign in with Google",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Footer Links
        Center(
          child: Column(
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey.shade600),
                  children: [
                    const TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: "Register",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          controller.gotoRegister();
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                  height: 20), // Increased spacing between footer links
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey.shade600),
                  children: [
                    const TextSpan(text: "Don't have an access? "),
                    TextSpan(
                      text: "Join Us",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigation
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
