import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/di/service_locator.dart';
import 'package:smart_text_thief/Core/Services/screenshot_protection_service.dart';
import 'package:smart_text_thief/Features/Exams/Domain/Repositories/view_exam_repository.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/Manager/Student/student_result_cubit.dart';
import 'package:smart_text_thief/Features/Exams/shared/Template/exam_view.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/exam_mode.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';

class StudentResultScreen extends StatefulWidget {
  const StudentResultScreen({
    super.key,
    required this.examModel,
    required this.idSubject,
  });

  final ExamModel examModel;
  final String idSubject;

  @override
  State<StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<StudentResultScreen> {
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
      create: (context) => StudentResultCubit(
        exam: widget.examModel,
        idSubject: widget.idSubject,
        repository: getIt<ViewExamRepository>(),
      )..init(),
      child: BlocBuilder<StudentResultCubit, StudentResultState>(
        builder: (context, state) {
          return ExamView(
            exam: state.exam,
            mode: ExamMode.studentResult,
            examResults: state.result == null ? const [] : [state.result!],
            studentResult: state.result,
            loading: state.loading,
          );
        },
      ),
    );
  }
}

