
class ClassStudentsResponse {
  final List<Student>? studentsList;
  final ClassSummary? classSummary;

  ClassStudentsResponse({this.studentsList, this.classSummary});

  factory ClassStudentsResponse.fromJson(Map<String, dynamic> json) => ClassStudentsResponse(
        studentsList: json["students_list"] == null
            ? null
            : List<Student>.from(json["students_list"].map((x) => Student.fromJson(x))),
        classSummary: json["class_summary"] != null && json["class_summary"].isNotEmpty
            ? ClassSummary.fromJson(json["class_summary"][0])
            : null,
      );
}

class ClassSummary {
  final int? totalSubmitted;
  final int? totalPendingReview;
  final double? avgTeacherGrade;

  ClassSummary({
    this.totalSubmitted,
    this.totalPendingReview,
    this.avgTeacherGrade,
  });

  factory ClassSummary.fromJson(Map<String, dynamic> json) => ClassSummary(
        totalSubmitted: json["total_submitted"],
        totalPendingReview: json["total_pending_review"],
        avgTeacherGrade: json["avg_teacher_grade"]?.toDouble(),
      );
}

class Student {
  final String? learnerId;
  final String? salutation;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? learnerStatus;
  final String? hasFingerprintSubmitted;

  Student({
    this.learnerId,
    this.salutation,
    this.firstName,
    this.lastName,
    this.email,
    this.learnerStatus,
    this.hasFingerprintSubmitted,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        learnerId: json["learner_id"],
        salutation: json["salutation"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        learnerStatus: json["learner_status"],
        hasFingerprintSubmitted: json["has_fingerprint_submitted"],
      );
}
