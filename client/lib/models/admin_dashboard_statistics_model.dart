import 'dart:convert';

// Main response model for admin dashboard statistics
AdminDashboardStatisticsModel adminDashboardStatisticsModelFromJson(String str) =>
    AdminDashboardStatisticsModel.fromJson(json.decode(str));

String adminDashboardStatisticsModelToJson(AdminDashboardStatisticsModel data) =>
    json.encode(data.toJson());

class AdminDashboardStatisticsModel {
  final TotalUsers totalUsers;
  final TotalStudents totalStudents;
  final TotalSchools totalSchools;

  AdminDashboardStatisticsModel({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalSchools,
  });

  factory AdminDashboardStatisticsModel.fromJson(Map<String, dynamic> json) =>
      AdminDashboardStatisticsModel(
        totalUsers: TotalUsers.fromJson(json["totalUsers"]),
        totalStudents: TotalStudents.fromJson(json["totalStudents"]),
        totalSchools: TotalSchools.fromJson(json["totalSchools"]),
      );

  Map<String, dynamic> toJson() => {
        "totalUsers": totalUsers.toJson(),
        "totalStudents": totalStudents.toJson(),
        "totalSchools": totalSchools.toJson(),
      };
}

// Total Users model
class TotalUsers {
  final int total;
  final int active;
  final int inactive;
  final RoleBreakdown roleBreakdown;

  TotalUsers({
    required this.total,
    required this.active,
    required this.inactive,
    required this.roleBreakdown,
  });

  factory TotalUsers.fromJson(Map<String, dynamic> json) => TotalUsers(
        total: json["total"] ?? 0,
        active: json["active"] ?? 0,
        inactive: json["inactive"] ?? 0,
        roleBreakdown: RoleBreakdown.fromJson(json["roleBreakdown"]),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "active": active,
        "inactive": inactive,
        "roleBreakdown": roleBreakdown.toJson(),
      };
}

// Role Breakdown model
class RoleBreakdown {
  final int admins;
  final int teachers;
  final int students;

  RoleBreakdown({
    required this.admins,
    required this.teachers,
    required this.students,
  });

  factory RoleBreakdown.fromJson(Map<String, dynamic> json) => RoleBreakdown(
        admins: json["admins"] ?? 0,
        teachers: json["teachers"] ?? 0,
        students: json["students"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "admins": admins,
        "teachers": teachers,
        "students": students,
      };
}

// Total Students model
class TotalStudents {
  final int total;
  final int active;
  final int inactive;
  final GradeBreakdown gradeBreakdown;

  TotalStudents({
    required this.total,
    required this.active,
    required this.inactive,
    required this.gradeBreakdown,
  });

  factory TotalStudents.fromJson(Map<String, dynamic> json) => TotalStudents(
        total: json["total"] ?? 0,
        active: json["active"] ?? 0,
        inactive: json["inactive"] ?? 0,
        gradeBreakdown: GradeBreakdown.fromJson(json["gradeBreakdown"]),
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "active": active,
        "inactive": inactive,
        "gradeBreakdown": gradeBreakdown.toJson(),
      };
}

// Grade Breakdown model
class GradeBreakdown {
  final int grade9;
  final int grade10;
  final int grade11;
  final int grade12;

  GradeBreakdown({
    required this.grade9,
    required this.grade10,
    required this.grade11,
    required this.grade12,
  });

  factory GradeBreakdown.fromJson(Map<String, dynamic> json) => GradeBreakdown(
        grade9: json["grade_9"] ?? 0,
        grade10: json["grade_10"] ?? 0,
        grade11: json["grade_11"] ?? 0,
        grade12: json["grade_12"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "grade_9": grade9,
        "grade_10": grade10,
        "grade_11": grade11,
        "grade_12": grade12,
      };

  // Helper method to get total students across all grades
  int get totalStudents => grade9 + grade10 + grade11 + grade12;

  // Helper method to get grade breakdown as a list for charts
  List<int> get gradeList => [grade9, grade10, grade11, grade12];

  // Helper method to get grade breakdown as a map for easier access
  Map<String, int> get gradeMap => {
        "Grade 9": grade9,
        "Grade 10": grade10,
        "Grade 11": grade11,
        "Grade 12": grade12,
      };

  // Operator to access grades by string key
  int? operator [](String grade) {
    switch (grade) {
      case 'Grade 9':
        return grade9;
      case 'Grade 10':
        return grade10;
      case 'Grade 11':
        return grade11;
      case 'Grade 12':
        return grade12;
      default:
        return null;
    }
  }
}

// Total Schools model
class TotalSchools {
  final int total;
  final int active;
  final int inactive;

  TotalSchools({
    required this.total,
    required this.active,
    required this.inactive,
  });

  factory TotalSchools.fromJson(Map<String, dynamic> json) => TotalSchools(
        total: json["total"] ?? 0,
        active: json["active"] ?? 0,
        inactive: json["inactive"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "active": active,
        "inactive": inactive,
      };

  // Helper method to calculate activity percentage
  double get activityPercentage => total > 0 ? (active / total) * 100 : 0.0;
}
