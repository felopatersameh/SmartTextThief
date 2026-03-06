import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/di/service_locator.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Dialog/app_dialog_service.dart';
import 'package:smart_text_thief/Core/Services/screenshot_protection_service.dart';
import 'package:smart_text_thief/Features/Exams/Domain/Repositories/view_exam_repository.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/Manager/Instructor/teacher_result_cubit.dart';
import 'package:smart_text_thief/Features/Exams/shared/Template/exam_view.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/exam_mode.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';

class PreviewExamScreen extends StatefulWidget {
  const PreviewExamScreen({
    super.key,
    required this.examModel,
    required this.nameSubject,
    required this.idSubject,
  });

  final ExamModel examModel;
  final String nameSubject;
  final String idSubject;

  @override
  State<PreviewExamScreen> createState() => _PreviewExamScreenState();
}

class _PreviewExamScreenState extends State<PreviewExamScreen> {
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
    return BlocProvider(
      create: (context) => TeacherResultCubit(
        exam: widget.examModel,
        isEditMode: true,
        nameSubject: widget.nameSubject,
        idSubject: widget.idSubject,
        repository: getIt<ViewExamRepository>(),
      )..init(),
      child: BlocBuilder<TeacherResultCubit, TeacherResultState>(
        builder: (context, state) {
          return ExamView(
            exam: state.exam,
            mode: ExamMode.create,
            examResults: state.examResults,
            loading: state.loadingResults,
            selectedStudentEmail: state.selectedStudentEmail,
            startDate: state.startDate,
            endDate: state.endDate,
            loadingSave: state.loadingSave,
            onStartChanged: (date) =>
                context.read<TeacherResultCubit>().changeStartDate(date),
            onEndChanged: (date) =>
                context.read<TeacherResultCubit>().changeEndDate(date),
            onQuestionUpdated: (index, question) => context
                .read<TeacherResultCubit>()
                .updateQuestion(index, question.toGenerated()),
            onQuestionDeleted: (index) =>
                context.read<TeacherResultCubit>().deleteQuestion(index),
            onSave: () async {
              final cubit = context.read<TeacherResultCubit>();
              final confirmed = await AppDialogService.showConfirmDialog(
                context,
                title: ViewExamStrings.saveAndSubmit,
                message: ViewExamStrings.saveExamMessage,
                confirmText: ViewExamStrings.saveAndSubmit,
                barrierDismissible: false,
                instructionsTitle: SubjectStrings.actionWarningsTitle,
                instructions: const [
                  ViewExamStrings.saveExamWarningQuestions,
                  ViewExamStrings.saveExamWarningPublish,
                ],
              );
              if (confirmed != true || !context.mounted) return;
              await cubit.saveSubmit(context);
            },
          );
        },
      ),
    );
  }
}

