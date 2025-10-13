import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';

class SubjectTeacher extends Equatable {
  const SubjectTeacher({
    required this.teacherEmail,
    required this.teacherName,
  });

  final String teacherEmail;
  final String teacherName;

  SubjectTeacher copyWith({
    String? teacherEmail,
    String? teacherName,
  }) {
    return SubjectTeacher(
      teacherEmail: teacherEmail ?? this.teacherEmail,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  factory SubjectTeacher.fromJson(Map<String, dynamic> json) {
    return SubjectTeacher(
      teacherEmail: json[DataKey.teacherEmail.key] ?? "",
      teacherName: json[DataKey.teacherName.key] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.teacherEmail.key: teacherEmail,
        DataKey.teacherName.key: teacherName,
      };

  @override
  List<Object?> get props => [
        teacherEmail,
        teacherName,
      ];
}
