import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';


class CommonDialogTextfield extends StatelessWidget {
  final String title;
  final String? hintText;
  final TextEditingController controller;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

  const CommonDialogTextfield(
      {super.key,
      required this.title,
      required this.controller,
      this.hintText,
      this.maxLines,
      this.inputFormatters, 
      });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: MySpacing.fullWidth(context) * 0.08,
          child: MyText.bodySmall(
            title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xff142228),
            ),
          ),
        ),
        15.horizontalSpace,
        Expanded(
            child: TextInputFields(
          textStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xff142228)),
          hintText: hintText ?? "",
          controller: controller,
          inputFormatters: inputFormatters,
          maxLine: maxLines ?? 1,
        )),
      ],
    );
  }
}
