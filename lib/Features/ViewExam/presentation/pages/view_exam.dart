import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/di/service_locator.dart';
import 'package:smart_text_thief/Core/Services/screenshot_protection_service.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Features/ViewExam/data/repositories/view_exam_repository.dart';
import 'package:smart_text_thief/Features/exams/presentation/cubits/student_result/student_result_cubit.dart';
import 'package:smart_text_thief/Features/exams/presentation/cubits/teacher_result/teacher_result_cubit.dart';
import 'package:smart_text_thief/Features/exams/presentation/enums/exam_mode.dart';
import 'package:smart_text_thief/Features/exams/presentation/screens/exam_view.dart';

class ViewExam extends StatefulWidget {
  const ViewExam({
    super.key,
    required this.examModel,
    required this.isEditMode,
    required this.nameSubject,
  });

  final ExamModel examModel;
  final String nameSubject;
  final bool isEditMode;

  @override
  State<ViewExam> createState() => _ViewExamState();
}

class _ViewExamState extends State<ViewExam> {
  @override
  void initState() {
    super.initState();
    unawaited(ScreenshotProtectionService.enableProtection());
  }

  @override
  void dispose() {
    unawaited(ScreenshotProtectionService.disableProtection());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTeacherFlow = widget.isEditMode || widget.examModel.isTeacher;
    if (isTeacherFlow) {
      return BlocProvider(
        create: (context) => TeacherResultCubit(
          exam: widget.examModel,
          isEditMode: widget.isEditMode,
          nameSubject: widget.nameSubject,
          repository: getIt<ViewExamRepository>(),
        ),
        child: _TeacherExamContent(
          mode: widget.isEditMode ? ExamMode.create : ExamMode.teacherResult,
        ),
      );
    }

    return BlocProvider(
      create: (context) => StudentResultCubit(
        exam: widget.examModel,
        repository: getIt<ViewExamRepository>(),
      )..init(),
      child: const _StudentExamContent(),
    );
  }
}

class _TeacherExamContent extends StatelessWidget {
  const _TeacherExamContent({required this.mode});

  final ExamMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherResultCubit, TeacherResultState>(
      builder: (context, state) {
        return ExamView(
          exam: state.exam,
          mode: mode,
          examResults: state.exam.examResult,
          selectedStudentEmail: state.selectedStudentEmail,
          startDate: state.startDate,
          endDate: state.endDate,
          loadingSave: state.loadingSave,
          onStartChanged: mode == ExamMode.create
              ? (date) => context.read<TeacherResultCubit>().changeStartDate(date)
              : null,
          onEndChanged: mode == ExamMode.create
              ? (date) => context.read<TeacherResultCubit>().changeEndDate(date)
              : null,
          onStudentSelect: mode == ExamMode.teacherResult
              ? (email) => context.read<TeacherResultCubit>().selectStudentResult(email)
              : null,
          onQuestionUpdated: mode == ExamMode.create
              ? (index, question) => context
                  .read<TeacherResultCubit>()
                  .updateQuestion(index, question.toGenerated())
              : null,
          onQuestionDeleted: mode == ExamMode.create
              ? (index) => context.read<TeacherResultCubit>().deleteQuestion(index)
              : null,
          onSave: mode == ExamMode.create
              ? () => context.read<TeacherResultCubit>().saveSubmit(context)
              : null,
        );
      },
    );
  }
}

class _StudentExamContent extends StatelessWidget {
  const _StudentExamContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentResultCubit, StudentResultState>(
      builder: (context, state) {
        return ExamView(
          exam: state.exam,
          mode: ExamMode.studentResult,
        );
      },
    );
  }
}
