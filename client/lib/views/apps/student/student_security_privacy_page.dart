import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/services/security_service.dart';
import 'widget/student_delete_account_dialog.dart';

class SecurityPrivacyPage extends StatefulWidget {
  final VoidCallback? onBack;
  const SecurityPrivacyPage({super.key, this.onBack});

  @override
  State<SecurityPrivacyPage> createState() => _SecurityPrivacyPageState();
}

class _SecurityPrivacyPageState extends State<SecurityPrivacyPage> {
  final SecurityService _securityService = SecurityService();
  Map<String, String>? _content;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final content = await _securityService.getSecurityContent();
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoint for mobile
          bool isMobile = constraints.maxWidth < 600;
          
          // Dynamic padding values
          // Desktop: Header @ 40, Content @ 64. Offset = 24 (Box padding).
          // Mobile: Header @ 16, Content @ 40 (16 + 24).
          double headerSidePadding = isMobile ? 16.0 : 40.0;
          double contentSidePadding = isMobile ? 40.0 : 64.0; 

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.only(top: 8.0, left: headerSidePadding, right: headerSidePadding, bottom: 24.0), // Reduced top padding since AppBar adds space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      "Settings",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111111),
                        fontSize: 24, 
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _content?['title'] ?? "Security & Privacy",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(height: 8),
                           Text(
                            _content?['description'] ?? "",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: contentSidePadding),
                  child: SelectionArea(
                     child: Text(
                      _content?['content'] ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.6,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Footer Buttons
              Padding(
                padding: EdgeInsets.all(contentSidePadding), // Use content padding for alignment
                child: isMobile 
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _showDeleteAccountDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: Text(
                            "Delete My Account",
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                             // Close logic
                             if (widget.onBack != null) {
                               widget.onBack!();
                             } else {
                               Navigator.of(context).pop();
                             }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E0E0),
                            foregroundColor: const Color(0xFF111111),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: Text(
                            "Accept and Close",
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _showDeleteAccountDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: Text(
                            "Delete My Account",
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                             // Close logic
                             if (widget.onBack != null) {
                               widget.onBack!();
                             } else {
                               Navigator.of(context).pop();
                             }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE0E0E0),
                            foregroundColor: const Color(0xFF111111),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: Text(
                            "Accept and Close",
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }
}
