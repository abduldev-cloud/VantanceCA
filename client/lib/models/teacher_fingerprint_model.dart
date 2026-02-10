import 'dart:convert';

TeachersFingerPrintModel teachersFingerPrintModelFromJson(String str) =>
    TeachersFingerPrintModel.fromJson(json.decode(str));

String teachersFingerPrintModelToJson(TeachersFingerPrintModel data) =>
    json.encode(data.toJson());


class TeachersFingerPrintModel {
  final String? classId;
  final String? className;
  final String? classDescription;
  final String? term;
  final int? academicYear;
  final String? classStatus;
  final String? teacherId;
  final String? teacherName;
  final String? gradeName;
  final int? totalStudents;
  final int? fingerprintsSubmitted;
  final int? numActiveAssignments;


  final String? lastFingerprintTaskId;

  
  String? get taskId => lastFingerprintTaskId;

  TeachersFingerPrintModel({
    this.classId,
    this.className,
    this.classDescription,
    this.term,
    this.academicYear,
    this.classStatus,
    this.teacherId,
    this.teacherName,
    this.gradeName,
    this.totalStudents,
    this.fingerprintsSubmitted,
    this.numActiveAssignments,
    this.lastFingerprintTaskId,
  });

  factory TeachersFingerPrintModel.fromJson(Map<String, dynamic> json) =>
      TeachersFingerPrintModel(
        classId: json["class_id"],
        className: json["class_name"],
        classDescription: json["description"],
        term: json["term"],
        academicYear: json["academic_year"],
        classStatus: json["class_status"],
        teacherId: json["teacher_id"],
        teacherName: json["teacher_name"],
        gradeName: json["grade_name"],
        totalStudents: json["num_students"],
        fingerprintsSubmitted: json["num_last_fingerprint_submitted"],
        numActiveAssignments: json["num_active_assignments"],
        lastFingerprintTaskId: json["last_fingerprint_task_id"],
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "description": classDescription,
        "term": term,
        "academic_year": academicYear,
        "class_status": classStatus,
        "teacher_id": teacherId,
        "teacher_name": teacherName,
        "grade_name": gradeName,
        "num_students": totalStudents,
        "num_last_fingerprint_submitted": fingerprintsSubmitted,
        "num_active_assignments": numActiveAssignments,
        "last_fingerprint_task_id": lastFingerprintTaskId,
      };
}


class TeacherSummary {
  final String? teacherId;
  final String? salutation;
  final String? firstName;
  final String? lastName;
  final int? totalLearners;

  TeacherSummary({
    this.teacherId,
    this.salutation,
    this.firstName,
    this.lastName,
    this.totalLearners,
  });

  factory TeacherSummary.fromJson(Map<String, dynamic> json) => TeacherSummary(
        teacherId: json["teacher_id"],
        salutation: json["salutation"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        totalLearners: json["total_learners"],
      );
}


class ClassStatusCount {
  final int? activeClasses;
  final int? archivedClasses;

  ClassStatusCount({
    this.activeClasses,
    this.archivedClasses,
  });

  factory ClassStatusCount.fromJson(Map<String, dynamic> json) => ClassStatusCount(
        activeClasses: json["active_classes"],
        archivedClasses: json["archived_classes"],
      );
}


class ClassDetails {
  final String? classId;
  final String? className;
  final String? description;
  final String? classStatus;
  final int? numStudents;
  final int? numActiveAssignments;
  final String? term;
  final int? academicYear;
  final String? gradeName;
  final int? numLastFingerprintSubmitted;


  final String? lastFingerprintTaskId;


  String? get taskId => lastFingerprintTaskId;

  ClassDetails({
    this.classId,
    this.className,
    this.description,
    this.classStatus,
    this.numStudents,
    this.numActiveAssignments,
    this.term,
    this.academicYear,
    this.gradeName,
    this.numLastFingerprintSubmitted,
    this.lastFingerprintTaskId,
  });

  factory ClassDetails.fromJson(Map<String, dynamic> json) => ClassDetails(
        classId: json["class_id"],
        className: json["class_name"],
        description: json["description"],
        classStatus: json["class_status"],
        numStudents: json["num_students"],
        numActiveAssignments: json["num_active_assignments"],
        term: json["term"],
        academicYear: json["academic_year"],
        gradeName: json["grade_name"],
        numLastFingerprintSubmitted: json["num_last_fingerprint_submitted"],
        lastFingerprintTaskId: json["last_fingerprint_task_id"],
      );
}
