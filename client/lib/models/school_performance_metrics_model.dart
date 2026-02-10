import 'dart:convert';

// Main response model for school performance metrics
SchoolPerformanceMetricsModel schoolPerformanceMetricsModelFromJson(String str) =>
    SchoolPerformanceMetricsModel.fromJson(json.decode(str));

String schoolPerformanceMetricsModelToJson(SchoolPerformanceMetricsModel data) =>
    json.encode(data.toJson());

class SchoolPerformanceMetricsModel {
  final AverageGrades? averageGrades;
  final AssignmentDuration? assignmentDuration;
  final String? message;
  final String? timestamp;

  SchoolPerformanceMetricsModel({
    this.averageGrades,
    this.assignmentDuration,
    this.message,
    this.timestamp,
  });

  factory SchoolPerformanceMetricsModel.fromJson(Map<String, dynamic> json) =>
      SchoolPerformanceMetricsModel(
        averageGrades: json["average_grades"] == null
            ? null
            : AverageGrades.fromJson(json["average_grades"]),
        assignmentDuration: json["assignment_duration"] == null
            ? null
            : AssignmentDuration.fromJson(json["assignment_duration"]),
        message: json["message"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "average_grades": averageGrades?.toJson(),
        "assignment_duration": assignmentDuration?.toJson(),
        "message": message,
        "timestamp": timestamp,
      };
}

// Average grades model
class AverageGrades {
  final double? overallAverage;
  final List<GradeBreakdown>? gradeBreakdown;

  AverageGrades({
    this.overallAverage,
    this.gradeBreakdown,
  });

  factory AverageGrades.fromJson(Map<String, dynamic> json) => AverageGrades(
        overallAverage: json["overall_average"]?.toDouble(),
        gradeBreakdown: json["grade_breakdown"] == null
            ? null
            : List<GradeBreakdown>.from(
                json["grade_breakdown"].map((x) => GradeBreakdown.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "overall_average": overallAverage,
        "grade_breakdown": gradeBreakdown == null
            ? null
            : List<dynamic>.from(gradeBreakdown!.map((x) => x.toJson())),
      };
}

// Grade breakdown model
class GradeBreakdown {
  final String? gradeLevel;
  final double? averageGrade;
  final List<ClassBreakdown>? classBreakdown;

  GradeBreakdown({
    this.gradeLevel,
    this.averageGrade,
    this.classBreakdown,
  });

  factory GradeBreakdown.fromJson(Map<String, dynamic> json) => GradeBreakdown(
        gradeLevel: json["grade_level"],
        averageGrade: json["average_grade"]?.toDouble(),
        classBreakdown: json["class_breakdown"] == null
            ? null
            : List<ClassBreakdown>.from(
                json["class_breakdown"].map((x) => ClassBreakdown.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "grade_level": gradeLevel,
        "average_grade": averageGrade,
        "class_breakdown": classBreakdown == null
            ? null
            : List<dynamic>.from(classBreakdown!.map((x) => x.toJson())),
      };
}

// Class breakdown model
class ClassBreakdown {
  final String? className;
  final double? averageGrade;

  ClassBreakdown({
    this.className,
    this.averageGrade,
  });

  factory ClassBreakdown.fromJson(Map<String, dynamic> json) => ClassBreakdown(
        className: json["class_name"],
        averageGrade: json["average_grade"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "class_name": className,
        "average_grade": averageGrade,
      };
}

// Assignment duration model
class AssignmentDuration {
  final double? overallAverageHours;
  final List<DurationGradeBreakdown>? gradeBreakdown;

  AssignmentDuration({
    this.overallAverageHours,
    this.gradeBreakdown,
  });

  factory AssignmentDuration.fromJson(Map<String, dynamic> json) =>
      AssignmentDuration(
        overallAverageHours: json["overall_average_hours"]?.toDouble(),
        gradeBreakdown: json["grade_breakdown"] == null
            ? null
            : List<DurationGradeBreakdown>.from(json["grade_breakdown"]
                .map((x) => DurationGradeBreakdown.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "overall_average_hours": overallAverageHours,
        "grade_breakdown": gradeBreakdown == null
            ? null
            : List<dynamic>.from(gradeBreakdown!.map((x) => x.toJson())),
      };
}

// Duration grade breakdown model
class DurationGradeBreakdown {
  final String? gradeLevel;
  final double? averageHours;

  DurationGradeBreakdown({
    this.gradeLevel,
    this.averageHours,
  });

  factory DurationGradeBreakdown.fromJson(Map<String, dynamic> json) =>
      DurationGradeBreakdown(
        gradeLevel: json["grade_level"],
        averageHours: json["average_hours"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "grade_level": gradeLevel,
        "average_hours": averageHours,
      };
}
