import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/models/school_support_model.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:vantanceCA/views/extra_pages/widgets/support_content_widgets.dart';

class AdminSupportViewPage extends StatelessWidget with UIMixin {
  final SupportModel ticket;

  // ❌ remove const because UIMixin adds instance fields
  AdminSupportViewPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 7, // ✅ keeps it aligned with sidebar
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Same title bar as AdminSupportTicketPage
          Padding(
            padding: EdgeInsets.only(
              right: MySpacing.fullWidth(context) * 0.04,
            ),
            child: CommanTitlebar(
              contentTheme: contentTheme,
              title: "Help - Support Ticket",
              subTitle: "Get quick, reliable support through our Help Desk.",
              buttonTitle: "", // ✅ required param, kept empty
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Ticket content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AdminSupportViewWidget(ticket: ticket),
            ),
          ),
        ],
      ),
    );
  }
}
