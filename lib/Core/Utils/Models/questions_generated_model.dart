import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';

class QuestionsGeneratedModel extends Equatable {
  const QuestionsGeneratedModel({
    required this.id,
    required this.text,
    required this.type,
    required this.correctAnswer,
    required this.options,
    this.studentAnswer,
  });

  final String id;
  final String text;
  final String type;
  final String correctAnswer;
  final List<OptionQuestionGeneratedModel> options;
  final String? studentAnswer;

  factory QuestionsGeneratedModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json[DataKey.options.key];
    final parsedOptions = <OptionQuestionGeneratedModel>[];

    if (rawOptions is List) {
      for (final item in rawOptions) {
        if (item is Map<String, dynamic>) {
          parsedOptions.add(OptionQuestionGeneratedModel.fromJson(item));
          continue;
        }
        if (item is Map) {
          parsedOptions.add(
            OptionQuestionGeneratedModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
          continue;
        }
        parsedOptions.add(
          OptionQuestionGeneratedModel(
            id: '',
            choice: item?.toString() ?? '',
          ),
        );
      }
    }

    return QuestionsGeneratedModel(
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
        DataKey.options.key: options.map((x) => x.toJson()).toList(),
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

  QuestionsGeneratedModel copyWith({
    String? id,
    String? text,
    String? type,
    String? correctAnswer,
    List<OptionQuestionGeneratedModel>? options,
    String? studentAnswer,
    bool clearStudentAnswer = false,
  }) {
    return QuestionsGeneratedModel(
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

class OptionQuestionGeneratedModel extends Equatable {
  const OptionQuestionGeneratedModel({
    required this.id,
    required this.choice,
  });

  final String id;
  final String choice;

  factory OptionQuestionGeneratedModel.fromJson(Map<String, dynamic> json) {
    return OptionQuestionGeneratedModel(
      id: (json[DataKey.id.key] ?? '').toString(),
      choice: (json[DataKey.choice.key] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.id.key: id,
        DataKey.choice.key: choice,
      };

  @override
  List<Object?> get props => [
        id,
        choice,
      ];
}
