class InstituteSummaryCounts {
  final int activeInstitutes;
  final int archivedInstitutes;
  final int totalUsers;

  InstituteSummaryCounts({
    required this.activeInstitutes,
    required this.archivedInstitutes,
    required this.totalUsers,
  });

  factory InstituteSummaryCounts.fromJson(Map<String, dynamic> json) {
    return InstituteSummaryCounts(
      activeInstitutes: json['active_institutes'] ?? 0,
      archivedInstitutes: json['archived_institutes'] ?? 0,
      totalUsers: json['total_users'] ?? 0,
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
      instituteId: json['institute_id'] ?? '',
      instituteName: json['institute_name'] ?? '',
      totalLearners: json['total_learners'] ?? 0,
      assignmentCount: json['assignment_count'] ?? 0,
      term: json['term'],
      fingerprintSubmittedCount: json['fingerprint_submitted_count'] ?? 0,
      rn: json['rn'] ?? 0,
    );
  }
}

class InstituteListResponse {
  final InstituteSummaryCounts summaryCounts;
  final List<InstituteDetail> instituteDetails;
  final String outStatus;

  InstituteListResponse({
    required this.summaryCounts,
    required this.instituteDetails,
    required this.outStatus,
  });

  factory InstituteListResponse.fromJson(Map<String, dynamic> json) {
    return InstituteListResponse(
      summaryCounts: InstituteSummaryCounts.fromJson(
        (json['summary_counts'] as List).first,
      ),
      instituteDetails: (json['institute_details'] as List)
          .map((e) => InstituteDetail.fromJson(e))
          .toList(),
      outStatus: json['out_status'] ?? '',
    );
  }
}
