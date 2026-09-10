enum NotificationType { appointmentBooked, appointmentReminder, appointmentCancelled, general }

extension NotificationTypeX on NotificationType {
  String get icon {
    switch (this) {
      case NotificationType.appointmentBooked:
        return '📅';
      case NotificationType.appointmentReminder:
        return '⏰';
      case NotificationType.appointmentCancelled:
        return '❌';
      case NotificationType.general:
        return '🔔';
    }
  }
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? relatedAppointmentId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.relatedAppointmentId,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      relatedAppointmentId: relatedAppointmentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'relatedAppointmentId': relatedAppointmentId,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.values[json['type'] as int],
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      relatedAppointmentId: json['relatedAppointmentId'] as String?,
    );
  }
}