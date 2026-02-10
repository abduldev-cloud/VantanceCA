enum QuestionStatus {
  notAnswered,
  wrongAnswered,
  partiallyAnswered,
  correctAnswered,
}

class Question {
  final int id;
  final String title;
  final String description;
  final QuestionStatus status;
  final double progressStart; // 0.0 to 1.0
  final double progressEnd;   // 0.0 to 1.0

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.progressStart,
    required this.progressEnd,
  });
  
  String get statusText {
    switch (status) {
      case QuestionStatus.notAnswered: return "Not Answered";
      case QuestionStatus.wrongAnswered: return "Wrong Answered";
      case QuestionStatus.partiallyAnswered: return "Partially Answered";
      case QuestionStatus.correctAnswered: return "Correct Answered";
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    
    return Question(
      id: json['id'] is int ? json['id'] : (json['question_id'] is int ? json['question_id'] : 0),
      title: json['title'] is String ? json['title'] : "Question",
      description: json['description'] is String ? json['description'] : (json['text'] is String ? json['text'] : ''),
      status: _parseStatus(json['status'] is String ? json['status'] : 'notAnswered'),
      progressStart: (json['progressStart'] as num?)?.toDouble() ?? 0.0,
      progressEnd: (json['progressEnd'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static QuestionStatus _parseStatus(String statusStr) {
    switch (statusStr) {
      case 'notAnswered': return QuestionStatus.notAnswered;
      case 'wrongAnswered': return QuestionStatus.wrongAnswered;
      case 'partiallyAnswered': return QuestionStatus.partiallyAnswered;
      case 'correctAnswered': return QuestionStatus.correctAnswered;
      default: return QuestionStatus.notAnswered;
    }
  }
}
