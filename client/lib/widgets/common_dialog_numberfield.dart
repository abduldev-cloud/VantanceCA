import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonDialogNumberfield extends StatelessWidget {
  final String title;
  final String? hintText;
  final TextEditingController controller;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  
  const CommonDialogNumberfield({
    super.key,
    required this.title,
    required this.controller,
    this.hintText,
    this.maxLines,
    this.keyboardType = TextInputType.number,
    this.validator,
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
              color: Color(0xff142228),
            ),
            hintText: hintText ?? "",
            controller: controller,
            maxLine: maxLines ?? 1,
            keyboardType: keyboardType,
            validator: validator ?? _validateNumber,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
