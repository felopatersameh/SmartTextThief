import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_thief/Core/Storage/Local/get_local_storage.dart';
import '../Enums/notification_type.dart';

class NotificationModel extends Equatable {
  final String _id;
  final String _topicId;
  final NotificationType _titleTopic;
  final String _body;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final List<String> _readOut;
  final List<String> _readIn;

  const NotificationModel._internal({
    String? id,
    required String topicId,
    required NotificationType type,
    required String body,
    required DateTime? createdAt,
    required DateTime? updatedAt,
    List<String>? readOut,
    List<String>? readIn,
  })  : _id = id ?? '',
        _topicId = topicId,
        _titleTopic = type,
        _body = body,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _readOut = readOut ?? const [],
        _readIn = readIn ?? const [];

  factory NotificationModel({
    String? id,
    required String topicId,
    required NotificationType type,
    required String body,
    List<String>? readOut,
    List<String>? readIn,
  }) {
    return NotificationModel._internal(
      id: id,
      topicId: topicId,
      type: type,
      body: body,
      createdAt: null,
      updatedAt: null,
      readOut: readOut,
      readIn: readIn,
    );
  }

  // Getters
  String get id => _id;
  String get topicId => _topicId;
  NotificationType get titleTopic => _titleTopic;
  String get title => _titleTopic.title;
  String get body => _body;
  List<String> get listReadIn => _readIn;
  List<String> get listReadOut => _readOut;
  DateTime? get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;
  bool get readOut {
    final email = GetLocalStorage.getEmailUser();
    return _readOut.contains(email);
  }

  bool get readIn {
    final email = GetLocalStorage.getEmailUser();
    return _readIn.contains(email);
  }

  IconData get icon => _titleTopic.icon;
  Color get iconColor => _titleTopic.iconColor;
  Color get backgroundColor => _titleTopic.backgroundColor;

  Duration? get timeSinceCreation =>
      _createdAt == null ? null : DateTime.now().difference(_createdAt);

  Duration? get timeSinceUpdate =>
      _updatedAt == null ? null : DateTime.now().difference(_updatedAt);

  String get formattedTime {
    if (_updatedAt == null) return '';
    final duration = DateTime.now().difference(_updatedAt);
    if (duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    if (duration.inDays < 7) return '${duration.inDays}d ago';
    return '${(duration.inDays / 7).floor()}w ago';
  }

  bool get isRead => readIn || readOut;

  NotificationModel copyWith({
    String? id,
    String? topicId,
    NotificationType? type,
    String? body,
    List<String>? readOut,
    List<String>? readIn,
  }) {
    return NotificationModel._internal(
      id: id ?? _id,
      topicId: topicId ?? _topicId,
      type: type ?? _titleTopic,
      body: body ?? _body,
      createdAt: _createdAt,
      updatedAt: _updatedAt,
      readOut: readOut ?? _readOut,
      readIn: readIn ?? _readIn,
    );
  }

  @override
  List<Object?> get props => [
        _id,
        _topicId,
        _titleTopic,
        _body,
        _createdAt,
        _updatedAt,
        _readOut,
        _readIn,
      ];

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // معالجة createdAt
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(
          json['createdAt'] as int,
        );
      } else if (json['createdAt'] is String) {
        createdAt = DateTime.tryParse(json['createdAt'] as String);
      }
    }

    // معالجة updatedAt
    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      if (json['updatedAt'] is int) {
        updatedAt = DateTime.fromMillisecondsSinceEpoch(
          json['updatedAt'] as int,
        );
      } else if (json['updatedAt'] is String) {
        updatedAt = DateTime.tryParse(json['updatedAt'] as String);
      }
    }

    // معالجة readOut
    List<String> readOut = [];
    if (json['readOut'] != null) {
      if (json['readOut'] is List) {
        readOut = List<String>.from(
          json['readOut'].map((item) => item.toString()),
        );
      } else if (json['readOut'] is String) {
        readOut = (json['readOut'] as String)
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
    }

    List<String> readIn = [];
    if (json['readIn'] != null) {
      if (json['readIn'] is List) {
        readIn = List<String>.from(
          json['readIn'].map((item) => item.toString()),
        );
      } else if (json['readIn'] is String) {
        readIn = (json['readIn'] as String)
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
    }

    return NotificationModel._internal(
      id: json['id']?.toString(),
      topicId: json['topicId']?.toString() ?? '',
      type: NotificationType.fromString(json['titleTopic']?.toString() ?? ''),
      body: json['body']?.toString() ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      readOut: readOut,
      readIn: readIn,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'topicId': _topicId,
      'titleTopic': _titleTopic.name,
      'body': _body,
      'createdAt': _createdAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      'updatedAt': _updatedAt?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch,
      'readOut': _readOut,
      'readIn': _readIn,
    };
  }

  Map<String, String> toJsonString() {
    return {
      'id': _id,
      'topicId': _topicId,
      'titleTopic': _titleTopic.name,
      'body': _body,
      'createdAt': (_createdAt?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch)
          .toString(),
      'updatedAt': (_updatedAt?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch)
          .toString(),
      'readOut': _readOut.join(','),
      'readIn': _readIn.join(','),
    };
  }
}
