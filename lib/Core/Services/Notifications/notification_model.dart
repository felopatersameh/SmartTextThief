import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../LocalStorage/get_local_storage.dart';
import '../../Utils/Enums/notification_type.dart';

class NotificationModel extends Equatable {
  final String _id;
  final String _topicId;
  final NotificationType _titleTopic;
  final String _contentTitle;
  final String _body;
  final String _entityType;
  final String _entityId;
  final DateTime? _aggregationDateKey;
  final int _aggregationCount;
  final String _aggregationFirstActorName;
  final String _metaSubjectId;
  final DateTime? _createdAt;
  final DateTime? _updatedAt;
  final bool _read;
  final bool _open;

  const NotificationModel._internal({
    String? id,
    required String topicId,
    required NotificationType type,
    required String contentTitle,
    required String body,
    required String entityType,
    required String entityId,
    required DateTime? aggregationDateKey,
    required int aggregationCount,
    required String aggregationFirstActorName,
    required String metaSubjectId,
    required DateTime? createdAt,
    required DateTime? updatedAt,
    required bool read,
    required bool open,
  })  : _id = id ?? '',
        _topicId = topicId,
        _titleTopic = type,
        _contentTitle = contentTitle,
        _body = body,
        _entityType = entityType,
        _entityId = entityId,
        _aggregationDateKey = aggregationDateKey,
        _aggregationCount = aggregationCount,
        _aggregationFirstActorName = aggregationFirstActorName,
        _metaSubjectId = metaSubjectId,
        _createdAt = createdAt,
        _updatedAt = updatedAt,
        _read = read,
        _open = open;

  factory NotificationModel({
    String? id,
    required String topicId,
    required NotificationType type,
    String? title,
    required String body,
    String entityType = '',
    String entityId = '',
    DateTime? aggregationDateKey,
    int aggregationCount = 0,
    String aggregationFirstActorName = '',
    String metaSubjectId = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    bool read = false,
    bool open = false,
  }) {
    return NotificationModel._internal(
      id: id,
      topicId: topicId,
      type: type,
      contentTitle: title ?? type.title,
      body: body,
      entityType: entityType,
      entityId: entityId,
      aggregationDateKey: aggregationDateKey,
      aggregationCount: aggregationCount,
      aggregationFirstActorName: aggregationFirstActorName,
      metaSubjectId: metaSubjectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      read: read,
      open: open,
    );
  }

  String get id => _id;
  String get topicId => _topicId;
  NotificationType get titleTopic => _titleTopic;
  String get type => _titleTopic.name;
  String get title => _contentTitle.isEmpty ? _titleTopic.title : _contentTitle;
  String get body => _body;

  String get entityType => _entityType;
  String get entityId => _entityId;
  DateTime? get aggregationDateKey => _aggregationDateKey;
  int get aggregationCount => _aggregationCount;
  String get aggregationFirstActorName => _aggregationFirstActorName;
  String get metaSubjectId => _metaSubjectId;

  DateTime? get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;

  bool get read => _read;

  bool get open => _open;

  IconData get icon => _titleTopic.icon;
  Color get iconColor => _titleTopic.iconColor;
  Color get backgroundColor => _titleTopic.backgroundColor;

  Duration? get timeSinceCreation =>
      _createdAt == null ? null : DateTime.now().difference(_createdAt);

  Duration? get timeSinceUpdate =>
      _updatedAt == null ? null : DateTime.now().difference(_updatedAt);

  String get formattedTime {
    final reference = _updatedAt ?? _createdAt;
    if (reference == null) return '';
    final duration = DateTime.now().difference(reference);
    if (duration.isNegative || duration.inMinutes < 1) return 'Just now';
    if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
    if (duration.inHours < 24) return '${duration.inHours}h ago';
    if (duration.inDays < 7) return '${duration.inDays}d ago';
    return '${(duration.inDays / 7).floor()}w ago';
  }

  String get detailsText {
    final parts = <String>[];

    if (_aggregationFirstActorName.isNotEmpty) {
      if (_aggregationCount > 1) {
        parts.add('$_aggregationFirstActorName +${_aggregationCount - 1}');
      } else {
        parts.add(_aggregationFirstActorName);
      }
    } else if (_aggregationCount > 1) {
      parts.add('$_aggregationCount activities');
    }

    if (_entityType.isNotEmpty) {
      parts.add(_entityType.toUpperCase());
    }

    if (_metaSubjectId.isNotEmpty) {
      parts.add('Subject ${_shortId(_metaSubjectId)}');
    }

    return parts.join(' | ');
  }

  bool get hasDetails => detailsText.isNotEmpty;

