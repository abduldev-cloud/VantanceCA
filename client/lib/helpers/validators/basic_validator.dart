import 'package:flutter/material.dart';

class BasicValidator {
  final List<String> fields;
  final Map<String, TextEditingController> _controllers = {};
  final formKey = GlobalKey<FormState>();

  BasicValidator({required this.fields}) {
    for (var field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  TextEditingController getController(String field) {
    return _controllers[field]!;
  }

  String? Function(String?) getValidation(String field) {
    switch (field) {
      case 'email':
        return (value) {
          if (value == null || value.isEmpty) {
            return 'Email is required';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Enter a valid email';
          }
          return null;
        };
      default:
        return (value) => null;
    }
  }
}
