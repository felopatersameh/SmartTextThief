import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/app_router.dart';
import 'package:smart_text_thief/Config/Routes/route_data.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Config/app_config.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
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
                style: const TextStyle(color: AppColors.danger),
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
                        AppRouter.pushToDoExam(
                          context,
                          data: DoExamRouteData(exam: exam),
                        );
                      },
                      pdf: () async {
                        await ExamPdfUtil.createExamPdf(
                          examData: exam,
                          examInfo: selected,
                        );
                      },
                      showQA: () {
                        AppRouter.pushToResult(
                          context,
                          data: ViewExamRouteData(
                            exam: exam,
                            isEditMode: false,
                            nameSubject: selected.subjectName,
                          ),
                          email: GetLocalStorage.getEmailUser(),
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
                      AppRouter.pushToCreateExam(
                        context,
                        data: CreateExamRouteData(subject: selected),
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
      title: nextStatus
          ? SubjectStrings.openSubject
          : SubjectStrings.closeSubject,
      message: nextStatus
          ? SubjectStrings.openSubjectMessage
          : SubjectStrings.closeSubjectMessage,
      confirmText: nextStatus
          ? SubjectStrings.openSubject
          : SubjectStrings.closeSubject,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SubjectCubit>().toggleSubjectOpen(subject, nextStatus);
  }

  Future<void> _deleteSubject(BuildContext context, SubjectModel subject) async {
    final confirmed = await showSubjectActionDialog(
      context,
      title: SubjectStrings.deleteSubject,
      message: SubjectStrings.deleteSubjectMessage,
      confirmText: AppStrings.delete,
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SubjectCubit>().removeSubject(subject);
  }

  Future<void> _leaveSubject(BuildContext context, SubjectModel subject) async {
    final confirmed = await showSubjectActionDialog(
      context,
      title: SubjectStrings.leaveSubject,
      message: SubjectStrings.leaveSubjectMessage,
      confirmText: SubjectStrings.leave,
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
    AppRouter.pushToDashboard(
      context,
      data: DashboardRouteData(
        subject: subject,
        exams: exams,
        results: results,
      ),
    );
  }
}
