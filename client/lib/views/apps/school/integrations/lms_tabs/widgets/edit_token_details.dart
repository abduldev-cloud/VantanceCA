import 'package:binary_success/controller/apps/school/lms_integration_controller.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:binary_success/helpers/utils/app_snakbar.dart';
import 'package:binary_success/helpers/utils/datetime_utils.dart';
import 'package:binary_success/helpers/widgets/app_button.dart';
import 'package:binary_success/helpers/widgets/my_text.dart';
import 'package:binary_success/models/lms_integration_model.dart';
import 'package:binary_success/views/apps/school/integrations/lms_tabs/widgets/header_text.dart';
import 'package:binary_success/views/apps/school/widget/loader_dialog.dart';
import 'package:binary_success/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EditTokenDetails extends StatefulWidget {
  final LmsIntegrationData lmsIntegrationData;
  final VoidCallback onPressedBack;
  final bool viewOnly;

  EditTokenDetails(
      {super.key,
      required this.lmsIntegrationData,
      required this.onPressedBack,
      this.viewOnly = false});

  @override
  State<EditTokenDetails> createState() => _EditTokenDetailsState();
}

class _EditTokenDetailsState extends State<EditTokenDetails> {
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController createdAtController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  bool isFormChanged = false;
  bool isCanvas = true;

  @override
  void initState() {
    if (widget.lmsIntegrationData.token == "") {
      isCanvas = false;
    }
    final DateTime? expiresAt = widget.lmsIntegrationData.expiresAt;
    tokenController.text = isCanvas
        ? widget.lmsIntegrationData.token ?? ""
        : widget.lmsIntegrationData.apiKey ?? "";
    appNameController.text = widget.lmsIntegrationData.appName;
    purposeController.text = widget.lmsIntegrationData.purpose;
    createdAtController.text = widget.lmsIntegrationData.createdAt.toString();
    expiryDateController.text = expiresAt == null
        ? ""
        : DateTimeUtils.utcIsoToLocalDateTime(expiresAt.toIso8601String())
                ?.toIso8601String() ??
            "";

    // Add listeners to check for changes
    appNameController.addListener(_checkFormChanged);
    purposeController.addListener(_checkFormChanged);
    expiryDateController.addListener(_checkFormChanged);

    super.initState();
  }

  void _checkFormChanged() {
    final originalAppName = (widget.lmsIntegrationData.appName ?? "").trim();
    final originalPurpose = (widget.lmsIntegrationData.purpose ?? "").trim();
    final originalExpiry =
        widget.lmsIntegrationData.expiresAt?.toString().trim() ?? "";

    final changed = appNameController.text.trim() != originalAppName ||
        purposeController.text.trim() != originalPurpose ||
        expiryDateController.text.trim() != originalExpiry;

    if (changed != isFormChanged) {
      setState(() {
        isFormChanged = changed;
      });
    }
  }

  @override
  void dispose() {
    tokenController.dispose();
    appNameController.dispose();
    purposeController.dispose();
    createdAtController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            BackButton(
              onPressed: widget.onPressedBack,
            ),
            SizedBox(width: 10),
            HeaderText(
              title: isCanvas
                  ? "${widget.viewOnly ? "View" : "Edit"} Token Details - Access Token Details"
                  : "${widget.viewOnly ? "View" : "Edit"} Consumer Key Details",
              subtitle: isCanvas
                  ? "Manage the authentication token required to connect with Canvas LMS to ensure continued integration."
                  : "Update the consumer key for your account, used for authentication and API integration.",
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildInputField(
          title: "Name",
          controller: appNameController,
          textOnly: widget.viewOnly,
        ),
        _buildInputField(
          title: "Purpose",
          controller: purposeController,
          textOnly: widget.viewOnly,
        ),
        _buildInputField(
          title: isCanvas ? "Token" : "Consumer Key",
          textOnly: true,
          controller: tokenController,
        ),
        _buildInputField(
          title: "last used ",
          readOnly: true,
          controller: createdAtController,
          suffixIcon: Icons.calendar_month_rounded,
          textOnly: widget.viewOnly,
        ),
        _buildInputField(
          title: "Expiry Date",
          controller: expiryDateController,
          suffixIcon: Icons.calendar_month_rounded,
          readOnly: true,
          textOnly: widget.viewOnly,
          onSuffixTap: widget.viewOnly
              ? null
              : () async {
                  final DateTime now = DateTime.now();

                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (pickedTime != null) {
                      final DateTime selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );

                      if (pickedDate.isAtSameMomentAs(
                              DateTime(now.year, now.month, now.day)) ||
                          pickedDate.isBefore(
                              DateTime(now.year, now.month, now.day))) {
                        if (selectedDateTime.isBefore(now)) {
                          appSnackbar(
                            message: "You cannot select past time",
                            snackbarState: SnackbarState.danger,
                          );
                          return;
                        }
                      }

                      setState(() {
                        expiryDateController.text = selectedDateTime.toString();
                        _checkFormChanged();
                      });
                    }
                  }
                },
        ),
        SizedBox(height: 20),
        if (!widget.viewOnly)
          SizedBox(
            width: 100,
            child: AppButton(
              title: "Submit",
              onTap: isFormChanged
                  ? () {
                      final String expiresAt = DateTimeUtils.localIsoToUtcIso(
                              expiryDateController.text) ??
                          "";
                      print("EXPIRES AT = $expiresAt");

                      final existing = widget.lmsIntegrationData;

                      final Map<String, dynamic> updateData = {
                        "app_name": appNameController.text,
                        "purpose": purposeController.text,
                        "expiry_date": expiresAt,
                        "middleware_id": existing.id,
                        "school_admin_id": LocalStorage.getDBUserID(),
                        "platform": existing.platform,
                        "token": existing.token,
                        "api_key": existing.apiKey,
                        "api_secret": existing.apiSecret,
                      };

                      final terminatingFuture =
                          lmsController.updateTokenDetails(
                        middlewareId: existing.id,
                        data: updateData,
                      );

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return LoaderDialog(
                            title:
                                "Updating Token Details\nThis may take a while",
                            terminatingFuture: terminatingFuture,
                          );
                        },
                      );

                      setState(() {
                        isFormChanged = false;
                      });
                    }
                  : null,
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required String title,
    bool readOnly = false,
    required TextEditingController controller,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool textOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 220.w,
            child: MyText(
              title,
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          textOnly
              ? Flexible(
                  child: MyText(
                    controller.text,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Expanded(
                  child: TextInputFields(
                    controller: controller,
                    readOnly: readOnly,
                    suffixWidget: suffixIcon != null
                        ? IconButton(
                            icon: Icon(
                              suffixIcon,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: onSuffixTap,
                          )
                        : null,
                  ),
                ),
        ],
      ),
    );
  }
}
