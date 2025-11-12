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
  updated('Updated', IconBroken.Edit, Color(0xFF607D8B), Color(0xFFECEFF1)),
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
