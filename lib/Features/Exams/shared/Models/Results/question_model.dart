import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';

import 'option_model.dart';

class QuestionModel extends Equatable {
  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.correctAnswer,
    this.options,
    this.studentAnswer,
  });

  final String id;
  final String text;
  final String type;
  final String correctAnswer;
  final List<OptionModel>? options;
  final String? studentAnswer;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json[DataKey.options.key];
    final parsedOptions = <OptionModel>[];

    if (rawOptions is List) {
      for (final item in rawOptions) {
        if (item is Map<String, dynamic>) {
          parsedOptions.add(OptionModel.fromJson(item));
          continue;
        }
        if (item is Map) {
          parsedOptions.add(
            OptionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
          continue;
        }
        parsedOptions.add(
          OptionModel(
            id: '',
            choice: item?.toString() ?? '',
          ),
        );
      }
    }

    return QuestionModel(
      id: (json[DataKey.id.key] ??
              json[DataKey.id_.key] ??
              json[DataKey.questionId.key] ??
              '')
          .toString(),
      text: (json[DataKey.text.key] ?? json[DataKey.questionText.key] ?? '')
          .toString(),
      type: (json[DataKey.type.key] ?? json[DataKey.questionType.key] ?? '')
          .toString(),
      correctAnswer: (json[DataKey.correctAnswer.key] ?? '').toString(),
      options: parsedOptions,
      studentAnswer: (json[DataKey.studentAnswer.key] ?? json['student answer'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.id.key: id,
        DataKey.text.key: text,
        DataKey.type.key: type,
        DataKey.correctAnswer.key: correctAnswer,
        DataKey.options.key: options?.map((x) => x.toJson()).toList(),
        if (studentAnswer != null) DataKey.studentAnswer.key: studentAnswer,
      };

  @override
  List<Object?> get props => [
        id,
        text,
        type,
        correctAnswer,
        options,
        studentAnswer,
      ];

  QuestionModel copyWith({
    String? id,
    String? text,
    String? type,
    String? correctAnswer,
    List<OptionModel>? options,
    String? studentAnswer,
    bool clearStudentAnswer = false,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      studentAnswer:
          clearStudentAnswer ? null : (studentAnswer ?? this.studentAnswer),
    );
  }

  bool get hasStudentAnswer =>
      studentAnswer != null && studentAnswer!.trim().isNotEmpty;

  bool isStudentAnswerCorrect([String? answer]) {
    final value = (answer ?? studentAnswer ?? '').trim();
    if (value.isEmpty) return false;
    return _normalize(value) == _normalize(correctAnswer);
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}