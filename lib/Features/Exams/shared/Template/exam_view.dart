import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/exam_model.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/Results/exam_result_model.dart';
import 'package:smart_text_thief/Core/Utils/Widget/ButtonsStyle/create_button.dart'
    as core_button;
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Features/Exams/shared/Template/exam_question_view_model.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/Widgets/exam_shell.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/exam_mode.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/student_result_level.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/Widgets/exam_info_card.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/Widgets/exam_question_card.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/View/Widgets/exam_questions_list.dart';
import 'package:smart_text_thief/Features/Exams/Presentation/Create/Widgets/exam_date_section.dart'
    as exam_date;
import 'package:smart_text_thief/Features/Exams/Presentation/View/Widgets/student_selector.dart';

class ExamView extends StatelessWidget {
  const ExamView({
    super.key,
    required this.exam,
    required this.mode,
    this.questions,
    this.examResults,
    this.studentResult,
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
    this.useTeacherTopTabs = false,
  });

  final ExamModel exam;
  final ExamMode mode;
  final List<ExamQuestionViewModel>? questions;
  final List<ExamResultModel>? examResults;
  final ExamResultModel? studentResult;
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
  final bool useTeacherTopTabs;

  bool get _isCreateMode => mode == ExamMode.create;
  bool get _isPreviewMode => mode == ExamMode.preview;
  bool get _isSolveMode => mode == ExamMode.solving;
  bool get _isStudentResultMode => mode == ExamMode.studentResult;
  bool get _isTeacherResultMode => mode == ExamMode.teacherResult;
  bool get _isResultMode => _isStudentResultMode || _isTeacherResultMode;
  bool get _isTeacherNoSelection =>
      _isTeacherResultMode && (_selectedResult == null);

  bool get _canEditQuestions => _isCreateMode;

