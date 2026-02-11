import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vantanceCA/models/student_subscription_model.dart';
import 'package:vantanceCA/app_colors.dart';

class SubscriptionCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onAction;

  const SubscriptionCard(
      {super.key, required this.plan, required this.onAction});

  @override
  Widget build(BuildContext context) {
    bool isPopular = plan.title
        .toLowerCase()
        .contains('standard'); // Mock logic for highlighting

    return Container(
      width: 260, // Reduced from 300
      padding: const EdgeInsets.all(16), // Reduced from 24
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: plan.isActive ? AppColors.purple : Colors.grey.shade200,
          width: plan.isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (plan.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Current Plan",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.purple,
                ),
              ),
            ),
          Text(
            plan.title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.description,
            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              text: plan.price,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              children: [
                TextSpan(
                  text: " / month",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...plan.features.map((feature) => _buildFeatureItem(feature)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: plan.isActive ? null : onAction, // Disable if active
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    plan.isActive ? Colors.grey[100] : Colors.black,
                foregroundColor: plan.isActive ? Colors.grey : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                plan.isActive ? "Active" : "Upgrade",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppColors.correct, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
