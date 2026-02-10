import 'package:flutter/material.dart';

class PaymentFailedPage extends StatelessWidget {
  final bool isOnboarding;
  const PaymentFailedPage({super.key, this.isOnboarding = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text("Payment Failed!", style: TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            const Text("Please try again or contact support if the problem persists.", 
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isOnboarding) {
                  // Return to onboarding with failure result
                  Navigator.of(context).pop('fail');
                } else {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: Text(isOnboarding ? "Try Again" : "Back to Billing"),
            )
          ],
        ),
      ),
    );
  }
}