import 'package:binary_success/helpers/theme/admin_theme.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CommanPopupmenu extends StatelessWidget {
  final ContentTheme contentTheme;
  final List<dynamic> list;
  final String title;
  final ValueChanged<String?>? onChanged;

  const CommanPopupmenu(
      {super.key,
      required this.contentTheme,
      required this.list,
      required this.title,
      this.onChanged,
      });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        onSelected: (value) {
          if (onChanged != null) {
            onChanged!(value.toString());
          }
        },
        itemBuilder: (BuildContext context) {
          return list.map((behavior) {
            return PopupMenuItem(
              value: behavior.toString(),
              height: 32,
              child: MyText.bodySmall(
                behavior,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: contentTheme.darkPurple,
                ),
              ),
            );
          }).toList();
        },
        color: contentTheme.background,
        child: Row(
          children: [
            Text.rich(TextSpan(children: [
              TextSpan(
                text: title,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: contentTheme.darkPurple,
                ),
              )
            ])),
            5.horizontalSpace,
            Icon(
              Icons.keyboard_arrow_down_sharp,
              color: contentTheme.k3D3C42,
              size: 14.r,
            )
          ],
        ));
  }
}
