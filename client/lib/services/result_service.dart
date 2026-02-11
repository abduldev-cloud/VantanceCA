import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:vantanceCA/models/result_model.dart';

class ResultService {
  Future<List<ResultModel>> getResults() async {
    try {
      final String response = await rootBundle.loadString('datas/results.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => ResultModel.fromJson(json)).toList();
    } catch (e) {
      print("Error loading results: $e");
      return [];
    }
  }
}
