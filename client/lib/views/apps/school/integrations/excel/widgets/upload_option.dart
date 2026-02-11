import 'package:vantanceCA/app_colors.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadOptionWidget extends StatelessWidget with UIMixin {
  final int optionNumber;
  final String title;
  final String description;
  final int groupValue;
  final ValueChanged<int?> onChanged;
  final VoidCallback onDownloadTemplate;

  UploadOptionWidget(
      {super.key,
      required this.optionNumber,
      required this.title,
      required this.description,
      required this.groupValue,
      required this.onChanged,
      required this.onDownloadTemplate});

  @override
  Widget build(BuildContext context) {
    bool isDisabled = groupValue == optionNumber || groupValue == 0;
    return Opacity(
      opacity: isDisabled ? 1.0 : 0.2,
      child: Column(
        children: [
          Row(
            children: [
              Radio<int>(
                value: optionNumber,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: Colors.black,
              ),
              const SizedBox(width: 10),
              MyText("Option $optionNumber"),
              const SizedBox(width: 10),
              MyText.titleMedium(
                title,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: contentTheme.k142228,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: "$description "),
                      TextSpan(
                        text: "Download the Template",
                        style: GoogleFonts.inter(color: AppColors.purple),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              groupValue == optionNumber || groupValue == 0
                                  ? onDownloadTemplate
                                  : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(),
        ],
      ),
    );
  }
}
