class IntegrationLog {
  final String id;
  final DateTime datetime;
  final String message;
  final String? middlewareId;
  final String? bulkUploadId;

  IntegrationLog({
    required this.id,
    required this.datetime,
    required this.message,
    this.middlewareId,
    this.bulkUploadId
  });

  factory IntegrationLog.fromJson(Map<String, dynamic> json) {
    return IntegrationLog(
      id: json['ID'] ?? '',
      datetime: DateTime.parse(json['DATETIME']),
      message: json['MESSAGE'] ?? '',
      middlewareId: json['MIDDLEWARE_ID'],
      bulkUploadId: json['BULK_UPLOAD_ID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'DATETIME': datetime.toIso8601String(),
      'MESSAGE': message,
      'MIDDLEWARE_ID': middlewareId,
      'BULK_UPLOAD_ID': bulkUploadId,
    };
  }
}
