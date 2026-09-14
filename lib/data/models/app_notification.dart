class AppNotification {
  const AppNotification({
    required this.id,
    required this.referenceId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.event,
    this.params,
    this.createdAt,
  });

  final String id;
  final String referenceId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? event;
  final Map<String, dynamic>? params;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'referenceId': referenceId,
      'title': title,
      'message': message,
      'event': event,
      'params': params,
      'type': type,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
