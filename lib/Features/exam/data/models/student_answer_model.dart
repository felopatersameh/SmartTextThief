import 'package:equatable/equatable.dart';

class StudentAnswerModel extends Equatable {
  const StudentAnswerModel({
    required this.id,
    required this.studentAnswer,
    this.score,
  });

  final String id;
  final String studentAnswer;
  final int? score;

  factory StudentAnswerModel.fromJson(Map<String, dynamic> json) {
    return StudentAnswerModel(
      id: (json['id'] ?? '').toString(),
      studentAnswer: (json['studentAnswer'] ?? '').toString(),
      score: _toNullableInt(json['score']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentAnswer': studentAnswer,
        if (score != null) 'score': score,
      };

  Map<String, dynamic> toSubmitJson() => {
        'id': id,
        'studentAnswer': studentAnswer,
      };

  StudentAnswerModel copyWith({
    String? id,
    String? studentAnswer,
    int? score,
    bool clearScore = false,
  }) {
    return StudentAnswerModel(
      id: id ?? this.id,
      studentAnswer: studentAnswer ?? this.studentAnswer,
      score: clearScore ? null : (score ?? this.score),
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [id, studentAnswer, score];
}

