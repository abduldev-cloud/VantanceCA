import 'package:vantanceCA/views/apps/school/integrations/widgets/asset_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';

class AppButton extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final String? prefixIconPath;
  final double prefixIconSize;
  final double? fontSize;

  const AppButton(
      {super.key,
      required this.title,
      this.onTap,
      this.padding,
      this.isLoading = false,
      this.fontSize,
      this.prefixIconPath,
      this.prefixIconSize = 20});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        padding: padding,
        decoration: BoxDecoration(
            color: onTap != null ? null : Colors.black.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            gradient: onTap != null
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xffCB6CE6),
                      Color(0xff004AAD),
                    ],
                  )
                : null),
        child: !isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  prefixIconPath != null
                      ? AssetIcon(
                          icon: prefixIconPath ?? "",
                          color: Colors.white,
                          size: prefixIconSize.w, // responsive icon height
                        )
                      : SizedBox(),
                  prefixIconPath != null ? SizedBox(width: 5) : SizedBox(),
                  MyText.bodyMedium(
                    title,
                    style: GoogleFonts.inter(
                        fontSize: fontSize ?? 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  padding: EdgeInsets.all(5),
                ),
              ),
      ),
    );
  }
}
