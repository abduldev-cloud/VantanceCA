import 'package:vantanceCA/views/apps/student/widget/paper_card.dart';
import 'package:flutter/material.dart';
import 'practice_screen.dart';

class PapersScreen extends StatelessWidget {
  final VoidCallback? onNavigateToPractice;

  const PapersScreen({super.key, this.onNavigateToPractice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Papers",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              // Paper Cards
              PaperCard(
                title: "Accounting",
                description:
                    "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
                daily: "60",
                weekly: "12",
                mock: "2",
                onTap: () => _handleNavigation(context),
              ),

              PaperCard(
                title: "Business Laws",
                description:
                    "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
                daily: "65",
                weekly: "12",
                mock: "2",
                onTap: () => _handleNavigation(context),
              ),

              PaperCard(
                title: "Quantitative Aptitude",
                description:
                    "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
                daily: "60",
                weekly: "12",
                mock: "2",
                onTap: () => _handleNavigation(context),
              ),

              PaperCard(
                title: "Business Economics",
                description:
                    "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
                daily: "60",
                weekly: "12",
                mock: "2",
                onTap: () => _handleNavigation(context),
              ),

              PaperCard(
                title: "Model Test Papers",
                description:
                    "Lorem ipsum is simply dummy text of the printing and typesetting industry.",
                daily: "50",
                weekly: "10",
                mock: "1",
                onTap: () => _handleNavigation(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context) {
    // Use callback if provided, otherwise navigate directly
    if (onNavigateToPractice != null) {
      onNavigateToPractice!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const QuizScreenExact(),
        ),
      );
    }
  }
}
