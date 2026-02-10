import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmGradeDialog extends StatefulWidget {
  final String grade;
  final int totalPoints;
  final VoidCallback onConfirm;

  const ConfirmGradeDialog({
    super.key,
    required this.grade,
    required this.totalPoints,
    required this.onConfirm,
  });

  @override
  State<ConfirmGradeDialog> createState() => _ConfirmGradeDialogState();
}

class _ConfirmGradeDialogState extends State<ConfirmGradeDialog> {
  bool isLoading = false;

  Future<void> _handleConfirm() async {
    setState(() {
      isLoading = true;
    });

    // Call the onConfirm callback (your API call)
    widget.onConfirm();

    // Note: You should call setState(() { isLoading = false; })
    // after your API completes in the parent widget or close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          constraints: const BoxConstraints(maxWidth: 500),
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 25.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Confirm Grade Submission",
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Are you sure you want to submit this grade ?",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15.h),

                  // Grade with gradient number + black total
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xff004AAD), Color(0xffCB6CE6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds),
                            child: Text(
                              widget.grade,
                              style: GoogleFonts.inter(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: "/${widget.totalPoints}",
                          style: GoogleFonts.inter(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 25.h),

                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Confirm (gradient)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: isLoading ? null : _handleConfirm,
                          child: Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 35.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.r),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xff004AAD),
                                    Color(0xffCB6CE6),
                                  ],
                                ),
                              ),
                              child: Text(
                                "Confirm",
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),

                      // Cancel (outlined, black text)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: isLoading ? null : () => Get.back(),
                          child: Opacity(
                            opacity: isLoading ? 0.6 : 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xff004AAD),
                                    Color(0xffCB6CE6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              padding: EdgeInsets.all(1.5),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 35.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xffCB6CE6),
                        ),
                        strokeWidth: 3,
                      ),
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
