import 'dart:convert';

TeacherClassModel teacherClassModelFromJson(String str) =>
    TeacherClassModel.fromJson(json.decode(str));

String teacherClassModelToJson(TeacherClassModel data) =>
    json.encode(data.toJson());

class TeacherClassModel {
  final String? classId;
  final String? className;
  final String? term;
  final String? academicYear;
  final String? isArchived;
  final String? classStatus;
  final String? teacherId;
  final String? teacherName;
  final int? studentCount;
  final String? gradeName;
  final int? fingerprintSubmissions;
  final int? assignmentSubmissions;
  final String? gradeId;

  TeacherClassModel({
    this.classId,
    this.className,
    this.term,
    this.academicYear,
    this.isArchived,
    this.classStatus,
    this.teacherId,
    this.teacherName,
    this.studentCount,
    this.gradeName,
    this.fingerprintSubmissions,
    this.assignmentSubmissions,
    this.gradeId,
    t
  });

  factory TeacherClassModel.fromJson(Map<String, dynamic> json) =>
      TeacherClassModel(
        classId: json["class_id"],
        className: json["class_name"],
        term: json["term"],
        academicYear: json["academic_year"],
        isArchived: json["is_archived"],
        classStatus: json["class_status"],
        teacherId: json["teacher_id"],
        teacherName: json["teacher_name"],
        studentCount: json["student_count"],
        gradeName: json["grade_name"],
        fingerprintSubmissions: json["fingerprint_submissions"],
        assignmentSubmissions: json["assignment_submissions"],
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "term": term,
        "academic_year": academicYear,
        "is_archived": isArchived,
        "class_status": classStatus,
        "teacher_id": teacherId,
        "teacher_name": teacherName,
        "student_count": studentCount,
        "grade_name": gradeName,
        "fingerprint_submissions": fingerprintSubmissions,
        "assignment_submissions": assignmentSubmissions,
      };
}

// Models for API response structure
class ApiResponse {
  final bool success;
  final List<InstituteModel> data;
  final String message;

  ApiResponse({required this.success, required this.data, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        success: json['success'],
        data: (json['data'] as List)
            .map((e) => InstituteModel.fromJson(e))
            .toList(),
        message: json['message'],
      );
}

class InstituteModel {
  final String instituteId;
  final String instituteName;
  final List<TeacherModel> teachers;

  InstituteModel({
    required this.instituteId,
    required this.instituteName,
    required this.teachers,
  });

  factory InstituteModel.fromJson(Map<String, dynamic> json) => InstituteModel(
        instituteId: json['institute_id'],
        instituteName: json['institute_name'],
        teachers: (json['teachers'] as List)
            .map((e) => TeacherModel.fromJson(e))
            .toList(),
      );
}

class TeacherModel {
  final String teacherId;
  final String teacherName;
  final List<ClassLightModel> classes; // Using a lightweight class model here below
  final List<GradeModel> grades;
  final List<String> terms;
  final List<int> academicYears;

  TeacherModel({
    required this.teacherId,
    required this.teacherName,
    required this.classes,
    required this.grades,
    required this.terms,
    required this.academicYears,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) => TeacherModel(
        teacherId: json['teacher_id'],
        teacherName: json['teacher_name'],
        classes: (json['classes'] as List)
            .map((e) => ClassLightModel.fromJson(e))
            .toList(),
        grades: (json['grades'] as List)
            .map((e) => GradeModel.fromJson(e))
            .toList(),
        terms: List<String>.from(json['terms']),
        academicYears: List<int>.from(json['academic_years']),
      );
}

/// Lightweight class model matching classes in API (no extra fields)
class ClassLightModel {
  final String classId;
  final String className;
  final String? gradeId;
 final String? term;
  ClassLightModel({
    required this.classId,
    required this.className,
    this.gradeId,
       this.term,
  });

  factory ClassLightModel.fromJson(Map<String, dynamic> json) => ClassLightModel(
        classId: json['class_id'],
        className: json['class_name'],
        gradeId: json['grade_id'],
        term: json['term'],
      );
}

class GradeModel {
  final String gradeId;
  final String gradeName;

  GradeModel({
    required this.gradeId,
    required this.gradeName,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) => GradeModel(
        gradeId: json['grade_id'],
        gradeName: json['grade_name'],
      );
}
