import 'package:flutter/material.dart';
import 'package:icon_broken/icon_broken.dart';

enum NotificationType {
  joinedSubject(
    'New Student Joined',
    IconBroken.AddUser,
    Color(0xFF4CAF50),
    Color(0xFFE8F5E9),
    'student_channel',
    'New Students ',
  ),

  createdExam(
    'New Exam Created',
    IconBroken.Document,
    Color(0xFF2196F3),
    Color(0xFFE3F2FD),
    'exam_channel',
    'Exam Notifications',
  ),

  submit(
    'Exam Submissions',
    IconBroken.Send,
    Color(0xFF9C27B0),
    Color(0xFFF3E5F5),
    'submission_channel',
    'Submission Notifications',
  ),

  examEnding(
    'Exam Ending Soon',
    IconBroken.Time_Circle,
    Color(0xFFFF9800),
    Color(0xFFFFF3E0),
    'urgent_channel',
    'Urgent Notifications',
  ),

  examEnded(
    'Exam Ended',
    IconBroken.Close_Square,
    Color(0xFFF44336),
    Color(0xFFFFEBEE),
    'urgent_channel',
    'Urgent Notifications',
  ),

  examStarted(
    'Exam Started',
    IconBroken.Play,
    Color(0xFF00BCD4),
    Color(0xFFE0F7FA),
    'exam_channel',
    'Exam Notifications',
  ),

  updated(
    'Updated',
    IconBroken.Edit,
    Color(0xFF607D8B),
    Color(0xFFECEFF1),
    'general_channel',
    'General Notifications',
  ),

  other(
    'Notification',
    IconBroken.Notification,
    Color(0xFF607D8B),
    Color(0xFFECEFF1),
    'general_channel',
    'General Notifications',
  );

  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String channelId;
  final String channelName;

  const NotificationType(
    this.title,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.channelId,
    this.channelName,
  );

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.other,
    );
  }
}