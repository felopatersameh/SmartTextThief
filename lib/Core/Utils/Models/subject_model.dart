import 'package:equatable/equatable.dart';

import '../../LocalStorage/get_local_storage.dart';
import '../Enums/data_key.dart';
import '../Extensions/date_time_extension.dart';
import 'subject_teacher.dart';

class SubjectModel extends Equatable {
  const SubjectModel({
    required this.subjectId,
    required this.subjectCode,
    required this.topicID,
    required this.subjectName,
    required this.subjectTeacher,
    required this.subjectIsOpen,
    required this.subjectCreatedAt,
  });

  final String subjectId;
  final String subjectCode;
  final String subjectName;
  final String topicID;
  final SubjectTeacher subjectTeacher;
  final bool subjectIsOpen;
  final DateTime subjectCreatedAt;

  SubjectModel copyWith({
    String? subjectId,
    String? subjectCode,
    String? subjectName,
    String? topicID,
    SubjectTeacher? subjectTeacher,
    List<String>? subjectEmailSts,
    bool? subjectIsOpen,
    DateTime? subjectCreatedAt,
  }) {
    return SubjectModel(
      subjectId: subjectId ?? this.subjectId,
      subjectCode: subjectCode ?? this.subjectCode,
      topicID: topicID ?? this.topicID,
      subjectName: subjectName ?? this.subjectName,
      subjectTeacher: subjectTeacher ?? this.subjectTeacher,
      subjectIsOpen: subjectIsOpen ?? this.subjectIsOpen,
      subjectCreatedAt: subjectCreatedAt ?? this.subjectCreatedAt,
    );
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    final status = (json[DataKey.status.key]) == 'active' ? true : false;

    return SubjectModel(
      subjectId: (json[DataKey.id_.key] ?? '').toString(),
      subjectCode: (json[DataKey.code.key]).toString(),
      subjectName: (json[DataKey.name.key]).toString(),
      subjectTeacher: SubjectTeacher.fromJson(json[DataKey.instructorInfo.key]),
      subjectIsOpen: status,
      topicID: (json[DataKey.topicId.key]).toString(),
      subjectCreatedAt: parseDate(json[DataKey.createdAt.key]),
    );
  }

  @override
  List<Object?> get props => [
        subjectId,
        subjectCode,
        subjectName,
        subjectTeacher,
        topicID,
        subjectIsOpen,
        subjectCreatedAt,
      ];

  String get createdAt => subjectCreatedAt.shortMonthYear;

  bool get isME =>
      (subjectTeacher.teacherEmail) == (GetLocalStorage.getEmailUser());

  /// Returns the topic ID for all subject members.
  String get subscribeToTopicForMembers => subjectId;

  /// Returns the topic ID for subject admin (teacher).
  // String get subscribeToTopicForAdmin => '${subjectId}_admin';
}
