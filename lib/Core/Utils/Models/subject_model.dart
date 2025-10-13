import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_teacher.dart';
import '../Enums/data_key.dart';

class SubjectModel extends Equatable {
  const SubjectModel({
    required this.subjectIdSubject,
    required this.subjectCodeSub,
    required this.subjectNameSubject,
    required this.subjectTeacher,
    required this.subjectEmailSts,
    required this.subjectCreatedAt,
  });

  final String subjectIdSubject;
  final String subjectCodeSub;
  final String subjectNameSubject;
  final SubjectTeacher? subjectTeacher;
  final List<String> subjectEmailSts;
  final DateTime? subjectCreatedAt;

  SubjectModel copyWith({
    String? subjectIdSubject,
    String? subjectCodeSub,
    String? subjectNameSubject,
    SubjectTeacher? subjectTeacher,
    List<String>? subjectEmailSts,
    DateTime? subjectCreatedAt,
  }) {
    return SubjectModel(
      subjectIdSubject: subjectIdSubject ?? this.subjectIdSubject,
      subjectCodeSub: subjectCodeSub ?? this.subjectCodeSub,
      subjectNameSubject: subjectNameSubject ?? this.subjectNameSubject,
      subjectTeacher: subjectTeacher ?? this.subjectTeacher,
      subjectEmailSts: subjectEmailSts ?? this.subjectEmailSts,
      subjectCreatedAt: subjectCreatedAt ?? this.subjectCreatedAt,
    );
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectIdSubject: json[DataKey.subjectIdSubject.key] ?? "",
      subjectCodeSub: json[DataKey.subjectCodeSub.key] ?? "",
      subjectNameSubject: json[DataKey.subjectNameSubject.key] ?? "",
      subjectTeacher: json[DataKey.subjectTeacher.key] == null
          ? null
          : SubjectTeacher.fromJson(json[DataKey.subjectTeacher.key]),
      subjectEmailSts: json[DataKey.subjectEmailSts.key] == null
          ? []
          : List<String>.from(
              json[DataKey.subjectEmailSts.key]!.map((x) => x)),
      subjectCreatedAt:
          DateTime.tryParse(json[DataKey.subjectCreatedAt.key] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.subjectIdSubject.key: subjectIdSubject,
        DataKey.subjectCodeSub.key: subjectCodeSub,
        DataKey.subjectNameSubject.key: subjectNameSubject,
        DataKey.subjectTeacher.key: subjectTeacher?.toJson(),
        DataKey.subjectEmailSts.key:
            subjectEmailSts.map((x) => x).toList(),
        DataKey.subjectCreatedAt.key: subjectCreatedAt == null
            ? null
            : "${subjectCreatedAt!.year.toString().padLeft(4, '0')}-${subjectCreatedAt!.month.toString().padLeft(2, '0')}-${subjectCreatedAt!.day.toString().padLeft(2, '0')}",
      };

  @override
  List<Object?> get props => [
        subjectIdSubject,
        subjectCodeSub,
        subjectNameSubject,
        subjectTeacher,
        subjectEmailSts,
        subjectCreatedAt,
      ];
}
