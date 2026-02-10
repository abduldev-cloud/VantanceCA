class AddSchoolModel {
  String schoolName;
  String schoolType;
  String schoolDistrict;
  String adminEmail;
  String emailDomain;
  String createdBy;
  String role;
  bool isDemoSchool;

  AddSchoolModel({
    required this.schoolName,
    required this.schoolType,
    required this.schoolDistrict,
    required this.adminEmail,
    required this.emailDomain,
    required this.createdBy,
    this.role = "institute_admin",
    this.isDemoSchool = false,
  });

  Map<String, dynamic> toJson() => {
        "school_name": schoolName,
        "school_type": schoolType,
        "school_district": schoolDistrict,
        "admin_email": adminEmail,
        "email_domain": emailDomain,
        "created_by": createdBy,
        "is_demo_school": isDemoSchool ? "Y" : "N",
      };

  Map<String, String> toMap() {
    return {
      'School Name': schoolName,
      'School Type': schoolType,
      'School District': schoolDistrict,
      'Admin Email': adminEmail,
      'Email Domain': emailDomain,
      'Created By': createdBy,
      "is_demo_school": isDemoSchool ? "Y" : "N",
    };
  }
}

class InviteSchoolModel {
  String inviteCode;
  String schoolName;
  String schoolType;
  String schoolDistrict;
  String schoolState;
  String adminEmail;
  String emailDomain;
  String keycloakUserId;
  String firstName;
  String lastName;
  String invitePersona;

  InviteSchoolModel({
    required this.inviteCode,
    required this.schoolName,
    required this.schoolType,
    required this.schoolDistrict,
    required this.schoolState,
    required this.adminEmail,
    required this.emailDomain,
    required this.keycloakUserId,
    required this.firstName,
    required this.lastName,
    required this.invitePersona,
  });

  factory InviteSchoolModel.fromJson(Map<String, dynamic> json) {
    return InviteSchoolModel(
      inviteCode: json['invite_code'] ?? '',
      schoolName: json['school_name'] ?? '',
      schoolType: json['school_type'] ?? '',
      schoolDistrict: json['school_district'] ?? '',
      schoolState: json['school_state'] ?? '',
      adminEmail: json['email'] ?? '',
      emailDomain: json['email_domain'] ?? '',
      keycloakUserId: json['keycloak_user_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      invitePersona: json['invite_persona'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'School Name': schoolName,
      'School Type': schoolType,
      'School District': schoolDistrict,
      'School State': schoolState,
      'Email': adminEmail,
      'Email Domain': emailDomain,
      'First Name': firstName,
      'Last Name': lastName,
    };
  }
}
