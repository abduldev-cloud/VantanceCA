import 'dart:convert';


TeacherClassSummaryResponse teacherClassSummaryResponseFromJson(String str) =>
    TeacherClassSummaryResponse.fromJson(json.decode(str));

String teacherClassSummaryResponseToJson(TeacherClassSummaryResponse data) =>
    json.encode(data.toJson());


class TeacherClassSummaryResponse {
  final List<ClassStatusCount>? classStatusCount;
  final List<TeacherSummary>? teacherSummary;
  final List<ClassInfo>? classDetails;  
  final String? outStatus;

  TeacherClassSummaryResponse({
    this.classStatusCount,
    this.teacherSummary,
    this.classDetails,
    this.outStatus,
  });

  factory TeacherClassSummaryResponse.fromJson(Map<String, dynamic> json) => TeacherClassSummaryResponse(
    classStatusCount: json["class_status_count"] == null
        ? null
        : List<ClassStatusCount>.from(
            json["class_status_count"].map((x) => ClassStatusCount.fromJson(x))),
    teacherSummary: json["teacher_summary"] == null
        ? null
        : List<TeacherSummary>.from(
            json["teacher_summary"].map((x) => TeacherSummary.fromJson(x))),
    classDetails: json["class_details"] == null
        ? null
        : List<ClassInfo>.from(
            json["class_details"].map((x) => ClassInfo.fromJson(x))),
    outStatus: json["out_status"],
  );

  Map<String, dynamic> toJson() => {
    "class_status_count": classStatusCount?.map((x) => x.toJson()).toList(),
    "teacher_summary": teacherSummary?.map((x) => x.toJson()).toList(),
    "class_details": classDetails?.map((x) => x.toJson()).toList(),
    "out_status": outStatus,
  };
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

  Map<String, dynamic> toJson() => {
    "active_classes": activeClasses,
    "archived_classes": archivedClasses,
  };
}

class TeacherSummary {
  final String? teacherId;
  final String? salutation;
  final String? firstName;
  final String? lastName;
  final int? totalLearners;
  final String? alfresco_user_id;
  final String? institute_id;
  final String? alfresco_site_id;

  TeacherSummary({
    this.teacherId,
    this.salutation,
    this.firstName,
    this.lastName,
    this.totalLearners,
    this.alfresco_user_id,
    this.institute_id,
    this.alfresco_site_id,
  });

  factory TeacherSummary.fromJson(Map<String, dynamic> json) => TeacherSummary(
    teacherId: json["teacher_id"],
    salutation: json["salutation"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    totalLearners: json["total_learners"],
    alfresco_user_id: json["alfresco_user_id"],
    institute_id: json["institute_id"],
    alfresco_site_id: json["alfresco_site_id"],
  );

  Map<String, dynamic> toJson() => {
    "teacher_id": teacherId,
    "salutation": salutation,
    "first_name": firstName,
    "last_name": lastName,
    "total_learners": totalLearners,
    "alfresco_user_id": alfresco_user_id,
    "institute_id": institute_id,
    "alfresco_site_id": alfresco_site_id,
  };
}

class ClassInfo {
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
  final String? alfresco_class_id;

  ClassInfo({
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
    this.alfresco_class_id,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
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
    alfresco_class_id: json["alfresco_class_id"],
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
    "grade_name": gradeName,
    "num_last_fingerprint_submitted": numLastFingerprintSubmitted,
    "alfresco_class_id": alfresco_class_id,
  };
}
