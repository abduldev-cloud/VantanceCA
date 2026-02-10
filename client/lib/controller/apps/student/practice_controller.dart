import 'dart:async';
import 'dart:convert';
import 'package:binary_success/helpers/services/practice_service.dart';
import 'package:binary_success/models/question.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizController extends ChangeNotifier {
  final QuizService _quizService = QuizService();

  // State
  int _currentQuestionIndex = 0;
  int _remainingSeconds = 60 * 60; // 1 hour
  Timer? _timer;
  bool _isLoading = true;
  bool _isExamSubmitted = false;
  bool _isTimerPaused = false;

  // Callback for when time runs out
  VoidCallback? onTimeUp;

  // Data
  final Map<int, List<String>> _savedAnswers = {};
  List<Question> _questions = [];

  // Getters
  int get currentQuestionIndex => _currentQuestionIndex;
  int get remainingSeconds => _remainingSeconds;
  int get totalTimeSeconds => 60 * 60;
  bool get isLoading => _isLoading;
  bool get isExamSubmitted => _isExamSubmitted;
  bool get isTimerPaused => _isTimerPaused;
  List<Question> get questions => _questions;

  Question get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      // Return a dummy question or handle error gracefully
      return Question(title: 'Loading...', text: '', subtext: '', bullets: []);
    }
    return _questions[_currentQuestionIndex];
  }

  List<String> getSavedAnswersForCurrentQuestion() =>
      _savedAnswers[_currentQuestionIndex] ?? [];

  QuizController() {
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load questions
      _questions = await _quizService.fetchQuestions();

      // Try to restore saved state
      await _restoreState();

      startTimer();
    } catch (e) {
      print("Error in controller loading questions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Restore timer
      final savedTime = prefs.getInt('quiz_remaining_seconds');
      if (savedTime != null && savedTime > 0) {
        _remainingSeconds = savedTime;
      }

      // Restore current question index
      final savedIndex = prefs.getInt('quiz_current_question');
      if (savedIndex != null && savedIndex < _questions.length) {
        _currentQuestionIndex = savedIndex;
      }

      // Restore saved answers
      final savedAnswersJson = prefs.getString('quiz_saved_answers');
      if (savedAnswersJson != null) {
        final Map<String, dynamic> decoded = json.decode(savedAnswersJson);
        _savedAnswers.clear();
        decoded.forEach((key, value) {
          _savedAnswers[int.parse(key)] = List<String>.from(value);
        });
      }

      // Restore exam submitted state
      final submitted = prefs.getBool('quiz_exam_submitted') ?? false;
      _isExamSubmitted = submitted;
    } catch (e) {
      print("Error restoring state: $e");
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save timer
      await prefs.setInt('quiz_remaining_seconds', _remainingSeconds);

      // Save current question index
      await prefs.setInt('quiz_current_question', _currentQuestionIndex);

      // Save answers
      final answersMap = <String, dynamic>{};
      _savedAnswers.forEach((key, value) {
        answersMap[key.toString()] = value;
      });
      await prefs.setString('quiz_saved_answers', json.encode(answersMap));

      // Save exam submitted state
      await prefs.setBool('quiz_exam_submitted', _isExamSubmitted);
    } catch (e) {
      print("Error saving state: $e");
    }
  }

  Future<void> clearSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('quiz_remaining_seconds');
      await prefs.remove('quiz_current_question');
      await prefs.remove('quiz_saved_answers');
      await prefs.remove('quiz_exam_submitted');
    } catch (e) {
      print("Error clearing state: $e");
    }
  }

  // Actions
  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && !_isTimerPaused) {
        _remainingSeconds--;
        // Save state every 5 seconds to avoid too frequent writes
        if (_remainingSeconds % 5 == 0) {
          _saveState();
        }
        notifyListeners();
      } else if (_remainingSeconds == 0) {
        _timer?.cancel();
        // Auto-submit when time is up
        _isExamSubmitted = true;
        _saveState();
        notifyListeners();
        onTimeUp?.call();
      }
    });
  }

  void pauseTimer() {
    _isTimerPaused = true;
    notifyListeners();
  }

  void resumeTimer() {
    _isTimerPaused = false;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _saveState();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      _saveState();
      notifyListeners();
    }
  }

  void saveAnswer(String answer) {
    if (answer.isEmpty) return;

    if (!_savedAnswers.containsKey(_currentQuestionIndex)) {
      _savedAnswers[_currentQuestionIndex] = [];
    }

    _savedAnswers[_currentQuestionIndex]!.add(answer);
    _saveState();
    notifyListeners();
  }

  void deleteAnswer(int index) {
    if (_savedAnswers.containsKey(_currentQuestionIndex)) {
      _savedAnswers[_currentQuestionIndex]!.removeAt(index);
      if (_savedAnswers[_currentQuestionIndex]!.isEmpty) {
        _savedAnswers.remove(_currentQuestionIndex);
      }
      _saveState();
      notifyListeners();
    }
  }

  void submitExam() {
    _timer?.cancel();
    _isExamSubmitted = true;
    _saveState();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Save state before disposing
    _saveState();
    super.dispose();
  }
}
