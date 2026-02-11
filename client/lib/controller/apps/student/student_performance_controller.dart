import 'package:get/get.dart';
import 'package:vantanceCA/models/student_performance_report_question_model.dart';
import 'package:vantanceCA/services/question_service.dart';

class StudentPerformanceController extends GetxController {
  final QuestionService _questionService = QuestionService();
  
  var isLoading = true.obs;
  var allQuestions = <Question>[].obs;
  var statusFilter = Rxn<QuestionStatus>();

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;
      final questions = await _questionService.getQuestions();
      allQuestions.value = questions;
    } catch (e) {
      print("Error loading questions: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(QuestionStatus? status) {
    statusFilter.value = status;
  }

  List<Question> get filteredQuestions {
    if (statusFilter.value == null) {
      return allQuestions;
    }
    return allQuestions.where((q) => q.status == statusFilter.value).toList();
  }
}