  String get _title {
    if (_isSolveMode) return NameRoutes.doExam.titleAppBar;
    if (_isTeacherResultMode || _isStudentResultMode) return exam.name;
    if (_isCreateMode) return NameRoutes.createExam.titleAppBar;
    return exam.name;
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
          for (final answer in activeResult.answers) {
            if (answer.id == q.id) {
              studentAnswer = answer.studentAnswer;
              score = answer.score?.toString();
              evaluated = answer.score != null;
              break;
            }
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
    final results = examResults ?? const <ExamResultModel>[];
    if (results.isEmpty) return null;

    if (_isStudentResultMode) {
      return studentResult ?? results.first;
    }

    if ((selectedStudentEmail ?? '').trim().isNotEmpty) {
      return results.firstWhere(
        (item) => item.student.email == selectedStudentEmail,
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

    if (_isResultMode && loading) {
      return ExamShell(
        title: _title,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isTeacherResultMode && useTeacherTopTabs) {
      return _buildTeacherTopTabsView();
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
      child: _buildMainContent(
        includeTeacherTabs: true,
        includeTeacherSelectorOnly: false,
      ),
    );
  }

  Widget _buildTeacherTopTabsView() {
    return DefaultTabController(
      length: 2,
      child: ExamShell(
        title: _title,
        useScrollBody: false,
        appBarBottom: PreferredSize(
          preferredSize: Size.fromHeight(72.h),
          child: Container(
            color: AppColors.colorsBackGround2,
            padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.colorBackgroundCardProjects,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.colorPrimary.withValues(alpha: 0.35),
                ),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.colorPrimary.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColors.transparent,
                labelColor: AppColors.textWhite,
                unselectedLabelColor: AppColors.textCoolGray.withValues(alpha: 0.9),
                labelStyle: AppTextStyles.bodyMediumSemiBold,
                tabs: const [
                  Tab(text: 'Exam'),
                  Tab(text: 'Analysis'),
                ],
              ),
            ),
          ),
        ),
        child: TabBarView(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: _buildMainContent(
                includeTeacherTabs: false,
                includeTeacherSelectorOnly: true,
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: _buildTeacherAnalysisContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent({
    required bool includeTeacherTabs,
    required bool includeTeacherSelectorOnly,
  }) {
    final results = examResults ?? const <ExamResultModel>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExamInfoCard(exam: exam),
        SizedBox(height: 16.h),
        if (!_isResultMode && !exam.isEnded)
          exam_date.ExamDateSection(
            startDate: startDate ?? exam.startedAt,
            endDate: endDate ?? exam.examFinishAt,
            isEditMode: _isCreateMode,
            onStartChanged: onStartChanged,
            onEndChanged: onEndChanged,
          ),
        SizedBox(height: 20.h),
        if (_isTeacherResultMode && results.isNotEmpty) ...[
          if (includeTeacherTabs) _buildTeacherTabs(),
          if (includeTeacherSelectorOnly) _buildTeacherStudentSelector(results),
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
          mode: _isTeacherNoSelection ? ExamMode.preview : mode,
          allowQuestionEditing: _canEditQuestions,
          onQuestionUpdated: onQuestionUpdated,
          onQuestionDeleted: onQuestionDeleted,
        ),
      ],
    );
  }

  Widget _buildTeacherStudentSelector(List<ExamResultModel> results) {
    return StudentSelector(
      examResults: results,
      selectedEmail: selectedStudentEmail,
      onSelect: onStudentSelect ?? (_) {},
    );
  }

  Widget _buildTeacherAnalysisContent() {
    final results = examResults ?? const <ExamResultModel>[];
    final distribution = _levelDistribution(results);
    final passRate = _passRate(results);
    final avgScore = _averageScore(results);
    final sorted = _sortedByScore(results);
    final best = _topStudentCandidate(sorted);
    final weakest = _needsSupportCandidate(sorted, best);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCustomText.generate(
            text: 'Exam Analysis',
            textStyle: AppTextStyles.h6SemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _buildKpiCard(
                title: 'Students',
                value: '${results.length}',
              ),
              _buildKpiCard(
                title: 'Avg Score',
                value: avgScore,
              ),
              _buildKpiCard(
                title: 'Pass Rate',
                value: '${passRate.toStringAsFixed(1)}%',
              ),
              _buildKpiCard(
                title: 'Best Score',
                value: best == null
                    ? '0/0'
                    : '${best.score.degree}/${best.score.total}',
              ),
            ],
          ),
          SizedBox(height: 18.h),
          AppCustomText.generate(
            text: 'Level Distribution',
            textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            height: 220.h,
            child: _buildLevelsBarChart(distribution),
          ),
          SizedBox(height: 14.h),
          _buildPerformanceSnapshot(best: best, weakest: weakest),
        ],
      ),
    );
  }

  Widget _buildTeacherTabs() {
    final results = examResults ?? const <ExamResultModel>[];

    return DefaultTabController(
      length: 2,
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
      final scoreValue = _selectedResult?.score.degree ?? 0;
      final totalQuestions = _selectedResult?.score.total ?? exam.questionCount;
      final level = StudentResultLevel.fromScore(
        degree: scoreValue,
        total: totalQuestions,
      );
      return '${ViewExamStrings.resultsTitle(scoreValue, totalQuestions)}'
          ' - ${ViewExamStrings.level}: ${level.label}';
    }
    return ViewExamStrings.questions;
  }

  String _averageScore(List<ExamResultModel> results) {
    if (results.isEmpty) return '0';
    final sum = results.fold<int>(
      0,
      (previousValue, element) => previousValue + element.score.degree,
    );
    final avg = sum / results.length;
    return avg.toStringAsFixed(1);
  }

