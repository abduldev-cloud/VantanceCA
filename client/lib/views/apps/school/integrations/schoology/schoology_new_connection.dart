import 'package:vantanceCA/controller/apps/school/lms_integration_controller.dart';
import 'package:vantanceCA/helpers/utils/datetime_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../helpers/storage/local_storage.dart';
import '../../../../../helpers/utils/ui_mixins.dart';
import '../../../../../helpers/widgets/app_button.dart';
import '../../../../../helpers/widgets/my_text.dart';
import '../../../../../widgets/custom_textfield.dart';
import '../../widget/loader_dialog.dart';
import '../lms_tabs/widgets/header_text.dart';

class SchoologyNewConnectionScreen extends StatefulWidget {
  final VoidCallback? onPressedBack;
  const SchoologyNewConnectionScreen({super.key, this.onPressedBack});

  @override
  State<SchoologyNewConnectionScreen> createState() =>
      _SchoologyConnectionScreenState();
}

class _SchoologyConnectionScreenState
    extends State<SchoologyNewConnectionScreen> with UIMixin {
  final LmsIntegrationController lmsController =
      Get.put(LmsIntegrationController());

  final TextEditingController keyController = TextEditingController();
  final TextEditingController secretController = TextEditingController();
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController expirationTimeController =
      TextEditingController();

  Future<void> refreshToken() async {
    if (lmsController.platform.value.isEmpty) {
      lmsController.platform.value =
          "Schoology"; // or "Schoology" depending on context
    }

    await lmsController.fetchConnectionStatus(lmsController.platform.value);
    lmsController.update();
  }

  @override
  void initState() {
    super.initState();
    keyController.addListener(_onFormChanged);
    secretController.addListener(_onFormChanged);
    appNameController.addListener(_onFormChanged);
    purposeController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    setState(() {});
  }

  bool get _isFormValid {
    return keyController.text.isNotEmpty &&
        secretController.text.isNotEmpty &&
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
      DateTime selectedDate = expirationDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(expirationDateController.text)
          : DateTime(now.year, now.month, now.day);
      final selectedDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, picked.hour, picked.minute);
      expirationTimeController.text =
          DateFormat('HH:mm:ss.SSSSSS').format(selectedDateTime);
    }
  }

  @override
  void dispose() {
    keyController.dispose();
    secretController.dispose();
    appNameController.dispose();
    purposeController.dispose();
    expirationDateController.dispose();
    expirationTimeController.dispose();
    super.dispose();
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
                    child: const Icon(Icons.arrow_back),
                  ),
                if (widget.onPressedBack != null) const SizedBox(width: 20),
                HeaderText(
                  title: "Add New Consumer Key & Consumer Secret",
                  subtitle:
                      "Connect your Schoology LMS account by adding a valid Consumer Key and Consumer Secret",
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInputField(
              label: "Name",
              controller: appNameController,
            ),
            _buildInputField(
              label: "Purpose",
              controller: purposeController,
            ),
            _buildInputField(
              label: "Consumer Key",
              hintText: "Schoology Consumer Key",
              controller: keyController,
            ),
            _buildInputField(
              label: "Consumer Secret",
              hintText: "Schoology Secret",
              controller: secretController,
              obSecureText: true,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: "Expiration Date",
                    controller: expirationDateController,
                    readOnly: true,
                    suffixIcon: Icons.calendar_today_outlined,
                    onSuffixTap: _selectDate,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildInputField(
                    label: "Expiration Time",
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
              width: 120.w,
              child: AppButton(
                title: "Connect",
                onTap: _isFormValid
                    ? () async {
                        final String? expiresAt =
                            DateTimeUtils.combineDateTimeToUtcIso(
                          dateStr: expirationDateController.text,
                          timeStr: expirationTimeController.text,
                        );
                        final String? dbUserId = LocalStorage.getDBUserID();
                        lmsController.platform.value = "Schoology";
                        final Map<String, dynamic> payload = {
                          "school_admin_id": dbUserId ?? "",
                          "api_key":
                              keyController.text.trim(), // Your API key input
                          "api_secret": secretController.text
                              .trim(), // Your API secret input
                          "app_name": appNameController.text.trim(),
                          "purpose": purposeController.text.trim(),
                          "platform": lmsController.platform.value,
                          if (expiresAt != null) "expires_at": expiresAt,
                        };

                        final future = lmsController.connectLms(payload);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return LoaderDialog(
                              title:
                                  "Authenticating your Schoology LMS credentials…\nThis may take a few moments.",
                              terminatingFuture: future,
                              onSuccess: widget.onPressedBack,
                            );
                          },
                        );
                      }
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
    bool obSecureText = false,
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
          obSecureText: obSecureText,
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
