import 'dart:convert';
import 'package:binary_success/models/student_subscription_model.dart';

class SubscriptionService {
  // Mock JSON data matching the design
  final String _mockJson = '''
  [
    {
      "title": "Daily Plan",
      "price": "\$00.00",
      "description": "Lorem Ipsum is simply dummy text",
      "isActive": false,
      "features": [
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text"
      ]
    },
    {
      "title": "Weekly Plan",
      "price": "\$00.00",
      "description": "Lorem Ipsum is simply dummy text",
      "isActive": false,
      "features": [
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text"
      ]
    },
    {
      "title": "Monthly Plan",
      "price": "\$00.00",
      "description": "Lorem Ipsum is simply dummy text",
      "isActive": true,
      "features": [
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text"
      ]
    },
    {
      "title": "Term Plan",
      "price": "\$00.00",
      "description": "Lorem Ipsum is simply dummy text",
      "isActive": false,
      "features": [
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text"
      ]
    },
    {
      "title": "Annual Plan",
      "price": "\$00.00",
      "description": "Lorem Ipsum is simply dummy text",
      "isActive": false,
      "features": [
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text",
        "Lorem Ipsum is simply dummy text"
      ]
    }
  ]
  ''';

  Future<List<Plan>> getPlans() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    final List<dynamic> data = jsonDecode(_mockJson);
    return data.map((json) => Plan.fromJson(json)).toList();
  }
}
