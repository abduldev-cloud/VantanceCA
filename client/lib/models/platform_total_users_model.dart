
// class PlatformUser {
//   final String firstName;
//   final String lastName;
//   final String roleDisplayName;
//   final String email;
//   final String statusCode;

//   PlatformUser({
//     required this.firstName,
//     required this.lastName,
//     required this.roleDisplayName,
//     required this.email,
//     required this.statusCode,
//   });

//   factory PlatformUser.fromJson(Map<String, dynamic> json) {
//     return PlatformUser(
//       firstName: json['first_name'] ?? '',
//       lastName: json['last_name'] ?? '',
//       roleDisplayName: json['role_display_name'] ?? '',
//       email: json['email'] ?? '',
//       statusCode: json['status_code'] ?? '',
//     );
//   }
// }

// class PlatformUserResponse {
//   final List<PlatformUser> users;
//   final int totalCount;

//   PlatformUserResponse({
//     required this.users,
//     required this.totalCount,
//   });

//   factory PlatformUserResponse.fromJson(Map<String, dynamic> json) {
//     int totalUsers = 0;
    
//     if (json['user_counts'] != null && json['user_counts'] is List) {
//       var countsList = json['user_counts'] as List<dynamic>;
//       if (countsList.isNotEmpty && countsList[0] is Map<String, dynamic>) {
//         totalUsers = countsList[0]['total_users'] ?? 0;
//       }
//     }

//     return PlatformUserResponse(
//       users: (json['user_list'] as List<dynamic>?)
//               ?.map((e) => PlatformUser.fromJson(e))
//               .toList() ??
//           [],
//       totalCount: totalUsers,
//     );
//   }
// }


// class PlatformUser {
//   final String firstName;
//   final String lastName;
//   final String roleDisplayName;
//   final String email;
//   final String statusCode;

//   PlatformUser({
//     required this.firstName,
//     required this.lastName,
//     required this.roleDisplayName,
//     required this.email,
//     required this.statusCode,
//   });

//   factory PlatformUser.fromJson(Map<String, dynamic> json) {
//     return PlatformUser(
//       firstName: json['first_name'] ?? '',
//       lastName: json['last_name'] ?? '',
//       roleDisplayName: json['role_display_name'] ?? '',
//       email: json['email'] ?? '',
//       statusCode: json['status_code'] ?? '',
//     );
//   }
// }

// class PlatformUserResponse {
//   final List<PlatformUser> users;
//   final int totalCount;

//   PlatformUserResponse({
//     required this.users,
//     required this.totalCount,
//   });

//   factory PlatformUserResponse.fromJson(Map<String, dynamic> json) {
//     int totalUsers = 0;
    
//     if (json['user_counts'] != null && json['user_counts'] is List) {
//       var countsList = json['user_counts'] as List<dynamic>;
//       if (countsList.isNotEmpty && countsList[0] is Map<String, dynamic>) {
//         totalUsers = countsList[0]['total_users'] ?? 0;
//       }
//     }

//     return PlatformUserResponse(
//       users: (json['user_list'] as List<dynamic>?)
//               ?.map((e) => PlatformUser.fromJson(e))
//               .toList() ??
//           [],
//       totalCount: totalUsers,
//     );
//   }
// }

import 'dart:convert';

/// =======================================================
/// JSON Helpers
/// =======================================================
PlatformUserResponse platformUserResponseFromJson(String str) =>
    PlatformUserResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String platformUserResponseToJson(PlatformUserResponse data) =>
    json.encode(data.toJson());

/// =======================================================
/// API Response Wrapper
/// =======================================================
class PlatformUserResponse {
  final int totalCount; // total users count
  final List<PlatformUser> users;

  PlatformUserResponse({
    this.totalCount = 0,
    this.users = const [],
  });

  factory PlatformUserResponse.fromJson(Map<String, dynamic> json) {
    int totalUsers = 0;

    if (json['user_counts'] != null && json['user_counts'] is List) {
      var countsList = json['user_counts'] as List<dynamic>;
      if (countsList.isNotEmpty && countsList[0] is Map<String, dynamic>) {
        totalUsers = countsList[0]['total_users'] ?? 0;
      }
    }

    return PlatformUserResponse(
      totalCount: totalUsers,
      users: (json['user_list'] as List?)
              ?.map((x) => PlatformUser.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        "total_users": totalCount,
        "user_list": users.map((x) => x.toJson()).toList(),
      };
}

/// =======================================================
/// Platform User Model
/// =======================================================
class PlatformUser {
  final String firstName;
  final String lastName;
  final String roleDisplayName;
  final String email;
  final String statusCode;
  final DateTime? createdAt; // ✅ ADDED

  PlatformUser({
    required this.firstName,
    required this.lastName,
    required this.roleDisplayName,
    required this.email,
    required this.statusCode,
    this.createdAt, // ✅ ADDED
  });

  factory PlatformUser.fromJson(Map<String, dynamic> json) {
    // Normalize status to lower case for consistency
    String rawStatus = (json['status_code'] ?? '').toString().toLowerCase();
    String normalizedStatus;
    if (rawStatus == "active") {
      normalizedStatus = "active";
    } else if (rawStatus == "inactive" || rawStatus == "archived") {
      normalizedStatus = "inactive";
    } else {
      normalizedStatus = rawStatus;
    }

    return PlatformUser(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      roleDisplayName: json['role_display_name'] ?? '',
      email: json['email'] ?? '',
      statusCode: normalizedStatus,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null, // ✅ MAPPED
    );
  }

  Map<String, dynamic> toJson() => {
        "first_name": firstName,
        "last_name": lastName,
        "role_display_name": roleDisplayName,
        "email": email,
        "status_code": statusCode,
        "created_at": createdAt?.toIso8601String(), // ✅ ADDED
      };

  PlatformUser copyWith({
    String? firstName,
    String? lastName,
    String? roleDisplayName,
    String? email,
    String? statusCode,
    DateTime? createdAt, // ✅ ADDED
  }) {
    return PlatformUser(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roleDisplayName: roleDisplayName ?? this.roleDisplayName,
      email: email ?? this.email,
      statusCode: statusCode ?? this.statusCode,
      createdAt: createdAt ?? this.createdAt, // ✅ ADDED
    );
  }
}
