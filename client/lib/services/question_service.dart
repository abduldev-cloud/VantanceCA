import 'dart:convert';
import 'package:vantanceCA/models/student_performance_report_question_model.dart';
import 'package:flutter/services.dart';

class QuestionService {
  /// Simulates fetching questions from a backend.
  /// Returns a Future to mimic network delay.
  Future<List<Question>> getQuestions() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      final String response = await rootBundle.loadString('assets/datas/student_question.json');
      final List<dynamic> parsedList = json.decode(response);
      return parsedList.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      print("Error loading questions: $e");
      return [];
    }
  }
}
