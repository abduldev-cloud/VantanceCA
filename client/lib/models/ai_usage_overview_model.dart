import 'dart:convert';
import 'package:flutter/material.dart';

// Main response model for AI usage overview analytics
AiUsageOverviewModel aiUsageOverviewModelFromJson(String str) =>
    AiUsageOverviewModel.fromJson(json.decode(str));

String aiUsageOverviewModelToJson(AiUsageOverviewModel data) =>
    json.encode(data.toJson());

class AiUsageOverviewModel {
  final WritingFingerprintAnalytics? writingFingerprintAnalytics;
  final AiPromptUsage? aiPromptUsage;
  final MonthlyWritingDashboard? monthlyWritingDashboard;
  final WritingFingerprintTrend? writingFingerprintTrend;
  final List<WritingFingerprintAlert>? writingFingerprintAlerts;
  final ScopeInfo? scopeInfo;
  final UserContext? userContext;
  final String? message;
  final String? timestamp;

  AiUsageOverviewModel({
    this.writingFingerprintAnalytics,
    this.aiPromptUsage,
    this.monthlyWritingDashboard,
    this.writingFingerprintTrend,
    this.writingFingerprintAlerts,
    this.scopeInfo,
    this.userContext,
    this.message,
    this.timestamp,
  });

  factory AiUsageOverviewModel.fromJson(Map<String, dynamic> json) =>
      AiUsageOverviewModel(
        writingFingerprintAnalytics: json["writing_fingerprint_analytics"] == null
            ? null
            : WritingFingerprintAnalytics.fromJson(json["writing_fingerprint_analytics"]),
        aiPromptUsage: json["ai_prompt_usage"] == null
            ? null
            : AiPromptUsage.fromJson(json["ai_prompt_usage"]),
        monthlyWritingDashboard: json["monthly_writing_dashboard"] == null
            ? null
            : MonthlyWritingDashboard.fromJson(json["monthly_writing_dashboard"]),
        writingFingerprintTrend: json["writing_fingerprint_trend"] == null
            ? null
            : WritingFingerprintTrend.fromJson(json["writing_fingerprint_trend"]),
        writingFingerprintAlerts: json["writing_fingerprint_alerts"] == null
            ? null
            : List<WritingFingerprintAlert>.from(json["writing_fingerprint_alerts"]!.map((x) => WritingFingerprintAlert.fromJson(x))),
        scopeInfo: json["scope_info"] == null
            ? null
            : ScopeInfo.fromJson(json["scope_info"]),
        userContext: json["user_context"] == null
            ? null
            : UserContext.fromJson(json["user_context"]),
        message: json["message"],
        timestamp: json["timestamp"],
      );

