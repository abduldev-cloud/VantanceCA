import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CommanTitlebar extends StatelessWidget {
  final ContentTheme contentTheme;
  final Function()? onTap;
  final String title;
  final String subTitle;
  final String? buttonTitle; // ✅ make it optional (nullable)

  const CommanTitlebar({
    super.key,
    required this.contentTheme,
    this.onTap,
    required this.title,
    required this.subTitle,
    this.buttonTitle, // ✅ optional now
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleMedium(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: contentTheme.k142228,
                ),
              ),
              MyText.bodySmall(
                subTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: contentTheme.k142228,
                ),
              ),
            ],
          ),
        ),

        // ✅ Action Button (only shown if buttonTitle is provided & not empty)
        if (buttonTitle != null && buttonTitle!.isNotEmpty)
          InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.r),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xff004AAD),
                    Color(0xffCB6CE6),
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: contentTheme.kFEFDFF, size: 20.r),
                  15.horizontalSpace,
                  Text(
                    buttonTitle!,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: contentTheme.kFEFDFF,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
