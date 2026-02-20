
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Enums/level_exam.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result_q_a.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    this.subject,
    this.exams = const [],
    this.results = const [],
  });

  final SubjectModel? subject;
  final List<ExamModel> exams;
  final List<ExamResultModel> results;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  _DashboardAnalytics? _analytics;

  @override
  void initState() {
    super.initState();
    _rebuildAnalyticsCache();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldRefresh = !identical(oldWidget.subject, widget.subject) ||
        !identical(oldWidget.exams, widget.exams) ||
        !identical(oldWidget.results, widget.results) ||
        oldWidget.exams.length != widget.exams.length ||
        oldWidget.results.length != widget.results.length;
    if (shouldRefresh) {
      _rebuildAnalyticsCache();
    }
  }

  void _rebuildAnalyticsCache() {
    final selectedSubject = widget.subject;
    if (selectedSubject == null || !selectedSubject.isME) {
      _analytics = null;
      return;
    }

    _analytics = _DashboardAnalytics.fromData(
      subject: selectedSubject,
      exams: widget.exams,
      fallbackResults: widget.results,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubject = widget.subject;
    if (selectedSubject == null) {
      return Scaffold(
        appBar: AppBar(title: Text(NameRoutes.dashboard.titleAppBar)),
        body: const Center(child: Text(DashboardStrings.noSubjectSelected)),
      );
    }

    if (!selectedSubject.isME) {
      return Scaffold(
        appBar: AppBar(title: Text(NameRoutes.dashboard.titleAppBar)),
        body: const Center(
          child: Text(DashboardStrings.teacherOnlyMessage),
        ),
      );
    }

    final analytics = _analytics ??
        _DashboardAnalytics.fromData(
          subject: selectedSubject,
          exams: widget.exams,
          fallbackResults: widget.results,
        );

    return Scaffold(
      appBar: AppBar(title: Text(NameRoutes.dashboard.titleAppBar)),
      body: SafeArea(
        child: _DashboardBody(
          subject: selectedSubject,
          analytics: analytics,
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.subject,
    required this.analytics,
  });

  final SubjectModel subject;
  final _DashboardAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isTablet = maxWidth >= 700;
        final isWide = maxWidth >= 1100;
        final contentMaxWidth = isWide ? 1200.0 : (isTablet ? 960.0 : 560.0);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 24.w : 14.w,
                vertical: 14.h,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      children: [
                        _buildHeaderCard(),
                        SizedBox(height: 10.h),
                        _buildStudentScoresButton(context),
                        SizedBox(height: 14.h),
                        _buildOverviewSection(wideMode: isTablet),
                        SizedBox(height: 14.h),
                        _buildResponsiveSections(
                          context,
                          isTablet: isTablet,
                          isWide: isWide,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStudentScoresButton(BuildContext context) {
    final count = analytics.studentExamSummaries.length;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: count == 0 ? null : () => _showStudentScoresBottomSheet(context),
        icon: const Icon(AppIcons.peopleAltOutlined),
        label: Text(
          count == 0
              ? DashboardStrings.noStudentRecordsYet
              : DashboardStrings.studentsScoreButton(count),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
          backgroundColor: AppColors.colorPrimary,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: AppColors.colorBackgroundCardProjects,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveSections(
    BuildContext context, {
    required bool isTablet,
    required bool isWide,
  }) {
    if (!isTablet) {
      return Column(
        children: [
          _buildDifficultySection(),
          SizedBox(height: 14.h),
          _buildQuestionPerformanceSection(context),
          SizedBox(height: 14.h),
          _buildTopicSection(),
          SizedBox(height: 14.h),
          _buildTimeSection(),
          SizedBox(height: 14.h),
          _buildStudentSplitSection(),
          SizedBox(height: 14.h),
          _buildComparisonSection(),
        ],
      );
    }

    return Column(
      children: [
        _SectionPair(
          spacing: 14.w,
          leftFlex: isWide ? 4 : 1,
          rightFlex: isWide ? 6 : 1,
          left: _buildDifficultySection(),
          right: _buildQuestionPerformanceSection(context),
        ),
        SizedBox(height: 14.h),
        _SectionPair(
          spacing: 14.w,
          left: _buildTopicSection(),
          right: _buildTimeSection(),
        ),
        SizedBox(height: 14.h),
        _SectionPair(
          spacing: 14.w,
          left: _buildStudentSplitSection(),
          right: _buildComparisonSection(),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.colorPrimary.withValues(alpha: 0.20),
            AppColors.colorsBackGround2.withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  AppIcons.analyticsOutlined,
                  color: AppColors.colorPrimary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  subject.subjectName,
                  style: AppTextStyles.h6Bold.copyWith(color: AppColors.textWhite),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _HeaderChip(
                icon: AppIcons.menuBookRounded,
                text: DashboardStrings.examsChip(analytics.examsCount),
              ),
              _HeaderChip(
                icon: AppIcons.groups2Outlined,
                text: DashboardStrings.studentsChip(analytics.studentsCount),
              ),
              _HeaderChip(
                icon: AppIcons.calendarMonthOutlined,
                text: DashboardStrings.createdChip(subject.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection({required bool wideMode}) {
    final cards = <_OverviewMetricData>[
      _OverviewMetricData(
        icon: AppIcons.assignmentOutlined,
        title: DashboardStrings.examsCount,
        value: '${analytics.examsCount}',
        color: AppColors.dashboardMetricBlue,
      ),
      _OverviewMetricData(
        icon: AppIcons.groupsRounded,
        title: DashboardStrings.studentsCount,
        value: '${analytics.studentsCount}',
        color: AppColors.dashboardMetricGreen,
      ),
      _OverviewMetricData(
        icon: AppIcons.percentRounded,
        title: DashboardStrings.averageScore,
        value: '${_formatPercent(analytics.averageScorePercent)}%',
        color: AppColors.dashboardMetricOrange,
      ),
      _OverviewMetricData(
        icon: AppIcons.verifiedRounded,
        title: DashboardStrings.passRate,
        value: '${_formatPercent(analytics.passRatePercent)}%',
        color: AppColors.dashboardMetricPurple,
      ),
    ];

    return _SectionCard(
      title: DashboardStrings.overview,
      subtitle: DashboardStrings.overviewSubtitle,
      child: wideMode
          ? GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 2.4,
              ),
              itemBuilder: (context, index) {
                return _OverviewMetricCard(
                  data: cards[index],
                  wideMode: true,
                );
              },
            )
          : SizedBox(
              height: 112.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => _OverviewMetricCard(
                  data: cards[index],
                ),
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemCount: cards.length,
              ),
            ),
    );
  }

  Widget _buildDifficultySection() {
    if (analytics.examsCount == 0) {
      return _SectionCard(
        title: DashboardStrings.examDifficulty,
        subtitle: DashboardStrings.examDifficultySubtitle,
        child: const _SectionEmptyState(message: DashboardStrings.noExamsToAnalyze),
      );
    }

    final segments = analytics.difficultySegments;
    return _SectionCard(
      title: DashboardStrings.examDifficulty,
      subtitle: DashboardStrings.examDifficultyChartSubtitle,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 150.w,
                height: 150.w,
                child: _DifficultyPieChart(segments: segments),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: segments
                      .map(
                        (segment) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: _LegendItem(
                            color: segment.color,
                            label: segment.label,
                            value: DashboardStrings.examsChip(segment.value.toInt()),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              analytics.latestDifficultyLabel == null
                  ? DashboardStrings.latestDifficultyEmpty()
                  : DashboardStrings.latestDifficulty(
                      analytics.latestDifficultyLabel!,
                    ),
              style: AppTextStyles.bodyMediumMedium.copyWith(
                color: AppColors.textCoolGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPerformanceSection(BuildContext context) {
    final questions = analytics.questionStats;
    if (questions.isEmpty) {
      return _SectionCard(
        title: DashboardStrings.questionPerformance,
        subtitle: DashboardStrings.questionPerformanceSubtitle,
        child: const _SectionEmptyState(
          message: DashboardStrings.noAnsweredQuestions,
        ),
      );
    }

    return _SectionCard(
      title: DashboardStrings.questionPerformance,
      subtitle: DashboardStrings.questionPerformanceLegend,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              _LegendItem(color: AppColors.success, label: DashboardStrings.correct),
              SizedBox(width: 14),
              _LegendItem(color: AppColors.danger, label: DashboardStrings.wrong),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 250.h,
            child: _QuestionPerformanceChart(
              stats: questions.take(12).toList(),
              onTap: (item) => _showQuestionInsightSheet(context, item),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTopicSection() {
    final topics = analytics.topicStats;
    if (topics.isEmpty) {
      return _SectionCard(
        title: DashboardStrings.topicAnalysis,
        subtitle: DashboardStrings.topicAnalysisSubtitle,
        child: const _SectionEmptyState(
          message: DashboardStrings.noTopicPerformance,
        ),
      );
    }

    return _SectionCard(
      title: DashboardStrings.topicAnalysis,
      subtitle: DashboardStrings.topicAnalysisChartSubtitle,
      child: Column(
        children: [
          SizedBox(
            height: 220.h,
            child: _TopicBarChart(topics: topics.take(8).toList()),
          ),
          SizedBox(height: 10.h),
          ...topics.take(4).map(
            (topic) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      topic.lesson,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${topic.successPercent.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmallBold.copyWith(
                      color: topic.needsReview
                          ? AppColors.dangerSoft
                          : AppColors.colorPrimary,
                    ),
                  ),
                  if (topic.needsReview) ...[
                    SizedBox(width: 8.w),
                    Text(
                      DashboardStrings.reviewThisLesson,
                      style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                        color: AppColors.dangerSoft,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    final timePoints = analytics.timeTrend;
    if (timePoints.isEmpty) {
      return _SectionCard(
        title: DashboardStrings.timeAnalysis,
        subtitle: DashboardStrings.timeAnalysisSubtitle,
        child: const _SectionEmptyState(
          message: DashboardStrings.noTimeData,
        ),
      );
    }

    final longest = analytics.longestTimeIndex >= 0
        ? timePoints[analytics.longestTimeIndex]
        : null;

    return _SectionCard(
      title: DashboardStrings.timeAnalysis,
      subtitle: DashboardStrings.timeAnalysisChartSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180.h,
            child: _LineTrendChart(
              points: timePoints,
              color: AppColors.colorPrimary,
              highlightedIndex: analytics.longestTimeIndex,
              ySuffix: DashboardStrings.minuteSuffix,
            ),
          ),
          if (longest != null) ...[
            SizedBox(height: 8.h),
            Text(
              DashboardStrings.longestValue(
                longest.fullLabel,
                longest.value.toStringAsFixed(0),
              ),
              style: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textCoolGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentSplitSection() {
    final split = analytics.studentSplit;
    if (!split.hasData) {
      return _SectionCard(
        title: DashboardStrings.studentPerformanceSplit,
        subtitle: DashboardStrings.studentPerformanceSplitSubtitle,
        child: const _SectionEmptyState(
          message: DashboardStrings.noStudentResults,
        ),
      );
    }

    final segments = <_SplitSegment>[
      _SplitSegment(
        label: DashboardStrings.excellent,
        percent: split.excellent,
        color: AppColors.dashboardSplitExcellent,
      ),
      _SplitSegment(
        label: DashboardStrings.average,
        percent: split.average,
        color: AppColors.dashboardSplitAverage,
      ),
      _SplitSegment(
        label: DashboardStrings.needsSupport,
        percent: split.needsSupport,
        color: AppColors.danger,
      ),
    ];

    return _SectionCard(
      title: DashboardStrings.studentPerformanceSplit,
      subtitle: DashboardStrings.studentPerformanceSplitChartSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 120.h,
            child: _StudentSplitChart(segments: segments),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: segments
                .map((segment) => _PercentChip(segment: segment))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    final trend = analytics.examComparison;
    if (trend.isEmpty) {
      return _SectionCard(
        title: DashboardStrings.examComparison,
        subtitle: DashboardStrings.examComparisonSubtitle,
        child: const _SectionEmptyState(
          message: DashboardStrings.noComparisonData,
        ),
      );
    }

    final improving = analytics.isImproving;

    return _SectionCard(
      title: DashboardStrings.examComparison,
      subtitle: DashboardStrings.examComparisonTrendSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180.h,
            child: _LineTrendChart(
              points: trend,
              color: improving
                  ? AppColors.dashboardSplitExcellent
                  : AppColors.danger,
              ySuffix: '%',
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(
                improving
                    ? AppIcons.trendingUpRounded
                    : AppIcons.trendingDownRounded,
                color: improving
                    ? AppColors.dashboardSplitExcellent
                    : AppColors.danger,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  DashboardStrings.trendMessage(improving),
                  style: AppTextStyles.bodyMediumBold.copyWith(
                    color: improving
                        ? AppColors.dashboardSplitExcellent
                        : AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuestionInsightSheet(BuildContext context, _QuestionStat question) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.colorsBackGround2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DashboardStrings.insightTitle(question.examName, question.label),
                style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.textWhite),
              ),
              SizedBox(height: 8.h),
              Text(
                question.questionText,
                style: AppTextStyles.bodyMediumMedium.copyWith(
                  color: AppColors.textCoolGray,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 14.h),
              _BottomSheetInfoRow(
                icon: AppIcons.percentRounded,
                title: DashboardStrings.successRate,
                value: '${_formatPercent(question.successPercent)}%',
              ),
              SizedBox(height: 8.h),
              _BottomSheetInfoRow(
                icon: AppIcons.howToVoteOutlined,
                title: DashboardStrings.mostSelected,
                value: question.mostSelectedAnswer,
              ),
              SizedBox(height: 8.h),
              _BottomSheetInfoRow(
                icon: AppIcons.groupsOutlined,
                title: DashboardStrings.attemptsLabel,
                value: '${question.attempts}',
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStudentScoresBottomSheet(BuildContext context) {
    final summaries = analytics.studentExamSummaries;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.colorsBackGround2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DashboardStrings.studentsScoreMatrix,
                    style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.textWhite),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DashboardStrings.studentsScoreMatrixHint,
                    style: AppTextStyles.bodySmallMedium.copyWith(
                      color: AppColors.textCoolGray,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (summaries.isEmpty)
                    const Expanded(
                      child: _SectionEmptyState(message: DashboardStrings.noStudentData),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: controller,
                        itemCount: summaries.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final summary = summaries[index];
                          return _StudentScoreCard(summary: summary);
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String _formatPercent(double value) {
    if (value.isNaN || value.isInfinite) return '0';
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.05) return rounded.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }
}
class _DashboardAnalytics {
  const _DashboardAnalytics({
    required this.examsCount,
    required this.studentsCount,
    required this.averageScorePercent,
    required this.passRatePercent,
    required this.difficultySegments,
    required this.latestDifficultyLabel,
    required this.questionStats,
    required this.topicStats,
    required this.timeTrend,
    required this.longestTimeIndex,
    required this.studentSplit,
    required this.examComparison,
    required this.isImproving,
    required this.studentExamSummaries,
  });

  final int examsCount;
  final int studentsCount;
  final double averageScorePercent;
  final double passRatePercent;
  final List<_ChartSegment> difficultySegments;
  final String? latestDifficultyLabel;
  final List<_QuestionStat> questionStats;
  final List<_TopicStat> topicStats;
  final List<_TrendPoint> timeTrend;
  final int longestTimeIndex;
  final _StudentSplit studentSplit;
  final List<_TrendPoint> examComparison;
  final bool isImproving;
  final List<_StudentExamSummary> studentExamSummaries;

  factory _DashboardAnalytics.fromData({
    required SubjectModel subject,
    required List<ExamModel> exams,
    required List<ExamResultModel> fallbackResults,
  }) {
    final sortedExams = List<ExamModel>.from(exams)
      ..sort((a, b) => a.examCreatedAt.compareTo(b.examCreatedAt));

    final resultsWithExam = <_ResultWithQuestionCount>[];
    for (final exam in sortedExams) {
      for (final result in exam.examResult) {
        resultsWithExam.add(
          _ResultWithQuestionCount(
            result: result,
            fallbackQuestions: exam.examStatic.numberOfQuestions,
          ),
        );
      }
    }

    if (resultsWithExam.isEmpty) {
      for (final result in fallbackResults) {
        resultsWithExam.add(
          _ResultWithQuestionCount(
            result: result,
            fallbackQuestions: result.numberOfQuestions,
          ),
        );
      }
    }

    final resultPercents = resultsWithExam
        .map(
          (item) => _calculateResultPercent(
            item.result,
            fallbackQuestions: item.fallbackQuestions,
          ),
        )
        .toList();

    final averageScore = _average(resultPercents);
    final passRate = resultPercents.isEmpty
        ? 0.0
        : (resultPercents.where((p) => p >= 50).length / resultPercents.length) * 100;

    final studentsCount =5;

    final difficultyCount = {
      LevelExam.easy: 0,
      LevelExam.normal: 0,
      LevelExam.hard: 0,
    };
    for (final exam in sortedExams) {
      difficultyCount[exam.examStatic.levelExam] =
          (difficultyCount[exam.examStatic.levelExam] ?? 0) + 1;
    }

    final segments = [
      _ChartSegment(
        label: DashboardStrings.easy,
        value: (difficultyCount[LevelExam.easy] ?? 0).toDouble(),
        color: AppColors.success,
      ),
      _ChartSegment(
        label: DashboardStrings.normal,
        value: (difficultyCount[LevelExam.normal] ?? 0).toDouble(),
        color: AppColors.warning,
      ),
      _ChartSegment(
        label: DashboardStrings.hard,
        value: (difficultyCount[LevelExam.hard] ?? 0).toDouble(),
        color: AppColors.danger,
      ),
    ];

    final latestExam = sortedExams.isEmpty ? null : sortedExams.last;

    final questionStats = _buildQuestionStats(sortedExams);
    final topicStats = _buildTopicStats(sortedExams);

    final timeTrend = <_TrendPoint>[];
    for (var i = 0; i < sortedExams.length; i++) {
      final exam = sortedExams[i];
      final minutes = double.tryParse(exam.examStatic.time) ?? 0;
      if (minutes <= 0) continue;
      timeTrend.add(
        _TrendPoint(
          label: _shortLabel(exam.examStatic.typeExam, i + 1),
          fullLabel: exam.examStatic.typeExam,
          value: minutes,
        ),
      );
    }

    final longestTimeIndex = _indexOfMax(timeTrend.map((e) => e.value).toList());

    final comparison = <_TrendPoint>[];
    for (var i = 0; i < sortedExams.length; i++) {
      final exam = sortedExams[i];
      final average = _calculateExamAveragePercent(exam);
      if (average == null) continue;
      comparison.add(
        _TrendPoint(
          label: _shortLabel(exam.examStatic.typeExam, i + 1),
          fullLabel: exam.examStatic.typeExam,
          value: average,
        ),
      );
    }

    final improving = comparison.length < 2
        ? true
        : comparison.last.value >= comparison.first.value;

    final split = _buildSplit(resultPercents);
    final studentSummaries = _buildStudentExamSummaries(
      subject: subject,
      exams: sortedExams,
    );

    return _DashboardAnalytics(
      examsCount: sortedExams.length,
      studentsCount: studentsCount,
      averageScorePercent: averageScore,
      passRatePercent: passRate,
      difficultySegments: segments,
      latestDifficultyLabel:
          latestExam == null ? null : _difficultyLabel(latestExam.examStatic.levelExam),
      questionStats: questionStats,
      topicStats: topicStats,
      timeTrend: timeTrend,
      longestTimeIndex: longestTimeIndex,
      studentSplit: split,
      examComparison: comparison,
      isImproving: improving,
      studentExamSummaries: studentSummaries,
    );
  }

  static List<_StudentExamSummary> _buildStudentExamSummaries({
    required SubjectModel subject,
    required List<ExamModel> exams,
  }) {
    final emails = <String>{};

    for (final exam in exams) {
      emails.addAll(
        exam.examResult
            .map((r) => r.examResultEmailSt.trim())
            .where((e) => e.isNotEmpty),
      );
    }

    final sortedEmails = emails.toList()
      ..sort(
        (a, b) => _extractUserName(a).toLowerCase().compareTo(_extractUserName(b).toLowerCase()),
      );

    final summaries = <_StudentExamSummary>[];
    for (final email in sortedEmails) {
      var totalScore = 0.0;
      var totalPossible = 0.0;
      final flaggedExamNames = <String>[];

      for (var examIndex = 0; examIndex < exams.length; examIndex++) {
        final exam = exams[examIndex];
        final result = _findResultByEmail(exam.examResult, email);
        final examName = exam.examStatic.typeExam.trim().isEmpty
            ? DashboardStrings.examLabel(examIndex)
            : exam.examStatic.typeExam;
        final fallbackTotal = exam.examStatic.numberOfQuestions;
        final resultTotal = result?.numberOfQuestions ?? 0;
        final normalizedTotal = fallbackTotal > 0
            ? fallbackTotal.toDouble()
            : (resultTotal > 0 ? resultTotal.toDouble() : 0.0);

        totalPossible += normalizedTotal;

        if (result == null) {
          flaggedExamNames.add(examName);
          continue;
        }

        final rawScore = double.tryParse(result.examResultDegree) ?? 0;
        final boundedScore = normalizedTotal > 0
            ? rawScore.clamp(0, normalizedTotal).toDouble()
            : math.max(0.0, rawScore);
        totalScore += boundedScore;

        if (boundedScore <= 0) {
          flaggedExamNames.add(examName);
        }
      }

      summaries.add(
        _StudentExamSummary(
          email: email,
          displayName: _extractUserName(email),
          totalScore: totalScore,
          totalPossible: totalPossible,
          flaggedExamNames: flaggedExamNames,
        ),
      );
    }

    return summaries;
  }

  static List<_QuestionStat> _buildQuestionStats(List<ExamModel> exams) {
    final output = <_QuestionStat>[];

    for (final exam in exams) {
      if (exam.examResult.isEmpty) continue;

      for (var index = 0; index < exam.examStatic.examResultQA.length; index++) {
        final examQuestion = exam.examStatic.examResultQA[index];
        final answerCount = <String, int>{};
        final answerLabel = <String, String>{};

        var attempts = 0;
        var correctCount = 0;

        for (final result in exam.examResult) {
          final submittedQuestion = _findQuestion(result.examResultQA, examQuestion.questionId);
          if (submittedQuestion == null) continue;

          attempts++;

          final rawAnswer = submittedQuestion.studentAnswer.trim();
          final normalizedAnswer = _normalize(rawAnswer);
          final normalizedCorrect = _normalize(examQuestion.correctAnswer);

          final score = double.tryParse(submittedQuestion.score ?? '');
          final isCorrectByScore = (score ?? -1) > 0;
          final isCorrectByAnswer =
              normalizedCorrect.isNotEmpty && normalizedAnswer == normalizedCorrect;

          if (isCorrectByScore || isCorrectByAnswer) {
            correctCount++;
          }

          if (normalizedAnswer.isNotEmpty &&
              normalizedAnswer != DashboardStrings.noAnswer) {
            answerCount[normalizedAnswer] = (answerCount[normalizedAnswer] ?? 0) + 1;
            answerLabel[normalizedAnswer] = rawAnswer;
          }
        }

        if (attempts == 0) continue;

        final success = (correctCount / attempts) * 100;
        final mostCommonKey = answerCount.entries.isEmpty
            ? null
            : answerCount.entries
                .reduce((a, b) => a.value >= b.value ? a : b)
                .key;

        output.add(
          _QuestionStat(
            label: DashboardStrings.questionLabel(index),
            examName: exam.examStatic.typeExam,
            questionText: examQuestion.questionText,
            successPercent: success,
            attempts: attempts,
            mostSelectedAnswer: mostCommonKey == null
                ? DashboardStrings.noClearAnswer
                : (answerLabel[mostCommonKey] ?? mostCommonKey),
          ),
        );
      }
    }

    output.sort((a, b) {
      final compareSuccess = a.successPercent.compareTo(b.successPercent);
      if (compareSuccess != 0) return compareSuccess;
      return b.attempts.compareTo(a.attempts);
    });

    return output;
  }

  static List<_TopicStat> _buildTopicStats(List<ExamModel> exams) {
    final map = <String, List<double>>{};

    for (final exam in exams) {
      final avg = _calculateExamAveragePercent(exam);
      if (avg == null) continue;
      final label = exam.examStatic.typeExam.trim().isEmpty
          ? DashboardStrings.examIdLabel(
              exam.examId.substring(
                0,
                math.min(AppConstants.examIdPreviewLength, exam.examId.length),
              ),
            )
          : exam.examStatic.typeExam;
      map.putIfAbsent(label, () => []).add(avg);
    }

    final output = map.entries
        .map((entry) {
          final avg = _average(entry.value);
          return _TopicStat(
            lesson: entry.key,
            successPercent: avg,
            needsReview: avg < 60,
          );
        })
        .toList()
      ..sort((a, b) => a.successPercent.compareTo(b.successPercent));

    return output;
  }

  static _StudentSplit _buildSplit(List<double> percents) {
    if (percents.isEmpty) {
      return const _StudentSplit(
        excellent: 0,
        average: 0,
        needsSupport: 0,
      );
    }

    var excellent = 0;
    var average = 0;
    var support = 0;

    for (final percent in percents) {
      if (percent >= 85) {
        excellent++;
      } else if (percent >= 60) {
        average++;
      } else {
        support++;
      }
    }

    final total = percents.length.toDouble();

    return _StudentSplit(
      excellent: (excellent / total) * 100,
      average: (average / total) * 100,
      needsSupport: (support / total) * 100,
    );
  }

  static String _difficultyLabel(LevelExam level) {
    switch (level) {
      case LevelExam.easy:
        return DashboardStrings.easy;
      case LevelExam.normal:
        return DashboardStrings.normal;
      case LevelExam.hard:
        return DashboardStrings.hard;
    }
  }

  static String _shortLabel(String value, int fallbackIndex) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return DashboardStrings.examFallbackLabel(fallbackIndex);
    if (trimmed.length <= AppConstants.examLabelMaxLength) return trimmed;
    return '${trimmed.substring(0, AppConstants.examLabelMaxLength)}...';
  }

  static String _extractUserName(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return email;
    return local.replaceAll(RegExp(r'[._-]+'), ' ');
  }

  static String _formatScore(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 0.001) return rounded.toInt().toString();
    return value.toStringAsFixed(1);
  }

  static ExamResultQA? _findQuestion(List<ExamResultQA> items, String id) {
    for (final item in items) {
      if (item.questionId == id) return item;
    }
    return null;
  }

  static ExamResultModel? _findResultByEmail(
    List<ExamResultModel> results,
    String email,
  ) {
    for (final result in results) {
      if (result.examResultEmailSt.trim().toLowerCase() == email.toLowerCase()) {
        return result;
      }
    }
    return null;
  }

  static String _normalize(String? text) {
    return (text ?? '').trim().toLowerCase();
  }

  static double _average(List<double> values) {
    if (values.isEmpty) return 0;
    final sum = values.fold<double>(0, (total, item) => total + item);
    return sum / values.length;
  }

  static double? _calculateExamAveragePercent(ExamModel exam) {
    if (exam.examResult.isEmpty) return null;
    final values = exam.examResult
        .map(
          (result) => _calculateResultPercent(
            result,
            fallbackQuestions: exam.examStatic.numberOfQuestions,
          ),
        )
        .toList();
    return _average(values);
  }

  static double _calculateResultPercent(
    ExamResultModel result, {
    required int fallbackQuestions,
  }) {
    final degree = double.tryParse(result.examResultDegree) ?? 0;
    final totalQuestions = result.numberOfQuestions > 0
        ? result.numberOfQuestions
        : fallbackQuestions;
    if (totalQuestions <= 0) return 0;

    final percent = (degree / totalQuestions) * 100;
    return percent.clamp(0, 100);
  }

  static int _indexOfMax(List<double> values) {
    if (values.isEmpty) return -1;
    var maxIndex = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[maxIndex]) {
        maxIndex = i;
      }
    }
    return maxIndex;
  }
}
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.textWhite),
          ),
          SizedBox(height: 3.h),
          Text(
            subtitle,
            style: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.textCoolGray,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _SectionPair extends StatelessWidget {
  const _SectionPair({
    required this.left,
    required this.right,
    this.leftFlex = 1,
    this.rightFlex = 1,
    this.spacing = 14,
  });

  final Widget left;
  final Widget right;
  final int leftFlex;
  final int rightFlex;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        SizedBox(width: spacing),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.colorPrimary),
          SizedBox(width: 6.w),
          Text(
            text,
            style: AppTextStyles.bodySmallMedium.copyWith(color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.data,
    this.wideMode = false,
  });

  final _OverviewMetricData data;
  final bool wideMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wideMode ? double.infinity : 150.w,
      padding: EdgeInsets.all(wideMode ? 10.w : 12.w),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: data.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(data.icon, color: data.color, size: 20.sp),
          SizedBox(height: wideMode ? 4.h : 8.h),
          Text(
            data.value,
            style: (wideMode ? AppTextStyles.bodyLargeBold : AppTextStyles.h6Bold)
                .copyWith(color: AppColors.textWhite),
          ),
          SizedBox(height: 2.h),
          Text(
            data.title,
            style: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.textCoolGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label, this.value});

  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          value == null ? label : '$label ${value!}',
          style: AppTextStyles.bodySmallMedium.copyWith(
            color: AppColors.textCoolGray,
          ),
        ),
      ],
    );
  }
}

class _DifficultyPieChart extends StatefulWidget {
  const _DifficultyPieChart({required this.segments});

  final List<_ChartSegment> segments;

  @override
  State<_DifficultyPieChart> createState() => _DifficultyPieChartState();
}

class _DifficultyPieChartState extends State<_DifficultyPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.segments.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );
    if (total <= 0) {
      return const Center(child: Text(DashboardStrings.noData));
    }

    return PieChart(
      PieChartData(
        centerSpaceRadius: 32.r,
        sectionsSpace: 3,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (!mounted) return;
            final section = response?.touchedSection;
            if (section == null) {
              if (_touchedIndex != -1) {
                setState(() => _touchedIndex = -1);
              }
              return;
            }
            final newIndex = section.touchedSectionIndex;
            if (newIndex != _touchedIndex) {
              setState(() => _touchedIndex = newIndex);
            }
          },
        ),
        sections: List.generate(widget.segments.length, (index) {
          final segment = widget.segments[index];
          final isTouched = index == _touchedIndex;
          return PieChartSectionData(
            value: segment.value,
            color: segment.color,
            radius: isTouched ? 58.r : 50.r,
            showTitle: segment.value > 0,
            title: segment.value.toInt().toString(),
            titleStyle: AppTextStyles.bodySmallBold.copyWith(
              color: AppColors.textWhite,
            ),
          );
        }),
      ),
    );
  }
}

class _QuestionPerformanceChart extends StatelessWidget {
  const _QuestionPerformanceChart({required this.stats, required this.onTap});

  final List<_QuestionStat> stats;
  final void Function(_QuestionStat stat) onTap;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 25,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.textWhite.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36.w,
              getTitlesWidget: (value, meta) {
                if (value != 0 && value != 50 && value != 100) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.toInt()}%',
                  style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                    color: AppColors.textCoolGray,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= stats.length) {
                  return const SizedBox.shrink();
                }
                if (stats.length > 8 && index.isOdd) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    stats[index].label,
                    style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                      color: AppColors.textCoolGray,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
            bottom: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            if (event is! FlTapUpEvent) return;
            final spot = response?.spot;
            if (spot == null) return;
            final index = spot.touchedBarGroupIndex;
            if (index < 0 || index >= stats.length) return;
            onTap(stats[index]);
          },
        ),
        barGroups: List.generate(stats.length, (index) {
          final item = stats[index];
          final wrong = (100 - item.successPercent).clamp(0.0, 100.0);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: 100,
                width: 14.w,
                borderRadius: BorderRadius.circular(4.r),
                rodStackItems: [
                  BarChartRodStackItem(0, wrong, AppColors.danger),
                  BarChartRodStackItem(wrong, 100, AppColors.success),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TopicBarChart extends StatelessWidget {
  const _TopicBarChart({required this.topics});

  final List<_TopicStat> topics;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 25,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.textWhite.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32.w,
              getTitlesWidget: (value, meta) {
                if (value != 0 && value != 50 && value != 100) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.toInt()}%',
                  style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                    color: AppColors.textCoolGray,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= topics.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    DashboardStrings.topicLabel(index),
                    style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                      color: AppColors.textCoolGray,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
            bottom: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
          ),
        ),
        barGroups: List.generate(topics.length, (index) {
          final item = topics[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.successPercent,
                width: 16.w,
                borderRadius: BorderRadius.circular(4.r),
                color: item.needsReview
                    ? AppColors.dangerSoft
                    : AppColors.colorPrimary,
              ),
            ],
          );
        }),
      ),
    );
  }
}
class _LineTrendChart extends StatelessWidget {
  const _LineTrendChart({
    required this.points,
    required this.color,
    this.highlightedIndex,
    this.ySuffix = '',
  });

  final List<_TrendPoint> points;
  final Color color;
  final int? highlightedIndex;
  final String ySuffix;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _SectionEmptyState(message: DashboardStrings.noChartData);
    }

    final values = points.map((point) => point.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).abs();
    final padding = range < 1 ? 1.0 : range * 0.2;
    final minY = (minValue - padding).clamp(0, 999999).toDouble();
    final maxY = (maxValue + padding).toDouble();

    final interval = ((maxY - minY) / 3).clamp(1, 999999).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: interval,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.textWhite.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
            bottom: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38.w,
              getTitlesWidget: (value, meta) {
                final closeToMin = (value - minY).abs() < (interval / 3);
                final closeToMid = (value - (minY + interval)).abs() < (interval / 3);
                final closeToMax = (value - maxY).abs() < (interval / 3);
                if (!closeToMin && !closeToMid && !closeToMax) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.toStringAsFixed(0)}$ySuffix',
                  style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                    color: AppColors.textCoolGray,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                final show = index == 0 ||
                    index == points.length - 1 ||
                    index == points.length ~/ 2;
                if (!show) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    points[index].label,
                    style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                      color: AppColors.textCoolGray,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.colorsBackGround,
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.x.toInt();
              final label = index >= 0 && index < points.length
                  ? points[index].fullLabel
                  : DashboardStrings.point;
              return LineTooltipItem(
                DashboardStrings.chartValueWithSuffix(
                  label,
                  '${spot.y.toStringAsFixed(1)}$ySuffix',
                ),
                AppTextStyles.bodyExtraSmallBold.copyWith(color: AppColors.textWhite),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              points.length,
              (index) => FlSpot(index.toDouble(), points[index].value),
            ),
            isCurved: true,
            color: color,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.12),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isHighlighted = highlightedIndex != null && index == highlightedIndex;
                return FlDotCirclePainter(
                  radius: isHighlighted ? 4.5 : 3,
                  color: color,
                  strokeWidth: 1.5,
                  strokeColor: AppColors.textWhite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentSplitChart extends StatelessWidget {
  const _StudentSplitChart({required this.segments});

  final List<_SplitSegment> segments;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (sum, item) => sum + item.percent);
    if (total <= 0) {
      return const _SectionEmptyState(message: DashboardStrings.noStudentSplitData);
    }

    var start = 0.0;
    final stackItems = <BarChartRodStackItem>[];
    for (final segment in segments) {
      final normalized = (segment.percent / total) * 100;
      final end = start + normalized;
      stackItems.add(BarChartRodStackItem(start, end, segment.color));
      start = end;
    }

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        alignment: BarChartAlignment.center,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 50,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.textWhite.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34.w,
              getTitlesWidget: (value, meta) {
                if (value != 0 && value != 50 && value != 100) {
                  return const SizedBox.shrink();
                }
                return Text(
                  '${value.toInt()}%',
                  style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                    color: AppColors.textCoolGray,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
            bottom: BorderSide(color: AppColors.textWhite.withValues(alpha: 0.15)),
          ),
        ),
        barTouchData: const BarTouchData(enabled: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: 100,
                width: 44.w,
                borderRadius: BorderRadius.circular(6.r),
                rodStackItems: stackItems,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PercentChip extends StatelessWidget {
  const _PercentChip({required this.segment});

  final _SplitSegment segment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: segment.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: segment.color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '${segment.label}: ${segment.percent.toStringAsFixed(1)}%',
        style: AppTextStyles.bodySmallBold.copyWith(color: segment.color),
      ),
    );
  }
}

class _BottomSheetInfoRow extends StatelessWidget {
  const _BottomSheetInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: AppColors.colorPrimary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            DashboardStrings.matrixHintText(title, value),
            style: AppTextStyles.bodyMediumMedium.copyWith(color: AppColors.textWhite),
          ),
        ),
      ],
    );
  }
}

class _StudentScoreCard extends StatelessWidget {
  const _StudentScoreCard({required this.summary});

  final _StudentExamSummary summary;

  @override
  Widget build(BuildContext context) {
    final totalLabel =
        '${_DashboardAnalytics._formatScore(summary.totalScore)} / ${_DashboardAnalytics._formatScore(summary.totalPossible)}';

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.colorBackgroundCardProjects.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.displayName,
                  style: AppTextStyles.bodyMediumBold.copyWith(color: AppColors.textWhite),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  DashboardStrings.totalLabel(totalLabel),
                  style: AppTextStyles.bodyExtraSmallBold.copyWith(
                    color: AppColors.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            summary.email,
            style: AppTextStyles.bodyExtraSmallMedium.copyWith(
              color: AppColors.textCoolGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (summary.flaggedExamNames.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: summary.flaggedExamNames
                    .map(
                      (examName) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Text(
                          DashboardStrings.flaggedExamLabel(examName),
                          style: AppTextStyles.bodyExtraSmallBold.copyWith(
                            color: AppColors.dashboardLightRed,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (summary.flaggedExamNames.isNotEmpty) SizedBox(height: 2.h),
          if (summary.flaggedExamNames.isEmpty)
            Text(
              DashboardStrings.noMissingOrZeroScores,
              style: AppTextStyles.bodyExtraSmallMedium.copyWith(
                color: AppColors.dashboardMetricGreen,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColors.colorBackgroundCardProjects.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmallMedium.copyWith(
          color: AppColors.textCoolGray,
        ),
      ),
    );
  }
}

class _OverviewMetricData {
  const _OverviewMetricData({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
}

class _QuestionStat {
  const _QuestionStat({
    required this.label,
    required this.examName,
    required this.questionText,
    required this.successPercent,
    required this.attempts,
    required this.mostSelectedAnswer,
  });

  final String label;
  final String examName;
  final String questionText;
  final double successPercent;
  final int attempts;
  final String mostSelectedAnswer;
}

class _TopicStat {
  const _TopicStat({
    required this.lesson,
    required this.successPercent,
    required this.needsReview,
  });

  final String lesson;
  final double successPercent;
  final bool needsReview;
}

class _TrendPoint {
  const _TrendPoint({
    required this.label,
    required this.fullLabel,
    required this.value,
  });

  final String label;
  final String fullLabel;
  final double value;
}

class _ChartSegment {
  const _ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class _SplitSegment {
  const _SplitSegment({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final double percent;
  final Color color;
}

class _StudentSplit {
  const _StudentSplit({
    required this.excellent,
    required this.average,
    required this.needsSupport,
  });

  final double excellent;
  final double average;
  final double needsSupport;

  bool get hasData => excellent > 0 || average > 0 || needsSupport > 0;
}

class _StudentExamSummary {
  const _StudentExamSummary({
    required this.email,
    required this.displayName,
    required this.totalScore,
    required this.totalPossible,
    required this.flaggedExamNames,
  });

  final String email;
  final String displayName;
  final double totalScore;
  final double totalPossible;
  final List<String> flaggedExamNames;
}

class _ResultWithQuestionCount {
  const _ResultWithQuestionCount({
    required this.result,
    required this.fallbackQuestions,
  });

  final ExamResultModel result;
  final int fallbackQuestions;
}

