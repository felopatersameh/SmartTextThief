import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Utils/Enums/data_key.dart';
import 'package:smart_text_thief/Core/Utils/Enums/level_exam.dart';

import 'exam_result_q_a.dart';
import 'result_exam_model.dart';

class ExamResultModel extends Equatable {
  const ExamResultModel({
    required this.examResultEmailSt,
    required this.examResultDegree,
    required this.examResultQA,
    required this.levelExam,
    required this.numberOfQuestions,
    this.randomQuestions = false,
    required this.typeExam,
  });

  final String examResultEmailSt;
  final String examResultDegree;
  final List<ExamResultQA> examResultQA;
  final LevelExam levelExam;
  final int numberOfQuestions;
  final bool randomQuestions;
  final String typeExam;

  static const ExamResultModel noLabel = ExamResultModel(
    examResultEmailSt: '',
    examResultDegree: '',
    examResultQA: [],
    levelExam: LevelExam.normal,
    numberOfQuestions: 0,
    randomQuestions: false,
    typeExam: 'Quiz',
  );

  ExamResultModel copyWith({
    String? examResultEmailSt,
    String? examResultDegree,
    List<ExamResultQA>? examResultQA,
    LevelExam? levelExam,
    int? numberOfQuestions,
    bool? randomQuestions,
    String? typeExam,
  }) {
    return ExamResultModel(
      examResultEmailSt: examResultEmailSt ?? this.examResultEmailSt,
      examResultDegree: examResultDegree ?? this.examResultDegree,
      examResultQA: examResultQA ?? this.examResultQA,
      levelExam: levelExam ?? this.levelExam,
      numberOfQuestions: numberOfQuestions ?? this.numberOfQuestions,
      randomQuestions: randomQuestions ?? this.randomQuestions,
      typeExam: typeExam ?? this.typeExam,
    );
  }

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    final rawQa = json[DataKey.examResultQandA.key] ?? json['results'];
    final parsedQa = <ExamResultQA>[];

    if (rawQa is List) {
      for (final item in rawQa) {
        if (item is Map<String, dynamic>) {
          parsedQa.add(ExamResultQA.fromJson(item));
          continue;
        }
        if (item is Map) {
          parsedQa.add(ExamResultQA.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return ExamResultModel(
      examResultEmailSt: (json[DataKey.examResultEmailSt.key] ??
              json['name'] ??
              json['studentName'] ??
              '')
          .toString(),
      examResultDegree:
          (json[DataKey.examResultDegree.key] ?? json['score'] ?? '0')
              .toString(),
      examResultQA: parsedQa,
      levelExam: LevelExam.fromString(
        (json[DataKey.levelExam.key] ?? LevelExam.normal.name).toString(),
      ),
      numberOfQuestions: _toInt(json['numberOfQuestions']) ??
          _toInt(json[DataKey.questionCount.key]) ??
          parsedQa.length,
      randomQuestions: _toBool(json['randomQuestions']) ??
          _toBool(json[DataKey.isRandom.key]) ??
          false,
      typeExam:
          (json['typeExam'] ?? json[DataKey.name.key] ?? 'Quiz').toString(),
    );
  }

  factory ExamResultModel.fromResultExamModel(
    ResultExamModel model, {
    required LevelExam levelExam,
    required int numberOfQuestions,
    required bool randomQuestions,
    required String typeExam,
  }) {
    return ExamResultModel(
      examResultEmailSt: model.name,
      examResultDegree: model.score,
      examResultQA: model.results
          .map(
            (item) => ExamResultQA(
              questionId: item.id,
              questionType: '',
              questionText: '',
              options: const [],
              correctAnswer: '',
              studentAnswer: item.studentAnswer,
              score: item.score,
              evaluated: item.evaluated,
            ),
          )
          .toList(growable: false),
      levelExam: levelExam,
      numberOfQuestions: numberOfQuestions,
      randomQuestions: randomQuestions,
      typeExam: typeExam,
    );
  }

  ResultExamModel toResultExamModel({String idExam = ''}) {
    return ResultExamModel(
      name: examResultEmailSt,
      idExam: idExam,
      score: examResultDegree,
      timeTakenMs: '0',
      results: examResultQA
          .map(
            (item) => Result(
              id: item.questionId,
              studentAnswer: item.studentAnswer,
              score: item.score,
              evaluated: item.evaluated,
            ),
          )
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        DataKey.examResultEmailSt.key: examResultEmailSt,
        DataKey.examResultDegree.key: examResultDegree,
        DataKey.examResultQandA.key:
            examResultQA.map((x) => x.toJson()).toList(),
        DataKey.levelExam.key: levelExam.name,
        'numberOfQuestions': numberOfQuestions,
        'randomQuestions': randomQuestions,
        'typeExam': typeExam,
      };

  bool get isDo =>
      examResultEmailSt.trim().toLowerCase() ==
      GetLocalStorage.getEmailUser().trim().toLowerCase();

  @override
  List<Object?> get props => [
        examResultEmailSt,
        examResultDegree,
        examResultQA,
        levelExam,
        numberOfQuestions,
        randomQuestions,
        typeExam,
      ];

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value == null) return null;
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;
    if (value == null) return null;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    return null;
  }
}
