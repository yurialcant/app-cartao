/// Notification model
class Notification {
  final String id;
  final String type; // PAYMENT, CREDIT, EXPENSE, SYSTEM, etc.
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final String? actionUrl; // Deep link URL

  const Notification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.metadata,
    this.actionUrl,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      type: json['type'] ?? 'SYSTEM',
      title: json['title'] ?? 'Notificação',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
      actionUrl: json['actionUrl'],
    );
  }

  Notification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    String? actionUrl,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'Agora';
    }
  }

  String get displayIcon {
    switch (type) {
      case 'PAYMENT':
        return '💳';
      case 'CREDIT':
        return '💰';
      case 'EXPENSE':
        return '📄';
      case 'SYSTEM':
        return 'ℹ️';
      default:
        return '🔔';
    }
  }

  bool get hasAction => actionUrl != null && actionUrl!.isNotEmpty;
}