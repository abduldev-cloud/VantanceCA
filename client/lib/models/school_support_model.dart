import 'dart:convert';
import 'package:binary_success/helpers/constant/app_constant.dart';

/// =======================================================
/// JSON Helpers
/// =======================================================
SupportResponse supportResponseFromJson(String str) =>
    SupportResponse.fromJson(json.decode(str) as Map<String, dynamic>);

String supportResponseToJson(SupportResponse data) =>
    json.encode(data.toJson());

/// =======================================================
/// API Response Wrapper
/// =======================================================
class ApiResponse<T> {
  final T? data;
  final String? error;

  ApiResponse({this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromData,
  ) {
    if (json.containsKey("error")) {
      return ApiResponse(error: json["error"]["message"]?.toString());
    }
    return ApiResponse(data: fromData(json));
  }
}

/// =======================================================
/// API Response: Support
/// =======================================================
class SupportResponse {
  final List<SupportModel> supportList;

  SupportResponse({required this.supportList});

  factory SupportResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("error")) {
      return SupportResponse(supportList: []);
    }

    final List<dynamic> records =
        (json["set"] is List) ? json["set"] : <dynamic>[];

    return SupportResponse(
      supportList: records
          .whereType<Map<String, dynamic>>()
          .map((e) => SupportModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "supportList": supportList.map((e) => e.toJson()).toList(),
    };
  }
}

/// =======================================================
/// Support Ticket Model
/// =======================================================
class SupportModel {
  final String? id;
  final String recordID;
  final String? caseId;
  final String? topic;
  final String? subject;
  final String? description;
  String? priority; // remove 'final'
  String? status;
  final String? caseNumber;
  final String? email;
  final String? solutionNote;
  final String? suppliedEmail;
  final String? suppliedName;
  final String? accountName;
  final String? contactName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? type;
  final String? response;
  final DateTime? createdDate;
  final List<AttachedFile>? attachments;
  List<SupportFile> files;

