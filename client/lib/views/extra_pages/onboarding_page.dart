import 'package:binary_success/controller/error_pages/onboarding_controller.dart';
import 'package:binary_success/views/apps/school/billing_page.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/app_button.dart';
import 'package:binary_success/helpers/widgets/my_responsiv.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/helpers/widgets/not_supportable.dart';
import 'package:binary_success/images.dart';
import 'package:binary_success/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatefulWidget {
  final String persona; // school, teacher, student, admin
  const OnboardingPage({super.key, required this.persona});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late OnboardingController controller;

  final personaConfig = {
    "school": {
      "title": "School Onboarding",
      "welcome": "Welcome to the School Onboarding",
      "detailsLabel": "School Details",
      "image": Images.elephant
    },
    "teacher": {
      "title": "Teacher Onboarding",
      "welcome": "Welcome to the Teacher Onboarding",
      "detailsLabel": "Class Details",
      "image": Images.elephant
    },
    "student": {
      "title": "Student Onboarding",
      "welcome": "Welcome to the Student Onboarding",
      "detailsLabel": "Classroom Info",
      "image": Images.elephant
    },
    "admin": {
      "title": "Admin Onboarding",
      "welcome": "Welcome to Binary Success Administration",
      "detailsLabel": "Institute Details",
      "image": Images.elephant
    }
  };

  @override
  void initState() {
    super.initState();
    controller = Get.put(OnboardingController(persona: widget.persona));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final inviteCode = Get.parameters['invite_code'];
      if (inviteCode == null) {
        Get.snackbar("Error", "Invite code is required for onboarding");
        Get.offAllNamed('/auth/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = personaConfig[widget.persona] ?? personaConfig["school"]!;

    return Scaffold(
      body: MyResponsive(
        builder: (context, _, screenMT) =>
            (screenMT.isMobile || screenMT.isTablet)
                ? buildMobileView()
                : _buildDesktopView(config),
      ),
    );
  }

  Widget _buildDesktopView(Map<String, dynamic> config) {
    return GetBuilder<OnboardingController>(
      init: controller,
      builder: (_) {
        final entityData = controller.partialSchoolModel.value?.toMap() ?? {};

        return Align(
          child: AutofillGroup(
            child: Form(
              key: controller.formKey,
              child: Container(
                width: MySpacing.fullWidth(context) * 0.70,
                padding: MySpacing.symmetric(
                  horizontal: MySpacing.fullWidth(context) * 0.07,
                  vertical: MySpacing.fullHeight(context) * 0.05,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffEEECFF),
                      Color(0xffEEECFF),
                      Color(0xffDBEBFF)
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFormSection(config, entityData),
                    const Spacer(),
                    Image.asset(config["image"],
                        fit: BoxFit.cover,
                        height: MySpacing.fullWidth(context) * 0.20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection(
      Map<String, dynamic> config, Map<String, String> entityData) {
    return SizedBox(
      width: MySpacing.fullWidth(context) * 0.3,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(child: _buildTitle(config["title"])),
            MySpacing.height(7),
            Align(child: _buildSubtitle(config["welcome"])),
            35.verticalSpace,
            MyText.bodyMedium(config["detailsLabel"],
                style: _sectionTitleStyle),
            15.verticalSpace,
            _buildDetailsList(entityData),
            20.verticalSpace,
            _buildPersonalDetailsFields(),
            25.verticalSpace,
            Obx(() => controller.isAcceptLoading.value
                ? const CircularProgressIndicator()
                : _buildSubmitButton())
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String text) => MyText.bodyMedium(
        text,
        style: GoogleFonts.inter(
          fontSize: 30.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.02,
          color: contentTheme.k030303,
        ),
      );

  Widget _buildSubtitle(String text) => MyText.bodySmall(
        text,
        style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: contentTheme.k636364),
      );

  TextStyle get _sectionTitleStyle =>
      GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600);

  Widget _buildDetailsList(Map<String, String> data) {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    } else if (data.isEmpty) {
      return MyText.bodySmall(
        "No details available",
        style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: contentTheme.k636364),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: data.length,
        itemBuilder: (_, index) {
          final key = data.keys.elementAt(index);
          if (data[key]!.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: MyText.bodySmall(
                    "$key:",
                    style: _detailsLabelStyle,
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  flex: 5,
                  child: MyText.bodySmall(
                    data[key]!,
                    style: _detailsValueStyle,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  TextStyle get _detailsLabelStyle => GoogleFonts.inter(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: contentTheme.k636364);
  TextStyle get _detailsValueStyle =>
      GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500);

  Widget _buildPersonalDetailsFields() {
    return Column(
      children: [
        if (controller.isReadOnly.value == false) ...[
          _buildTextInput(
              "First Name", controller.firstName, "Please enter first name"),
          20.verticalSpace,
          _buildTextInput(
              "Last Name", controller.lastName, "Please enter last name"),
          20.verticalSpace,
        ],
        _buildPasswordInput(),
      ],
    );
  }

  Widget _buildTextInput(
    String label,
    TextEditingController ctrl,
    String validatorMsg,
  ) {
    return SizedBox(
      width: MySpacing.fullWidth(context) * 0.20,
      child: TextInputFields(
        validator: (value) => value!.isEmpty ? validatorMsg : null,
        controller: ctrl,
        name: label,
        filled: true,
        hintText: "Enter your $label".toLowerCase(),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return SizedBox(
      width: MySpacing.fullWidth(context) * 0.20,
      child: TextInputFields(
        autofillHints: const [AutofillHints.password],
        validator: (value) => value!.isEmpty ? "Please enter password" : null,
        controller: controller.password,
        name: "Password",
        suffixWidget: InkWell(
          onTap: controller.onChangeShowPassword,
          child: Icon(
            controller.showPassword
                ? Icons.remove_red_eye_rounded
                : Icons.remove_red_eye_outlined,
            color: contentTheme.k181818,
          ).paddingOnly(right: 20.w),
        ),
        filled: true,
        obSecureText: !controller.showPassword,
        hintText: "**********",
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: MySpacing.fullWidth(context) * 0.20,
      child: AppButton(
        title: "Complete Onboarding",
        onTap: () async {
          if (controller.formKey.currentState!.validate()) {
            controller.saveTemporaryUserDetails();

            if (widget.persona == "school") {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BillingPage(isOnboarding: true),
                ),
              );

              if (result == 'success') {
                await controller.acceptInvite();
              } else if (result == 'fail') {
                Get.snackbar("Payment Failed",
                    "Please try again to complete onboarding");
              }
            } else {
              await controller.acceptInvite();
            }
          }
        },
      ),
    );
  }
}
