import 'package:vantanceCA/controller/auth/forgot_password_controller.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_responsiv.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/images.dart';
import 'package:vantanceCA/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late ForgotPasswordController controller;
  @override
  void initState() {
    super.initState();
    // Ensure we start with a fresh controller to avoid duplicate GlobalKey issues
    // caused by GetX persisting the controller (and its formKey) across navigation.
    if (Get.isRegistered<ForgotPasswordController>()) {
      Get.delete<ForgotPasswordController>();
    }
    controller = Get.put(ForgotPasswordController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload images to prevent "pop-in" or loading delay
    precacheImage(AssetImage(Images.loginLogo), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MyResponsive(
        builder: (BuildContext context, _, screenMT) {
          bool isMobile = screenMT.isMobile || screenMT.isTablet;

          return Center(
            child: GetBuilder<ForgotPasswordController>(
              init: controller,
              builder: (controller) {
                return SingleChildScrollView(
                  child: Align(
                    child: AutofillGroup(
                      child: Form(
                        key: controller.basicValidator.formKey,
                        child: Container(
                          width: isMobile
                              ? MySpacing.fullWidth(context) * 0.90
                              : MySpacing.fullWidth(context) * 0.75,
                          // Minimum height for desktop to look good
                          constraints:
                              BoxConstraints(minHeight: isMobile ? 0 : 600),
                          padding: MySpacing.symmetric(
                              horizontal: isMobile
                                  ? 24
                                  : MySpacing.fullWidth(context) * 0.04,
                              vertical: isMobile
                                  ? 32
                                  : MySpacing.fullHeight(context) * 0.08),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: isMobile
                              ? Column(
                                  children: [
                                    // Brand Header (Mobile)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 32.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            Images.logoCircle,
                                            height: 48,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Binary Success",
                                            style: GoogleFonts.inter(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildContent(context, controller,
                                        isMobile: true),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Brand Header
                                    Padding(
                                      // Removed Expanded/Flexible here
                                      padding:
                                          const EdgeInsets.only(bottom: 40.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            Images.logoCircle,
                                            height: 48,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            "Binary Success",
                                            style: GoogleFonts.inter(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Row Content (Image + Form)
                                    Row(
                                      // Removed Expanded wrapper
                                      children: [
                                        // Image Section (Left)
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: Container(
                                              width: 400,
                                              height: 400,
                                              clipBehavior: Clip.antiAlias,
                                              decoration: const BoxDecoration(),
                                              child: Image.asset(
                                                Images.loginLogo,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                      Images.elephant,
                                                      fit: BoxFit.contain);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 64),
                                        // Form Section (Right)
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: SizedBox(
                                              width: isMobile
                                                  ? double.infinity
                                                  : 380,
                                              child: _buildContent(
                                                  context, controller,
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
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ForgotPasswordController controller,
      {required bool isMobile}) {
    return Obx(() {
      if (controller.isSuccess.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText.displaySmall(
              "FORGOT PASSWORD\nCONFIRMATION",
              style: GoogleFonts.inter(
                fontSize: isMobile ? 24 : 30,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            MyText.bodyMedium(
              "We have sent the link to your email address!",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xff667085),
              ),
            ),
            const SizedBox(height: 8),
            MyText.bodyMedium(
              controller.sentEmail,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: InkWell(
                onTap: controller.gotoLogIn,
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Text (Left Aligned)
            MyText.displaySmall(
              "FORGOT PASSWORD?",
              style: GoogleFonts.inter(
                  fontSize: isMobile ? 24 : 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.black),
            ),
            const SizedBox(height: 8),
            MyText.bodyMedium(
              "Where would you like to receive an email verification link?",
              textAlign: TextAlign.left, // changed from center
              style: GoogleFonts.inter(
                  fontSize: isMobile ? 14 : 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xff667085)),
            ),

            SizedBox(height: isMobile ? 32 : 40),

            // Input Label
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Enter your email address ',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600, // Matching design label weight
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: '*',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Input Field
            TextInputFields(
              autofillHints: const [AutofillHints.username],
              validator: controller.basicValidator.getValidation("email"),
              controller: controller.basicValidator.getController("email"),
              name: "",
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your email address",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide:
                    BorderSide(color: Colors.grey.shade600), // Dark grey border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.black),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.red),
              ),
              hintTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              suffixWidget: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Icon(Icons.email_outlined, color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            Obx(() => controller.isLoading.value
                ? SizedBox(
                    height: 52,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.basicValidator.formKey.currentState!
                            .validate()) {
                          controller.onForgotPassword();
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
                        "Submit",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )),

            const SizedBox(height: 24),

            // Back to Login
            Center(
              child: InkWell(
                onTap: controller.gotoLogIn,
                child: Text(
                  'Back to Login',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      }
    });
  }
}
