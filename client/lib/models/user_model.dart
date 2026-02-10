

import 'dart:convert';

/// =======================================================
/// JSON Helpers
/// =======================================================
ApiResponse apiResponseFromJson(String str) =>
    ApiResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String apiResponseToJson(ApiResponse data) => json.encode(data.toJson());

/// =======================================================
/// API Response Wrapper
/// =======================================================
class ApiResponse {
  final String? outStatus;
  final List<UserCount> userCounts;
  final List<UserModel> userList;

  ApiResponse({
    this.outStatus,
    this.userCounts = const [],
    this.userList = const [],
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        outStatus: json["out_status"],
        userCounts: (json["user_counts"] as List?)
                ?.map((x) => UserCount.fromJson(x))
                .toList() ??
            [],
        userList: (json["user_list"] as List?)
                ?.map((x) => UserModel.fromJson(x))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        "out_status": outStatus,
        "user_counts": userCounts.map((x) => x.toJson()).toList(),
        "user_list": userList.map((x) => x.toJson()).toList(),
      };
}

/// =======================================================
/// User Counts
/// =======================================================
class UserCount {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers; // normalized (archived → inactive)

  UserCount({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
  });

  factory UserCount.fromJson(Map<String, dynamic> json) => UserCount(
        totalUsers: json["total_users"] ?? 0,
        activeUsers: json["active_users"] ?? 0,
        inactiveUsers: json["archived_users"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "total_users": totalUsers,
        "active_users": activeUsers,
        "archived_users": inactiveUsers,
      };
}

/// =======================================================
/// User Model (Flexible: Oracle + Keycloak)
/// =======================================================
class UserModel {
  final String? userId; // mapped from user_id
  final String? keycloakUserId; // new field for keycloak_user_id
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool? emailVerified;
  final bool? enabled;
  final int? createdTimestamp;
  final bool? totp;
  final int? notBefore;
  final Access? access;
  final String? roleName;
  final String? userType;
  final String? schoolName;
  final String? status; // normalized status ("active"/"inactive")
  final String? createdDate;
  final DateTime? createdAt;
  final String? name;

  UserModel({
    this.userId,
    this.keycloakUserId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerified,
    this.enabled,
    this.createdTimestamp,
    this.totp,
    this.notBefore,
    this.access,
    this.roleName,
    this.userType,
    this.schoolName,
    this.status,
    this.createdDate,
    this.createdAt,
    this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Normalize status
    String rawStatus = (json["status_code"] ?? "").toString().toUpperCase();
    String normalizedStatus;
    if (rawStatus == "ACTIVE") {
      normalizedStatus = "active";
    } else if (rawStatus == "INACTIVE" || rawStatus == "ARCHIVED") {
      normalizedStatus = "inactive";
    } else {
      normalizedStatus = rawStatus.toLowerCase();
    }

    return UserModel(
      userId: json["user_id"]?.toString() ?? json["id"]?.toString(),
      keycloakUserId: json["keycloak_user_id"]?.toString(),
      username: json["username"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      email: json["email"],
      emailVerified: json["emailVerified"] ?? json["email_verified"],
      enabled: json["enabled"],
      createdTimestamp: json["createdTimestamp"] ?? json["created_timestamp"],
      totp: json["totp"],
      notBefore: json["notBefore"] ?? json["not_before"],
      access: json["access"] == null ? null : Access.fromJson(json["access"]),
      roleName: json["role_display_name"],
      userType: json["userType"] ?? json["user_type"],
      schoolName: json["school_name"],
      status: normalizedStatus,
      createdDate: json["created_date"],
      name: json['name'],
      createdAt:
          json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    String apiStatus;
    if (status == "active") {
      apiStatus = "ACTIVE";
    } else {
      apiStatus = "INACTIVE";
    }

    return {
      "user_id": userId,
      "keycloak_user_id": keycloakUserId,
      "username": username,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "email_verified": emailVerified,
      "enabled": enabled,
      "created_timestamp": createdTimestamp,
      "totp": totp,
      "not_before": notBefore,
      "access": access?.toJson(),
      "role_display_name": roleName,
      "user_type": userType,
      "school_name": schoolName,
      "status_code": apiStatus,
      "created_date": createdDate,
      "created_at": createdAt?.toIso8601String(),
      "name": name,
    };
  }
}

/// UserModel copyWith extension
extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    String? userId,
    String? keycloakUserId,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? emailVerified,
    bool? enabled,
    int? createdTimestamp,
    bool? totp,
    int? notBefore,
    Access? access,
    String? roleName,
    String? userType,
    String? schoolName,
    String? status,
    String? createdDate,
    DateTime? createdAt,
    String? name,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      keycloakUserId: keycloakUserId ?? this.keycloakUserId,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      enabled: enabled ?? this.enabled,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      totp: totp ?? this.totp,
      notBefore: notBefore ?? this.notBefore,
      access: access ?? this.access,
      roleName: roleName ?? this.roleName,
      userType: userType ?? this.userType,
      schoolName: schoolName ?? this.schoolName,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
    );
  }
}

/// Access (Keycloak only)
class Access {
  final bool? manage;

  Access({this.manage});

  factory Access.fromJson(Map<String, dynamic> json) => Access(
        manage: json["manage"],
      );

  Map<String, dynamic> toJson() => {
        "manage": manage,
      };
}
