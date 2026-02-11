import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/images.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SchoologyGuideTab extends StatelessWidget with UIMixin {
  SchoologyGuideTab({super.key});

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
              Images.schoology, // <-- add Schoology logo in assets
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 20),
            Text("Schoology", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "Schoology is a Learning Management System that enables schools, teachers, and students to manage classes, assignments, and grades effectively.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),

            Text("Tool Name", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "Enter a recognizable name for this integration. Example: Schoology LMS or your institution’s Schoology instance name.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),

            Text("Consumer Key", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "A unique key provided by your Schoology administrator. This is required for LTI (Learning Tools Interoperability) authentication.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),

            Text("Shared Secret", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "A secure password-like string provided alongside the Consumer Key. This is used to authenticate requests between Binary Success and Schoology.",
              style: bodyStyle,
            ),
            const SizedBox(height: 16),

            Text("Privacy", style: headingStyle),
            const SizedBox(height: 4),
            Text(
              "Set the privacy level for data sharing between Schoology and Binary Success. We recommend using the Name and Email Only option so student information is shared securely.",
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
                Text("The base URL of your Schoology instance. Example: "),
                InkWell(
                  onTap: () {},
                  child: Text(
                    API.schoologyUrl,
                    style: bodyStyle.copyWith(
                      color: contentTheme.onPrimary,
                      decoration: TextDecoration.underline,
                      decorationColor: contentTheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Image.asset(
            //   Images.arrow, // <-- add screenshot for Schoology guide
            //   height: 300.h,
            // ),
          ],
        ),
      ),
    );
  }
}
