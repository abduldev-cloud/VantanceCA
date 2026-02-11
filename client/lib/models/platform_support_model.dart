import 'dart:convert';
import 'package:vantanceCA/helpers/constant/app_constant.dart';
import 'package:vantanceCA/helpers/services/platform_service.dart';

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
  final String? id; // Ticket record ID
  final String recordID;
  final String? caseNumber;
  final String? response; // latest response (optional)
  final String? type; // Topic/Type of ticket
  final String? suppliedName; // Customer name
  final String? topic; // From Type
  final String? subject;
  final String? description;
  final String? priority;
  final String? status;
  final String? accountName; // Institute name
  final String? contactName; // User
  final String? solutionNote;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? createdDate; // Local created date
  final DateTime? updatedAt;
  final List<AttachedFile>? attachments;
  List<SupportFile> files; // Attached files

  SupportModel({
    required this.recordID,
    this.id,
    this.caseNumber,
    this.topic,
    this.subject,
    this.description,
    this.priority,
    this.response,
    this.type,
    this.suppliedName,
    this.status,
    this.accountName,
    this.contactName,
    this.solutionNote,
    this.ownerId,
    this.createdAt,
    this.createdDate,
    this.updatedAt,
    this.attachments,
    this.files = const [],
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    return SupportModel(
      recordID: json["recordID"]?.toString() ?? "",
      id: json["id"],
      caseNumber: json["CaseNumber"]?.toString(),
      topic: json["Type"]?.toString(),
      subject: json["Subject"]?.toString(),
      description: json["Description"]?.toString(),
      priority: json["Priority"]?.toString(),
      status: json["Status"]?.toString().toUpperCase(),
      accountName: json["AccountName"]?.toString(),
      response: json["response"],
      type: json["type"],
      suppliedName: json["supplied_name"],
      contactName: json["ContactName"]?.toString(),
      solutionNote: json["SolutionNote"]?.toString(),
      ownerId: json["OwnerId"]?.toString(),
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"].toString())
          : null,
      createdDate: DateTime.tryParse(
        (json['createdAt'] ?? json['CreatedAt'] ?? json['created_date'] ?? '')
            .toString(),
      )?.toLocal(),
      files: (json["files"] as List<dynamic>?)
              ?.map((e) => SupportFile.fromJson(e))
              .toList() ??
          [],
      attachments: (json["attachments"] is List)
          ? (json["attachments"] as List)
              .whereType<Map<String, dynamic>>()
              .map((a) => AttachedFile(
                    fileName: a["fileName"] ?? "Unknown",
                    url: a["url"] ?? a["fileUrl"] ?? "",
                    fileType: a["fileType"],
                  ))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "recordID": recordID,
      "CaseNumber": caseNumber,
      "Type": topic,
      "Subject": subject,
      "Description": description,
      "Priority": priority,
      "Status": status,
      "AccountName": accountName,
      "ContactName": contactName,
      "SolutionNote": solutionNote,
      "response": response,
      "type": type,
      "supplied_name": suppliedName,
      "OwnerId": ownerId,
      "createdAt": createdAt?.toIso8601String(),
      "createdDate": createdDate?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "files": files.map((f) => f.toJson()).toList(),
      "attachments": attachments?.map((a) => a.toJson()).toList(),
    };
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

class SupportListResponse {
  final List<SupportModel> ticketList;
  final int allCount;
  final int openCount;
  final int closedCount;

  SupportListResponse({
    required this.ticketList,
    required this.allCount,
    required this.openCount,
    required this.closedCount,
  });

  factory SupportListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> records =
        (json["records"] is List) ? json["records"] : <dynamic>[];
    final statusCounts = json["status_counts"] ?? {};

    return SupportListResponse(
      ticketList: records
          .whereType<Map<String, dynamic>>()
          .map((e) => SupportModel.fromJson(e))
          .toList(),
      allCount: statusCounts["all"] ?? records.length,
      openCount: statusCounts["open"] ?? 0,
      closedCount: statusCounts["closed"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "records": ticketList.map((e) => e.toJson()).toList(),
      "status_counts": {
        "all": allCount,
        "open": openCount,
        "closed": closedCount,
      }
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

  SupportHistoryModel({
    required this.recordId,
    required this.caseId,
    required this.userId,
    required this.userType,
    required this.message,
    required this.createdAt,
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
      fileId: json["file_id"]?.toString() ?? "",
      name: json["name"] ?? "",
      url: json["url"] ?? "",
      mimetype: json["mimetype"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "file_id": fileId,
      "name": name,
      "url": url,
      "mimetype": mimetype,
    };
  }
}

class Ticket {
  final String? caseNumber;
  final String? type;
  final String? priorityCode;
  final String? status;
  final String? createdAt;

  final String? instituteName; // <- map from account.AccountName
  final String? userName; // <- map from contact.FullName

  Ticket({
    this.caseNumber,
    this.type,
    this.priorityCode,
    this.status,
    this.createdAt,
    this.instituteName,
    this.userName,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final ticketResp = json['ticket']?['response'];
    final values = (ticketResp?['values'] as List?) ?? [];

    String? getValue(String field) {
      return values.firstWhere(
        (v) => v['name'] == field,
        orElse: () => {"value": null},
      )['value'];
    }

    return Ticket(
      caseNumber: getValue("CaseNumber"),
      type: getValue("Type"),
      priorityCode: getValue("Priority"),
      status: getValue("Status"),
      createdAt: ticketResp?['createdAt'] != null
          ? DateTime.tryParse(ticketResp?['createdAt'] ?? '')
              ?.toLocal()
              .toIso8601String()
          : null,

      // ✅ map from API response
      instituteName: json['account']?['AccountName'],
      userName: json['contact']?['FullName'],
    );
  }
}
