import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';

enum NotificationType {
  joinedSubject(
    'Joined Subject',
    IconBroken.AddUser,
    Color(0xFF4CAF50),
    Color(0xFFE8F5E9),
  ),
  createdExam(
    'Created Exam',
    IconBroken.Document,
    Color(0xFF2196F3),
    Color(0xFFE3F2FD),
  ),
  submit('Submit', IconBroken.Send, Color(0xFF9C27B0), Color(0xFFF3E5F5)),
  examEnding(
    'Exam Ending',
    IconBroken.Time_Circle,
    Color(0xFFFF9800),
    Color(0xFFFFF3E0),
  ),
  examEnded(
    'Exam Ended',
    IconBroken.Close_Square,
    Color(0xFFF44336),
    Color(0xFFFFEBEE),
  ),
  examStarted(
    'Exam Started',
    IconBroken.Play,
    Color(0xFF00BCD4),
    Color(0xFFE0F7FA),
  ),
  other(
    'Notification',
    IconBroken.Notification,
    Color(0xFF607D8B),
    Color(0xFFECEFF1),
  );

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const NotificationType(
    this.title,
    this.icon,
    this.iconColor,
    this.backgroundColor,
  );

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.other,
    );
  }
}

class NotificationModel extends Equatable {
  final String _id;
  final NotificationType _type;
  final String _body;
  final String _createdAt;
  final bool _readOut;
  final bool _readIn;

  const NotificationModel({
    required String id,
    required NotificationType type,
    required String body,
    required String createdAt,
    bool readOut = false,
    bool readIn = false,
  }) : _id = id,
       _createdAt = createdAt,
       _body = body,
       _type = type,
       _readOut = readOut,
       _readIn = readIn;

  // Getters
  String get id => _id;
  NotificationType get type => _type;
  String get title => _type.title;
  String get body => _body;
  String get createdAt => _createdAt;
  bool get readOut => _readOut;
  bool get readIn => _readIn;
  IconData get icon => _type.icon;
  Color get iconColor => _type.iconColor;
  Color get backgroundColor => _type.backgroundColor;

  // Duration since creation
  Duration get timeSinceCreation {
    final created = DateTime.parse(_createdAt);
    return DateTime.now().difference(created);
  }

  // Formatted time string
  String get formattedTime {
    final duration = timeSinceCreation;

    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    if (duration.inDays < 7) return '${duration.inDays}d ago';

    return '${(duration.inDays / 7).floor()}w ago';
  }

  // Check if notification is read
  bool get isRead => _readIn || _readOut;

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? body,
    String? createdAt,
    bool? readOut,
    bool? readIn,
  }) {
    return NotificationModel(
      id: id ?? _id,
      type: type ?? _type,
      body: body ?? _body,
      createdAt: createdAt ?? _createdAt,
      readOut: readOut ?? _readOut,
      readIn: readIn ?? _readIn,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id_notification'] as String? ?? '',
      type: NotificationType.fromString(json['type'] as String? ?? ''),
      body: json['body'] as String? ?? '',
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      readOut: json['readOut'] as bool? ?? false,
      readIn: json['readIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_notification': _id,
      'type': _type.name,
      'body': _body,
      'createdAt': _createdAt,
      'readOut': _readOut,
      'readIn': _readIn,
    };
  }

  @override
  List<Object?> get props => [_id, _type, _body, _createdAt, _readOut, _readIn];
}

// Notification Widget
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.notification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2630),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: notification.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.body,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.formattedTime,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Read indicator
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: notification.iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
