import 'package:flutter/material.dart';

class PaperCard extends StatelessWidget {
  final String title;
  final String description;
  final String daily;
  final String weekly;
  final String mock;
  final VoidCallback onTap;

  const PaperCard({
    super.key,
    required this.title,
    required this.description,
    required this.daily,
    required this.weekly,
    required this.mock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),

              // Metrics row
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildMetric("Daily Practices $daily"),
                  _buildMetric("Weekly Practices $weekly"),
                  _buildMetric("Mock Practices $mock"),
                ],
              ),
            ],
          );

          final button = GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFDADADA),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                "View Schedule",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          );

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: button,
                ),
              ],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: 24),
                button,
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMetric(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circular dot indicator
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF8A8A8A),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        // Metric text
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blueGrey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
