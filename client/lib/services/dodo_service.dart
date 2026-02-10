// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:binary_success/helpers/constant/app_constant.dart'; // Ensure this has API.baseURl

// class DodoService {
//   static Future<void> subscribe(String planKey, String userEmail, String userId) async {
//     // Construct URL: http://.../payment/dodo/initiate
//     final url = Uri.parse('${API.baseURl}/payment/dodo/initiate');
    
//     try {
//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "user_id": userId,
//           "email": userEmail,
//           "product_id": planKey, // e.g. "BS-Foundation-Daily"
//           "return_url": "https://yoursite.com/payment-success" 
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final String checkoutUrl = data['checkoutUrl'];
//         final uri = Uri.parse(checkoutUrl);
        
//         if (await canLaunchUrl(uri)) {
//           await launchUrl(uri, mode: LaunchMode.externalApplication);
//         } else {
//           print("Could not launch $checkoutUrl");
//         }
//       } else {
//         print("Failed: ${response.body}");
//       }
//     } catch (e) {
//       print("Error initiating payment: $e");
//     }
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb

class DodoService {

    //   static const String baseUrl = "http://10.0.2.2:8000"; 
    static String get baseUrl {
        if (kIsWeb) {
        return "http://localhost:8000"; // For Web
        } else if (Platform.isAndroid) {
        return "http://10.0.2.2:8000"; // For Android Emulator
        } else {
        return "http://localhost:8000"; // For iOS Simulator
        }
    }

  static Future<void> subscribe(String planKey, String userEmail, String userId) async {
    final url = Uri.parse('$baseUrl/payment/dodo/initiate');
    
    print("Initiating Dodo Payment for $planKey...");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "email": userEmail,
          "product_id": planKey, // e.g. "BS-Foundation-Daily"
          "return_url": "https://google.com" // Redirect back to app later
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String checkoutUrl = data['checkoutUrl'];
        print("✅ Checkout URL: $checkoutUrl");
        
        final uri = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print("❌ Could not launch url");
        }
      } else {
        print("❌ Server Error: ${response.body}");
      }
    } catch (e) {
      print("❌ App Error: $e");
      // Fallback for local simulation: Mock a successful checkout launch
      print("⚠️ Server unavailable. Using local mock for testing.");
      final mockUrl = Uri.parse("https://google.com"); 
      if (await canLaunchUrl(mockUrl)) {
        await launchUrl(mockUrl, mode: LaunchMode.externalApplication);
      }
    }
  }
}