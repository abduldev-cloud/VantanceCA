import 'package:binary_success/helpers/widgets/my_card.dart';
import 'package:binary_success/models/platform_support_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:binary_success/helpers/services/platform_service.dart';
import 'package:intl/intl.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminSupportViewWidget extends StatefulWidget {
  final SupportModel ticket;

  const AdminSupportViewWidget({super.key, required this.ticket});

  @override
  State<AdminSupportViewWidget> createState() => _AdminSupportViewWidgetState();
}

class _AdminSupportViewWidgetState extends State<AdminSupportViewWidget> {
  late TextEditingController _responseController;
  late String _currentResponse;
  late String _status;
  String _priority = "Select";
  final allowedPriorities = ["P1", "P2", "P3", "P4"];
  final Map<String, String> priorityMap = {
    "P1": "High",
    "P2": "Medium",
    "P3": "Low",
    "P4": "Very Low",
  };

  // Removed duplicate build method to resolve the error.

  /// Support History
  // Example: Current logged-in user
  final String currentUserId =
      LocalStorage.getUserName() ?? ""; // or get from auth

  List<Map<String, dynamic>> supportHistory = [];
  bool _hasRepliedInProgress = false;
  bool showResponseBox = true;
  bool enableResponseBox = false;
  bool _isLoading = false;

  /// Format chat time
  String _formatChatTime(DateTime dt) {
    return DateFormat("MMM d, h:mm a").format(dt);
  }

