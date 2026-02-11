import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LastSyncDatetime extends StatelessWidget with UIMixin{
  final String title;
  final String date;
  final String time;
  LastSyncDatetime({super.key, required this.date, required this.time, this.title = "Last Sync Date: "});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: contentTheme.k7E7E7E,
        ),
        children: [
          TextSpan(text: title),
          WidgetSpan(
            child: Icon(
              Icons.calendar_month_outlined,
              color: contentTheme.k7E7E7E,
              size: 15,
            ),
          ),
          WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(text: date),
          WidgetSpan(child: SizedBox(width: 10)),
          WidgetSpan(
            child: Icon(
              Icons.access_time,
              color: contentTheme.k7E7E7E,
              size: 15,
            ),
          ),
          WidgetSpan(child: SizedBox(width: 5)),
          TextSpan(text: time)
        ],
      ),
    );
  }
}
