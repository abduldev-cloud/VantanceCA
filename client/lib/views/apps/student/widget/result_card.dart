import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String description;
  final String subject;
  final String date;
  final String frequency; // e.g., Daily, Weekly
  final int naCount; // Not Attempted
  final int waCount; // Wrong Answer
  final int paCount; // Partially Answered (Assumed)
  final int caCount; // Correct Answer

  const ResultCard({
    super.key,
    required this.title,
    required this.description,
    required this.subject,
    required this.date,
    required this.frequency,
    required this.naCount,
    required this.waCount,
    required this.paCount,
    required this.caCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), // Increased opacity for better visibility
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContentSection(),
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildContentSection(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildStatsRow(),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF666666),
            height: 1.4,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildMetadataItem(Icons.bookmark_border, subject),
            _buildMetadataItem(Icons.calendar_today_outlined, date),
            _buildMetadataItem(Icons.calendar_month_outlined, frequency),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF999999),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: [
        _buildStatusPill("NA", naCount, const Color(0xFFFFE082).withOpacity(0.4), const Color(0xFF8B6B00)), // Yellowish
        _buildStatusPill("WA", waCount, const Color(0xFFFFCDD2).withOpacity(0.4), const Color(0xFFB71C1C)), // Reddish
        _buildStatusPill("PA", paCount, const Color(0xFFFFE0B2).withOpacity(0.4), const Color(0xFFE65100)), // Orangeish
        _buildStatusPill("CA", caCount, const Color(0xFFB2EBF2).withOpacity(0.4), const Color(0xFF006064)), // Cyanish
      ],
    );
  }

  Widget _buildStatusPill(String label, int count, Color bgColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8), // Rectangular with curved edge
          ),
          child: Text(
            label, // Label only inside colored box
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 8), // Spacing between colored box and count
        Text(
          "$count", // Count outside
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
