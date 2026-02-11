import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
// Just in case, though unused here

class SchoolSecurityPrivacyPage extends StatefulWidget {
  const SchoolSecurityPrivacyPage({super.key});

  @override
  State<SchoolSecurityPrivacyPage> createState() =>
      _SchoolSecurityPrivacyPageState();
}

class _SchoolSecurityPrivacyPageState extends State<SchoolSecurityPrivacyPage>
    with UIMixin {
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: const Color(0xFFF9F9F9),
          child: Container(
            width: 500, // Matched width from student dialog
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Delete My Account",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2040),
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2040),
                    ),
                    children: [
                      const TextSpan(text: "Are you sure you want to delete "),
                      TextSpan(
                        text: LocalStorage.getUserName() ?? "",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[500]),
                      ),
                      const TextSpan(text: "?"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Warning Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 60,
                        margin: const EdgeInsets.only(right: 12),
                        color: const Color(0xFFFF9933),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: Color(0xFFFF9933), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Warning",
                                  style: GoogleFonts.inter(
                                      color: const Color(0xFFFF9933),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "By deleting this account, you won't be able to access the Binary Success system.",
                              style: GoogleFonts.inter(
                                  color: const Color(0xFFFF9933),
                                  fontSize: 13,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E0E0),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        elevation: 0,
                      ),
                      child: Text(
                        "No, Cancel",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _deleteAccountAndNavigate();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                      ),
                      child: Text(
                        "Yes, Delete",
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
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
  }

  Future<void> _deleteAccountAndNavigate() async {
    print("----------------------------------------------------------------");
    print("SUCCESS! The 'Yes, Delete' button was clicked in the popup.");
    print("Actual deletion is disabled for testing purposes.");
    print("----------------------------------------------------------------");
    return;

    /* RE-ENABLE THIS AFTER VERIFICATION
    final keycloakUserId = LocalStorage.getUserID();
    final dbUserId = LocalStorage.getDBUserID();

    if (keycloakUserId == null || dbUserId == null) {
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

      await http.post(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      Get.toNamed('/delete/account');
    } catch (e) {
      Get.toNamed('/delete/account');
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      shrinkContent: true,
      selectedPage: 4, // Assuming Settings index is 4
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              top: 20.h,
              bottom: MySpacing.fullHeight(context) * 0.05,
              left: 20.w,
              right: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  MyText.titleMedium(
                    "Settings",
                    style: GoogleFonts.inter(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.k142228,
                    ),
                  ),
                ],
              ),
              30.verticalSpace,

              // Content Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Security & Privacy",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Explains how we protect user data and ensure a secure, trustworthy experience for everyone",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Long text
                    Text(
                      """At BinarySuccess, we are committed to safeguarding the privacy and security of all users, including students, teachers, and administrators. This policy explains how we collect, use, store, and protect personal information on our platform.

We collect only the information necessary to provide our educational services. This may include account details such as names, email addresses, school affiliations, and user roles; student-related data such as assignments, submissions, grades, and activity logs; device and usage data for security and analytics purposes; and integration data such as access tokens or keys for connected Learning Management Systems and third-party apps.

The information we collect is used to deliver and improve our platform, enable class and assignment management, track student progress, send notifications, ensure account security, and comply with legal and institutional requirements. We do not sell or share personal data with third parties for marketing purposes.

All user data is protected through encryption in transit and at rest, strict role-based access controls, and secure storage within our database. Our system undergoes regular security audits to ensure ongoing data protection and to prevent unauthorized access.

We are dedicated to protecting student information. Data is collected only with school authorization, and parents or guardians may request access or deletion of their child’s information through the school. Student data is never used for advertising or non-educational purposes.""",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        height: 1.6,
                        color: Colors.grey.shade800,
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // Buttons
                    LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 600;
                        return isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: _showDeleteAccountDialog,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w, vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "Delete My Account",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      foregroundColor: Colors.black87,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w, vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                    ),
                                    child: Text(
                                      "Accept and Close",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _showDeleteAccountDialog,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w, vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "Delete My Account",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.grey.shade200,
                                      foregroundColor: Colors.black87,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w, vertical: 16.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.r),
                                      ),
                                    ),
                                    child: Text(
                                      "Accept and Close",
                                      style: GoogleFonts.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
