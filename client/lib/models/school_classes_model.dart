/// ===== MODEL FOR CLASS STATUS (Active / Archived summary) =====
class ClassStatusCount {
  final int activeClasses;
  final int archivedClasses;
  final int totalStudents;

  ClassStatusCount({
    required this.activeClasses,
    required this.archivedClasses,
    required this.totalStudents,
  });

  factory ClassStatusCount.fromJson(Map<String, dynamic> json) {
    return ClassStatusCount(
      activeClasses: json['active_classes'] ?? 0,
      archivedClasses: json['archived_classes'] ?? 0,
      totalStudents: json['total_students'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_classes': activeClasses,
      'archived_classes': archivedClasses,
      'total_students': totalStudents,
    };
  }
}

/// ===== MODEL FOR CLASS DETAILS (each class record) =====
class ClassDetail {
  final String classId;
  final String className;
  final String description;
  final String teacherSalutation;
  final String teacherFirstName;
  final String teacherLastName;
  final String classStatus;
  final int numStudents;
  final String term;
  final int academicYear;
  final String gradeName;
  final int numLastFingerprintSubmitted;

  ClassDetail({
    required this.classId,
    required this.className,
    required this.description,
    required this.classStatus,
    required this.teacherSalutation,
    required this.teacherFirstName,
    required this.teacherLastName,
    required this.numStudents,
    required this.term,
    required this.academicYear,
    required this.gradeName,
    required this.numLastFingerprintSubmitted,
  });

  factory ClassDetail.fromJson(Map<String, dynamic> json) {
    return ClassDetail(
      classId: json['class_id'] ?? '',
      className: json['class_name'] ?? '',
      description: json['description'] ?? '',
      teacherSalutation: json['teacher_salutation'] ?? '',
      teacherFirstName: json['teacher_first_name'] ?? '',
      teacherLastName: json['teacher_last_name'] ?? '',
      classStatus: json['class_status'] ?? '',
      numStudents: json['num_students'] ?? 0,
      term: json['term'] ?? '',
      academicYear: json['academic_year'] ?? 0,
      gradeName: json['grade_name'] ?? '',
      numLastFingerprintSubmitted:
          json['num_last_fingerprint_submitted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_id': classId,
      'class_name': className,
      'description': description,
      'teacher_salutation': teacherSalutation,
      'teacher_first_name': teacherFirstName,
      'teacher_last_name': teacherLastName,
      'class_status': classStatus,
      'num_students': numStudents,
      'term': term,
      'academic_year': academicYear,
      'grade_name': gradeName,
      'num_last_fingerprint_submitted': numLastFingerprintSubmitted,
    };
  }
}

/// ===== MODEL FOR THE CLASS SUMMARY RESPONSE =====
class SchoolClassSummary {
  final List<ClassStatusCount> classStatusCount;
  final List<ClassDetail> classDetails;
  final String outStatus;

  SchoolClassSummary({
    required this.classStatusCount,
    required this.classDetails,
    required this.outStatus,
  });

  factory SchoolClassSummary.fromJson(Map<String, dynamic> json) {
    return SchoolClassSummary(
      classStatusCount: (json['class_status_count'] as List? ?? [])
          .map((item) => ClassStatusCount.fromJson(item))
          .toList(),
      classDetails: (json['class_details'] as List? ?? [])
          .map((item) => ClassDetail.fromJson(item))
          .toList(),
      outStatus: json['out_status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class_status_count':
          classStatusCount.map((item) => item.toJson()).toList(),
      'class_details': classDetails.map((item) => item.toJson()).toList(),
      'out_status': outStatus,
    };
  }
}

/// ===== MODEL FOR LEARNERS (Total Students API) =====
/// API: /institute/get_school_admin_all_learners
class Learner {
  final String learnerId;
  final String salutation;
  final String firstName;
  final String lastName;
  final String email;
  final String learnerStatus;
  final String hasFingerprintSubmitted;

  Learner({
    required this.learnerId,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.learnerStatus,
    required this.hasFingerprintSubmitted,
  });

  factory Learner.fromJson(Map<String, dynamic> json) {
    return Learner(
      learnerId: json['learner_id'] ?? '',
      salutation: json['salutation'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      learnerStatus: json['learner_status'] ?? '',
      hasFingerprintSubmitted: json['has_fingerprint_submitted'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'learner_id': learnerId,
      'salutation': salutation,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'learner_status': learnerStatus,
      'has_fingerprint_submitted': hasFingerprintSubmitted,
    };
  }

  String get fullName => "$salutation $firstName $lastName".trim();
}
