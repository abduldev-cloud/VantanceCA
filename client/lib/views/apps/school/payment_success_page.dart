import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:binary_success/helpers/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:binary_success/controller/error_pages/onboarding_controller.dart';
// at the top

class PaymentSuccessPage extends StatefulWidget {
  final bool isOnboarding;

  // NEW: allow passing values directly from the app (no URL needed for Basic plan)
  final String? planNameFromApp;
  final String? accountIdFromApp;

  const PaymentSuccessPage(
      {super.key,
      this.isOnboarding = false,
      this.planNameFromApp,
      this.accountIdFromApp});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isLoading = true;
  String? _planName;
  String? _message;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleSubscription();
  }

  Future<void> _handleSubscription() async {
    // Prefer values provided by the app; fall back to URL
    // Prefer values provided by the app; fall back to URL (Mock for mobile)
    final url = Uri.parse("https://binarysuccess.com");
    final String? planName =
        widget.planNameFromApp ?? url.queryParameters['planName'];
    final String? accountId =
        widget.accountIdFromApp ?? url.queryParameters['account-id'];

    if (planName == null) {
      setState(() {
        _isLoading = false;
        _error = 'Missing plan name.';
      });
      return;
    }

    _planName = planName;

    if (planName.toLowerCase() == "basic") {
      setState(() {
        _isLoading = false;
        _message = 'Congrats! You are now on the free "$planName" plan.';
      });

      if (widget.isOnboarding) {
        final controller = Get.put(OnboardingController(persona: 'school'));
        await Future.delayed(const Duration(seconds: 1));
        await controller.acceptInvite();
      }

      return;
    }

    if (accountId == null) {
      setState(() {
        _isLoading = false;
        _error = 'Missing account ID for paid plan.';
      });
      return;
    }
    final apiUrl =
        "${API.subscriptionBaseUrl}?account-id=$accountId&planName=$planName";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _message = 'Congrats! You successfully subscribed to "$planName".';
        });

        if (widget.isOnboarding && planName.toLowerCase() == "essentials") {
          final controller = Get.put(OnboardingController(persona: 'school'));
          await Future.delayed(const Duration(seconds: 1));
          await controller.acceptInvite();
        }
      } else {
        setState(() {
          _isLoading = false;
          _error =
              'Subscription failed. Server responded with ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error during subscription: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? _buildErrorView()
                : _buildSuccessView(),
      ),
    );
  }

  Widget _buildSuccessView() {
    if (_planName?.toLowerCase() == "basic" && widget.isOnboarding) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 20),
          Text('Congrats! You are now on the free "Basic" plan.',
              style: TextStyle(fontSize: 22), textAlign: TextAlign.center),
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Completing onboarding...', style: TextStyle(fontSize: 16)),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text(_message ?? '',
            style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            debugPrint(
                "👉 Collecting temp user details and calling acceptInvite");

            final controller = Get.put(OnboardingController(persona: 'school'));

            try {
              final tempDetails = LocalStorage.getTemporaryUserDetails();

              if (tempDetails == null) {
                debugPrint("❌ No temporary user details found in LocalStorage");
                Get.snackbar("Error",
                    "Missing temporary user details. Please try onboarding again.");
                return;
              }

              debugPrint("📦 Temp user details loaded: $tempDetails");

              await controller.acceptInviteFromTempDetails(tempDetails);

              debugPrint("✅ acceptInvite finished successfully");
            } catch (e, s) {
              debugPrint("❌ acceptInvite failed: $e");
              debugPrintStack(stackTrace: s);
            }
          },
          child: const Text("Back to Billings"),
        )
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 80),
        const SizedBox(height: 20),
        Text(_error ?? 'Unknown error.',
            style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            if (widget.isOnboarding) {
              final controller =
                  Get.put(OnboardingController(persona: 'school'));
              await controller.acceptInvite();
              Navigator.of(context).pop('success');
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
          child: Text(widget.isOnboarding
              ? "Complete Onboarding"
              : "Back to Billings1"),
        )
      ],
    );
  }
}
