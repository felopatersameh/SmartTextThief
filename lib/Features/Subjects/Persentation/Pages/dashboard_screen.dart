import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import 'package:smart_text_thief/Features/exam/data/models/analytics_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.subjectId});
  final String? subjectId;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<AnalyticsSubjectModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subjectId != widget.subjectId) _future = _load();
  }

  Future<AnalyticsSubjectModel> _load() {
    final id = widget.subjectId;
    if (id == null || id.isEmpty) return Future.value(_empty);
    return context.read<SubjectCubit>().getAnalyticsSubjects(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NameRoutes.dashboard.titleAppBar)),
      body: FutureBuilder<AnalyticsSubjectModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _Message('Failed to load analytics.');
          }
          if ((widget.subjectId ?? '').isEmpty) {
            return const _Message('Subject ID is missing.');
          }
          return _Body(analytics: snapshot.data ?? _empty);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.analytics});
  final AnalyticsSubjectModel analytics;

  @override
  Widget build(BuildContext context) {
    final participation = analytics.participation;
    final scores = analytics.scores;
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject Analytics',
                      style: AppTextStyles.h6Bold
                          .copyWith(color: AppColors.textWhite)),
                  SizedBox(height: 8.h),
                  Text(
                    'Summary based on AnalyticsSubjectModel.',
                    style: AppTextStyles.bodySmallMedium
                        .copyWith(color: AppColors.textCoolGray),
                  ),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      _metric('Students', '${analytics.totalStudents.length}',
                          AppColors.dashboardMetricGreen, AppIcons.groupsRounded),
                      _metric('Exams', '${analytics.totalExams}',
                          AppColors.dashboardMetricBlue, AppIcons.assignmentOutlined),
                      _metric('Submissions', '${analytics.totalSubmissions}',
                          AppColors.dashboardMetricOrange, AppIcons.uploadFile),
                      _metric('Rate', '${participation?.rate ?? 0}%',
                          AppColors.dashboardMetricPurple, AppIcons.percentRounded),
                    ],
                  ),
                  if (analytics.generatedAt != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      'Last updated: ${_date(analytics.generatedAt)}',
                      style: AppTextStyles.bodySmallMedium
                          .copyWith(color: AppColors.textCoolGray),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 14.h),
            InkWell(
              onTap: analytics.totalStudents.isEmpty
                  ? null
                  : () => _openStudents(context, analytics.totalStudents),
              borderRadius: BorderRadius.circular(16.r),
              child: _Card(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.colorPrimary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(AppIcons.peopleAltOutlined,
                          color: AppColors.colorPrimary, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Student List',
                              style: AppTextStyles.bodyLargeBold
                                  .copyWith(color: AppColors.textWhite)),
                          SizedBox(height: 4.h),
                          Text(
                            analytics.totalStudents.isEmpty
                                ? 'No students available.'
                                : 'Tap to view names, emails, status filters, and join dates.',
                            style: AppTextStyles.bodySmallMedium
                                .copyWith(color: AppColors.textCoolGray),
                          ),
                        ],
                      ),
                    ),
                    _countBadge('${analytics.totalStudents.length}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Participation Overview'),
                  SizedBox(height: 12.h),
                  SizedBox(height: 210.h, child: _Participation(participation)),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(child: _pill('Joined', '${participation?.participated ?? 0}', AppColors.dashboardMetricGreen)),
                      SizedBox(width: 10.w),
                      Expanded(child: _pill('Not joined', '${participation?.notParticipated ?? 0}', AppColors.dashboardMetricOrange)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Score Range'),
                  SizedBox(height: 12.h),
                  SizedBox(height: 220.h, child: _Scores(scores)),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Question Analysis'),
                  SizedBox(height: 12.h),
                  SizedBox(height: 240.h, child: _Questions(analytics.questionsAnalysis)),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Exam Difficulty'),
                  SizedBox(height: 10.h),
                  _row('Hardest', _exam(analytics.examsDifficulty?.hardest)),
                  _row('Easiest', _exam(analytics.examsDifficulty?.easiest)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openStudents(BuildContext context, List<TotalStudent> students) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.colorsBackGround2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _StudentsSheet(students: students),
    );
  }

  Widget _metric(String title, String value, Color color, IconData icon) {
    return Container(
      width: 145.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(height: 10.h),
          Text(value,
              style: AppTextStyles.h6Bold.copyWith(color: AppColors.textWhite)),
          SizedBox(height: 2.h),
          Text(title,
              style: AppTextStyles.bodySmallMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _countBadge(String value) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.colorPrimary,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(value,
            style: AppTextStyles.bodyMediumBold
                .copyWith(color: AppColors.textWhite)),
      );

  Widget _pill(String label, String value, Color color) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTextStyles.bodyMediumBold
                    .copyWith(color: AppColors.textWhite)),
            SizedBox(height: 2.h),
            Text(label,
                style: AppTextStyles.bodyExtraSmallBold.copyWith(color: color)),
          ],
        ),
      );

  Widget _title(String text) => Text(text,
      style: AppTextStyles.bodyLargeBold.copyWith(color: AppColors.textWhite));

  Widget _row(String label, String value) => Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodySmallMedium
                      .copyWith(color: AppColors.textCoolGray)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.bodySmallBold
                      .copyWith(color: AppColors.textWhite)),
            ),
          ],
        ),
      );
}

