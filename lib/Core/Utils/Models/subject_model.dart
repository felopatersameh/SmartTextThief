import 'package:equatable/equatable.dart';

import '../../Storage/Local/get_local_storage.dart';
import '../Enums/data_key.dart';
import '../Extensions/date_time_extension.dart';
import 'subject_teacher.dart';

class SubjectModel extends Equatable {
  const SubjectModel({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.subjectTeacher,
    required this.subjectEmailSts,
    required this.subjectCreatedAt,
  });

  final String subjectId;
  final String subjectCode;
  final String subjectName;
  final SubjectTeacher subjectTeacher;
  final List<String> subjectEmailSts;
  final DateTime subjectCreatedAt;

  SubjectModel copyWith({
    String? subjectId,
    String? subjectCode,
    String? subjectName,
    SubjectTeacher? subjectTeacher,
    List<String>? subjectEmailSts,
    DateTime? subjectCreatedAt,
  }) {
    return SubjectModel(
      subjectId: subjectId ?? this.subjectId,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectName: subjectName ?? this.subjectName,
      subjectTeacher: subjectTeacher ?? this.subjectTeacher,
      subjectEmailSts: subjectEmailSts ?? this.subjectEmailSts,
      subjectCreatedAt: subjectCreatedAt ?? this.subjectCreatedAt,
    );
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json[DataKey.subjectIdSubject.key] ?? "",
      subjectCode: json[DataKey.subjectCodeSub.key] ?? "",
      subjectName: json[DataKey.subjectNameSubject.key] ?? "",
      subjectTeacher: SubjectTeacher.fromJson(json[DataKey.subjectTeacher.key]),
      subjectEmailSts: json[DataKey.subjectEmailSts.key] == null
          ? []
          : List<String>.from(json[DataKey.subjectEmailSts.key]!.map((x) => x)),
      subjectCreatedAt: DateTime.fromMillisecondsSinceEpoch(
        json[DataKey.subjectCreatedAt.key] ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    DataKey.subjectIdSubject.key: subjectId,
    DataKey.subjectCodeSub.key: subjectCode,
    DataKey.subjectNameSubject.key: subjectName,
    DataKey.subjectTeacher.key: subjectTeacher.toJson(),
    DataKey.subjectEmailSts.key: subjectEmailSts.map((x) => x).toList(),
    DataKey.subjectCreatedAt.key: subjectCreatedAt.millisecondsSinceEpoch,
  };

  @override
  List<Object?> get props => [
    subjectId,
    subjectCode,
    subjectName,
    subjectTeacher,
    subjectEmailSts,
    subjectCreatedAt,
  ];

  get createdAt => subjectCreatedAt.shortMonthYear;
  bool get isME =>
      (subjectTeacher.teacherEmail) == (GetLocalStorage.getEmailUser());

  /// Returns the topic ID for all subject members.
  String get subscribeToTopicForMembers => subjectId;

  /// Returns the topic ID for subject admin (teacher).
  String get subscribeToTopicForAdmin => '${subjectId}_admin';
}
