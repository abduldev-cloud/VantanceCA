import 'package:vantanceCA/controller/apps/school/lms_integration_controller.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:vantanceCA/helpers/utils/app_snakbar.dart';
import 'package:vantanceCA/helpers/utils/datetime_utils.dart';
import 'package:vantanceCA/helpers/utils/ui_mixins.dart';
import 'package:vantanceCA/helpers/widgets/app_button.dart';
import 'package:vantanceCA/helpers/widgets/my_text.dart';
import 'package:vantanceCA/views/apps/school/integrations/lms_tabs/widgets/header_text.dart';
import 'package:vantanceCA/views/apps/school/widget/loader_dialog.dart';
import 'package:vantanceCA/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class ConnectionInputScreen extends StatefulWidget {
  final VoidCallback? onPressedBack;
  const ConnectionInputScreen({super.key, this.onPressedBack});

  @override
  State<ConnectionInputScreen> createState() => _ConnectionInputScreenState();
}

class _ConnectionInputScreenState extends State<ConnectionInputScreen>
    with UIMixin {
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  Future<void> refreshToken() async {
    if (lmsController.platform.value.isEmpty) {
      lmsController.platform.value =
          "Canvas"; // or "Schoology" depending on context
    }

    await lmsController.fetchConnectionStatus(lmsController.platform.value);
    lmsController.update();
  }

  String token = "";
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController expirationTimeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    tokenController.addListener(_onFormChanged);
    appNameController.addListener(_onFormChanged);
    purposeController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    return tokenController.text.isNotEmpty &&
        appNameController.text.isNotEmpty &&
        purposeController.text.isNotEmpty;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      expirationDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();

      // Parse selected date from expirationDateController (if any)
      DateTime selectedDate;
      if (expirationDateController.text.isNotEmpty) {
        selectedDate =
            DateFormat('yyyy-MM-dd').parse(expirationDateController.text);
      } else {
        selectedDate = DateTime(now.year, now.month, now.day); // default: today
      }

      final selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        picked.hour,
        picked.minute,
      );

      // 🚨 Check only if selected date is today or no date chosen
      if (selectedDate
              .isAtSameMomentAs(DateTime(now.year, now.month, now.day)) ||
          selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
        if (selectedDateTime.isBefore(now)) {
          appSnackbar(
            message: "You cannot select a past time",
            snackbarState: SnackbarState.danger,
          );
          return;
        }
      }

      // ✅ Valid time → format to backend format with microseconds
      final formattedTime =
          DateFormat('HH:mm:ss.SSSSSS').format(selectedDateTime);
      expirationTimeController.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (widget.onPressedBack != null)
                  GestureDetector(
                    onTap: widget.onPressedBack,
                    child: Icon(Icons.arrow_back),
                  ),
                if (widget.onPressedBack != null) SizedBox(width: 20),
                HeaderText(
                    title: "Add New Token",
                    subtitle:
                        "Connect your Canvas LMS account by adding a valid access token"),
              ],
            ),
            SizedBox(height: 20),
            _buildInputField(
              label: "Name",
              controller: appNameController,
            ),
            _buildInputField(
              label: "Purpose",
              controller: purposeController,
            ),
            _buildInputField(
              label: "Canvas API Token",
              hintText: "Canvas API Token",
              controller: tokenController,
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Expiration date",
                    controller: expirationDateController,
                    readOnly: true,
                    suffixIcon: Icons.calendar_today_outlined,
                    onSuffixTap: _selectDate,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildInputField(
                    label: "Expiration time",
                    controller: expirationTimeController,
                    readOnly: true,
                    suffixIcon: Icons.access_time_outlined,
                    onSuffixTap: _selectTime,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            MyText.labelSmall(
              "Leave the expiration fields blank for no expiration.",
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: 150.w,
              child: AppButton(
                title: "Submit",
                onTap: _isFormValid
                    ? () async {
                        if (expirationDateController.text.isNotEmpty &&
                            expirationTimeController.text.isNotEmpty) {
                          final selectedDate = DateFormat('yyyy-MM-dd')
                              .parse(expirationDateController.text);
                          final selectedDateTime = DateFormat('HH:mm:ss.SSSSSS')
                              .parse(expirationTimeController.text);

                          final combined = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedDateTime.hour,
                            selectedDateTime.minute,
                            selectedDateTime.second,
                            selectedDateTime.millisecond,
                            selectedDateTime.microsecond,
                          );

                          if (combined.isBefore(DateTime.now())) {
                            appSnackbar(
                              message: "You cannot select a past date/time",
                              snackbarState: SnackbarState.danger,
                            );
                            return;
                          }
                        }
                        // Validate both fields if one is selected
                        if ((expirationDateController.text.isNotEmpty &&
                                expirationTimeController.text.isEmpty) ||
                            (expirationTimeController.text.isNotEmpty &&
                                expirationDateController.text.isEmpty)) {
                          appSnackbar(
                            message: "Please select both expiry date and time",
                            snackbarState: SnackbarState.danger,
                          );
                          return;
                        }

                        final String? expiresAt =
                            DateTimeUtils.combineDateTimeToUtcIso(
                          dateStr: expirationDateController.text,
                          timeStr: expirationTimeController.text,
                        );

                        final String? dbUserId = LocalStorage.getDBUserID();
                        lmsController.platform.value = "Canvas"; // or "Canvas"

                        final Map<String, dynamic> payload = {
                          "school_admin_id": dbUserId ?? "",
                          "token": tokenController.text,
                          "purpose": purposeController.text,
                          "app_name": appNameController.text,
                          "platform": lmsController
                              .platform.value, // dynamic platform value
                          "expires_at": expiresAt,
                        };

                        final future = lmsController.connectLms(payload);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return LoaderDialog(
                              title:
                                  "Authenticating your Canvas LMS token…\nThis may take a few moments.",
                              terminatingFuture: future,
                              onSuccess: widget.onPressedBack,
                            );
                          },
                        );
                      }
                    : null,
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    String? hintText,
    required TextEditingController controller,
    bool readOnly = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        MyText.titleMedium(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: contentTheme.k142228,
          ),
        ),
        SizedBox(height: 5),
        TextInputFields(
          hintText: hintText,
          controller: controller,
          readOnly: readOnly,
          suffixWidget: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, size: 20),
                  onPressed: onSuffixTap,
                )
              : null,
        ),
      ],
    );
  }
}
