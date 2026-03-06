import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/di/service_locator.dart';
import 'package:smart_text_thief/Core/Services/screenshot_protection_service.dart';
import 'package:smart_text_thief/Features/Exams/Domain/Repositories/view_exam_repository.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/Manager/Instructor/teacher_result_cubit.dart';
import 'package:smart_text_thief/Features/Exams/shared/Template/exam_view.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/exam_mode.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';

class TeacherResultScreen extends StatefulWidget {
  const TeacherResultScreen({
    super.key,
    required this.examModel,
    required this.nameSubject,
    required this.idSubject,
  });

  final ExamModel examModel;
  final String nameSubject;
  final String idSubject;

  @override
  State<TeacherResultScreen> createState() => _TeacherResultScreenState();
}

class _TeacherResultScreenState extends State<TeacherResultScreen> {
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
        isEditMode: false,
        nameSubject: widget.nameSubject,
        idSubject: widget.idSubject,
        repository: getIt<ViewExamRepository>(),
      )..init(),
      child: BlocBuilder<TeacherResultCubit, TeacherResultState>(
        builder: (context, state) {
          return ExamView(
            exam: state.exam,
            mode: ExamMode.teacherResult,
            examResults: state.examResults,
            loading: state.loadingResults,
            selectedStudentEmail: state.selectedStudentEmail,
            onStudentSelect: (email) =>
                context.read<TeacherResultCubit>().selectStudentResult(email),
          );
        },
      ),
    );
  }
}

