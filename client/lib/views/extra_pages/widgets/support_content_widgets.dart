import 'package:vantanceCA/models/school_support_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:vantanceCA/helpers/services/school_support_service.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vantanceCA/images.dart';

class AdminSupportViewWidget extends StatefulWidget {
  final SupportModel ticket;

  const AdminSupportViewWidget({super.key, required this.ticket});

  @override
  State<AdminSupportViewWidget> createState() => _AdminSupportViewWidgetState();
}

class _AdminSupportViewWidgetState extends State<AdminSupportViewWidget> {
  bool showDenyBox = false;
  bool isDenyActive = false; // track deny button state
  bool get _isTicketClosed => widget.ticket.status?.toLowerCase() == "closed";

  bool _isSending = false;
  bool _showResponsePopup = false;

  bool _isClosed = false;

  final TextEditingController _denyController = TextEditingController();

  /// Replace this with the actual current user's identifier
  final String currentUserFullName =
      LocalStorage.getUserName() ?? "Support Team";
  final ScrollController _scrollController = ScrollController();

// fallback Customer // Example: "AG" or fetch from user profile

  /// Simulated support history (can later fetch from API)
  List<Map<String, dynamic>> supportHistory = [];
  String? latestResponse;

  /// Clean HTML tags
  String _stripHtml(String? htmlText) {
    if (htmlText == null || htmlText.trim().isEmpty) return "-";
    final regex = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    final cleanText = htmlText.replaceAll(regex, "").trim();
    return cleanText.isEmpty ? "-" : cleanText;
  }

  String _formatChatTime(DateTime dt) {
    return DateFormat("MMM d, h:mm a").format(dt.toLocal());
  }