class _StudentsSheet extends StatefulWidget {
  const _StudentsSheet({required this.students});
  final List<TotalStudent> students;

  @override
  State<_StudentsSheet> createState() => _StudentsSheetState();
}

class _StudentsSheetState extends State<_StudentsSheet> {
  String selected = _all;

  @override
  Widget build(BuildContext context) {
    final statuses = <String>{
      for (final s in widget.students)
        if (s.status.trim().isNotEmpty) s.status.trim(),
    }.toList()
      ..sort();
    final data = widget.students.where((s) {
      if (selected == _all) return true;
      return s.status.trim().toLowerCase() == selected.trim().toLowerCase();
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.white38,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text('Students',
                  style: AppTextStyles.h6Bold
                      .copyWith(color: AppColors.textWhite)),
              SizedBox(height: 4.h),
              Text('Total students: ${widget.students.length}',
                  style: AppTextStyles.bodySmallMedium
                      .copyWith(color: AppColors.textCoolGray)),
              SizedBox(height: 14.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('All', selected == _all, () => setState(() => selected = _all)),
                    ...statuses.map(
                      (status) => Padding(
                        padding: EdgeInsetsDirectional.only(start: 8.w),
                        child: _chip(status, selected == status,
                            () => setState(() => selected = status)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Expanded(
                child: data.isEmpty
                    ? const _Message('No students found for this status.')
                    : ListView.separated(
                        itemCount: data.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (_, i) => _student(data[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.colorPrimary
                  : AppColors.colorBackgroundCardProjects.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: active
                    ? AppColors.colorPrimary
                    : AppColors.textWhite.withValues(alpha: 0.08),
              ),
            ),
            child: Text(label,
                style: AppTextStyles.bodySmallBold
                    .copyWith(color: AppColors.textWhite)),
          ),
        ),
      );

  Widget _student(TotalStudent student) {
    final color = _statusColor(student.status);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.colorBackgroundCardProjects.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(student.name.isEmpty ? 'Unknown student' : student.name,
                    style: AppTextStyles.bodyMediumBold
                        .copyWith(color: AppColors.textWhite)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(student.status.isEmpty ? 'Unknown' : student.status,
                    style: AppTextStyles.bodyExtraSmallBold.copyWith(color: color)),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(student.email.isEmpty ? 'No email provided' : student.email,
              style: AppTextStyles.bodySmallMedium
                  .copyWith(color: AppColors.textCoolGray)),
          SizedBox(height: 8.h),
          Text('Joined: ${_date(student.joinedAt)}',
              style: AppTextStyles.bodyExtraSmallSemiBold
                  .copyWith(color: AppColors.textWhite)),
        ],
      ),
    );
  }
}

class _Participation extends StatelessWidget {
  const _Participation(this.data);
  final Participation? data;

  @override
  Widget build(BuildContext context) {
    final a = (data?.participated ?? 0).toDouble();
    final b = (data?.notParticipated ?? 0).toDouble();
    final total = a + b;
    if (total == 0) return const _Message('No participation data yet.');
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 34.r,
              sections: [
                _pie(a, total, AppColors.dashboardMetricGreen),
                _pie(b, total, AppColors.dashboardMetricOrange),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Legend('Joined', AppColors.dashboardMetricGreen),
              _Legend('Not joined', AppColors.dashboardMetricOrange),
            ],
          ),
        ),
      ],
    );
  }

  PieChartSectionData _pie(double value, double total, Color color) {
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 42.r,
      title: '${((value / total) * 100).round()}%',
      titleStyle: AppTextStyles.bodyExtraSmallBold
          .copyWith(color: AppColors.textWhite),
    );
  }
}