  /// Factory constructor to create from API response format
 factory AiUsageOverviewModel.fromApiResponse(Map<String, dynamic> json, {int? periods}) {
    final data = json['data'] ?? {};

    final wfJson = data['writing_fingerprint_analytics'] ?? {};

    final writingFingerprintAnalytics = WritingFingerprintAnalytics(
      averageDeviation: (wfJson['average_deviation'] ?? 0.0).toDouble(),
      totalCount: wfJson['total_count'] ?? 0,
      averageTimeMinutes: (wfJson['average_time_minutes'] ?? 0.0).toDouble(),
      averageTeacherGrade: (wfJson['average_teacher_grade'] ?? 0.0).toDouble(),
      averageDeviationTrend: wfJson['average_deviation_trend']?.toString(), // Get from API
      totalCountTrend: wfJson['total_count_trend']?.toString(), // Get from API
    );

  // Extract trend series
    final trendJson = wfJson['trend'] as Map<String, dynamic>?;
    final trendSeries = trendJson?['series'] as List<dynamic>? ?? [];

    // Convert trend series to list of ints (for chart)
    List<int> chartData = trendSeries.map<int>((point) {
      final avgDeviation = (point['avg_deviation'] ?? 0.0).toDouble();
      return avgDeviation.round();
    }).toList();

    // Pad chart data if less than periods
    final periodCount = periods ?? chartData.length;
    while (chartData.length < periodCount) {
      chartData.insert(0, 0);
    }

    final monthlyWritingDashboard = MonthlyWritingDashboard.fromList(chartData);

    // Writing Fingerprint Trend
    final writingFingerprintTrend = trendJson == null
        ? null
        : WritingFingerprintTrend.fromJson(trendJson);

    final aiUsage = data['ai_prompt_usage'] ?? {};

    final aiPromptUsage = AiPromptUsage(
      averageUsage: (aiUsage['average_usage'] ?? 0.0).toDouble(),
      totalCount: aiUsage['total_count'] ?? 0,
      averageUsageTrend: aiUsage['average_usage_trend']?.toString(), // Get from API
      totalCountAiTrend: aiUsage['total_count_ai_trend']?.toString(), // Get from API
    );

    return AiUsageOverviewModel(
      writingFingerprintAnalytics: writingFingerprintAnalytics,
      writingFingerprintTrend: writingFingerprintTrend,
      aiPromptUsage: aiPromptUsage,
      monthlyWritingDashboard: monthlyWritingDashboard,
      scopeInfo: data['scope_info'] == null ? null : ScopeInfo.fromJson(data['scope_info']),
      userContext: data['user_context'] == null ? null : UserContext.fromJson(data['user_context']),
      message: json['message'] ?? "AI usage overview data retrieved successfully",
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        "writing_fingerprint_analytics": writingFingerprintAnalytics?.toJson(),
        "ai_prompt_usage": aiPromptUsage?.toJson(),
        "monthly_writing_dashboard": monthlyWritingDashboard?.toJson(),
        "writing_fingerprint_trend": writingFingerprintTrend?.toJson(),
        "writing_fingerprint_alerts": writingFingerprintAlerts?.map((x) => x.toJson()).toList(),
        "scope_info": scopeInfo?.toJson(),
        "user_context": userContext?.toJson(),
        "message": message,
        "timestamp": timestamp,
      };
}

// Writing Fingerprint Analytics model
class WritingFingerprintAnalytics {
  final double? averageDeviation;
  final int? totalCount;
  final double? averageTimeMinutes;
  final double? averageTeacherGrade;
  final String? averageDeviationTrend; // fixed
  final String? totalCountTrend; // fixed

  WritingFingerprintAnalytics({
    this.averageDeviation,
    this.totalCount,
    this.averageTimeMinutes,
    this.averageTeacherGrade,
    this.averageDeviationTrend,
    this.totalCountTrend,
  });

  factory WritingFingerprintAnalytics.fromJson(Map<String, dynamic> json) =>
      WritingFingerprintAnalytics(
        averageDeviation: (json["average_deviation"] ?? 0.0).toDouble(),
        totalCount: json["total_count"] ?? 0,
        averageTimeMinutes: (json["average_time_minutes"] ?? 0.0).toDouble(),
        averageTeacherGrade: (json["average_teacher_grade"] ?? 0.0).toDouble(),
        averageDeviationTrend: json["average_deviation_trend"]?.toString() ,
        totalCountTrend: json["total_count_trend"]?.toString() ,
      );

  Map<String, dynamic> toJson() => {
        "average_deviation": averageDeviation,
        "total_count": totalCount,
        "average_time_minutes": averageTimeMinutes,
        "average_teacher_grade": averageTeacherGrade,
        "average_deviation_trend": averageDeviationTrend,
        "total_count_trend": totalCountTrend,
      };
}

// AiPromptUsage model
class AiPromptUsage {
  final double? averageUsage;
  final int? totalCount;
  final String? averageUsageTrend; // fixed
  final String? totalCountAiTrend; // fixed

  AiPromptUsage({
    this.averageUsage,
    this.totalCount,
    this.averageUsageTrend,
    this.totalCountAiTrend,
  });

  factory AiPromptUsage.fromJson(Map<String, dynamic> json) => AiPromptUsage(
        averageUsage: (json["average_usage"] ?? 0.0).toDouble(),
        totalCount: json["total_count"] ?? 0,
        averageUsageTrend: json["average_usage_trend"]?.toString() ,
        totalCountAiTrend: json["total_count_ai_trend"]?.toString() ,
      );

  Map<String, dynamic> toJson() => {
        "average_usage": averageUsage,
        "total_count": totalCount,
        "average_usage_trend": averageUsageTrend,
        "total_count_ai_trend": totalCountAiTrend,
      };
}


// Monthly Writing Dashboard model
class MonthlyWritingDashboard {
  final List<int> data;

