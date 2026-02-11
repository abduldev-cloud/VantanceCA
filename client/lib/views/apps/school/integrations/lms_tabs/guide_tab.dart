import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


class GuideTab extends StatelessWidget with UIMixin {
  GuideTab({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle headingStyle = GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );

    TextStyle bodyStyle = GoogleFonts.inter(
      fontSize: 14,
      color: Colors.black87,
      height: 1.5,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              Images.canvas,
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 20),
            Text("Canvas", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "Canvas is a Learning Management System that allows schools, teachers, and students to manage classes, assignments and grades.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text("Tool Name", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "Enter a recognizable name for this integration. For example: Canvas LMS or your institution's Canvas instance name.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text("Consumer Key", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "A unique key provided by your Canvas administrator. This is required for LTI (Learning Tools Interoperability) authentication.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text("Shared Secret", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "A secure password-like string provided alongside the Consumer Key. This is used to authenticate requests between Binary Success and Canvas.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text("Privacy", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "Set the privacy level for data sharing between Canvas and Binary Success. We recommend using the Name and Email Only option so student information is transmitted securely while maintaining essential functionality.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),
            Text("Configuration Type", style: headingStyle),
            const SizedBox(height: 4),
            Text("Manual", style: bodyStyle),
            const SizedBox(height: 16),
            Text("Domain/URL", style: headingStyle),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "The base URL of your Canvas instance. Example: ",
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    API.institutionUrl,
                    style: bodyStyle.copyWith(
                        color: contentTheme.onPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: contentTheme.onPrimary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Image.asset(
              Images.canvasGuideSs,
              height: 300.h,
            )
          ],
        ),
      ),
    );
  }
}
