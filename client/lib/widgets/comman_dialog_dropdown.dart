import 'package:binary_success/controller/widgets/common_dialog_dropdown_controller.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/helpers/widgets/my_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommonDialogDropdown extends StatelessWidget {
  final ContentTheme contentTheme;
  final String title;
  // final String selectedValue;
  final List<String> itemList;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final Widget? prefixIcon;
  final CommonDialogDropdownController? controller;
  final String? selectedValue;

  const CommonDialogDropdown({
    super.key,
    required this.contentTheme,
    required this.title,
    required this.itemList,
    required this.selectedValue,
    this.onChanged,
    this.hintText,
    this.prefixIcon,
    this.controller,
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
              color: contentTheme.k142228,
            ),
          ),
        ),
        15.horizontalSpace,
        Expanded(
          child: DropdownButtonFormField<String>(
            onChanged: onChanged, // ✅ PASS CALLBACK
            initialValue: selectedValue,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: contentTheme.k142228,
            ),
            dropdownColor: contentTheme.background,
            menuMaxHeight: 200.h,
            padding: EdgeInsets.zero,
            items: itemList
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: MyText.labelMedium(
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          color: contentTheme.k142228,
                        ),
                        item,
                      ),
                    ))
                .toList(),
            icon: Icon(
              LucideIcons.chevronDown,
              size: 20.r,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText ?? "",
              hintStyle: MyTextStyle.bodySmall(xMuted: true),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: contentTheme.kC5CAD1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: contentTheme.kC5CAD1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: contentTheme.kC5CAD1),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
              isCollapsed: true,
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
        ),
      ],
    );
  }
}