  NotificationModel copyWith({
    String? id,
    String? topicId,
    NotificationType? type,
    String? title,
    String? body,
    String? entityType,
    String? entityId,
    DateTime? aggregationDateKey,
    int? aggregationCount,
    String? aggregationFirstActorName,
    String? metaSubjectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? read,
    bool? open,
    List<String>? readOut,
    List<String>? readIn,
  }) {
    return NotificationModel._internal(
      id: id ?? _id,
      topicId: topicId ?? _topicId,
      type: type ?? _titleTopic,
      contentTitle: title ?? _contentTitle,
      body: body ?? _body,
      entityType: entityType ?? _entityType,
      entityId: entityId ?? _entityId,
      aggregationDateKey: aggregationDateKey ?? _aggregationDateKey,
      aggregationCount: aggregationCount ?? _aggregationCount,
      aggregationFirstActorName:
          aggregationFirstActorName ?? _aggregationFirstActorName,
      metaSubjectId: metaSubjectId ?? _metaSubjectId,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
      read: read ?? _read,
      open: open ?? _open,
    );
  }

  @override
  List<Object?> get props => [
        _id,
        _topicId,
        _titleTopic,
        _contentTitle,
        _body,
        _entityType,
        _entityId,
        _aggregationDateKey,
        _aggregationCount,
        _aggregationFirstActorName,
        _metaSubjectId,
        _createdAt,
        _updatedAt,
        _read,
        _open,
      ];

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final content = _toMap(json['content']);
    final entity = _toMap(json['entity']);
    final aggregation = _toMap(json['aggregation']);
    final meta = _toMap(json['meta']);

    final topicId = _valueAsString(json['topicId']);
    final typeRaw = _firstNonEmpty([
      json['type'],
      json['titleTopic'],
      content['type'],
      content['content'],
    ]);
    final title = _firstNonEmpty([content['title'], json['title']]);
    final body = _firstNonEmpty([content['body'], json['body']]);
    final createdAt = _parseDateTime(json['createdAt']);
    final updatedAt = _parseDateTime(json['updatedAt']);

    final readOut = _parseStringList(json['readOut']);
    final readIn = _parseStringList(json['readIn']);
    final read = _parseBool(json['isRead']) ?? _isCurrentUserIn(readIn);
    final open = _parseBool(json['isOpen']) ?? _isCurrentUserIn(readOut);

    final rawId = _firstNonEmpty([json['id'], json['_id']]);
    final fallbackId =
        '${topicId}_${updatedAt?.millisecondsSinceEpoch ?? createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}_${typeRaw}_$body';

    return NotificationModel._internal(
      id: rawId.isEmpty ? fallbackId : rawId,
      topicId: topicId,
      type: NotificationType.fromString(typeRaw),
      contentTitle: title,
      body: body,
      entityType: _firstNonEmpty([entity['type']]),
      entityId: _firstNonEmpty([entity['id']]),
      aggregationDateKey: _parseDateTime(aggregation['dateKey']),
      aggregationCount: _parseInt(aggregation['count']) ?? 0,
      aggregationFirstActorName:
          _firstNonEmpty([aggregation['firstActorName']]),
      metaSubjectId: _firstNonEmpty([meta['subjectId'], json['subjectId']]),
      createdAt: createdAt,
      updatedAt: updatedAt,
      read: read,
      open: open,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'type': _titleTopic.name,
      'topicId': _topicId,
      'entity': {
        'type': _entityType,
        'id': _entityId,
      },
      'aggregation': {
        if (_aggregationDateKey != null)
          'dateKey': _aggregationDateKey.toIso8601String(),
        'count': _aggregationCount,
        if (_aggregationFirstActorName.isNotEmpty)
          'firstActorName': _aggregationFirstActorName,
      },
      'content': {
        'title': title,
        'body': _body,
      },
      'meta': {
        if (_metaSubjectId.isNotEmpty) 'subjectId': _metaSubjectId,
      },
      'createdAt': _createdAt?.toIso8601String(),
      'updatedAt': _updatedAt?.toIso8601String(),
      'isRead': _read,
      'isOpen': _open,
      'titleTopic': _titleTopic.name,
      'body': _body,
    };
  }

  Map<String, String> toJsonString() {
    return {
      'id': _id,
      'topicId': _topicId,
      'type': _titleTopic.name,
      'titleTopic': _titleTopic.name,
      'title': title,
      'body': _body,
      'createdAt': (_createdAt?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch)
          .toString(),
      'updatedAt': (_updatedAt?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch)
          .toString(),
      'isRead': _read.toString(),
      'isOpen': _open.toString(),
    };
  }

  static bool _isCurrentUserIn(List<String> values) {
    final email = GetLocalStorage.getEmailUser().trim();
    if (email.isEmpty) return false;
    return values.contains(email);
  }

  static String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final text = _valueAsString(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _valueAsString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsedInt = int.tryParse(value);
      if (parsedInt != null) {
        return DateTime.fromMillisecondsSinceEpoch(parsedInt);
      }
      return DateTime.tryParse(value);
    }
    return null;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return <String>[];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      if (value.trim().isEmpty) return <String>[];
      return value.split(',').map((e) => e.trim()).toList();
    }
    return <String>[];
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _shortId(String value) {
    final normalized = value.trim();
    if (normalized.length <= 8) return normalized;
    return normalized.substring(0, 8);
  }
}
