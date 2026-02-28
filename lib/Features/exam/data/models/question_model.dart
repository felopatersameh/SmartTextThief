import 'package:equatable/equatable.dart';

import 'option_model.dart';

class QuestionModel extends Equatable {
  const QuestionModel({
    required this.id,
    required this.text,
    required this.type,
    required this.correctAnswer,
    required this.options,
  });

  final String id;
  final String text;
  final String type;
  final String correctAnswer;
  final List<OptionModel>? options;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    List<OptionModel>? parsedOptions;

    if (rawOptions is List) {
      parsedOptions = rawOptions
          .whereType<Map>()
          .map((item) => OptionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return QuestionModel(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      correctAnswer: (json['correctAnswer'] ?? '').toString(),
      options: parsedOptions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'type': type,
        'correctAnswer': correctAnswer,
        'options': options?.map((item) => item.toJson()).toList(),
      };

  QuestionModel copyWith({
    String? id,
    String? text,
    String? type,
    String? correctAnswer,
    List<OptionModel>? options,
    bool clearOptions = false,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: clearOptions ? null : (options ?? this.options),
    );
  }

  @override
  List<Object?> get props => [id, text, type, correctAnswer, options];
}

