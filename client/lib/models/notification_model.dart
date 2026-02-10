class NotificationItem {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final bool read;
  final DateTime timestamp;
  final Map<String, dynamic>? meta;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.timestamp,
    this.meta,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      read: json['read'],
      timestamp: DateTime.parse(json['timestamp']),
      meta: json['meta'],
    );
  }

  NotificationItem copyWith({
    bool? read,
  }) {
    return NotificationItem(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      read: read ?? this.read,
      timestamp: timestamp,
      meta: meta,
    );
  }
}
