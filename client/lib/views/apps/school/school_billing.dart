import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:binary_success/views/layouts/layout.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:binary_success/services/dodo_service.dart';

class SchoolBillingPage extends StatefulWidget {
  const SchoolBillingPage({super.key});

  @override
  State<SchoolBillingPage> createState() => _SchoolBillingPageState();
}

class _SchoolBillingPageState extends State<SchoolBillingPage> {
  String? _currentPlan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchPlan();
  }

  // Future<void> fetchPlan() async {
  //   final email = LocalStorage.getUserEmail();
  //   if (email == null) return;

  //   try {
  //     final uri = Uri.parse(
  //       "${API.baseURl}/killbill/user-plan?email=${Uri.encodeComponent(email)}",
  //     );

  //     final response = await http.get(uri);

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       setState(() {
  //         _currentPlan = data['plan']; // "Basic" or "Essentials"
  //       });
  //     } else {
  //       debugPrint('Failed to fetch plan info');
  //     }
  //   } catch (e) {
  //     debugPrint('Exception fetching plan: $e');
  //   } finally {
  //     setState(() {
  //       _loading = false;
  //     });
  //   }
  // }

  Future<void> fetchPlan() async {
    final email = LocalStorage.getUserEmail();
    if (email == null) return;

    try {
      // CHANGED: Now pointing to Dodo endpoint
      final uri = Uri.parse(
        "${API.baseURl}/payment/dodo/user-plan?email=${Uri.encodeComponent(email)}",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentPlan = data['plan'];
        });
      } else {
        // Fallback for local simulation as requested
        setState(() {
          //_currentPlan = "pdt_0NVGKxMFFCmbFsuzZABTd"; // Foundation Weekly ID
          _currentPlan = "pdt_0NVP76bBAslPrshj79K8o"; // Intermediate Weekly ID
          // _currentPlan = "BS-Final-Weekly";
        });
      }
    } catch (e) {
      // Fallback for local simulation as requested
      setState(() {
        // _currentPlan = "pdt_0NVGKxMFFCmbFsuzZABTd"; // Foundation Weekly ID
        _currentPlan = "pdt_0NVP76bBAslPrshj79K8o"; // Intermediate Weekly ID
        // _currentPlan = "BS-Final-Weekly";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _handlePlanUpgrade(String newPlanId) {
    setState(() {
      _currentPlan = newPlanId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      shrinkContent: true,
      selectedPage: 4,
      child: Padding(
        padding:
            const EdgeInsetsDirectional.only(top: 3, start: 28.0, end: 28.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, size: 24),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Billing & Plans',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Manage customer billing and plans.",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // if (_currentPlan != null)
                      //   CurrentPlanInfo(currentPlan: _currentPlan!),
                      const SizedBox(height: 10),

                      // Subscription Cards - Showing Only Foundation Plans as per local setup
                      // Wrap(
                      //   spacing: 24,
                      //   runSpacing: 24,
                      //   children: [
                      //     _buildPlanCard("Daily", "Daily access", "396", "pdt_0NVFxDHXtczvsMmgB1c6E"),
                      //     _buildPlanCard("Weekly", "Weekly access", "2772", "pdt_0NVGKxMFFCmbFsuzZABTd"),
                      //     _buildPlanCard("Monthly", "Monthly access", "11880", "pdt_0NVGLbZZxB5JyzrCJ55Mc"),
                      //     _buildPlanCard("Term", "Per Term access", "42768", "pdt_0NVGPZdbcG8Rvx4uGh5Sy"),
                      //     _buildPlanCard("Lifetime", "Yearly access", "33264", "pdt_0NVGd7TKu9mv4Fd1BuLmM"),
                      //   ],
                      // ),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          // Change these lines to use Intermediate keys and prices
                          _buildPlanCard("Daily", "Daily access", "1192",
                              "pdt_0NVGeoqi2dUcbicacTWq1"),
                          _buildPlanCard("Weekly", "Weekly access", "8344",
                              "pdt_0NVP76bBAslPrshj79K8o"),
                          _buildPlanCard("Monthly", "Monthly access", "35760",
                              "pdt_0NVOyUZny1LqG2fU2vmYx"),
                          _buildPlanCard("Term", "Per Term access", "128736",
                              "pdt_0NVOz9ffQL0VMhrwThKTd"),
                          _buildPlanCard("Yearly", "Yearly access", "71520",
                              "pdt_0NVP169WEIqUkk8VXKcga"),
                        ],
                      ),
                      // Wrap(
                      //       spacing: 24,
                      //       runSpacing: 24,
                      //       children: [
                      //         // Final Level Plans
                      //         _buildPlanCard("Daily", "Daily access", "1194", "BS-Final-Daily"),
                      //         _buildPlanCard("Weekly", "Weekly access", "8358", "BS-Final-Weekly"),
                      //         _buildPlanCard("Monthly", "Monthly access", "35820", "BS-Final-Monthly"),
                      //         _buildPlanCard("Term", "Per Term access", "128952", "BS-Final-Term"),
                      //         _buildPlanCard("Yearly", "Yearly access", "71640", "BS-Final-Yearly"),
                      //       ],
                      //     ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPlanCard(
      String title, String subtitle, String price, String planId) {
    // Placeholder features matching the design's "Lorem ipsum" style visually
    List<String> features = [
      "Lorem Ipsum is simply dummy text",
      "Lorem Ipsum is simply dummy text",
      "Lorem Ipsum is simply dummy text",
      "Lorem Ipsum is simply dummy text",
      "Lorem Ipsum is simply dummy text",
    ];

    return SizedBox(
      width: 230, // Narrower to fit 5 in a row
      child: BillingCard(
        title: title,
        subtitle: subtitle,
        price: "₹$price",
        features: features,
        currentPlan: _currentPlan,
        planKey: planId,
        onUpgraded: _handlePlanUpgrade,
      ),
    );
  }
}

class CurrentPlanInfo extends StatelessWidget {
  final String currentPlan;

  const CurrentPlanInfo({required this.currentPlan, super.key});

  @override
  Widget build(BuildContext context) {
    // Keep existing simplified info or hide if preferred.
    // Design doesn't show this explicit banner, but it's good UX.
    // Will keep it minimal.
    if (currentPlan.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.black87),
          const SizedBox(width: 10),
          Text(
            "Current Plan: $currentPlan",
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class BillingCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String price;
  final List<String> features;
  final String? currentPlan;
  final String planKey;
  final ValueChanged<String>? onUpgraded;

  const BillingCard(
      {required this.title,
      required this.subtitle,
      required this.price,
      required this.features,
      this.currentPlan,
      required this.planKey,
      this.onUpgraded,
      super.key});

  @override
  State<BillingCard> createState() => _BillingCardState();
}

class _BillingCardState extends State<BillingCard> {
  bool _isHovered = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final bool isCurrentPlan = widget.currentPlan == widget.planKey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCurrentPlan
                ? Colors.black
                : (_isHovered ? Colors.black54 : Colors.grey.shade200),
            width: isCurrentPlan ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.price,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle, // "Lorem ipsum..."
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Features List
            Column(
              children: widget.features.map((f) => BillingFeature(f)).toList(),
            ),

            const SizedBox(height: 24),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(_errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    )),
              ),

            const SizedBox(height: 24), // Push button to bottom

            SizedBox(
              width: 140, // Small pill button
              height: 36,
              child: ElevatedButton(
                onPressed: (isCurrentPlan || _isLoading)
                    ? null
                    : () async {
                        setState(() => _isLoading = true);

                        // 1. Get User Details
                        final email =
                            LocalStorage.getUserEmail() ?? "test@example.com";
                        final userId =
                            LocalStorage.getUserID() ?? "unknown_user";

                        // 2. Call Dodo Service
                        await DodoService.subscribe(
                            widget.planKey, email, userId);

                        // 3. Immediately update UI to show this as Current Plan (Local Simulation)
                        widget.onUpgraded?.call(widget.planKey);

                        setState(() => _isLoading = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors
                      .black, // Keep black even if disabled (current plan)
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isCurrentPlan ? "Current Plan" : "Upgrade",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class BillingFeature extends StatelessWidget {
  final String text;
  const BillingFeature(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.check_circle_outline_rounded,
            color: Colors.black54, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    color: Colors.grey.shade700, fontSize: 11, height: 1.3)))
      ]),
    );
  }
}