  Future<void> _submitResponse() async {
    if (_status == "Closed") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot reply to a closed ticket")),
      );
      return;
    }

    final replyText = _responseController.text.trim();
    if (replyText.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Response cannot be empty")),
      );
      return;
    }

    if (_priority == "Select") {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a priority")),
      );
      return;
    }

    setState(() => _isLoading = true); // 🔹 show spinner

    try {
      final response = await SupportService.replyToCustomerTicket(
        caseId: widget.ticket.recordID,
        description: replyText,
      );

      final apiPriority = priorityMap[_priority] ?? "";
      await SupportService.updateTicketPriority(
        ticketId: widget.ticket.recordID,
        priority: apiPriority,
      );

      if (!mounted) return;

      if (response != null) {
        setState(() {
          _currentResponse = _stripHtml(replyText);
          _responseController.text = "";

          if (_status == "In-Progress" && !_hasRepliedInProgress) {
            _hasRepliedInProgress = true;
            _status = "Resolved";
          }

          supportHistory.add({
            "isCustomer": true,
            "user": currentUserId,
            "message": replyText,
            "time": _formatChatTime(DateTime.now()),
          });

          if (widget.ticket.status == "Closed") _status = "Closed";
        });

        _showResponseSubmittedDialog();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // 🔹 hide spinner
    }
  }

  void _showResponseSubmittedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // user cannot tap outside to dismiss
      builder: (context) {
        // Auto close after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 300, // Increased width
            height: 180, // Increased height
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment:
                    MainAxisAlignment.center, // center vertically
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 70),
                  const SizedBox(height: 16),
                  Text(
                    "Response Updated",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _currentResponse = widget.ticket.response ?? "";
    _responseController = TextEditingController(text: _currentResponse);

    _priority = allowedPriorities.contains(widget.ticket.priorityCode)
        ? widget.ticket.priorityCode
        : "P1";

    // ✅ Force "In-Progress" as default unless ticket is Closed
    final apiStatus = (widget.ticket.status ?? "").toUpperCase();
    if (apiStatus == "CLOSED") {
      _status = "Closed"; // Ticket is closed → go to closed tab
    } else {
      _status =
          "In-Progress"; // OPEN / RESOLVED / IN-PROGRESS → treat all as open
    }

    _loadFiles();
    _loadSupportHistory().then((_) {
      if (_hasRepliedInProgress && _status != "Closed") {
        setState(() {
          _status = "Resolved";
        });
      }
    });
  }

  Future<void> _loadFiles() async {
    final files = await SupportService.getTicketFiles(
      recordId: widget.ticket.recordID,
      moduleId: "450287529901977603", // or dynamic value
    );

    setState(() {
      widget.ticket.files =
          files; // make sure SupportModel has `files` as mutable
    });

    print("📂 Loaded files: ${files.map((f) => f.name).toList()}");
  }

  Future<void> _loadSupportHistory() async {
    final history =
        await SupportService.getTicketHistory(widget.ticket.recordID);
    final List<Map<String, dynamic>> formattedHistory = [];

    if ((widget.ticket.description ?? "").trim().isNotEmpty) {
      formattedHistory.add({
        "isCustomer": false,
        "user": widget.ticket.suppliedName ?? "Support Team",
        "message": widget.ticket.description!,
        "time": _formatChatTime(
          (widget.ticket.createdAt ?? DateTime.now()).toLocal(),
        ),
      });
    }

    formattedHistory.addAll(history.map((h) {
      final createdLocal = (h.createdAt ?? DateTime.now()).toLocal();

      // ✅ If admin replied in In-Progress → lock it permanently
      if (h.isCustomer == true) {
        _hasRepliedInProgress = true;
      }

      return {
        "isCustomer": h.isCustomer ?? false,
        "user":
            h.userName ?? (h.isCustomer == true ? "Customer" : "Support Team"),
        "message": h.message,
        "time": _formatChatTime(createdLocal),
      };
    }).toList());

    if (mounted) {
      setState(() {
        supportHistory = formattedHistory;
      });
    }
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  String _stripHtml(String? htmlText) {
    if (htmlText == null || htmlText.trim().isEmpty) return "-";
    final regex = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    final cleanText = htmlText.replaceAll(regex, "").trim();
    return cleanText.isEmpty ? "-" : cleanText;
  }

  Widget _buildAttachedFiles(List<SupportFile> files) {
    if (files.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attached Files",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        10.verticalSpace,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: files.map((file) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: () async {
                  final url = Uri.parse(file.url);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.insert_drive_file,
                        size: 18, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(
                      file.name,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        20.verticalSpace,
      ],
    );
  }

  /// ✅ Ticket history widget
  Widget _buildSupportHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        20.verticalSpace,
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          title: Text(
            "Support Ticket History",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          children: [
            12.verticalSpace,
            if (supportHistory.isEmpty)
              SizedBox(
                height: 160,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 48, color: Colors.grey.shade400),
                      12.verticalSpace,
                      Text(
                        "Support Ticket History Not Found",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: supportHistory.map((entry) {
                  final bool isCustomer = entry["isCustomer"] ?? false;

                  // ✅ Get display name
                  String displayUser = entry["user"].toString();

                  if (!isCustomer) {
                    displayUser = widget.ticket.contactName ?? "Support Team";
                  }

                  if (isCustomer && displayUser == "Customer") {
                    displayUser =
                        currentUserId; // use local logged-in user full name
                  }

                  // ✅ Extract initials properly (First + Last)
                  String initials = "NA";
                  if (displayUser.trim().isNotEmpty) {
                    final parts = displayUser.trim().split(" ");
                    if (parts.length >= 2) {
                      initials = (parts.first[0] + parts.last[0]).toUpperCase();
                    } else {
                      initials = parts.first[0].toUpperCase();
                    }
                  }

                  // ✅ Format: "Full Name (XX)"
                  final displayLabel = "$displayUser ($initials)";

                  final Color bubbleColor = isCustomer
                      ? const Color(0xffFDE7F3)
                      : const Color(0xffE6F0FF);
                  final Color avatarColor =
                      isCustomer ? Colors.pink : Colors.blue;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: isCustomer
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isCustomer) ...[
                          CircleAvatar(
                            backgroundColor: avatarColor,
                            radius: 20,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ❌ Removed displayLabel (Support Team ST, etc.)
                                Text(
                                  _stripHtml(entry["message"]),
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black87,
                                  ),
                                ),
                                6.verticalSpace,
                                Text(
                                  entry["time"],
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isCustomer) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: avatarColor,
                            radius: 20,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              )
          ],
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
    } else {
      return "Just now";
    }
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required List<Color> colors,
  }) {
    return SizedBox(
      width: 160,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, Widget valueWidget) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const Text(": "),
          Expanded(child: valueWidget),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    bool showResponseBox = true;
    bool enableResponseBox = false;

    // ===============================
    // Workflow logic
    // ===============================

// ===============================
// Workflow logic
// ===============================
    if (_status == "Closed") {
      showResponseBox = false;
      enableResponseBox = false;
    } else if (_status == "In-Progress") {
      showResponseBox = true;
      enableResponseBox = !_hasRepliedInProgress; // first reply disables box
    } else if (_status == "Resolved") {
      showResponseBox = true;
      enableResponseBox = true; // all subsequent replies allowed
    }

    return MyCard.circular(
      margin: EdgeInsets.only(
        top: 0.h,
        bottom: 40.h,
        left: 0.w,
        right: 0.w,
      ),
      borderRadiusAll: 25.r,
      bordered: false,
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 25.h),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ======= Info Section =======
                _buildInfoRow(
                  "Ticket ID",
                  Text(
                    ticket.caseNumber ?? "-",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                ),

                _buildInfoRow(
                  "Topic",
                  Text(
                    ticket.topic ?? "-",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                _buildInfoRow(
                  "Priority",
                  DropdownButton2<String>(
                    value: _priority,
                    underline: const SizedBox(),
                    isExpanded: false,
                    buttonStyleData: ButtonStyleData(
                      height: 40.h,
                      width: 80.w,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xffE5E7EB)),
                        color: _status == "Closed"
                            ? Colors.grey.shade200
                            : Colors.white,
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      width: 80.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: Colors.white,
                        border: Border.all(color: const Color(0xffE5E7EB)),
                      ),
                      elevation: 2,
                      padding: EdgeInsets.zero,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    items: priorityMap.keys.map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            code,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (_status == "Closed")
                        ? null // ❌ disable dropdown completely
                        : (value) {
                            if (value != null)
                              setState(() => _priority = value);
                          },
                    disabledHint: Text(
                      _priority,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),

                _buildInfoRow(
                  "Subject",
                  Text(
                    ticket.subject ?? "-",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                16.verticalSpace,

                Text(
                  "Description",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                6.verticalSpace,
                Text(
                  _stripHtml(ticket.description),
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                20.verticalSpace,

                // ==== Attached Files ====
                _buildAttachedFiles(ticket.files),
                // ======= Status Tabs =======
                Text(
                  "Status",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                6.verticalSpace,
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text("In-Progress"),
                      selected: _status == "In-Progress",
                      onSelected: (_hasRepliedInProgress || _status == "Closed")
                          ? null // ❌ disable if first reply sent or ticket closed
                          : (_) {
                              setState(() => _status = "In-Progress");
                            },
                      selectedColor: const Color(0xffE3F2FD),
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Resolved"),
                      selected: _status == "Resolved",
                      onSelected: (_status == "Closed")
                          ? null // ❌ disable if ticket closed
                          : (_) {
                              if (_hasRepliedInProgress) {
                                setState(() => _status = "Resolved");
                              }
                            },
                      selectedColor: const Color(0xffE3F2FD),
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text("Closed"),
                      selected: _status == "Closed",
                      onSelected: null, // ❌ always non-clickable
                      selectedColor: const Color(0xffE3F2FD),
                      backgroundColor: Colors.grey.shade200,
                      showCheckmark: false,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ticket.createdDate != null
                          ? "Ticket Created ${_getTimeAgo(ticket.createdDate!.toLocal())}"
                          : "Created date not available",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                20.verticalSpace,

                // ======= Response Box Logic =======
                if (showResponseBox) ...[
                  Text(
                    "Response",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  6.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                      color: enableResponseBox
                          ? Colors.white
                          : Colors.grey.shade100, // lighter when disabled
                    ),
                    child: TextField(
                      controller: _responseController,
                      maxLines: 4,
                      enabled: enableResponseBox,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Type your response here...",
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  30.verticalSpace,
                  if (enableResponseBox)
                    _buildGradientButton(
                      text: "Submit",
                      onPressed: () async {
                        await _submitResponse();
                      },
                      colors: const [Color(0xff004AAD), Color(0xffCB6CE6)],
                    ),
                  20.verticalSpace,
                ],

                _buildSupportHistory(),
              ],
            ),
          ),
          if (_isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff004AAD), // your brand color
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
