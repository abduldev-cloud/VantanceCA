import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildMobileView() => Center(
      child: MyText.labelMedium(
        "Mobile view is not supported",
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20),
      ),
    );
