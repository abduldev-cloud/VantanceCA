import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:vantanceCA/helpers/storage/local_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'payment_success_page.dart';

class BillingPage extends StatefulWidget {
  final bool isOnboarding;
  const BillingPage({super.key, this.isOnboarding = false});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  String? _currentPlan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // During onboarding, skip fetching current plan (user may not exist yet)
    if (widget.isOnboarding) {
      _currentPlan = "None";
      _loading = false;
      setState(() {});
    } else {
      fetchPlan();
    }
  }

  Future<void> fetchPlan() async {
    final email = LocalStorage.getUserEmail();
    if (email == null) {
      setState(() => _loading = false);
      return;
    }

    try {
     final uri = Uri.parse(
  "${API.baseURl}/killbill/user-plan?email=${Uri.encodeComponent(email)}",
);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _currentPlan = data['plan']);
      } else {
        debugPrint('Failed to fetch plan info: ${response.statusCode}');
        _currentPlan = "None";
      }
    } catch (e) {
      debugPrint('Exception fetching plan: $e');
      _currentPlan = "None";
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget.isOnboarding
      //     ? AppBar(
      //         title: const Text('Select Your Plan'),
      //         automaticallyImplyLeading: false,
      //       )
      //     : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_currentPlan != null && _currentPlan != "None") {
      return PremiumInfo(isOnboarding: widget.isOnboarding, planName: _currentPlan!);
    } else {
      return BillingOptions(isOnboarding: widget.isOnboarding);
    }
  }
}

class PremiumInfo extends StatelessWidget {
  final bool isOnboarding;
  final String planName;

  const PremiumInfo({super.key, required this.isOnboarding, required this.planName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billing & Plans', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'You\'re currently on the $planName Plan.\nYour subscription will auto-renew annually.',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (isOnboarding) ...[
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop('success'),
                child: const Text('Continue to Onboarding'),
              ),
            )
          ]
        ],
      ),
    );
  }
}

class BillingOptions extends StatelessWidget {
  final bool isOnboarding;
  const BillingOptions({super.key, required this.isOnboarding});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Billing & Plans', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Manage customer billing and plans.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0), // space left & right
                        child: BillingCard(isBasic: true, isOnboarding: isOnboarding),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0), // space left & right
                        child: BillingCard(isBasic: false, isOnboarding: isOnboarding),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // side space
                      child: BillingCard(isBasic: true, isOnboarding: isOnboarding),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0), // side space
                      child: BillingCard(isBasic: false, isOnboarding: isOnboarding),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class BillingCard extends StatefulWidget {
  final bool isBasic;
  final bool isOnboarding;

  const BillingCard({required this.isBasic, required this.isOnboarding, super.key});

  @override
  State<BillingCard> createState() => _BillingCardState();
}

class _BillingCardState extends State<BillingCard> {
  bool _isHovered = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final bool isBasic = widget.isBasic;

    final List<String> features = isBasic
        ? [
            "AI Smart Grading with Recommended Grade",
            "AI-generated student submission summaries",
            "Dashboard to track usage and writing patterns",
            "Up to 10 prompts per student per assignment",
            "AI-generated assignment prompts for Teachers",
            "Admin view for full school oversight",
          ]
        : [
            "Split Screen Student Writing Interface",
            "Teacher Dashboard with AI Assistance control",
            "Full report to student AI use",
            "Up to 5 prompts per student per assignment",
            "Authorship confidence with Writing Fingerprint",
            "Manual grading with teacher's own rubric",
          ];

    final String title = isBasic ? "Basic - Sandbox Access" : "Essentials";
    final String price = isBasic ? "\$0" : "\$199";
    final String footer = isBasic
        ? "Best for: Time-saving teachers, AI-at-scale classrooms, school-wide use"
        : "Best for: teachers testing AI, small pilots, budget-conscious schools";
    final String buttonText = isBasic ? "Get Sandbox Access" : "Get Unlimited Now";

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFCB6CE6), Color(0xFF004AAD)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? Colors.white.withOpacity(0.7) : Colors.transparent,
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text("Annual Plan", style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 16),
            Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ...features.map((f) => BillingFeature(f, color: Colors.white)),
            const SizedBox(height: 16),
            Text(footer, style: TextStyle(color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
              ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final String plan = isBasic ? "Basic" : "Essentials";

                      // Prefer temp details during onboarding; fall back to logged-in user
                      final temp = LocalStorage.getTemporaryUserDetails();
                      final String name = widget.isOnboarding
                          ? "${temp?["first_name"] ?? ""} ${temp?["last_name"] ?? ""}".trim()
                          : (LocalStorage.getUserName() ?? "User");
                      final String? email = widget.isOnboarding
                          ? (temp?["email"])
                          : LocalStorage.getUserEmail();

                      if (email == null || email.isEmpty) {
                        setState(() {
                          _isLoading = false;
                          _errorMessage = 'Email is missing. Please go back and fill onboarding details.';
                        });
                        return;
                      }

                      // For Basic (free) plan, skip API & go straight to success page
                      if (isBasic) {
                      final uri = Uri.parse(
  "${API.baseURl}/killbill/initiate-subscription?plan=$plan",
);


                        final body = {
                          "name": name.isEmpty ? "User" : name,
                          "email": email,
                          "currency": "USD",
                          "company": "Binary Success",
                          "phone": "0000000"
                        };

                        try {
                          final response = await http.post(
                            uri,
                            headers: {
                              "accept": "application/json",
                              "Content-Type": "application/json",
                            },
                            body: jsonEncode(body),
                          );

                          if (response.statusCode == 200) {
                            // Go directly to success page and replace BillingPage
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => PaymentSuccessPage(
                                  isOnboarding: widget.isOnboarding,
                                  planNameFromApp: 'Basic',
                                  accountIdFromApp: null,
                                ),
                              ),
                            );
                          } else {
                            final errorData = jsonDecode(response.body);
                            setState(() => _errorMessage = errorData['detail'] ?? 'Something went wrong.');
                          }
                        } catch (e) {
                          debugPrint("Exception during subscription: $e");
                          setState(() => _errorMessage = 'Failed to start Basic plan.');
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }

                        return;
                      }

                    final uri = Uri.parse(
  "${API.baseURl}/killbill/initiate-subscription?plan=$plan",
);


                      final body = {
                        "name": name.isEmpty ? "User" : name,
                        "email": email,
                        "currency": "USD",
                        "company": "Binary Success",
                        "phone": "0000000"
                      };

                      try {
                        final response = await http.post(
                          uri,
                          headers: {
                            "accept": "application/json",
                            "Content-Type": "application/json",
                          },
                          body: jsonEncode(body),
                        );

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          final String checkoutUrl = data['checkoutUrl'];

                          if (checkoutUrl.isNotEmpty) {
                            if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
                              await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);

                              if (widget.isOnboarding && mounted) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Payment Processing'),
                                      content: const Text('Your payment is being processed. You will be redirected once completed.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } else {
                              throw 'Could not launch $checkoutUrl';
                            }
                          }
                        } else {
                          final errorData = jsonDecode(response.body);
                          final message = errorData['detail'] ?? 'Something went wrong.';
                          setState(() => _errorMessage = message);
                        }
                      } catch (e) {
                        debugPrint("Exception during subscription: $e");
                        setState(() => _errorMessage = 'Failed to start subscription.');
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 252, 252, 252)),
                      ),
                    )
                  : Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class BillingFeature extends StatelessWidget {
  final String text;
  final Color? color;
  const BillingFeature(this.text, {this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: color ?? Colors.black54, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color ?? Colors.black87))),
        ],
      ),
    );
  }
}