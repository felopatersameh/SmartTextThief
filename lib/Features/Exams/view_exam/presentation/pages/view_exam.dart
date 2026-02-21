import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/app_config.dart';
import 'package:smart_text_thief/Config/di/service_locator.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/screenshot_protection_service.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/data/repositories/view_exam_repository.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/presentation/cubit/view_exam_cubit.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/presentation/widgets/create_button.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/presentation/widgets/exam_date_section.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/presentation/widgets/exam_info_card.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/presentation/widgets/questions_list.dart';
import 'package:smart_text_thief/Features/Exams/view_exam/presentation/widgets/student_selector.dart';

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
    return BlocProvider(
      create: (context) => ViewExamCubit(
        exam: widget.examModel,
        isEditMode: widget.isEditMode,
        nameSubject: widget.nameSubject,
        repository: getIt<ViewExamRepository>(),
      )..init(),
      child: const _ViewExamContent(),
    );
  }
}

class _ViewExamContent extends StatelessWidget {
  const _ViewExamContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewExamCubit, ViewExamState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(state.exam.examStatic.typeExam)),
          body: CustomScrollView(
            physics: AppConfig.physicsCustomScrollView,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ExamInfoCard(exam: state.exam),
                    SizedBox(height: 16.h),
                    if (!state.exam.isEnded)
                      ExamDateSection(
                        startDate: state.startDate,
                        endDate: state.endDate,
                        isEditMode: state.isEditMode,
                        onStartChanged: (date) =>
                            context.read<ViewExamCubit>().changeStartDate(date),
                        onEndChanged: (date) =>
                            context.read<ViewExamCubit>().changeEndDate(date),
                      ),
                    SizedBox(height: 20.h),
                    if (!state.isEditMode &&
                        state.exam.examResult.isNotEmpty) ...[
                      StudentSelector(
                        examResults: state.exam.examResult,
                        selectedEmail: state.selectedStudentEmail,
                        onSelect: (email) => context
                            .read<ViewExamCubit>()
                            .selectStudentResult(email),
                      ),
                      SizedBox(height: 20.h),
                    ],
                    AppCustomText.generate(
                      text: state.isEditMode
                          ? ViewExamStrings.questionsEditMode
                          : ViewExamStrings.resultsTitle(
                              int.tryParse(
                                    state.exam.myTest?.examResultDegree ?? '0',
                                  ) ??
                                  0,
                              state.exam.examStatic.numberOfQuestions,
                            ),
                      textStyle: AppTextStyles.h5SemiBold.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    QuestionsList(
                      questions: state.exam.questions,
                      isEditMode: state.isEditMode,
                      studentAnswers: state.selectedStudentEmail != null &&
                              state.selectedStudentEmail != ''
                          ? state.exam.examResult
                              .firstWhere(
                                (result) =>
                                    result.examResultEmailSt ==
                                    state.selectedStudentEmail,
                                orElse: () => state.exam.examResult.first,
                              )
                              .examResultQA
                          : null,
                      onUpdate: (index, question) => context
                          .read<ViewExamCubit>()
                          .updateQuestion(index, question),
                      onDelete: (index) =>
                          context.read<ViewExamCubit>().deleteQuestion(index),
                    ),
                  ]),
                ),
              ),
            ],
          ),
          persistentFooterButtons: state.isEditMode
              ? [
                  CreateButton(
                    onPress: state.loadingSave
                        ? null
                        : () =>
                            context.read<ViewExamCubit>().saveSubmit(context),
                    text: state.loadingSave
                        ? ViewExamStrings.saving
                        : ViewExamStrings.saveAndSubmit,
                  ),
                  if (state.loadingSave)
                    LinearProgressIndicator(color: AppColors.colorPrimary),
                ]
              : null,
          persistentFooterDecoration: const BoxDecoration(),
        );
      },
    );
  }
}
