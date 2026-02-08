import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/app_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Config/app_config.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';
import 'package:smart_text_thief/Core/Resources/app_icons.dart';
import 'package:smart_text_thief/Core/Services/PDF/pdf_services.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_exam_result.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/centered_section.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/empty_list_exams.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/exam_card.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/subject_action_dialog.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/subject_info_card.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.subjectModel,
  });

  final SubjectModel subjectModel;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubjectCubit>().openSubjectDetails(widget.subjectModel);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectCubit, SubjectState>(
      listenWhen: (previous, current) => previous.action != current.action,
      listener: (context, state) {
        if (state.action == SubjectAction.removed &&
            state.selectedSubject == null &&
            context.mounted) {
          AppRouter.backScreen(context);
        }
      },
      child: BlocBuilder<SubjectCubit, SubjectState>(
        builder: (context, state) {
          final selected = _subjectForPage(state);
          final exams = state.exams;

          Widget body;
          if (state.loadingExams) {
            body = const CenteredSection(
              child: CircularProgressIndicator(),
            );
          } else if (state.error != null) {
            body = CenteredSection(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (exams.isEmpty) {
            body = const CenteredSection(child: EmptyListExams());
          } else {
            body = SliverPadding(
              padding: EdgeInsets.only(
                top: 20.h,
                right: 20.h,
                left: 20.h,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exam = exams[index];
                    return ExamCard(
                      exam: exam,
                      againTest: () {
                        AppRouter.nextScreenNoPath(
                          context,
                          NameRoutes.doExam,
                          extra: exam,
                          pathParameters: {
                            'exam': exam.examId,
                            'id': exam.examIdSubject,
                          },
                        );
                      },
                      pdf: () async {
                        await ExamPdfUtil.createExamPdf(
                          examData: exam,
                          examInfo: selected,
                        );
                      },
                      showQA: () {
                        final email =
                            GetLocalStorage.getEmailUser().split('@').first;

                        AppRouter.nextScreenNoPath(
                          context,
                          NameRoutes.result,
                          extra: {
                            'exam': exam,
                            'isEditMode': false,
                            'nameSubject': selected.subjectName,
                          },
                          pathParameters: {
                            'exam': exam.examId,
                            'id': exam.examIdSubject,
                            'email': email,
                          },
                        );
                      },
                    );
                  },
                  childCount: exams.length,
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(NameRoutes.subjectDetails.titleAppBar),
            ),
            body: CustomScrollView(
              physics: AppConfig.physicsCustomScrollView,
              slivers: [
                SliverToBoxAdapter(
                  child: SubjectInfoCard(
                    subjectModel: selected,
                    examLength: exams.length,
                    onOpenDashboard: selected.isME
                        ? () => _openSubjectDashboard(context, selected, exams)
                        : null,
                    onToggleOpen: selected.isME
                        ? () => _toggleSubjectOpen(context, selected)
                        : null,
                    onDeleteSubject: selected.isME
                        ? () => _deleteSubject(context, selected)
                        : null,
                    onLeaveSubject: selected.isME
                        ? null
                        : () => _leaveSubject(context, selected),
                  ),
                ),
                body,
              ],
            ),
            floatingActionButton: selected.isME
                ? FloatingActionButton(
                    onPressed: () {
                      AppRouter.nextScreenNoPath(
                        context,
                        NameRoutes.createExam,
                        extra: selected,
                        pathParameters: {'id': selected.subjectId},
                      );
                    },
                    backgroundColor: AppColors.colorPrimary,
                    child: AppIcons.add,
                  )
                : null,
          );
        },
      ),
    );
  }

  SubjectModel _subjectForPage(SubjectState state) {
    final selected = state.selectedSubject;
    if (selected == null) return widget.subjectModel;
    if (selected.subjectId != widget.subjectModel.subjectId) {
      return widget.subjectModel;
    }
    return selected;
  }

  Future<void> _toggleSubjectOpen(BuildContext context, SubjectModel subject) async {
    final nextStatus = !subject.subjectIsOpen;
    final confirmed = await showSubjectActionDialog(
      context,
      title: nextStatus ? 'Open Subject' : 'Close Subject',
      message: nextStatus
          ? 'Students will be able to join this subject again.'
          : 'No new student will be able to join this subject.',
      confirmText: nextStatus ? 'Open' : 'Close',
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SubjectCubit>().toggleSubjectOpen(subject, nextStatus);
  }

  Future<void> _deleteSubject(BuildContext context, SubjectModel subject) async {
    final confirmed = await showSubjectActionDialog(
      context,
      title: 'Delete Subject',
      message: 'This will permanently delete the subject and all related exams.',
      confirmText: 'Delete',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SubjectCubit>().removeSubject(subject);
  }

  Future<void> _leaveSubject(BuildContext context, SubjectModel subject) async {
    final confirmed = await showSubjectActionDialog(
      context,
      title: 'Leave Subject',
      message: 'You will lose access to this subject. Continue?',
      confirmText: 'Leave',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    await context
        .read<SubjectCubit>()
        .leaveSubject(subject, GetLocalStorage.getEmailUser());
  }

  void _openSubjectDashboard(
    BuildContext context,
    SubjectModel subject,
    List<ExamModel> exams,
  ) {
    final results = <ExamResultModel>[
      for (final exam in exams) ...exam.examResult,
    ];
    AppRouter.nextScreenNoPath(
      context,
      NameRoutes.dashboard,
      extra: {
        'subject': subject,
        'exams': exams,
        'results': results,
      },
    );
  }
}
