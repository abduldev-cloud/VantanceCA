import 'package:binary_success/controller/auth/register_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_responsiv.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/widgets/custom_textfield.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin, UIMixin {
  late RegisterController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RegisterController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(AssetImage(Images.loginLogo), context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: MyResponsive(
          builder: (BuildContext context, _, screenMT) {
            bool isMobile = screenMT.isMobile || screenMT.isTablet;

            return Center(
              child: GetBuilder<RegisterController>(
                init: controller,
                builder: (controller) {
                  return SingleChildScrollView(
                    child: Align(
                      child: Container(
                        width: isMobile
                            ? MySpacing.fullWidth(context) * 0.90
                            : 1080,
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
                          color: Colors.white,
                        ),
                        child: isMobile
                            ? _buildMobileView(context, controller)
                            : Row(
                                children: [
                                  // Image Section (Left)
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: SizedBox(
                                        width: 400,
                                        height: 400,
                                        child: Image.asset(
                                          Images.loginLogo,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(Images.elephant,
                                                fit: BoxFit.contain);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 80),
                                  // Form Section (Right)
                                  Expanded(
                                    flex: 1,
                                    child: Center(
                                      child: SizedBox(
                                        width: 400,
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context, RegisterController controller) {
    return Center(
      child: MyText.labelMedium(
        "Mobile view is not supported",
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 20.sp,
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, RegisterController controller,
      {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        Center(
          child: Column(
            children: [
              MyText.displaySmall(
                "CREATE ACCOUNT",
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
        SizedBox(height: isMobile ? 24 : 32),

        // Step Indicator
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(
                  step: 1,
                  label: "Personal",
                  isActive: controller.selectedIndex.value == 0,
                  onTap: () => controller.selectedIndex.value = 0,
                ),
                Container(
                  width: 40,
                  height: 2,
                  color: controller.selectedIndex.value == 1
                      ? Colors.black
                      : Colors.grey.shade300,
                ),
                _buildStepIndicator(
                  step: 2,
                  label: "School",
                  isActive: controller.selectedIndex.value == 1,
                  onTap: () => controller.selectedIndex.value = 1,
                ),
              ],
            )),

        SizedBox(height: isMobile ? 24 : 32),

        // PageView for forms
        SizedBox(
          height: 450,
          child: PageView(
            physics: NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            children: [
              _buildPersonalInfoForm(controller, isMobile),
              _buildSchoolInfoForm(controller, isMobile),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Footer
        Center(
          child: RichText(
            text: TextSpan(
              style:
                  GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
              children: [
                const TextSpan(text: "Already have an account? "),
                TextSpan(
                  text: "Login here",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.offAllNamed("/auth/login");
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.black : Colors.grey.shade300,
            ),
            child: Center(
              child: Text(
                "$step",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(RegisterController controller, bool isMobile) {
    return ScrollConfiguration(
      behavior:
          ScrollConfiguration.of(Get.context!).copyWith(scrollbars: false),
      child: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // First Name
            TextInputFields(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter first name";
                }
                return null;
              },
              name: "First Name",
              controller: controller.firstName,
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your first name",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                color: Colors.black,
              ),
              hintTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),

            // Last Name
            TextInputFields(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter last name";
                }
                return null;
              },
              name: "Last Name",
              controller: controller.lastName,
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your last name",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                color: Colors.black,
              ),
              hintTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextInputFields(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter email";
                } else if (!value.isEmail) {
                  return "Please enter valid email";
                }
                return null;
              },
              controller: controller.schoolEmail,
              name: "School Email",
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your school email",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                color: Colors.black,
              ),
              hintTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),

            // Mobile Number
            TextInputFields(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter mobile number";
                }
                return null;
              },
              controller: controller.schoolMobileNo,
              name: "Mobile Number",
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter your mobile number",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                color: Colors.black,
              ),
              hintTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextInputFields(
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
              obSecureText: controller.showPassword,
              hintText: "**********",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
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
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextInputFields(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please confirm password";
                } else if (controller.password.text !=
                    controller.confirmPasswords.text) {
                  return "Passwords do not match";
                }
                return null;
              },
              controller: controller.confirmPasswords,
              name: "Confirm Password",
              filled: true,
              fillColor: Colors.white,
              obSecureText: controller.confirmPassword,
              hintText: "**********",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                  controller.onConfirmChangeShowPassword();
                },
                child: Icon(
                  controller.confirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
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
            ),
            const SizedBox(height: 16),

            // Terms and Conditions
            Obx(() => Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: Checkbox(
                        onChanged: (value) {
                          controller.isCheck.value = !controller.isCheck.value;
                        },
                        value: controller.isCheck.value,
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.black;
                            }
                            return Colors.white;
                          },
                        ),
                        checkColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "I accept the ",
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600),
                            ),
                            TextSpan(
                              text: "Terms and Conditions",
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 24),

            // Next Button
            Obx(
              () => controller.isLoginLoading.value
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
                        onPressed: controller.isCheck.value
                            ? () async {
                                if (controller.formKey.currentState!
                                    .validate()) {
                                  controller.isLoginLoading(true);
                                  await controller.onSignUp(
                                    phoneNo: controller.schoolMobileNo.text,
                                    email: controller.schoolEmail.text,
                                    fName: controller.firstName.text,
                                    lastName: controller.lastName.text,
                                    passwrod: controller.password.text,
                                  );
                                  controller.isLoginLoading(false);
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          "Next",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolInfoForm(RegisterController controller, bool isMobile) {
    return ScrollConfiguration(
      behavior:
          ScrollConfiguration.of(Get.context!).copyWith(scrollbars: false),
      child: Form(
        key: controller.formKeyTwo,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // School Name
            TextInputFields(
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter school name";
                }
                return null;
              },
              controller: controller.schoolName,
              name: "School Name",
              filled: true,
              fillColor: Colors.white,
              hintText: "Enter school name",
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                color: Colors.black,
              ),
              hintTextStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),

            // Role Selection
            Text(
              "Select Role",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            Obx(() => Column(
                  children: [
                    _buildRoleOption(
                      title: "Student",
                      icon: Icons.school_outlined,
                      value: RegisterRole.student,
                      groupValue: controller.selectedRole.value,
                      onChanged: (value) {
                        controller.selectedRole(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildRoleOption(
                      title: "Teacher",
                      icon: Icons.person_outline,
                      value: RegisterRole.teacher,
                      groupValue: controller.selectedRole.value,
                      onChanged: (value) {
                        controller.selectedRole(value);
                      },
                    ),
                  ],
                )),

            const SizedBox(height: 32),

            // Submit Button
            Obx(
              () => controller.isLoginLoading.value
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
                          if (controller.formKeyTwo.currentState!.validate()) {
                            controller.isLoginLoading(true);
                            await controller.userRoleUpdate(
                              role: controller.selectedRole.value ==
                                      RegisterRole.student
                                  ? "Student"
                                  : "Teacher",
                              userID: LocalStorage.getUserID() ?? "",
                            );
                            controller.isLoginLoading(false);
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
                          "Complete Registration",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String title,
    required IconData icon,
    required RegisterRole value,
    required RegisterRole? groupValue,
    required Function(RegisterRole?) onChanged,
  }) {
    bool isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.grey.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Radio<RegisterRole>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.black,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
