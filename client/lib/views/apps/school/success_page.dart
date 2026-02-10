import 'package:binary_success/helpers/constant/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PaymentSuccessPageIn extends StatefulWidget {
  const PaymentSuccessPageIn({super.key});

  @override
  State<PaymentSuccessPageIn> createState() => _PaymentSuccessPageInState();
}

class _PaymentSuccessPageInState extends State<PaymentSuccessPageIn> {
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
    // Get query parameters from URL
    // Get query parameters from URL (Mock for mobile)
    final uri = Uri.parse("https://binarysuccess.com/?account-id=mock&planName=mock");
    final accountId = uri.queryParameters['account-id'];
    final planName = uri.queryParameters['planName'];
    final currency = 'USD';

    if (accountId == null || planName == null) {
      setState(() {
        _isLoading = false;
        _error = 'Missing account ID or plan name in the URL.';
      });
      return;
    }

    _planName = planName;

   final apiUrl =
    "${API.baseURl}/killbill/finalize-subscription?account_id=$accountId&plan=$planName&currency=$currency";


    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json',
        },
        body: '', // matches `-d ''` in curl
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
          _message = 'Congrats! You successfully subscribed to "$planName".';
        });
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text(
          _message ?? '',
          style: const TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          child: const Text("Back to Billing"),
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
        Text(
          _error ?? 'Unknown error.',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          child: const Text("Back to Billing"),
        )
      ],
    );
  }
}
