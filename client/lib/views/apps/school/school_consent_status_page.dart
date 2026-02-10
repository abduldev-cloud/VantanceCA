import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:binary_success/helpers/utils/ui_mixins.dart'; // Import mixin
import 'package:http/http.dart' as http;

class SchoolConsentController extends GetxController {
  var isLoginLoading = false.obs;
}

class SchoolConsentStatusPage extends StatefulWidget {
  final String? source;
  final String? sourceId;

  SchoolConsentStatusPage({super.key, this.source, this.sourceId});

  @override
  _SchoolConsentStatusPageState createState() =>
      _SchoolConsentStatusPageState();
}

class _SchoolConsentStatusPageState extends State<SchoolConsentStatusPage>
    with UIMixin {
  final controller = Get.put(SchoolConsentController());

  @override
  void initState() {
    super.initState();
    if (widget.source != null && widget.sourceId != null) {
      _postConsentAgree(widget.source!, widget.sourceId!);
    }
  }

  Future<void> _postConsentAgree(String source, String sourceId) async {
    try {
      controller.isLoginLoading(true);

      final url = Uri.parse(
        "${API.baseURl}/sync/consent-from-admin/agree?source=$source&source_id=$sourceId",
      );

      print("➡️ Posting to: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("✅ Consent recorded successfully!");
      } else {
        print("❌ Failed to record consent: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (e) {
      print("⚠️ Exception while posting consent agree: $e");
    } finally {
      controller.isLoginLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const String headline = "Great! Consent Approved";
    const String subtext =
        "You’ve given your consent. The invite mails will now be sent to the students in the attached list.";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: 640.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: const Color(0xffEEECFF),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.17),
                blurRadius: 28,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Message section
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 48.w, vertical: 44.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo
                      SizedBox(
                        width: 220.w,
                        height: 100.h,
                        child: Image.asset(
                          Images.logoIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Row with tick icon and headline
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: const Color(0xff32b153),
                            size: 32.w,
                          ),
                          SizedBox(width: 8.w),
                          Flexible(
                            child: MyText.bodyMedium(
                              headline,
                              style: GoogleFonts.inter(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff262931),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),
                      MyText.bodySmall(
                        subtext,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff565660),
                        ),
                      ),
                      SizedBox(height: 35.h),

                      // Reactive login button with loading indicator
                      Obx(() {
                        if (controller.isLoginLoading.value) {
                          return SizedBox(
                            height: 50.h,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          return Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 200.w,
                              height: 50.h,
                              child: InkWell(
                                onTap: () {
                                  controller.isLoginLoading(true);
                                  Future.delayed(const Duration(seconds: 1),
                                      () {
                                    controller.isLoginLoading(false);
                                    Get.toNamed('/auth/login');
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFc76be4),
                                        Color(0xFF004aad),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: MyText.bodyMedium(
                                    "Take me to Login",
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      }),
                    ],
                  ),
                ),
              ),

              // Mascot section
              Padding(
                padding: EdgeInsets.only(right: 44.w),
                child: SizedBox(
                  width: 280.w,
                  height: 280.w,
                  child: Image.asset(
                    Images.elephant,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
