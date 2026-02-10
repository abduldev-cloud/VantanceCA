class ResultModel {
  final String title;
  final String description;
  final String subject;
  final String date;
  final String frequency;
  final int na;
  final int wa;
  final int pa;
  final int ca;

  ResultModel({
    required this.title,
    required this.description,
    required this.subject,
    required this.date,
    required this.frequency,
    required this.na,
    required this.wa,
    required this.pa,
    required this.ca,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      date: json['date'] ?? '',
      frequency: json['frequency'] ?? '',
      na: json['na'] ?? 0,
      wa: json['wa'] ?? 0,
      pa: json['pa'] ?? 0,
      ca: json['ca'] ?? 0,
    );
  }
}
