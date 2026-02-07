import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../Config/app_config.dart';
import '../widgets/create_button.dart';
import '../widgets/questions_list.dart';
import '../widgets/exam_info_card.dart';
import '../widgets/student_selector.dart';
import '../Manager/view/view_exam_cubit.dart';
import '../../../../../Core/Resources/app_colors.dart';
import '../../../../../Core/Resources/app_fonts.dart';
import '../../../../../Core/Utils/Models/exam_model.dart';
import '../../../../../Core/Utils/Widget/custom_text_app.dart';
import '../widgets/exam_date_section.dart';

// ==================== View ====================
class ViewExam extends StatelessWidget {
  final ExamModel examModel;
  final String nameSubject;
  final bool isEditMode;

  const ViewExam({
    super.key,
    required this.examModel,
    required this.isEditMode,
    required this.nameSubject,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewExamCubit(
          exam: examModel, isEditMode: isEditMode, nameSubject: nameSubject)
        ..init(),
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
                    /// === Exam Info ===
                    ExamInfoCard(exam: state.exam),
                    SizedBox(height: 16.h),

                    /// === Exam Date Section ===
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

                    /// === Student Selector ===
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

                    /// === Section Title ===
                    AppCustomText.generate(
                      text: state.isEditMode
                          ? "Questions (Edit Mode)"
                          : "Results(${state.exam.myTest?.examResultDegree ?? 0} From ${state.exam.examStatic.numberOfQuestions})",
                      textStyle: AppTextStyles.h5SemiBold.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    /// === Questions List ===
                    QuestionsList(
                      questions: state.exam.examStatic.examResultQA,
                      isEditMode: state.isEditMode,
                      studentAnswers: state.selectedStudentEmail != null &&
                              state.selectedStudentEmail != ""
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
                        : () => context.read<ViewExamCubit>().saveSubmit(
                              context,
                            ),
                    text: state.loadingSave ? "Saving" : "Save && Submit",
                  ),
                  if (state.loadingSave)
                    LinearProgressIndicator(color: AppColors.colorPrimary),
                ]
              : null,
          persistentFooterDecoration: BoxDecoration(),
        );
      },
    );
  }
}
