class Question {
  final String title;
  final String text;
  final String subtext;
  final List<String> bullets;

  Question({
    required this.title,
    required this.text,
    required this.subtext,
    required this.bullets,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      subtext: map['subtext'] ?? '',
      bullets: List<String>.from(map['bullets'] ?? []),
    );
  }
}
