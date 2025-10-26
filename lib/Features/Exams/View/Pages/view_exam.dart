import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/create_button.dart';
import '../widgets/questions_list.dart';
import '../widgets/exam_info_card.dart';
import '../widgets/student_selector.dart';
import '../../cubit/view/view_exam_cubit.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_fonts.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';
import '../widgets/exam_date_section.dart';

// ==================== View ====================
class ViewExam extends StatelessWidget {
  final ExamModel examModel;

  const ViewExam({super.key, required this.examModel});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewExamCubit(exam: examModel),
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
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    /// === Exam Info ===
                    ExamInfoCard(exam: state.exam),
                    SizedBox(height: 16.h),

                    /// === Exam Date Section ===
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
                    AppCustomtext(
                      text: state.isEditMode
                          ? "Questions (Edit Mode)"
                          : "Results",
                      textStyle: AppTextStyles.h5SemiBold.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    /// === Questions List ===
                    QuestionsList(
                      questions: state.exam.examStatic.examResultQA,
                      isEditMode: state.isEditMode,
                      studentAnswers: state.selectedStudentEmail != null
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
          persistentFooterButtons: [
            CreateButton(
              onPress: state.loadingSave
                  ? null
                  : () => context.read<ViewExamCubit>().saveSubmint(context),
              text: state.loadingSave ? "Saveing" : "Save && Submint",
            ),
             if (state.loadingSave)
              LinearProgressIndicator(color: AppColors.colorPrimary),
          ],
          persistentFooterDecoration: BoxDecoration(),
        );
      },
    );
  }
}