class _Scores extends StatelessWidget {
  const _Scores(this.data);
  final Scores? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) return const _Message('No score data yet.');
    final max = [data!.average, data!.highest, data!.lowest]
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    return BarChart(
      BarChartData(
        minY: 0,
        maxY: max <= 0 ? 10 : max + 10,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
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
              reservedSize: 34.w,
              getTitlesWidget: (v, m) => Text(
                v.toInt().toString(),
                style: AppTextStyles.bodyExtraSmallMedium
                    .copyWith(color: AppColors.textCoolGray),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, m) {
                const labels = ['Avg', 'High', 'Low'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(labels[i],
                      style: AppTextStyles.bodyExtraSmallBold
                          .copyWith(color: AppColors.textWhite)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          _bar(0, data!.average.toInt(), AppColors.dashboardMetricBlue),
          _bar(1, data!.highest.toInt(), AppColors.dashboardMetricGreen),
          _bar(2, data!.lowest.toInt(), AppColors.dashboardMetricOrange),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, int y, Color color) => BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y.toDouble(),
            width: 22.w,
            color: color,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ],
      );
}

class _Questions extends StatelessWidget {
  const _Questions(this.data);
  final QuestionsAnalysis? data;

  @override
  Widget build(BuildContext context) {
    final wrong = data?.topWrong.take(3).toList() ?? const <TopWrong>[];
    final skip = data?.mostSkipped.take(3).toList() ?? const <MostSkipped>[];
    if (wrong.isEmpty && skip.isEmpty) {
      return const _Message('No question analytics yet.');
    }

    final groups = <BarChartGroupData>[];
    final labels = <String>[];
    var x = 0;
    for (final item in wrong) {
      labels.add('W${labels.length + 1}');
      groups.add(_bar(x++, item.wrongCount.toInt(), AppColors.danger));
    }
    for (final item in skip) {
      labels.add('S${labels.length + 1 - wrong.length}');
      groups.add(_bar(x++, item.skipCount.toInt(), AppColors.warning));
    }
    final max = groups.fold<double>(
      0,
      (p, e) => e.barRods.first.toY > p ? e.barRods.first.toY : p,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            _Legend('Top wrong', AppColors.danger),
            _Legend('Most skipped', AppColors.warning),
          ],
        ),
        SizedBox(height: 12.h),
        Expanded(
          child: BarChart(
            BarChartData(
              minY: 0,
              maxY: max <= 0 ? 5 : max + 2,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
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
                    reservedSize: 30.w,
                    getTitlesWidget: (v, m) => Text(
                      v.toInt().toString(),
                      style: AppTextStyles.bodyExtraSmallMedium
                          .copyWith(color: AppColors.textCoolGray),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, m) {
                      final i = v.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(labels[i],
                            style: AppTextStyles.bodyExtraSmallBold
                                .copyWith(color: AppColors.textWhite)),
                      );
                    },
                  ),
                ),
              ),
              barGroups: groups,
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _bar(int x, int y, Color color) => BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: y.toDouble(),
            width: 18.w,
            color: color,
            borderRadius: BorderRadius.circular(6.r),
          ),
        ],
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 14.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          SizedBox(width: 6.w),
          Text(label,
              style: AppTextStyles.bodyExtraSmallBold
                  .copyWith(color: AppColors.textWhite)),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(text,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMediumMedium
                .copyWith(color: AppColors.textCoolGray)),
      ),
    );
  }
}

const String _all = '__all__';
const AnalyticsSubjectModel _empty = AnalyticsSubjectModel(
  totalStudents: [],
  totalExams: 0,
  totalSubmissions: 0,
  participation: null,
  scores: null,
  examsDifficulty: null,
  questionsAnalysis: null,
  generatedAt: null,
);

String _exam(Est? exam) {
  if (exam == null) return 'No data';
  if (exam.title.isEmpty) return '${exam.averageScore}%';
  return '${exam.title} (${exam.averageScore}%)';
}

String _date(DateTime? date) {
  if (date == null) return 'Not available';
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  final h = date.hour.toString().padLeft(2, '0');
  final min = date.minute.toString().padLeft(2, '0');
  return '$d/$m/${date.year} $h:$min';
}

Color _statusColor(String status) {
  final s = status.trim().toLowerCase();
  if (s.contains('active') || s.contains('approved') || s.contains('joined')) {
    return AppColors.success;
  }
  if (s.contains('pending') || s.contains('wait')) return AppColors.warning;
  if (s.contains('blocked') || s.contains('reject') || s.contains('remove')) {
    return AppColors.danger;
  }
  return AppColors.colorPrimary;
}
