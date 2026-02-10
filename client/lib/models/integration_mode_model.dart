class IntegrationMode {
  final String? integrationMode;
  final String? integrationType;
  final String? alfrescoSiteId;
  final String? bulkUploadId;
  final String? lastIntegrationTimestamp;
  final String? integrationStatus;

  IntegrationMode({
    required this.integrationMode,
    required this.integrationType,
    required this.alfrescoSiteId,
    this.bulkUploadId,
    this.lastIntegrationTimestamp,
    this.integrationStatus
  });

  factory IntegrationMode.fromJson(Map<String, dynamic> json) {
    return IntegrationMode(
      integrationMode: json['INTEGRATION_MODE'] ?? "OFF",
      integrationType: json['INTEGRATION_TYPE'],
      alfrescoSiteId: json['ALFRESCO_SITE_ID'],
      bulkUploadId: json['BULK_UPLOAD_ID'],
      lastIntegrationTimestamp: json['LAST_INTEGRATION_TIMESTAMP'],
      integrationStatus: json['INTEGRATION_STATUS'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'INTEGRATION_MODE': integrationMode,
      'INTEGRATION_TYPE': integrationType,
      'ALFRESCO_SITE_ID': alfrescoSiteId,
      'BULK_UPLOAD_ID': bulkUploadId,
      'LAST_INTEGRATION_TIMESTAMP': lastIntegrationTimestamp,
      'INTEGRATION_STATUS': integrationStatus
    };
  }
}
