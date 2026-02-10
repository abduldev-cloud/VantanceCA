import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:binary_success/models/student_subscription_model.dart';
import 'package:binary_success/services/subscription_service.dart';
import 'widget/subscription_card.dart';

class SubscriptionPage extends StatefulWidget {
  final VoidCallback? onBack;
  const SubscriptionPage({super.key, this.onBack});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Plan> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final plans = await _subscriptionService.getPlans();
      setState(() {
        _plans = plans;
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
      backgroundColor: Colors.white, // Or generic background color
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile =
                constraints.maxWidth < 800; // Switch to vertical earlier

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button Section
                  if (widget.onBack != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onBack,
                        color: Colors.black,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(
                        top: 12.0, left: 32.0, right: 32.0, bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Billing & Plans",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Manage customer billing and plans.",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Plans Layout
                isMobile
                    // Mobile: Vertical List (Column)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: _plans.map((plan) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0), // Vertical spacing
                              child: SizedBox(
                                width: double.infinity, // Full width cards on mobile
                                child: SubscriptionCard(
                                  plan: plan,
                                  onAction: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Selected \${plan.title}")),
                                    );
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    // Desktop: Horizontal Scroll (Row)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _plans.map((plan) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: SubscriptionCard(
                                plan: plan,
                                onAction: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Selected \${plan.title}")),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    ),
    );
  }
}
