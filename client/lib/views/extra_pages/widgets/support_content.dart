import 'dart:io'; // ✅ required for File
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:binary_success/helpers/services/school_support_service.dart';
// ✅ Import your AdminSupportViewWidget & SupportModel
import 'package:binary_success/models/school_support_model.dart';
import 'package:binary_success/views/extra_pages/support_content_view.dart';
import 'package:flutter/foundation.dart';

class SupportPageContent extends StatefulWidget {
  const SupportPageContent({super.key});

  @override
  State<SupportPageContent> createState() => _SupportPageContentState();
}

class _SupportPageContentState extends State<SupportPageContent> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  bool _isLoading = false; // spinner state
  bool _showSuccess = false;

  String? selectedTopic;
  String? selectedFile;
  String? selectedPriority;
  Uint8List? selectedFileBytes;
  String? selectedFileName;
  List<Map<String, String>> supportHistory = [];

  final List<String> topics = [
    "Billing",
    "Integration",
    "Sage AI",
    "Writingpad",
    "Technical",
    "Others",
  ];

  String _mapPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return 'P1';
      case 'medium':
        return 'P2';
      case 'low':
        return 'P3';
      case 'very low':
        return 'P4';
      default:
        return '-';
    }
  }

  Widget _statusBadge(String? status) {
    switch (status?.toUpperCase()) {
      case "CLOSED":
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xffD1D5DB),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Text(
            "Closed",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff111827),
            ),
          ),
        );
      case "OPEN":
      default:
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xffE6F4EA),
            border: Border.all(color: const Color(0xff0A8041), width: 2),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Text(
            "Open",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xff0A8041),
            ),
          ),
        );
    }
  }

  int currentPage = 1;
  int totalTickets = 0;

  Future<void> fetchAndLoadTickets({int page = 1}) async {
    final response = await SchoolSupportService.getSupportCases(
        //raccountId: "459981697237151747",
        );

    if (response == null) return;

    setState(() {
      currentPage = page;
      supportHistory = response.ticketList.map((e) {
        return {
          "caseNumber": (e.caseNumber ?? "-").toString(),
          "recordID": (e.recordID ?? "-").toString(),
          "type": (e.type ?? "-").toString(),
          "subject": (e.subject ?? "-").toString(),
          "description": (e.description ?? "-").toString(),
          "priority": (e.priority ?? "-").toString(),
          "status": (e.status ?? "OPEN").toString(),
          "response": (e.solutionNote ?? "").toString(),
          "accountName": (e.accountName ?? "-").toString(),
          "contactName": (e.contactName ?? "-").toString(),
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAndLoadTickets(); // Always load from backend
  }

// inside _SupportPageContentState
  void submitTicket() async {
    if (selectedTopic == null ||
        subjectController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true); // Show spinner

    try {
      // Prepare file for mobile/desktop
      File? fileToSend =
          (!kIsWeb && selectedFile != null) ? File(selectedFile!) : null;

      final result = await SchoolSupportService.createTicketWithDetails(
        ticketType: selectedTopic!,
        subject: subjectController.text,
        description: descriptionController.text,
        priority: selectedPriority ?? "",
        file: fileToSend,
        fileBytes: kIsWeb ? selectedFileBytes : null,
        fileName: kIsWeb ? selectedFileName : null,
      );

      if (result != null) {
        await fetchAndLoadTickets();

        descriptionController.clear();
        subjectController.clear();
        selectedTopic = null;
        selectedFile = null;
        selectedPriority = null;

        if (!mounted) return;

        // Show success popup
        setState(() {
          _showSuccess = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showSuccess = false);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit ticket: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false); // Hide spinner
    }
  }

  // <-- Add this closing bracket to properly end submitTicket()

  void cancelTicket() {
    setState(() {
      selectedTopic = null;
      subjectController.clear();
      descriptionController.clear();
      selectedFile = null;
    });
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        // For web: keep bytes + name
        selectedFile = result.files.single.path; // desktop/mobile
        selectedFileBytes = result.files.single.bytes; // web
        selectedFileName = result.files.single.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------- TOPIC ----------------------
                  Text(
                    "Topic",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  6.verticalSpace,

// ✅ Topic box like Subject
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          value: selectedTopic,
                          hint: Align(
                            alignment:
                                Alignment.centerLeft, // left-align hint text
                            child: Text(
                              "Select a Topic",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          items: topics
                              .map((topic) => DropdownMenuItem<String>(
                                    value: topic,
                                    child: Text(
                                      topic,
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedTopic = value);
                          },
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            elevation: 4,
                          ),
                          menuItemStyleData:
                              const MenuItemStyleData(height: 40),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------------- SUBJECT ----------------------
                  // ---------------------- SUBJECT ----------------------
                  Text(
                    "Subject",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  6.verticalSpace,

// ✅ Make subject box same width as Topic dropdown
                  SizedBox(
                    width: double.infinity, // ensures full width
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: subjectController,
                        decoration: const InputDecoration.collapsed(
                          hintText: "Enter your Subject",
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  20.verticalSpace,

                  // ---------------------- DESCRIPTION ----------------------
                  Text(
                    "Description",
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
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration.collapsed(
                        hintText: "Type a description",
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  20.verticalSpace,

                  // ---------------------- ATTACH FILE ----------------------
                  Text(
                    "Attach File",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  6.verticalSpace,
                  ElevatedButton.icon(
                    onPressed: pickFile,
                    icon: const Icon(Icons.attach_file, color: Colors.black87),
                    label: Text(
                      selectedFile ?? "Attach File",
                      style: const TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xffF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),

                  20.verticalSpace,

                  // ---------------------- BUTTONS ----------------------
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : submitTicket,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xff004AAD), Color(0xffCB6CE6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                "Submit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        height: 40,
                        child: OutlinedButton(
                          onPressed: cancelTicket,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                width: 1.5, color: Colors.black26),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ---------------------- SUPPORT HISTORY ----------------------
                  const Text(
                    "Support History",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  supportHistory.isEmpty
                      ? const Text("No Support Tickets Found.")
                      : SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            headingRowColor:
                                WidgetStateProperty.all(Colors.white),
                            border: TableBorder.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            columnSpacing: 24,
                            horizontalMargin: 12,
                            columns: const [
                              DataColumn(label: Text("Ticket ID")),
                              DataColumn(label: Text("Topic")),
                              DataColumn(label: Text("Priority")),
                              DataColumn(label: Text("Status")),
                              DataColumn(label: Text("Action")),
                            ],
                            rows: supportHistory.map((ticket) {
                              return DataRow(
                                cells: [
                                  // Ticket ID
                                  DataCell(
                                    Text(
                                      ticket['caseNumber'] ?? '-',
                                      style: const TextStyle(
                                        color: Color(0xFF9C27B0), // Purple
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  // Topic
                                  DataCell(Text(ticket['type'] ?? '-')),

                                  // Priority
                                  DataCell(
                                      Text(_mapPriority(ticket['priority']))),

                                  // Status badge
                                  DataCell(_statusBadge(ticket['status'])),

                                  // Action button
                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminSupportViewPage(
                                              ticket: SupportModel(
                                                id: ticket['recordID'] ?? "-",
                                                recordID:
                                                    ticket['recordID'] ?? "-",
                                                caseNumber:
                                                    ticket['caseNumber'] ?? "-",
                                                topic: ticket['type'] ?? "-",
                                                priority: _mapPriority(
                                                    ticket['priority']),
                                                subject:
                                                    ticket['subject'] ?? "-",
                                                description:
                                                    ticket['description'] ??
                                                        "-",
                                                response:
                                                    ticket['response'] ?? "",
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xff3B82F6),
                                              Color(0xffA855F7)
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: const Icon(Icons.arrow_forward,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),

        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xff004AAD),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),

        // ✅ Success popup
        if (_showSuccess)
          Positioned.fill(
            child: Center(
              child: Container(
                width: 340,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 12),
                    Text(
                      "Successfully Submitted",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Your request has been submitted.\nOur support team is reviewing it now.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

// ------------------- SUCCESS DIALOG -------------------
  void _showTicketSubmittedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            minWidth: 300,
            maxHeight:
                MediaQuery.of(context).size.height * 0.6, // responsive height
          ),
          child: Dialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              // ✅ Make content scrollable
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Successfully Submitted",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Your request has been successfully submitted.\nOur support team is reviewing it now.",
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Auto-close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}