  SupportModel({
    this.id,
    required this.recordID,
    this.caseId,
    this.topic,
    this.subject,
    this.description,
    this.priority,
    this.status,
    this.caseNumber,
    this.email,
    this.solutionNote,
    this.suppliedEmail,
    this.suppliedName,
    this.accountName,
    this.contactName,
    this.createdAt,
    this.updatedAt,
    this.response,
    this.type,
    this.createdDate,
    this.attachments,
    this.files = const [],
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    final List values = (json["values"] is List) ? json["values"] : [];

    String? getValue(String key) {
      try {
        // first check values array
        final match = values.whereType<Map>().firstWhere(
              (v) => v["name"] == key,
              orElse: () => {},
            );
        if (match.isNotEmpty) return match["value"]?.toString();

        // fallback to top-level key
        return json[key]?.toString();
      } catch (_) {
        return json[key]?.toString();
      }
    }

    List<AttachedFile>? parseAttachments() {
      final attachmentsJson = json['attachments'] as List<dynamic>?;
      if (attachmentsJson == null || attachmentsJson.isEmpty) return null;

      return attachmentsJson
          .map((a) {
            if (a is Map) {
              String? rawUrl = a['url'] ?? a['fileUrl'];
              if (rawUrl != null && !rawUrl.startsWith("http")) {
                rawUrl = "${API.baseURl}/$rawUrl";
              }
              return AttachedFile(
                fileName: a['fileName'] ?? 'Unknown',
                url: rawUrl,
                fileType: a['fileType'],
              );
            }
            return null;
          })
          .whereType<AttachedFile>()
          .toList();
    }

    return SupportModel(
      id: json['id'],
      // ✅ Always fallback to recordID if no caseId
      recordID: json['recordID'] ?? '',
      caseId: json['CaseNumber'] ?? '',
      topic: getValue("Type") ?? "-",
      subject: getValue("Subject") ?? "-",
      description: getValue("Description") ?? "-",
      priority: getValue("Priority") ?? "-",
      status: getValue("Status") ?? "OPEN",
      caseNumber: json['CaseNumber'] ?? '',
      solutionNote: getValue("SolutionNote"),
      suppliedEmail: getValue("SuppliedEmail"),
      suppliedName: getValue("SuppliedName"),
      accountName: getValue("AccountId") ?? json["AccountId"]?.toString(),
      contactName: getValue("ContactId") ?? json["ContactId"]?.toString(),
      email: getValue("SuppliedEmail"),
      // 👇 map createdAt and updatedAt
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"]).toLocal()
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"]).toLocal()
          : null,
      type: getValue("Type"),
      response: getValue("SolutionNote") ?? "",
      attachments: parseAttachments(),
      createdDate: json['response']?['createdAt'] != null
          ? DateTime.tryParse(json['response']['createdAt']?.toString() ?? "")
              ?.toLocal()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt']?.toString() ?? "")
                  ?.toLocal()
              : null,

      files: (json["files"] is List)
          ? (json["files"] as List<dynamic>)
              .map((f) => SupportFile.fromJson(f as Map<String, dynamic>))
              .toList()
          // fallback if API returns a bare array instead of {"files":[]}
          : (json is List)
              ? (json as List<dynamic>)
                  .map((f) => SupportFile.fromJson(f as Map<String, dynamic>))
                  .toList()
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "caseId": caseId,
      "topic": type,
      "subject": subject,
      "description": description,
      "priority": priority,
      "status": status,
      "caseNumber": caseNumber,
      "solutionNote": solutionNote,
      "suppliedEmail": suppliedEmail,
      "suppliedName": suppliedName,
      "accountName": accountName,
      "contactName": contactName,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "attachments": attachments?.map((a) => a.toJson()).toList(),
    };
  }

  SupportModel copyWith({
    String? status,
    DateTime? updatedAt,
    String? response,
  }) {
    return SupportModel(
      id: id,
      recordID: recordID,
      caseId: caseId,
      topic: topic,
      subject: subject,
      description: description,
      priority: priority,
      status: status ?? this.status,
      caseNumber: caseNumber,
      solutionNote: solutionNote,
      suppliedEmail: suppliedEmail,
      suppliedName: suppliedName,
      accountName: accountName,
      contactName: contactName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      response: response ?? this.response, // ✅ handle it
      attachments: attachments,
    );
  }

  String get priorityCode {
    switch ((priority ?? "").toLowerCase()) {
      case "high":
        return "P1";
      case "medium":
        return "P2";
      case "low":
        return "P3";
      case "very low":
        return "P4";
      default:
        return "-";
    }
  }
}

/// =======================================================
/// Support List Response
/// =======================================================
class SupportListResponse {
  final List<SupportModel> ticketList;
  final int totalCount;
  final int openCount;
  final int closedCount;

  SupportListResponse({
    required this.ticketList,
    required this.totalCount,
    required this.openCount,
    required this.closedCount,
  });

  factory SupportListResponse.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("error")) {
      return SupportListResponse(
        ticketList: [],
        totalCount: 0,
        openCount: 0,
        closedCount: 0,
      );
    }

    final List<dynamic> records =
        (json["records"] is List) ? json["records"] : <dynamic>[];

    return SupportListResponse(
      ticketList: records
          .whereType<Map<String, dynamic>>()
          .map((e) => SupportModel.fromJson(e))
          .toList(),
      totalCount: json["totalCount"] ?? records.length,
      openCount: json["openCount"] ?? 0,
      closedCount: json["closedCount"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "set": ticketList.map((e) => e.toJson()).toList(),
      "totalCount": totalCount,
      "openCount": openCount,
      "closedCount": closedCount,
    };
  }
}

/// =======================================================
/// Support History Model
/// =======================================================
class SupportHistoryModel {
  final String recordId;
  final String caseId;
  final String userId;
  final String userType;
  final String message;
  final DateTime createdAt;
  final String user;
  final String time;

