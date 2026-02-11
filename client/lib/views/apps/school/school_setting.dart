import 'dart:convert';
import 'package:vantanceCA/controller/apps/setting_controller.dart';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/services/auth_services.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/utils/utils.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;
import 'package:vantanceCA/controller/change_password_controller.dart';
import 'package:vantanceCA/models/change_password_model.dart';

class SchoolSettingPage extends StatefulWidget {
  const SchoolSettingPage({super.key});

  @override
  SchoolSettingPageState createState() => SchoolSettingPageState();
}

class SchoolSettingPageState extends State<SchoolSettingPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late SettingController controller;
  late final Map<String, Function(BuildContext)> menuActions;

  String? plan;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SettingController());
    menuActions = {
      "Edit": (context) => print("Edit clicked"),
      "Change": (context) => print("Change clicked"),
      "View": (context) => _showSecurityPrivacyPopup(context),
      "Logout": (context) => print("Logout clicked"),
    };

    _loadPlan();
  }

  final isStudent = RoleUtils.isLearner;
  final isTeacher = RoleUtils.isTeacher;
  final isSchool = RoleUtils.isInstituteAdmin;
  final isPlatformAdmin = RoleUtils.isPlatformAdmin;

  Future<void> _loadPlan() async {
    final email = LocalStorage.getUserEmail();
    if (email == null) {
      setState(() {
        plan = "Unknown";
        loading = false;
      });
      return;
    }

    final url =
        "${API.baseURl}/killbill/user-plan?email=${Uri.encodeComponent(email)}";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          plan = data['plan'];
          loading = false;
        });
      } else {
        setState(() {
          plan = "Unknown";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        plan = "Error";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      shrinkContent: true,
      selectedPage: 4,
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 600;
              double padding = isMobile ? 20.0 : 40.0;

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: padding,
                  right: padding,
                  top: 0,
                  bottom: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium(
                      "Settings",
                      style: GoogleFonts.inter(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w600,
                        color: contentTheme.k142228,
                      ),
                    ),
                    30.verticalSpace,

                    // Profile Header Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.w, vertical: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        "Your Profile",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: contentTheme.k142228,
                        ),
                      ),
                    ),
                    20.verticalSpace,

                    if (isStudent || isTeacher) ...[
                      _buildSettingItem(
                        title: "Name",
                        subtitle: LocalStorage.getUserName() ?? "",
                        isMobile: isMobile,
                      ),
                      _buildSettingItem(
                        title: "Email",
                        subtitle: LocalStorage.getUserEmail() ?? "",
                        isMobile: isMobile,
                      ),
                      _buildSettingItem(
                        title: "Password",
                        actionLabel: "Change",
                        onTap: () {
                          showChangePasswordDialog(context);
                        },
                        isMobile: isMobile,
                      ),
                      _buildSettingItem(
                        title: "Plan & Subscription",
                        subtitle: loading
                            ? "Loading..."
                            : "${plan ?? "Unknown"} Plan",
                        actionLabel: "View",
                        onTap: () {
                          Navigator.pushNamed(context, '/school/billing');
                        },
                        isMobile: isMobile,
                      ),
                      _buildSettingItem(
                        title: "Security & Privacy",
                        actionLabel: "View",
                        onTap: () {
                          Get.toNamed('/school/security');
                        },
                        isMobile: isMobile,
                      ),
                    ],

                    // Logout Card
                    InkWell(
                      onTap: () async {
                        await AuthService.userSessionLogout({
                          "refresh_token": LocalStorage.getRefreshTokenn(),
                        });
                        await LocalStorage.erase();
                        Get.offAllNamed("/auth/login");
                      },
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.w, vertical: 20.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Text(
                          "Logout",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onTap,
    required bool isMobile,
  }) {
    // Shared content for Title/Subtitle
    final infoWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: contentTheme.k142228,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: contentTheme.k142228.withOpacity(0.7),
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ]
      ],
    );

    // Shared content for Action Button
    final actionWidget = (actionLabel != null && actionLabel.isNotEmpty)
        ? InkWell(
            borderRadius: BorderRadius.circular(30.r),
            onTap: onTap,
            child: Container(
              width: 100.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30.r),
              ),
              alignment: Alignment.center,
              child: Text(
                actionLabel,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoWidget,
                if (actionWidget != null) ...[
                  SizedBox(height: 12.h),
                  actionWidget,
                ]
              ],
            )
          : Row(
              children: [
                Expanded(child: infoWidget),
                if (actionWidget != null)
                  Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: actionWidget,
                  ),
              ],
            ),
    );
  }

  void _showSecurityPrivacyPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: 32.w,
            vertical: 48.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            width: 0.85.sw,
            height: 0.70.sh,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Security & Privacy",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: contentTheme.k142228,
                        ),
                      ),
                      8.verticalSpace,
                      Text(
                        "Explains how we protect user data and ensure a secure, trustworthy experience for everyone",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: contentTheme.k142228.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                      16.verticalSpace,
                      Divider(color: Colors.grey.shade300, thickness: 1),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 4,
                      radius: Radius.circular(12.r),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '''
At BinarySuccess, we are committed to safeguarding the privacy and security of all users, including students, teachers, and administrators. This policy explains how we collect, use, store, and protect personal information on our platform.

We collect only the information necessary to provide our educational services. This may include account details such as names, email addresses, school affiliations, and user roles; student-related data such as assignments, submissions, grades, and activity logs; device and usage data for security and analytics purposes; and integration data such as access tokens or keys for connected Learning Management Systems and third-party apps.

The information we collect is used to deliver and improve our platform, enable class and assignment management, track student progress, send notifications, ensure account security, and comply with legal and institutional requirements. We do not sell or share personal data with third parties for marketing purposes.

All user data is protected through encryption in transit and at rest, strict role-based access controls, and secure storage within our database. Our system undergoes regular security audits to ensure ongoing data protection and to prevent unauthorized access.

We are dedicated to protecting student information. Data is collected only with school authorization, and parents or guardians may request access or deletion of their child’s information through the school. Student data is never used for advertising or non-educational purposes.

We may update this policy from time to time, and any significant changes will be communicated to users and schools through the platform or via email. For any questions regarding this policy or our data protection practices, you can reach us at:
                            ''',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                                color: contentTheme.k142228,
                              ),
                            ),
                            10.verticalSpace,
                            GestureDetector(
                              onTap: () {
                                launchUrl(
                                    Uri.parse("mailto:devops.colakin@gma"));
                              },
                              child: Text(
                                "devops.colakin@gmail.com",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            20.verticalSpace,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          showDeleteAccountDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Delete My Account",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side:
                              BorderSide(color: contentTheme.k142228, width: 1),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                        ),
                        child: Text(
                          "Accept and Close",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.k142228,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 16,
            backgroundColor: Colors.white,
            child: SizedBox(
              width: 400,
              height: 330,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Delete My Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF191A47),
                      ),
                    ),
                    SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Are you sure you want to delete ',
                        style: TextStyle(
                            fontSize: 16, color: Colors.black54, height: 1.5),
                        children: [
                          TextSpan(
                              text: LocalStorage.getUserName() ?? "",
                              style: TextStyle(
                                color: Color(0xFFB3005E),
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFFAF0F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFFF1475C),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFF1475C),
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Warning',
                                    style: TextStyle(
                                        color: Color(0xFFF1475C),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "By deleting this account, you won't be able to access the Binary Success system.",
                                    style: TextStyle(
                                      color: Color(0xFF7A7D8B),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xff004AAD),
                                  Color(0xffCB6CE6),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                "No, Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: () async {
                              print("=== YES DELETE BUTTON CLICKED ===");
                              Navigator.of(context)
                                  .pop(); // Close the confirmation dialog

                              // Call API first
                              await _deleteAccountAndNavigate(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                            ),
                            child: Text(
                              "Yes, Delete",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

// Call this method from your DeleteAccountPage's initState
  Future<void> _deleteAccountAndNavigate(BuildContext context) async {
    print("=== _deleteAccountAndNavigate STARTED ===");

    final keycloakUserId = LocalStorage.getUserID();
    final dbUserId = LocalStorage.getDBUserID();

    print("keycloak_user_id: $keycloakUserId");
    print("user_id (DB): $dbUserId");

    if (keycloakUserId == null || dbUserId == null) {
      print("ERROR: User IDs are null");
      // Navigate anyway even if IDs are missing
      Get.toNamed('/delete/account');
      return;
    }

    try {
      final url = "${API.baseURl}/users/update-user-status";

      final payload = {
        'keycloak_user_id': keycloakUserId,
        'user_id': dbUserId,
        'status': 'archived',
        'updated_by': dbUserId,
      };

      print("=== API REQUEST ===");
      print("URL: $url");
      print("Payload: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print("=== API RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Navigate to success page regardless of API response
      print("Navigating to /delete/account");
      Get.toNamed('/delete/account');
    } catch (e) {
      print("=== EXCEPTION OCCURRED ===");
      print("Error: $e");

      // Navigate to success page even on error
      print("Navigating to /delete/account (after error)");
      Get.toNamed('/delete/account');
    }
  }

  Future<void> showChangePasswordDialog(BuildContext context) async {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final String userEmail = LocalStorage.getUserEmail() ?? "";

    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;

    void showSnackBar(String message, {required bool isError}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color(0xFF333333)
              : Colors.green, // Dark grey for error
          duration: const Duration(seconds: 3),
        ),
      );
    }

    Future<void> handlePasswordChange() async {
      String? validationError = PasswordChangeController.validatePasswords(
        newPasswordController.text,
        confirmPasswordController.text,
      );

      if (validationError != null) {
        showSnackBar(validationError, isError: true);
        return;
      }

      isLoading = true;

      try {
        final request = PasswordChangeRequest(
          email: userEmail,
          newPassword: newPasswordController.text,
        );

        final response = await PasswordChangeController.changePassword(request);

        isLoading = false;

        if (response.success) {
          Navigator.pop(context);
          showSnackBar(response.message, isError: false);
        } else {
          showSnackBar(response.message, isError: true);
        }
      } catch (e) {
        isLoading = false;
        showSnackBar('An unexpected error occurred', isError: true);
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              backgroundColor: Colors.white,
              child: Container(
                width: 420.w, // Increased width for better spacing
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Change Your Password",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Are you sure you want to change?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 25.h),

                    // New Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          text: "New Password",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: " *",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: newPasswordController,
                      obscureText: obscureNew,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: "**********",
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20.sp,
                            color: Colors.grey,
                          ),
                          onPressed: !isLoading
                              ? () {
                                  setState(() => obscureNew = !obscureNew);
                                }
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Confirm Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          text: "Confirm Password",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: " *",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirm,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: "**********",
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 14.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.black54),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20.sp,
                            color: Colors.grey,
                          ),
                          onPressed: !isLoading
                              ? () {
                                  setState(
                                      () => obscureConfirm = !obscureConfirm);
                                }
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    // Buttons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cancel Button
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(30.r),
                          child: Container(
                            width: 100.w,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFEBEBEB), // Light grey for cancel
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black, // darker grey text
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Confirm Button
                        InkWell(
                          onTap: isLoading
                              ? null
                              : () async {
                                  setState(() => isLoading = true);
                                  await handlePasswordChange();
                                  setState(() => isLoading = false);
                                },
                          borderRadius: BorderRadius.circular(30.r),
                          child: Container(
                            width: 100.w,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            alignment: Alignment.center,
                            child: isLoading
                                ? SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Confirm",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
