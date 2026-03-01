import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/create_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/dashboard_route_data.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/do_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/DataScreens/view_exam_route_data.dart';
import 'package:smart_text_thief/Config/Routes/Routes/create_exam_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/dashboard_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/do_exam_route.dart';
import 'package:smart_text_thief/Config/Routes/Routes/result_route.dart';
import 'package:smart_text_thief/Config/Routes/app_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Config/app_config.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Api/api_endpoints.dart';
import 'package:smart_text_thief/Core/Services/Api/api_service.dart';
import 'package:smart_text_thief/Core/Services/Dialog/app_dialog_service.dart';
import 'package:smart_text_thief/Core/Services/PDF/pdf_services.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/centered_section.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/empty_list_exams.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/exam_card.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/subject_action_dialog.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/subject_info_card.dart';

import '../../../../Core/Services/Permissions/file_access_permission_service.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';
import '../../../../Core/Utils/show_message_snack_bar.dart';

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
                       inst:selected.isME ,
                       againTest: () async =>
                           _startExamAttempt(context, selected, exam),
                      pdf: () async {
                        if (!selected.isME) return;
                        final canAccessFiles = await FileAccessPermissionService
                            .requestForExamFiles();
                        if (!canAccessFiles) {
                          if (!context.mounted) return;
                          await showMessageSnackBar(
                            context,
                            title: CreateExamStrings.filePermissionDenied,
                            type: MessageType.warning,
                          );
                          return;
                        }
                          if (!context.mounted) return;
                        await showMessageSnackBar(context,
                            title: CreateExamStrings.creating,
                            type: MessageType.loading,
                            onLoading: () async =>
                                await ExamPdfUtil.createExamPdf(
                                  examData: exam,
                                  examInfo: selected,
                                ));
                      },
                      showQA: () {
                        ResultRoute.push(
                          context,
                          data: ViewExamRouteData(
                            exam: exam,
                            isEditMode: false,
                            nameSubject: selected.subjectName,
                            idSubject: selected.subjectId,
                            isTeacherView: selected.isME,
                          ),
                          email: GetLocalStorage.getEmailUser(),
                          idSubject: selected.subjectId,
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
                        ? () => showMessageSnackBar(
                              context,
                              title: 'Changing',
                              type: MessageType.loading,
                              onLoading: () =>
                                  _toggleSubjectOpen(context, selected),
                            )
                        : null,
                    onDeleteSubject: selected.isME
                        ? () => showMessageSnackBar(context,
                            title: 'Deleting',
                            type: MessageType.loading,
                            onLoading: () => _deleteSubject(context, selected))
                        : null,
                    onLeaveSubject: selected.isME
                        ? null
                        : () => showMessageSnackBar(context,
                            title: 'Leaving',
                            type: MessageType.loading,
                            onLoading: () => _leaveSubject(context, selected)),
                  ),
                ),
                body,
                if (selected.isME)
                  SliverToBoxAdapter(
                    child: SizedBox(height: 88.h),
                  ),
              ],
            ),
            floatingActionButton: selected.isME
                ? FloatingActionButton.extended(
                    heroTag: 'details_screen_fab',
                    elevation: 6,
                    focusElevation: 8,
                    onPressed: () {
                     CreateExamRoute.push(
                        context,
                        data: CreateExamRouteData(subject: selected),
                      );
                    },
                    backgroundColor: AppColors.colorPrimary,
                    foregroundColor: AppColors.textWhite,
                    icon: AppIcons.add,
                    label: AppCustomText.generate(
                      text: 'New Exam',
                      textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Future<void> _toggleSubjectOpen(
      BuildContext context, SubjectModel subject) async {
    final nextStatus = !subject.subjectIsOpen;
    final confirmed = await showSubjectActionDialog(
      context,
      title:
          nextStatus ? SubjectStrings.openSubject : SubjectStrings.closeSubject,
      message: nextStatus
          ? SubjectStrings.openSubjectMessage
          : SubjectStrings.closeSubjectMessage,
      confirmText:
          nextStatus ? SubjectStrings.openSubject : SubjectStrings.closeSubject,
      instructionsTitle: SubjectStrings.actionWarningsTitle,
      instructions: nextStatus
          ? const [
              SubjectStrings.openSubjectWarningJoin,
              SubjectStrings.openSubjectWarningExisting,
            ]
          : const [
              SubjectStrings.closeSubjectWarningJoin,
              SubjectStrings.closeSubjectWarningExisting,
            ],
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SubjectCubit>().toggleSubjectOpen(subject, nextStatus);
  }

  Future<void> _deleteSubject(
      BuildContext context, SubjectModel subject) async {
    final confirmed = await showSubjectActionDialog(
      context,
      title: SubjectStrings.deleteSubject,
      message: SubjectStrings.deleteSubjectMessage,
      confirmText: AppStrings.delete,
      destructive: true,
      instructionsTitle: SubjectStrings.actionWarningsTitle,
      instructions: const [
        SubjectStrings.deleteSubjectWarningPermanent,
        SubjectStrings.deleteSubjectWarningDataLoss,
      ],
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
      instructionsTitle: SubjectStrings.actionWarningsTitle,
      instructions: const [
        SubjectStrings.leaveSubjectWarningAccess,
        SubjectStrings.leaveSubjectWarningRejoin,
      ],
    );
    if (confirmed != true || !context.mounted) return;
    await context
        .read<SubjectCubit>()
        .leaveSubject(subject, GetLocalStorage.getEmailUser());
  }

  Future<void> _startExamAttempt(
    BuildContext context,
    SubjectModel subject,
    ExamModel exam,
  ) async {
    final subjectCubit = context.read<SubjectCubit>();

    if (exam.doExam) {
      await showMessageSnackBar(
        context,
        title: DoExamStrings.alreadySubmitted,
        type: MessageType.warning,
      );
      return;
    }

    final confirmed = await AppDialogService.showConfirmDialog(
      context,
      title: ExamCardStrings.startExamNow,
      message: ExamCardStrings.startExamMessage,
      confirmText: ExamCardStrings.startExamNow,
      barrierDismissible: false,
      instructionsTitle: SubjectStrings.actionWarningsTitle,
      instructions: const [
        ExamCardStrings.startExamWarningNoExit,
        ExamCardStrings.startExamWarningExitRisk,
        ExamCardStrings.startExamWarningReady,
      ],
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final response = await DioHelper.postData(
        path: ApiEndpoints.subjectStartExam(subject.subjectId, exam.id),
      );
        
      final message = response.message.trim();
      final rawData = response.data;
      final data = rawData is Map<String, dynamic>
          ? rawData
          : rawData is Map
              ? Map<String, dynamic>.from(rawData)
              : const <String, dynamic>{};
      final status = (data['status'] ?? '').toString().trim();

      if (!response.status) {
        if (!context.mounted) return;
        await showMessageSnackBar(
          context,
          title: message.isEmpty ? DoExamStrings.error : message,
          type: MessageType.warning,
        );
        return;
      }

      if (status == 'running') {
        final isExistingAttempt =
            message.toLowerCase().contains('already started');
        if (isExistingAttempt && context.mounted) {
          await showMessageSnackBar(
            context,
            title: message,
            type: MessageType.info,
          );
        }
        if (!context.mounted) return;
        await DoExamRoute.push(
          context,
          data: DoExamRouteData(exam: exam),
          idSubject: subject.subjectId,
        );
        if (!context.mounted) return;
        await subjectCubit.getExams(subject.subjectId);
        return;
      }

      if (status == 'time_expired') {
        if (!context.mounted) return;
        await showMessageSnackBar(
          context,
          title: message.isEmpty ? 'Exam time expired' : message,
          type: MessageType.info,
        );
        await subjectCubit.getExams(subject.subjectId);
        return;
      }

      if (!context.mounted) return;
      await showMessageSnackBar(
        context,
        title: message.isEmpty ? DoExamStrings.error : message,
        type: MessageType.warning,
      );
    } catch (error) {
      if (!context.mounted) return;
      await showMessageSnackBar(
        context,
        title: error.toString(),
        type: MessageType.error,
      );
    }
  }

  void _openSubjectDashboard(
    BuildContext context,
    SubjectModel subject,
    List<ExamModel> exams,
  ) {
    DashboardRoute.push(
      context,
      data: DashboardRouteData(subjectId: subject.subjectId),
    );
  }
}