  SupportHistoryModel({
    required this.recordId,
    required this.caseId,
    required this.userId,
    required this.userType,
    required this.message,
    required this.createdAt,
    required this.user,
    required this.time,
  });

  factory SupportHistoryModel.fromJson(Map<String, dynamic> json) {
    return SupportHistoryModel(
      recordId: json["recordID"]?.toString() ?? "",
      caseId: json["CaseId"]?.toString() ?? json["caseId"]?.toString() ?? "",
      userId: json["UserId"]?.toString() ?? "",
      userType: json["Type"]?.toString() ?? "",
      message: json["Description"]?.toString() ?? "",
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
          : DateTime.now(),
      user: json["user"] ?? "",
      time: json["createdAt"] ?? "", // backend gives ISO timestamp
    );
  }

  bool get isCustomer => userType.toLowerCase() == "customer";
  bool get isSupportTeam => userType.toLowerCase() == "supportteam";

  String get userName => isSupportTeam ? "Support Team" : "Customer";
}

class SupportTicketModel {
  final String caseNumber;
  final String contactId;
  final String accountId;
  String? userName;
  String? instituteName;
  final String type;
  final String priorityCode;
  final String status;
  final DateTime createdAt;

  SupportTicketModel({
    required this.caseNumber,
    required this.contactId,
    required this.accountId,
    this.userName,
    this.instituteName,
    required this.type,
    required this.priorityCode,
    required this.status,
    required this.createdAt,
  });
}

class AttachedFile {
  final String? fileName;
  final String? url; // The actual file link
  final String? fileType; // e.g. "image/png", "application/pdf"

  AttachedFile({this.fileName, this.url, this.fileType});

  Map<String, dynamic> toJson() {
    return {
      "fileName": fileName,
      "url": url, // ✅ matches the field name
      "fileType": fileType, // ✅ include type if needed
    };
  }

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    String? rawUrl = json["url"] ?? json["fileUrl"];
    if (rawUrl != null && !rawUrl.startsWith("http")) {
      rawUrl = "${API.baseURl}/$rawUrl"; // prepend base if relative
    }

    return AttachedFile(
      fileName: json["fileName"],
      url: rawUrl,
      fileType: json["fileType"],
    );
  }
}

class TicketResponse {
  final String recordID;
  final String? moduleID;
  final int? revision;
  final String? caseNumber;
  final String? type;
  final String? description;
  final String? priority;
  final String? subject;
  final String? status;
  final DateTime? createdAt;

  TicketResponse({
    required this.recordID,
    this.moduleID,
    this.revision,
    this.caseNumber,
    this.type,
    this.description,
    this.priority,
    this.subject,
    this.status,
    this.createdAt,
  });

  factory TicketResponse.fromJson(Map<String, dynamic> json) {
    final values = json['values'] as List<dynamic>? ?? [];

    String? getValue(String key) {
      try {
        return values
            .firstWhere((v) => v['name'] == key,
                orElse: () => {"value": null})['value']
            ?.toString();
      } catch (_) {
        return null;
      }
    }

    return TicketResponse(
      recordID: json['recordID'] ?? '',
      moduleID: json['moduleID'],
      revision: json['revision'],
      caseNumber: getValue("CaseNumber"),
      type: getValue("Type"),
      description: getValue("Description"),
      priority: getValue("Priority"),
      subject: getValue("Subject"),
      status: getValue("Status"),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

class SupportFile {
  final String fileId;
  final String name;
  final String url;
  final String mimetype;

  SupportFile({
    required this.fileId,
    required this.name,
    required this.url,
    required this.mimetype,
  });

  factory SupportFile.fromJson(Map<String, dynamic> json) {
    return SupportFile(
      fileId: json["file_id"],
      name: json["name"],
      url: json["url"],
      mimetype: json["mimetype"],
    );
  }
}
