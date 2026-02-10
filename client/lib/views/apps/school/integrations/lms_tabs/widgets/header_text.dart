import 'package:binary_success/helpers/utils/ui_mixins.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderText extends StatelessWidget with UIMixin {
  final String title, subtitle;
  final CrossAxisAlignment alignment;
  HeaderText({super.key, required this.title, required this.subtitle, this.alignment = CrossAxisAlignment.start});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        MyText.titleMedium(
          title,
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: contentTheme.k142228,
          ),
        ),
        MyText.titleMedium(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: contentTheme.k142228,
          ),
        )
      ],
    );
  }
}
