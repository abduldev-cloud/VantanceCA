import 'dart:convert';

StudentClassModel studentClassModelFromJson(String str) =>
    StudentClassModel.fromJson(json.decode(str));

String studentClassModelToJson(StudentClassModel data) =>
    json.encode(data.toJson());

class StudentClassModel {
  final List<LearnerSummary>? learnerSummary;
  final List<ClassDetail>? classDetails;
  final String? outStatus;

  StudentClassModel({
    this.learnerSummary,
    this.classDetails,
    this.outStatus,
  });

  factory StudentClassModel.fromJson(Map<String, dynamic> json) =>
      StudentClassModel(
        learnerSummary: json["learner_summary"] == null
            ? []
            : List<LearnerSummary>.from(
                json["learner_summary"].map((x) => LearnerSummary.fromJson(x))),
        classDetails: json["class_details"] == null
            ? []
            : List<ClassDetail>.from(
                json["class_details"].map((x) => ClassDetail.fromJson(x))),
        outStatus: json["out_status"],
      );

  Map<String, dynamic> toJson() => {
        "learner_summary": learnerSummary == null
            ? []
            : List<dynamic>.from(learnerSummary!.map((x) => x.toJson())),
        "class_details": classDetails == null
            ? []
            : List<dynamic>.from(classDetails!.map((x) => x.toJson())),
        "out_status": outStatus,
      };
}

class LearnerSummary {
  final String? learnerId;
  final String? firstName;
  final String? lastName;
  final String? gradeName;

  LearnerSummary({
    this.learnerId,
    this.firstName,
    this.lastName,
    this.gradeName,
  });

  factory LearnerSummary.fromJson(Map<String, dynamic> json) => LearnerSummary(
        learnerId: json["learner_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        gradeName: json["grade_name"],
      );

  Map<String, dynamic> toJson() => {
        "learner_id": learnerId,
        "first_name": firstName,
        "last_name": lastName,
        "grade_name": gradeName,
      };
}

class ClassDetail {
  final String? classId;
  final String? className;
  final String? description;
  final String? classStatus;
  final int? numStudents;
  final int? numActiveAssignments;
  final String? term;
  final int? academicYear;
  final String? lastFingerprintTaskStatus;

  ClassDetail({
    this.classId,
    this.className,
    this.description,
    this.classStatus,
    this.numStudents,
    this.numActiveAssignments,
    this.term,
    this.academicYear,
    this.lastFingerprintTaskStatus,
  });

  factory ClassDetail.fromJson(Map<String, dynamic> json) => ClassDetail(
        classId: json["class_id"],
        className: json["class_name"],
        description: json["description"],
        classStatus: json["class_status"],
        numStudents: json["num_students"],
        numActiveAssignments: json["num_active_assignments"],
        term: json["term"],
        academicYear: json["academic_year"],
        lastFingerprintTaskStatus: json["last_fingerprint_task_status"],
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "description": description,
        "class_status": classStatus,
        "num_students": numStudents,
        "num_active_assignments": numActiveAssignments,
        "term": term,
        "academic_year": academicYear,
        "last_fingerprint_task_status": lastFingerprintTaskStatus,
      };
}
