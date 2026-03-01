import 'package:smart_text_thief/Features/exam/domain/enums/exam_lifecycle_status.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/result_exam_status.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart'
    as legacy_exam;
import 'package:smart_text_thief/Features/exam/data/models/questions_generated_model.dart';

import 'exam_contract_model.dart' as v3_exam;
import 'question_model.dart' as v3_question;

class ExamsV3LegacyMapper {
  static legacy_exam.ExamModel toLegacyExam(v3_exam.ExamModel source) {
    final isTeacherRecord = source.status == null && source.score == null;
    return legacy_exam.ExamModel(
      id: source.id,
      name: source.name,
      levelExam: source.levelExam,
      isRandom: source.isRandom,
      questionCount: source.questionCount,
      timeMinutes: source.timeMinutes,
      startAt: source.startAt,
      endAt: source.endAt,
      createdAt: source.createdAt ?? source.startAt,
      statusExam: _mapStatus(
        status: source.status,
        isTeacherRecord: isTeacherRecord,
      ),
      questions: source.questions.map(_toLegacyQuestion).toList(growable: false),
      teacherMode: isTeacherRecord,
    );
  }

  static QuestionsGeneratedModel _toLegacyQuestion(v3_question.QuestionModel q) {
    return QuestionsGeneratedModel(
      id: q.id,
      text: q.text,
      type: q.type,
      correctAnswer: q.correctAnswer,
      options: (q.options ?? const [])
          .map(
            (item) => OptionQuestionGeneratedModel(
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

