import 'package:binary_success/controller/widgets/date_time_picker_controller.dart';
import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_spacing.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommonDatePicker extends StatelessWidget {
  final ContentTheme contentTheme;
  final String title;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final DateTimePickerController? controller;
  final String? selectedValue;

  const CommonDatePicker({
    super.key,
    required this.contentTheme,
    required this.title,
    this.selectedValue,
    this.onChanged,
    this.hintText,
    this.controller,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: contentTheme.primary,
              onPrimary: Colors.white,
              surface: contentTheme.background,
              onSurface: contentTheme.k142228,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('MMM dd, yyyy').format(picked);
      if (controller != null) {
        controller!.updateSelectedDate(formattedDate);
      }
      onChanged?.call(formattedDate);
    }
  }

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
          child: InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
              decoration: BoxDecoration(
                border: Border.all(color: contentTheme.kC5CAD1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final displayText = controller?.selectedDate.value.isNotEmpty == true
                        ? controller!.selectedDate.value
                        : (selectedValue ?? hintText ?? "Select Date");
                    
                    return MyText.labelMedium(
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: contentTheme.k142228,
                      ),
                      displayText,
                    );
                  }),
                  Icon(
                    LucideIcons.calendar,
                    size: 20.r,
                    color: contentTheme.k142228,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
