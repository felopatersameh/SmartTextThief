import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result_q_a.dart';
import 'package:smart_text_thief/Core/Utils/Widget/ButtonsStyle/create_button.dart'
    as core_button;
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Core/Utils/Widget/exam_date_section.dart'
    as core_date;
import 'package:smart_text_thief/Features/exams/presentation/components/exam_question_view_model.dart';
import 'package:smart_text_thief/Features/exams/presentation/components/exam_shell.dart';
import 'package:smart_text_thief/Features/exams/presentation/enums/exam_mode.dart';
import 'package:smart_text_thief/Features/exams/presentation/widgets/exam_info_card.dart';
import 'package:smart_text_thief/Features/exams/presentation/widgets/exam_question_card.dart';
import 'package:smart_text_thief/Features/exams/presentation/widgets/exam_questions_list.dart';
import 'package:smart_text_thief/Features/exams/presentation/widgets/student_selector.dart';

class ExamView extends StatelessWidget {
  const ExamView({
    super.key,
    required this.exam,
    required this.mode,
    this.questions,
    this.examResults,
    this.selectedStudentEmail,
    this.startDate,
    this.endDate,
    this.loading = false,
    this.loadingSave = false,
    this.currentQuestionIndex = 0,
    this.totalQuestions = 0,
    this.remainingTime = Duration.zero,
    this.solvingAnswers = const {},
    this.onStartChanged,
    this.onEndChanged,
    this.onStudentSelect,
    this.onQuestionUpdated,
    this.onQuestionDeleted,
    this.onAnswerChanged,
    this.onSave,
    this.onNext,
    this.onPrevious,
    this.onSubmit,
    this.onNavigateQuestion,
  });

  final ExamModel exam;
  final ExamMode mode;

  final List<ExamQuestionViewModel>? questions;
  final List<ExamResultModel>? examResults;
  final String? selectedStudentEmail;
  final DateTime? startDate;
  final DateTime? endDate;

  final bool loading;
  final bool loadingSave;

  final int currentQuestionIndex;
  final int totalQuestions;
  final Duration remainingTime;
  final Map<String, String> solvingAnswers;

  final ValueChanged<DateTime>? onStartChanged;
  final ValueChanged<DateTime>? onEndChanged;
  final ValueChanged<String>? onStudentSelect;
  final void Function(int index, ExamQuestionViewModel question)? onQuestionUpdated;
  final ValueChanged<int>? onQuestionDeleted;
  final void Function(String questionId, String answer)? onAnswerChanged;
  final VoidCallback? onSave;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Future<void> Function()? onSubmit;
  final ValueChanged<int>? onNavigateQuestion;

  bool get _isCreateMode => mode == ExamMode.create;
  bool get _isPreviewMode => mode == ExamMode.preview;
  bool get _isSolveMode => mode == ExamMode.solving;
  bool get _isStudentResultMode => mode == ExamMode.studentResult;
  bool get _isTeacherResultMode => mode == ExamMode.teacherResult;
  bool get _isResultMode => _isStudentResultMode || _isTeacherResultMode;

  bool get _canEditQuestions => _isCreateMode;

  String get _title {
    if (_isSolveMode) return NameRoutes.doExam.titleAppBar;
    if (_isTeacherResultMode || _isStudentResultMode) return exam.examStatic.typeExam;
    if (_isCreateMode) return NameRoutes.createExam.titleAppBar;
    return exam.examStatic.typeExam;
  }

  List<ExamQuestionViewModel> get _effectiveQuestions {
    if (questions != null) return questions!;

    final sourceQuestions = exam.questions;
    if (_isTeacherResultMode || _isStudentResultMode) {
      final activeResult = _selectedResult;
      return sourceQuestions.map((q) {
        String studentAnswer = '';
        String? score;
        bool? evaluated;
        if (activeResult != null) {
          final match = activeResult.examResultQA.firstWhere(
            (qa) => qa.questionId == q.id,
            orElse: () => const EmptyExamResultQA._(),
          );
          if (match is! EmptyExamResultQA) {
            studentAnswer = match.studentAnswer;
            score = match.score;
            evaluated = match.evaluated;
          }
        }
        return ExamQuestionViewModel.fromGenerated(
          q,
          studentAnswer: studentAnswer,
          score: score,
          evaluated: evaluated,
        );
      }).toList(growable: false);
    }

    return sourceQuestions
        .map((q) => ExamQuestionViewModel.fromGenerated(q))
        .toList(growable: false);
  }

