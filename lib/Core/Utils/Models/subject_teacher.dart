import 'package:equatable/equatable.dart';
import '../Enums/data_key.dart';

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
      teacherEmail:
          (json[DataKey.email.key] ).toString(),
      teacherName:
          (json[DataKey.name.key]).toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.email.key: teacherEmail,
        DataKey.name.key: teacherName,
      };

  @override
  List<Object?> get props => [
        teacherEmail,
        teacherName,
      ];
}
