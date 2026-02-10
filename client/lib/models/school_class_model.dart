class SchoolClassModel {
  final String? classId;
  final String? className;
  final String? description;
  final String? classStatus;
  final int? studentCount;
  final String? teacherName;
  final String? gradeName;

  SchoolClassModel({
    this.classId,
    this.className,
    this.description,
    this.classStatus,
    this.studentCount,
    this.teacherName,
    this.gradeName,
  });

  factory SchoolClassModel.fromJson(Map<String, dynamic> json) => SchoolClassModel(
        classId: json["class_id"],
        className: json["class_name"],
        description: json["description"],
        classStatus: json["class_status"],
        studentCount: json["student_count"],
        teacherName: json["teacher_name"],
        gradeName: json["grade_name"],
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "description": description,
        "class_status": classStatus,
        "student_count": studentCount,
        "teacher_name": teacherName,
        "grade_name": gradeName,
      };

  @override
  String toString() {
    return 'SchoolClassModel(classId: $classId, className: $className, studentCount: $studentCount)';
  }
}

class SchoolClassesResponse {
  final List<SchoolClassModel> classes;
  final String? message;
  final String? timestamp;

  SchoolClassesResponse({
    required this.classes,
    this.message,
    this.timestamp,
  });

  factory SchoolClassesResponse.fromJson(Map<String, dynamic> json) => SchoolClassesResponse(
        classes: json["classes"] != null
            ? List<SchoolClassModel>.from(json["classes"].map((x) => SchoolClassModel.fromJson(x)))
            : [],
        message: json["message"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "classes": List<dynamic>.from(classes.map((x) => x.toJson())),
        "message": message,
        "timestamp": timestamp,
      };
}
