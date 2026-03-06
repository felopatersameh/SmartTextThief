import 'package:smart_text_thief/Features/Exams/shared/Enums/exam_lifecycle_status.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/result_exam_status.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';

import 'Results/option_model.dart';
import 'Results/question_model.dart';

class ExamsLegacyMapper {
  static ExamModel toLegacyExam(ExamModel source) {
    final isTeacherRecord = source.score == null;
    return ExamModel(
      id: source.id,
      name: source.name,
      levelExam: source.levelExam,
      isRandom: source.isRandom,
      questionCount: source.questionCount,
      timeMinutes: source.timeMinutes,
      startAt: source.startAt,
      endAt: source.endAt,
      createdAt: source.createdAt,
      statusExam: _mapStatus(
        status: source.status,
        isTeacherRecord: isTeacherRecord,
      ),
      questions:
          source.questions.map(_toLegacyQuestion).toList(growable: false),
      teacherMode: isTeacherRecord,
    );
  }

  static QuestionModel _toLegacyQuestion(QuestionModel q) {
    return QuestionModel(
      id: q.id,
      text: q.text,
      type: q.type,
      correctAnswer: q.correctAnswer,
      options: (q.options ?? const [])
          .map(
            (item) => OptionModel(
              id: item.id,
              choice: item.choice,
            ),
          )
          .toList(growable: false),
    );
  }

  static ExamStatus _mapStatus({
    required String? status,
    required bool isTeacherRecord,
  }) {
    if (isTeacherRecord) {
      return ExamStatus.instructor;
    }

    switch (ResultExamStatus.fromString(status?.trim())) {
      case ResultExamStatus.running:
        return ExamStatus.pendingTime;
      case ResultExamStatus.finished:
      case ResultExamStatus.timeExpired:
      case ResultExamStatus.connectionLost:
      case ResultExamStatus.disposed:
        return ExamStatus.time;
      case ResultExamStatus.unknown:
      case ResultExamStatus.els:
        return ExamStatus.available;
    }
  }
}
