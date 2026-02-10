class LmsIntegrationData {
  final String id;
  final String token;
  final String schoolAdminId;
  final String appName;
  final String purpose;
  final String platform;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastUsed;
  final String? instituteId;
  final String? status;
  final String? apiKey;   // Added API_KEY field
  final String? apiSecret;  // Added API_SECRET field

  LmsIntegrationData({
    required this.id,
    required this.token,
    required this.schoolAdminId,
    required this.appName,
    required this.purpose,
    required this.platform,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.lastUsed,
    this.instituteId,
    this.status,
    this.apiKey,
    this.apiSecret,
  });

  factory LmsIntegrationData.fromJson(Map<String, dynamic> json) {
    return LmsIntegrationData(
      id: json['ID'] ?? '',
      token: json['TOKEN'] ?? '',
      schoolAdminId: json['SCHOOL_ADMIN_ID'] ?? '',
      appName: json['APP_NAME'] ?? '',
      purpose: json['PURPOSE'] ?? '',
      platform: json['PLATFORM'] ?? '',
      expiresAt: json['EXPIRES_AT'] != null ? DateTime.tryParse(json['EXPIRES_AT']) : null,
      createdAt: DateTime.parse(json['CREATED_AT']),
      updatedAt: DateTime.parse(json['UPDATED_AT']),
      lastUsed: json['LAST_USED'],
      instituteId: json['INSTITUTE_ID'],
      status: json['STATUS'],
      apiKey: json['API_KEY'],
      apiSecret: json['API_SECRET'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TOKEN': token,
      'SCHOOL_ADMIN_ID': schoolAdminId,
      'APP_NAME': appName,
      'PURPOSE': purpose,
      'PLATFORM': platform,
      'EXPIRES_AT': expiresAt?.toIso8601String(),
      'CREATED_AT': createdAt.toIso8601String(),
      'UPDATED_AT': updatedAt.toIso8601String(),
      'LAST_USED': lastUsed,
      'INSTITUTE_ID': instituteId,
      'STATUS': status,
      'API_KEY': apiKey,
      'API_SECRET': apiSecret,
    };
  }
}