  MonthlyWritingDashboard(this.data);

  factory MonthlyWritingDashboard.fromJson(Map<String, dynamic> json) {
    // Attempt to parse 12 months or fallback to zeros
    List<int> values = List.generate(12, (i) => json[MonthlyWritingDashboard.monthNames[i].toLowerCase()] ?? 0);
    return MonthlyWritingDashboard(values);
  }

  factory MonthlyWritingDashboard.fromList(List<int> values) => MonthlyWritingDashboard(values);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    for (int i = 0; i < data.length && i < 12; i++) {
      map[MonthlyWritingDashboard.monthNames[i].toLowerCase()] = data[i];
    }
    return map;
  }

  List<int> get monthlyDataList => data;

  static List<String> get monthNames => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
}

// Writing Fingerprint Trend model
class WritingFingerprintTrend {
  final String? bucket;
  final int? periods;
  final String? className;
  final List<TrendDataPoint>? series;

  WritingFingerprintTrend({
    this.bucket,
    this.periods,
    this.className,
    this.series,
  });

  factory WritingFingerprintTrend.fromJson(Map<String, dynamic> json) =>
      WritingFingerprintTrend(
        bucket: json["bucket"],
        periods: json["periods"],
        className: json["class_name"],
        series: json["series"] == null
            ? null
            : List<TrendDataPoint>.from(json["series"]!.map((x) => TrendDataPoint.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "bucket": bucket,
        "periods": periods,
        "class_name": className,
        "series": series?.map((x) => x.toJson()).toList(),
      };
}

// Trend Data Point model
class TrendDataPoint {
  final String? label;
  final double? avgDeviation;
  final String? startTs;

  TrendDataPoint({
    this.label,
    this.avgDeviation,
    this.startTs,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) =>
      TrendDataPoint(
        label: json["label"],
        avgDeviation: json["avg_deviation"]?.toDouble(),
        startTs: json["start_ts"],
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "avg_deviation": avgDeviation,
        "start_ts": startTs,
      };
}

// Writing Fingerprint Alert model
class WritingFingerprintAlert {
  final String? studentName;
  final String? assignmentTitle;
  final double? deviationPercentage;
  final String? submissionDate;
  final String? alertLevel;
  final String? description;

  WritingFingerprintAlert({
    this.studentName,
    this.assignmentTitle,
    this.deviationPercentage,
    this.submissionDate,
    this.alertLevel,
    this.description,
  });

 factory WritingFingerprintAlert.fromJson(Map<String, dynamic> json) =>
    WritingFingerprintAlert(
      studentName: json["learner_name"],  // Use 'learner_name' from API
      assignmentTitle: json["assignment_title"],
      deviationPercentage: json["deviation_percentage"]?.toDouble(),
      submissionDate: json["created_date"] ?? json["submission_date"],
      alertLevel: json["alert_level"],
      description: json["description"],
    );


  Map<String, dynamic> toJson() => {
        "student_name": studentName,
        "assignment_title": assignmentTitle,
        "deviation_percentage": deviationPercentage,
        "submission_date": submissionDate,
        "alert_level": alertLevel,
        "description": description,
      };

  /// Get alert level color
  Color get alertColor {
    switch (alertLevel?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  /// Get formatted deviation percentage
  String get formattedDeviation => 
      deviationPercentage != null ? "${deviationPercentage!.toStringAsFixed(1)}%" : "N/A";
}

// Scope Info model
class ScopeInfo {
  final String? scope;
  final String? scopeId;

  ScopeInfo({
    this.scope,
    this.scopeId,
  });

  factory ScopeInfo.fromJson(Map<String, dynamic> json) =>
      ScopeInfo(
        scope: json["scope"],
        scopeId: json["scope_id"],
      );

  Map<String, dynamic> toJson() => {
        "scope": scope,
        "scope_id": scopeId,
      };
}

// User Context model
class UserContext {
  final String? email;
  final String? role;
  final int? daysBack;

  UserContext({
    this.email,
    this.role,
    this.daysBack,
  });

  factory UserContext.fromJson(Map<String, dynamic> json) =>
      UserContext(
        email: json["email"],
        role: json["role"],
        daysBack: json["days_back"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "role": role,
        "days_back": daysBack,
      };
}
