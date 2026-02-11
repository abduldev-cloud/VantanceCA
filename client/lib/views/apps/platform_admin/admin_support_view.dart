import 'package:vantanceCA/views/layouts/layout.dart';
import 'package:vantanceCA/models/platform_support_model.dart';
import 'package:vantanceCA/widgets/comman_titlebar.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'widget/admin_support_view_widget.dart';

class AdminSupportViewPage extends StatelessWidget with UIMixin {
  final SupportModel ticket;

  AdminSupportViewPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Layout(
      selectedPage: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              right: MySpacing.fullWidth(context) * 0.04,
            ),
            child: CommanTitlebar(
              contentTheme: contentTheme,
              title: "Support Ticket",
              subTitle: "Manage submitted support tickets",
              buttonTitle: "",

            ),
          ),

          const SizedBox(height: 20),

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
