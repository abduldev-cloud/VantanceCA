import 'package:vantanceCA/controller/widgets/date_time_picker_controller.dart';
import 'package:vantanceCA/helpers/theme/admin_theme.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommonTimePicker extends StatelessWidget {
  final ContentTheme contentTheme;
  final String title;
  final String? hintText;
  final ValueChanged<String?>? onChanged;
  final DateTimePickerController? controller;
  final String? selectedValue;

  const CommonTimePicker({
    super.key,
    required this.contentTheme,
    required this.title,
    this.selectedValue,
    this.onChanged,
    this.hintText,
    this.controller,
  });

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      final formattedTime = DateFormat('hh:mm a').format(dt);
      
      if (controller != null) {
        controller!.updateSelectedTime(formattedTime);
      }
      onChanged?.call(formattedTime);
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
            onTap: () => _selectTime(context),
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
                    final displayText = controller?.selectedTime.value.isNotEmpty == true
                        ? controller!.selectedTime.value
                        : (selectedValue ?? hintText ?? "Select Time");
                    
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
                    LucideIcons.clock,
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
