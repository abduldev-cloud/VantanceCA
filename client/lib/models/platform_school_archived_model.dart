class InstituteSchoolArchivedResponse {
  final List<SummaryCount> summaryCounts;
  final List<InstituteDetail> instituteDetails;
  final String outStatus;

  InstituteSchoolArchivedResponse({
    required this.summaryCounts,
    required this.instituteDetails,
    required this.outStatus,
  });

  factory InstituteSchoolArchivedResponse.fromJson(Map<String, dynamic> json) {
    var summaryList = (json['summary_counts'] as List)
        .map((e) => SummaryCount.fromJson(e))
        .toList();
    var instituteList = (json['institute_details'] as List)
        .map((e) => InstituteDetail.fromJson(e))
        .toList();

    return InstituteSchoolArchivedResponse(
      summaryCounts: summaryList,
      instituteDetails: instituteList,
      outStatus: json['out_status'] as String,
    );
  }
}

class SummaryCount {
  final int activeInstitutes;
  final int archivedInstitutes;
  final int totalUsers;

  SummaryCount({
    required this.activeInstitutes,
    required this.archivedInstitutes,
    required this.totalUsers,
  });

  factory SummaryCount.fromJson(Map<String, dynamic> json) {
    return SummaryCount(
      activeInstitutes: json['active_institutes'] as int,
      archivedInstitutes: json['archived_institutes'] as int,
      totalUsers: json['total_users'] as int,
    );
  }
}

class InstituteDetail {
  final String instituteId;
  final String instituteName;
  final int totalLearners;
  final int assignmentCount;
  final String? term;
  final int fingerprintSubmittedCount;
  final int rn;

  InstituteDetail({
    required this.instituteId,
    required this.instituteName,
    required this.totalLearners,
    required this.assignmentCount,
    this.term,
    required this.fingerprintSubmittedCount,
    required this.rn,
  });

  factory InstituteDetail.fromJson(Map<String, dynamic> json) {
    return InstituteDetail(
      instituteId: json['institute_id'] as String,
      instituteName: json['institute_name'] as String,
      totalLearners: json['total_learners'] as int,
      assignmentCount: json['assignment_count'] as int,
      term: json['term'] as String?,
      fingerprintSubmittedCount: json['fingerprint_submitted_count'] as int,
      rn: json['rn'] as int,
    );
  }
}