  Map<StudentResultLevel, int> _levelDistribution(List<ExamResultModel> results) {
    final map = <StudentResultLevel, int>{
      StudentResultLevel.excellent: 0,
      StudentResultLevel.veryGood: 0,
      StudentResultLevel.good: 0,
      StudentResultLevel.pass: 0,
      StudentResultLevel.fail: 0,
    };

    for (final result in results) {
      final level = StudentResultLevel.fromScore(
        degree: result.score.degree,
        total: result.score.total,
      );
      map[level] = (map[level] ?? 0) + 1;
    }
    return map;
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
  }) {
    return Container(
      width: 155.w,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.colorTextFieldBackGround,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCustomText.generate(
            text: title,
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.textCoolGray,
            ),
          ),
          SizedBox(height: 4.h),
          AppCustomText.generate(
            text: value,
            textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSnapshot({
    required ExamResultModel? best,
    required ExamResultModel? weakest,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStudentHighlightCard(
            title: 'Top Student',
            model: best,
            accent: AppColors.green,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildStudentHighlightCard(
            title: 'Needs Support',
            model: weakest,
            accent: AppColors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentHighlightCard({
    required String title,
    required ExamResultModel? model,
    required Color accent,
  }) {
    final content = model == null
        ? 'No data'
        : '${_displayStudentIdentity(model.student.name, model.student.email)}\n'
            '${model.score.degree}/${model.score.total}';
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.colorTextFieldBackGround,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCustomText.generate(
            text: title,
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: accent,
            ),
          ),
          SizedBox(height: 6.h),
          AppCustomText.generate(
            text: content,
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  String _displayStudentIdentity(String name, String email) {
    final short = _shortName(name);
    if (short.isEmpty) return email;
    return '$short - $email';
  }

  String _shortName(String fullName) {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    final takeCount = words.length >= 3 ? 3 : (words.length >= 2 ? 2 : 1);
    return words.take(takeCount).join(' ');
  }

  List<ExamResultModel> _sortedByScore(List<ExamResultModel> results) {
    final sorted = List<ExamResultModel>.from(results);
    sorted.sort((a, b) => _scorePercent(b).compareTo(_scorePercent(a)));
    return sorted;
  }

  ExamResultModel? _topStudentCandidate(List<ExamResultModel> sorted) {
    if (sorted.isEmpty) return null;
    for (final student in sorted) {
      if (_scorePercent(student) >= 0.9) return student;
    }
    return null;
  }

  ExamResultModel? _needsSupportCandidate(
    List<ExamResultModel> sorted,
    ExamResultModel? topStudent,
  ) {
    if (sorted.isEmpty) return null;
    for (final student in sorted.reversed) {
      if (topStudent == null || student.student.email != topStudent.student.email) {
        return student;
      }
    }
    return null;
  }

  double _scorePercent(ExamResultModel model) {
    if (model.score.total <= 0) return 0;
    return model.score.degree / model.score.total;
  }

  double _passRate(List<ExamResultModel> results) {
    if (results.isEmpty) return 0;
    final passCount = results.where((item) {
      final level = StudentResultLevel.fromScore(
        degree: item.score.degree,
        total: item.score.total,
      );
      return level != StudentResultLevel.fail;
    }).length;
    return (passCount / results.length) * 100;
  }

  Widget _buildLevelsBarChart(Map<StudentResultLevel, int> distribution) {
    const orderedLevels = <StudentResultLevel>[
      StudentResultLevel.excellent,
      StudentResultLevel.veryGood,
      StudentResultLevel.good,
      StudentResultLevel.pass,
      StudentResultLevel.fail,
    ];
    const labels = <String>['Ex', 'VG', 'G', 'P', 'F'];

    final values = orderedLevels.map((level) => distribution[level] ?? 0).toList();
    var maxCount = 1;
    for (final value in values) {
      if (value > maxCount) maxCount = value;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxCount + 1).toDouble(),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.colorPrimary.withValues(alpha: 0.15),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28.w,
              interval: 1,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: AppTextStyles.bodySmallMedium.copyWith(
                  color: AppColors.textCoolGray,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    labels[index],
                    style: AppTextStyles.bodySmallMedium.copyWith(
                      color: AppColors.textCoolGray,
                      fontSize: 10.sp,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List<BarChartGroupData>.generate(values.length, (index) {
          final value = values[index].toDouble();
          final color = switch (index) {
            0 => AppColors.green,
            1 => AppColors.colorPrimary,
            2 => AppColors.colorPrimary.withValues(alpha: 0.8),
            3 => AppColors.colorPrimary.withValues(alpha: 0.6),
            _ => AppColors.red,
          };
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value,
                width: 22.w,
                borderRadius: BorderRadius.circular(6.r),
                color: color,
              ),
            ],
          );
        }),
      ),
    );
  }
}
