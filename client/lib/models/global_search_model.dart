class GlobalSearchModel {
  final String entityId;
  final String entityName;
  final String entityType;

  GlobalSearchModel({
    required this.entityId,
    required this.entityName,
    required this.entityType,
  });

  factory GlobalSearchModel.fromJson(Map<String, dynamic> json) {
    return GlobalSearchModel(
      entityId: json["entity_id"] ?? "",
      entityName: json["entity_name"] ?? "",
      entityType: json["entity_type"] ?? "",
    );
  }

  static List<GlobalSearchModel> listFromJson(List<dynamic> data) {
    return data.map((e) => GlobalSearchModel.fromJson(e)).toList();
  }
}