  String getInitials(String fullName) {
    final parts = fullName.split(" ");
    final first = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0][0] : "";
    final last = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : "";
    return (first + last).toUpperCase();
  }

  /// Priority mapping
  String _mapPriority(String? p) {
    switch (p?.toLowerCase()) {
      case "high":
      case "p1":
        return "P1";
      case "medium":
      case "p2":
        return "P2";
      case "low":
      case "p3":
        return "P3";
      case "very low":
      case "p4":
        return "P4";
      default:
        return "-";
    }
  }

  bool get _canTakeAction {
    final hasResponse =
        latestResponse != null && latestResponse!.trim().isNotEmpty;
    final hasReplies = supportHistory.isNotEmpty;
    return hasResponse || hasReplies;
  }

  @override
  void initState() {
    super.initState();
    latestResponse = widget.ticket.response;
    _refreshTicket();
    _loadTicketHistory();
    _loadFiles();
  }

  Future<void> _refreshTicket() async {
    final freshTicket =
        await SchoolSupportService.getTicketById(widget.ticket.recordID);
    if (!mounted) return;
    setState(() {
      widget.ticket.status = freshTicket?.status;
      latestResponse = freshTicket?.response;
      _isClosed = (widget.ticket.status ?? "").toLowerCase() == "closed";
    });
  }

  Future<void> _loadFiles() async {
    final files = await SchoolSupportService.getTicketFiles(
      recordId: widget.ticket.recordID,
      moduleId: "450287529901977603", // or dynamic value
    );

    setState(() {
      widget.ticket.files =
          files; // make sure SupportModel has `files` as mutable
    });

    print("📂 Loaded files: ${files.map((f) => f.name).toList()}");
  }

  Future<void> _loadTicketHistory() async {
    final history =
        await SchoolSupportService.getTicketHistory(widget.ticket.recordID);

    if (!mounted) return;

    List<Map<String, dynamic>> items = [];

    // ✅ Check if any customer reply exists
    final hasCustomerResponse = history.any((h) {
      final type = h.userType.toString().toLowerCase().replaceAll(" ", "");
      return type != "supportteam"; // means it's customer
    });

    // ✅ Add description ONLY if there is a customer reply
    if (hasCustomerResponse &&
        widget.ticket.description != null &&
        widget.ticket.description!.trim().isNotEmpty) {
      items.add({
        "user": currentUserFullName, // Support Team
        "message": widget.ticket.description!,
        "time": _formatChatTime(
            (widget.ticket.createdAt ?? DateTime.now()).toLocal()),
        "userType": "supportteam", // right side bubble
      });
    }

    // 👇 Add replies
    items.addAll(history.map((h) {
      return {
        "user": h.user.isNotEmpty
            ? h.user
            : widget.ticket.suppliedName ?? "Customer",
        "message": h.message,
        "time": _formatChatTime(h.createdAt.toLocal()),
        "userType": h.userType.toString().toLowerCase().replaceAll(" ", "") ??
            "supportteam",
      };
    }).toList());

    setState(() {
      supportHistory = items;
    });
  }

  String get _lastCustomerMessage {
    // Check support history first
    if (supportHistory.isNotEmpty) {
      // Find the last message that is NOT from support team
      final customerMessages = supportHistory
          .where((entry) =>
              (entry["userType"]?.toString().toLowerCase() ?? "") !=
              "supportteam")
          .toList();

      if (customerMessages.isNotEmpty) {
        return customerMessages.last["message"] ?? "No response yet";
      }
    }

    // If no customer message, check original ticket response
    if (latestResponse != null && latestResponse!.trim().isNotEmpty) {
      return latestResponse!;
    }

    return "No response yet";
  }

  Future<void> _onSubmit() async {
    final text = _denyController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true; // show spinner
    });

    Map<String, dynamic>? reply = await SchoolSupportService.replyToTicket(
      caseId: widget.ticket.recordID,
      message: text,
    );

    if (!mounted) return;

    if (reply != null) {
      await _loadTicketHistory();

      setState(() {
        _denyController.clear();
        showDenyBox = false;
        isDenyActive = false;
        _isSending = false;
        _showResponsePopup = true; // ✅ Show in-container popup
      });

      // Auto-hide after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showResponsePopup = false;
          });
        }
      });
    } else {
      setState(() {
        _isSending = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit response")),
      );
    }
  }

  /// Info row builder
  Widget _buildInfoRow(
    String label,
    String value, {
    Color valueColor = Colors.black87,
    bool isTicketId = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            ": ",
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: isTicketId ? FontWeight.w700 : FontWeight.w400,
                color: isTicketId ? const Color(0xFF9C27B0) : valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Gradient Button
  /// Gradient Button with optional border-only style
  Widget _buildGradientButton({
    required String text,
    VoidCallback? onPressed,
    required List<Color> colors,
    bool borderOnly = false, // 👈 new flag
  }) {
    return SizedBox(
      width: 120,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
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
            decoration: BoxDecoration(
              color: borderOnly
                  ? Colors.white
                  : null, // 👈 white fill for border-only
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                color: borderOnly
                    ? Colors.black
                    : Colors.white, // 👈 black text for deny
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Attached Files widget
  /// Attached Files widget
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
                  final bool isSupportReply =
                      (entry["userType"]?.toString().toLowerCase() ==
                          "supportteam");

                  final String initials = isSupportReply
                      ? getInitials(currentUserFullName)
                      : ""; // no text if using image

                  final Color bubbleColor = isSupportReply
                      ? const Color(0xffFDE7F3)
                      : const Color(0xffE6F0FF);
                  final Color avatarColor =
                      isSupportReply ? Colors.pink : Colors.blue;

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isSupportReply
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🐘 Customer (left side)
                        if (!isSupportReply) ...[
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(Images.elephant),
                            backgroundColor: Colors.transparent,
                          ),
                          const SizedBox(width: 8),
                        ],

                        // 💬 Chat bubble
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSupportReply
                                  ? const Color(
                                      0xffFDE7F3) // pinkish for support
                                  : const Color(
                                      0xffE6F0FF), // bluish for customer
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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

                        // 👤 Support team avatar (right side)
                        if (isSupportReply) ...[
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.pink,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;

    return Stack(
      children: [
        // Main content
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 30),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(30, 0, 0, 0),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow("Ticket ID", ticket.caseNumber ?? "-",
                    isTicketId: true),
                _buildInfoRow("Topics", ticket.topic ?? "-"),
                _buildInfoRow("Priority", _mapPriority(ticket.priority)),
                _buildInfoRow("Subject", ticket.subject ?? "-"),
                20.verticalSpace,
                // Description
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
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                20.verticalSpace,
                _buildAttachedFiles(ticket.files),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: (_lastCustomerMessage.trim().isNotEmpty)
                      ? Html(
                          data: _lastCustomerMessage,
                          style: {
                            "body": Style(
                              fontSize: FontSize(14),
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          },
                        )
                      : const Text(
                          "No response yet",
                          style: TextStyle(fontSize: 14),
                        ),
                ),
                22.verticalSpace,
                // Action buttons
                if (!_isTicketClosed && _canTakeAction) ...[
                  Row(
                    children: [
                      if (!showDenyBox)
                        _buildGradientButton(
                          text: "Accept",
                          onPressed: () async {
                            final success =
                                await SchoolSupportService.closeTicket(
                                    widget.ticket.recordID ?? "");
                            if (success && mounted) {
                              await _loadTicketHistory();
                              setState(() {
                                _isClosed = true;
                                widget.ticket.status = "closed";
                                showDenyBox = false;
                                isDenyActive = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Ticket closed successfully")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Failed to close ticket")),
                              );
                            }
                          },
                          colors: [
                            const Color(0xff004AAD),
                            const Color(0xffCB6CE6)
                          ],
                        ),
                      if (!showDenyBox) const SizedBox(width: 12),
                      _buildGradientButton(
                        text: "Deny",
                        onPressed: () {
                          setState(() {
                            showDenyBox = !showDenyBox;
                            isDenyActive = showDenyBox;
                          });
                        },
                        colors: [
                          const Color(0xFF4A00E0),
                          const Color(0xFF8E2DE2)
                        ],
                        borderOnly: true,
                      ),
                    ],
                  ),
                  if (showDenyBox) ...[
                    20.verticalSpace,
                    Text(
                      "If response not clear please contact",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    8.verticalSpace,
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: TextField(
                        controller: _denyController,
                        maxLines: 2,
                        decoration: const InputDecoration.collapsed(
                          hintText: "Type a description",
                        ),
                      ),
                    ),
                    16.verticalSpace,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildGradientButton(
                        text: "Submit",
                        onPressed: _onSubmit,
                        colors: [
                          const Color(0xff004AAD),
                          const Color(0xffCB6CE6)
                        ],
                      ),
                    ),
                  ],
                ],
                _buildSupportHistory(),
              ],
            ),
          ),
        ),

        if (_showResponsePopup)
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    "Response Submitted",
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

// Page-level loading spinner (no dim background)
        if (_isSending)
          const Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xff004AAD),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