  ExamResultModel? get _selectedResult {
    if (!_isResultMode) return null;
    final results = examResults ?? exam.examResult;
    if (results.isEmpty) return null;

    if (_isStudentResultMode) {
      return exam.myTest;
    }

    if ((selectedStudentEmail ?? '').trim().isNotEmpty) {
      return results.firstWhere(
        (item) => item.examResultEmailSt == selectedStudentEmail,
        orElse: () => results.first,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isSolveMode) {
      return _buildSolvingMode();
    }

    return ExamShell(
      title: _title,
      useScrollBody: true,
      persistentFooterButtons: _isCreateMode || _isPreviewMode
          ? [
              core_button.CreateButton(
                onPress: loadingSave ? null : onSave,
                text: loadingSave ? ViewExamStrings.saving : ViewExamStrings.saveAndSubmit,
              ),
              if (loadingSave)
                LinearProgressIndicator(
                  color: AppColors.colorPrimary,
                ),
            ]
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExamInfoCard(exam: exam),
          SizedBox(height: 16.h),
          if (!exam.isEnded)
            core_date.ExamDateSection(
              startDate: startDate ?? exam.startedAt,
              endDate: endDate ?? exam.examFinishAt,
              isEditMode: _isCreateMode,
              onStartChanged: onStartChanged,
              onEndChanged: onEndChanged,
            ),
          SizedBox(height: 20.h),
          if (_isTeacherResultMode && (examResults ?? exam.examResult).isNotEmpty) ...[
            _buildTeacherTabs(),
            SizedBox(height: 16.h),
          ],
          AppCustomText.generate(
            text: _headerText(),
            textStyle: AppTextStyles.h5SemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 12.h),
          ExamQuestionsList(
            questions: _effectiveQuestions,
            mode: mode,
            allowQuestionEditing: _canEditQuestions,
            onQuestionUpdated: onQuestionUpdated,
            onQuestionDeleted: onQuestionDeleted,
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherTabs() {
    final results = examResults ?? exam.examResult;
    final shortAnswerCount = _effectiveQuestions
        .where((question) => question.isShortAnswer)
        .length;
    final selectedEmailText =
        (selectedStudentEmail ?? '').trim().isEmpty ? '-' : selectedStudentEmail!;

    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorsBackGround2,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.colorPrimary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            TabBar(
              indicatorColor: AppColors.colorPrimary,
              labelColor: AppColors.textWhite,
              unselectedLabelColor: AppColors.textCoolGray,
              tabs: const [
                Tab(text: 'Students'),
                Tab(text: 'Analytics'),
                Tab(text: 'Essays'),
              ],
            ),
            SizedBox(
              height: 160.h,
              child: TabBarView(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: StudentSelector(
                      examResults: results,
                      selectedEmail: selectedStudentEmail,
                      onSelect: onStudentSelect ?? (_) {},
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppCustomText.generate(
                          text: '${SubjectStrings.students}: ${results.length}',
                          textStyle: AppTextStyles.bodyMediumSemiBold,
                        ),
                        SizedBox(height: 8.h),
                        AppCustomText.generate(
                          text:
                              '${DashboardStrings.questionPerformance}: ${exam.questionCount}',
                          textStyle: AppTextStyles.bodyMediumSemiBold,
                        ),
                        SizedBox(height: 8.h),
                        AppCustomText.generate(
                          text:
                              '${DashboardStrings.averageScore}: ${_averageScore(results)}',
                          textStyle: AppTextStyles.bodyMediumSemiBold,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppCustomText.generate(
                          text: 'Essay grading section',
                          textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                            color: AppColors.colorPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        AppCustomText.generate(
                          text: 'Short-answer questions: $shortAnswerCount',
                          textStyle: AppTextStyles.bodyMediumMedium,
                        ),
                        SizedBox(height: 8.h),
                        AppCustomText.generate(
                          text: 'Selected student: $selectedEmailText',
                          textStyle: AppTextStyles.bodyMediumMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolvingMode() {
    if (loading) {
      return ExamShell(
        title: _title,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_effectiveQuestions.isEmpty || totalQuestions == 0) {
      return ExamShell(
        title: DoExamStrings.error,
        child: Center(
          child: AppCustomText.generate(
            text: DoExamStrings.noQuestionsAvailable,
            textStyle: AppTextStyles.h6Bold,
          ),
        ),
      );
    }

    final safeIndex = currentQuestionIndex.clamp(0, _effectiveQuestions.length - 1);
    final currentQuestion = _effectiveQuestions[safeIndex];

    return ExamShell(
      title: _title,
      appBarBottom: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: Container(
          padding: EdgeInsets.all(16.w),
          color: AppColors.colorsBackGround2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimer(),
              _buildProgress(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildSolvingBottomBar(safeIndex),
      child: SafeArea(
        child: Column(
          children: [
            _buildQuestionTimeline(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: ExamQuestionCard(
                  index: safeIndex,
                  question: currentQuestion,
                  mode: mode,
                  currentAnswer: solvingAnswers[currentQuestion.id],
                  onAnswerChanged: (value) =>
                      onAnswerChanged?.call(currentQuestion.id, value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTimeline() {
    return Container(
      height: 80.h,
      padding: EdgeInsets.all(16.w),
      color: AppColors.colorsBackGround2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _effectiveQuestions.length,
        itemBuilder: (context, index) {
          final question = _effectiveQuestions[index];
          final answer = solvingAnswers[question.id];
          final isAnswered = answer != null && answer.trim().isNotEmpty;
          final isCurrent = index == currentQuestionIndex;

          return GestureDetector(
            onTap: () => onNavigateQuestion?.call(index),
            child: Container(
              width: 50.w,
              height: 50.h,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.colorPrimary
                    : isAnswered
                        ? AppColors.green.withValues(alpha: 0.3)
                        : AppColors.colorBackgroundCardProjects,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.colorPrimary
                      : isAnswered
                          ? AppColors.green
                          : AppColors.colorUnActiveIcons,
                  width: isCurrent ? 3 : 1,
                ),
              ),
              child: Center(
                child: AppCustomText.generate(
                  text: '${index + 1}',
                  textStyle: AppTextStyles.bodyMediumBold.copyWith(
                    color: isCurrent || isAnswered
                        ? AppColors.textWhite
                        : AppColors.textCoolGray,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimer() {
    final minutes = remainingTime.inMinutes.toString().padLeft(2, '0');
    final seconds = (remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    final danger = remainingTime.inSeconds < 60;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: danger
            ? AppColors.red.withValues(alpha: 0.2)
            : AppColors.colorPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: danger ? AppColors.red : AppColors.colorPrimary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.timer,
            color: danger ? AppColors.red : AppColors.colorPrimary,
          ),
          SizedBox(width: 8.w),
          AppCustomText.generate(
            text: DoExamStrings.timerText(minutes, seconds),
            textStyle: AppTextStyles.h6Bold.copyWith(
              color: danger ? AppColors.red : AppColors.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final safeTotal = totalQuestions == 0 ? 1 : totalQuestions;
    final progress = (currentQuestionIndex + 1) / safeTotal;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCustomText.generate(
              text: DoExamStrings.questionProgress(
                currentQuestionIndex + 1,
                totalQuestions,
              ),
              textStyle: AppTextStyles.bodyMediumMedium,
            ),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.colorBackgroundCardProjects,
                valueColor: AlwaysStoppedAnimation(AppColors.colorPrimary),
                minHeight: 6.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolvingBottomBar(int safeIndex) {
    final isLast = safeIndex == _effectiveQuestions.length - 1;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: safeIndex == 0 ? null : onPrevious,
              icon: const Icon(AppIcons.arrowBackMaterial),
              label: const Text(DoExamStrings.previous),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorBackgroundCardProjects,
                foregroundColor: AppColors.textWhite,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: isLast
                ? ElevatedButton.icon(
                    onPressed: () async {
                      await onSubmit?.call();
                    },
                    icon: const Icon(AppIcons.checkCircle),
                    label: const Text(DoExamStrings.submitExam),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.textWhite,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onNext,
                    icon: const Icon(AppIcons.arrowForwardMaterial),
                    label: const Text(DoExamStrings.next),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      foregroundColor: AppColors.textWhite,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _headerText() {
    if (_isCreateMode) return ViewExamStrings.questionsEditMode;
    if (_isPreviewMode) return ViewExamStrings.questions;

    if (_isResultMode) {
      if (_isTeacherResultMode && _selectedResult == null) {
        return ViewExamStrings.questions;
      }
      final scoreValue = int.tryParse(_selectedResult?.examResultDegree ?? '0') ?? 0;
      return ViewExamStrings.resultsTitle(scoreValue, exam.examStatic.numberOfQuestions);
    }
    return ViewExamStrings.questions;
  }

  String _averageScore(List<ExamResultModel> results) {
    if (results.isEmpty) return '0';
    final sum = results.fold<int>(
      0,
      (previousValue, element) =>
          previousValue + (int.tryParse(element.examResultDegree) ?? 0),
    );
    final avg = sum / results.length;
    return avg.toStringAsFixed(1);
  }
}

class EmptyExamResultQA extends ExamResultQA {
  const EmptyExamResultQA._()
      : super(
          questionId: '',
          questionType: '',
          questionText: '',
          options: const [],
          correctAnswer: '',
          studentAnswer: '',
        );
}
