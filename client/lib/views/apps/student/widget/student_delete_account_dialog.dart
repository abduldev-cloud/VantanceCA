import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_account_deleted_success_dialog.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFFF9F9F9),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Delete My Account",
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2040),
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2040),
                ),
                children: [
                  const TextSpan(text: "Are you sure you want to delete "),
                  TextSpan(
                    text: "Arun Kumar", // Mocked user name
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.grey[500]),
                  ),
                  const TextSpan(text: "?"),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const SizedBox(height: 24),
            
            // Warning Box
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Container(
                            width: 4,
                            height: 60,
                            margin: const EdgeInsets.only(right: 12),
                            color: const Color(0xFFFF9933),
                        ),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        children: [
                                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9933), size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                                "Warning",
                                                style: GoogleFonts.inter(
                                                    color: const Color(0xFFFF9933),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14
                                                )
                                            )
                                        ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        "By deleting this account, you won't be able to access the Deskpad system.",
                                        style: GoogleFonts.inter(
                                            color: const Color(0xFFFF9933),
                                            fontSize: 13,
                                            height: 1.4
                                        )
                                    )
                                ],
                            )
                        )
                    ],
                )
            ),

            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    "No, Cancel",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close warning
                    // Open Success
                    showDialog(
                        context: context,
                        builder: (context) => const AccountDeletedDialog()
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                  child: Text(
                    "Yes, Delete",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
