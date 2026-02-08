import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';

class DashboardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(NameRoutes.dashboard.titleAppBar),
      ),
      body: SafeArea(
        child: subject == null
            ? const Center(child: Text('No subject selected'))
            : ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _InfoCard(
                    title: subject!.subjectName,
                    subtitle: 'Subject',
                    value: subject!.subjectId,
                  ),
                  SizedBox(height: 10.h),
                  _InfoCard(
                    title: '${exams.length}',
                    subtitle: 'Exams',
                    value: 'All exams in this subject',
                  ),
                  SizedBox(height: 10.h),
                  _InfoCard(
                    title: '${results.length}',
                    subtitle: 'Results',
                    value: 'All results from all exams',
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Exams List',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8.h),
                  if (exams.isEmpty)
                    const Text('No exams yet')
                  else
                    ...exams.map(
                      (exam) => Card(
                        child: ListTile(
                          title: Text(exam.examStatic.typeExam),
                          subtitle: Text(
                            'Results: ${exam.examResult.length}',
                          ),
                          trailing: Text(exam.created),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      ),
    );
  }
}
