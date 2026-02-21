import 'package:equatable/equatable.dart';

class ResultExamModel extends Equatable {
  const ResultExamModel({
    required this.name,
    required this.idExam,
    required this.score,
    required this.timeTakenMs,
    required this.results,
  });

  final String name;
  final String idExam;
  final String score;
  final String timeTakenMs;
  final List<Result> results;

  static const ResultExamModel empty = ResultExamModel(
    name: '',
    idExam: '',
    score: '0',
    timeTakenMs: '0',
    results: [],
  );

  ResultExamModel copyWith({
    String? name,
    String? idExam,
    String? score,
    String? timeTakenMs,
    List<Result>? results,
  }) {
    return ResultExamModel(
      name: name ?? this.name,
      idExam: idExam ?? this.idExam,
      score: score ?? this.score,
      timeTakenMs: timeTakenMs ?? this.timeTakenMs,
      results: results ?? this.results,
    );
  }

  factory ResultExamModel.fromJson(Map<String, dynamic> json) {
    final rawResults = json["results"] ?? json["answers"];
    final parsedResults = <Result>[];
    if (rawResults is List) {
      for (final item in rawResults) {
        if (item is Map<String, dynamic>) {
          parsedResults.add(Result.fromJson(item));
          continue;
        }
        if (item is Map) {
          parsedResults.add(Result.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return ResultExamModel(
      name: (json["name"] ?? json["studentName"] ?? json["email"] ?? '')
          .toString(),
      idExam: (json["idExam"] ?? json["examId"] ?? '').toString(),
      score: (json["score"] ?? '0').toString(),
      timeTakenMs: (json["timeTakenMs"] ?? json["timeTaken"] ?? '0').toString(),
      results: parsedResults,
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "idExam": idExam,
        "score": score,
        "timeTakenMs": timeTakenMs,
        "results": results.map((x) => x.toJson()).toList(),
      };

  Result? answerForQuestion(String questionId) {
    try {
      return results.firstWhere((element) => element.id == questionId);
    } catch (_) {
      return null;
    }
  }

  bool get hasAnswers =>
      results.any((result) => result.studentAnswer.isNotEmpty);

  @override
  List<Object?> get props => [
        name,
        idExam,
        score,
        timeTakenMs,
        results,
      ];
}

class Result extends Equatable {
  const Result({
    required this.id,
    required this.studentAnswer,
    this.score,
    this.evaluated,
  });

  final String id;
  final String studentAnswer;
  final String? score;
  final bool? evaluated;

  String get stdudentAnswer => studentAnswer;
  String get correctAnswer => studentAnswer;

  Result copyWith({
    String? id,
    String? studentAnswer,
    String? score,
    bool? evaluated,
  }) {
    return Result(
      id: id ?? this.id,
      studentAnswer: studentAnswer ?? this.studentAnswer,
      score: score ?? this.score,
      evaluated: evaluated ?? this.evaluated,
    );
  }

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: (json["id"] ?? json["questionId"] ?? '').toString(),
      studentAnswer:
          (json["student answer"] ?? json["studentAnswer"] ?? '').toString(),
      score: json["score"]?.toString(),
      evaluated: json["evaluated"] is bool ? json["evaluated"] as bool : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "student answer": studentAnswer,
        if (score != null) "score": score,
        if (evaluated != null) "evaluated": evaluated,
      };

  @override
  List<Object?> get props => [
        id,
        studentAnswer,
        score,
        evaluated,
      ];
}
