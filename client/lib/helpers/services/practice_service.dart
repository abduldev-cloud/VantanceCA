import 'dart:convert';
import 'package:binary_success/models/question.dart';
import 'package:flutter/services.dart';
class QuizService {
  Future<List<Question>> fetchQuestions() async {
    try {
      // Load the JSON file from assets
      final String response =
          await rootBundle.loadString('assets/datas/questions.json');
      final List<dynamic> data = json.decode(response);

      // Convert JSON list to List<Question>
      return data.map((json) => Question.fromMap(json)).toList();
    } catch (e) {
      print('Error loading questions: $e');
      // Return empty list or throw error depending on requirements
      return [];
    }
  }
}
