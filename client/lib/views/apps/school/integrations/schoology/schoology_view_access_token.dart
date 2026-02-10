import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/helpers/utils/app_snakbar.dart';
import 'package:binary_success/helpers/utils/datetime_utils.dart';
import 'package:binary_success/helpers/widgets/app_button.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/widgets/edit_token_details.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/widgets/header_text.dart';
import 'package:binary_success/views/apps/school/integrations/schoology/schoology_new_connection.dart';
import 'package:binary_success/views/apps/school/widget/confirm_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SchoologyViewAccessToken extends StatefulWidget {
  const SchoologyViewAccessToken({super.key});

  @override
  State<SchoologyViewAccessToken> createState() =>
      _SchoologyViewAccessTokenState();
}

class _SchoologyViewAccessTokenState extends State<SchoologyViewAccessToken> {
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  bool addNewTokenView = false;
  bool editTokenView = false;
  bool viewTokenDetails = false;

  @override
  Widget build(BuildContext context) {
    return addNewTokenView
        ? SchoologyNewConnectionScreen(onPressedBack: () {
            setState(() => addNewTokenView = false);
          })
        : editTokenView
            ? EditTokenDetails(
                lmsIntegrationData: lmsController.integrationData.value!,
                onPressedBack: () {
                  setState(() {
                    viewTokenDetails = false;
                    editTokenView = false;
                  });
                },
                viewOnly: viewTokenDetails,
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeaderText(
                      title: "View Access Token - View Token Details",
                      subtitle:
                          "View your current access token for authentication and API integration",
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: Text('Name',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              flex: 2,
                              child: Text('Purpose',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              flex: 3,
                              child: Text('Consumer Key',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold))),
                          Expanded(
                              flex: 4,
                              child: Text('Date',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold))),
                          SizedBox(width: 60),
                        ],
                      ),
                    ),
                    Obx(() {
                      final connection = lmsController.integrationData.value;
                      if (connection == null) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text("No token found for this LMS."),
                        );
                      }
                      return buildTokenDetailsTile(
                        id: connection.id,
                        appName: connection.appName,
                        purpose: connection.purpose,
                        token: connection.apiKey ?? '',
                        expiry: connection.expiresAt == null
                            ? "Never"
                            : DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                DateTimeUtils.utcIsoToLocalDateTime(
                                    connection.expiresAt!.toIso8601String())!),
                        lastUsed: lmsController
                            .integrationMode.value?.lastIntegrationTimestamp,
                        onDelete: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return ConfirmDeleteDialog(
                                onConfirm: () {
                                  lmsController.deleteToken(connection.id);
                                  Get.offAndToNamed('/school/integrations');
                                },
                                token: connection.token,
                              );
                            },
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 32),
                    Obx(() {
                      final connection = lmsController.integrationData.value;
                      bool hasActiveToken = false;
                      if (connection != null) {
                        if (connection.expiresAt == null) {
                          hasActiveToken = true;
                        } else {
                          hasActiveToken = !DateTimeUtils.isTokenExpired(
                              connection.expiresAt!.toIso8601String());
                        }
                      }
                      return SizedBox(
                        width: 200,
                        child: AppButton(
                          title: 'New Access Token',
                          onTap: hasActiveToken
                              ? null
                              : () {
                                  setState(() => addNewTokenView = true);
                                },
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      );
                    }),
                  ],
                ),
              );
  }

  Widget buildTokenDetailsTile({
    required String id,
    required String appName,
    required String purpose,
    required String token,
    required dynamic expiry,
    required dynamic lastUsed,
    required VoidCallback onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(appName)),
          Expanded(flex: 2, child: Text(purpose)),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child:
                      Text(token, overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token));
                    appSnackbar(message: "Token copied to the clipboard");
                  },
                  icon: const Icon(Icons.copy, size: 16),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expires:  $expiry'),
                const SizedBox(height: 4),
                Text(
                    'Last Used:  ${DateTimeUtils.utcIsoToLocalDateTime(lastUsed)}'),
              ],
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    viewTokenDetails = true;
                    editTokenView = true;
                  });
                },
                child: Text('Details',
                    style: GoogleFonts.inter(color: Color(0xff004AAD))),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: lmsController.isSyncingData.value ||
                        lmsController.integrationData.value == null ||
                        lmsController
                                .integrationMode.value?.integrationStatus ==
                            "STARTED"
                    ? null
                    : () {
                        setState(() {
                          editTokenView = true;
                        });
                      },
                icon: const Icon(Icons.edit, size: 20),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: lmsController.isSyncingData.value ||
                        lmsController
                                .integrationMode.value?.integrationStatus ==
                            "STARTED"
                    ? null
                    : onDelete,
                icon: const Icon(Icons.delete_outline, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
