class PlatformSupportTicket {
  final String ticketNumber;
  final String userName;
  final String priority;

  PlatformSupportTicket({
    required this.ticketNumber,
    required this.userName,
    required this.priority,
  });

  factory PlatformSupportTicket.fromJson(Map<String, dynamic> json) {
    return PlatformSupportTicket(
      ticketNumber: json['CaseNumber'] ?? '',
      userName: json['SuppliedName'] ?? 'Unknown',
      priority: json['Priority'] ?? 'Unknown',
    );
  }
}

class PlatformSupportListResponse {
  final List<PlatformSupportTicket> tickets;

  PlatformSupportListResponse({required this.tickets});

  factory PlatformSupportListResponse.fromJson(Map<String, dynamic> json) {
    var ticketList = json['tickets'] as List<dynamic>? ?? [];
    return PlatformSupportListResponse(
      tickets: ticketList
          .map((e) => PlatformSupportTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
