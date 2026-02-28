import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/di/service_locator.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Dialog/app_dialog_service.dart';
import 'package:smart_text_thief/Core/Services/screenshot_protection_service.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/result_exam_status.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/show_message_snack_bar.dart';
import 'package:smart_text_thief/Features/exam/data/repositories/do_exam_repository.dart';
import 'package:smart_text_thief/Features/exam/presentation/widgets/exam_question_view_model.dart';
import 'package:smart_text_thief/Features/exam/presentation/manager/solve_exam_cubit.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/exam_mode.dart';
import 'package:smart_text_thief/Features/exam/presentation/pages/exam_view.dart';

class DoExam extends StatefulWidget {
  const DoExam({
    super.key,
    required this.model,
    required this.idSubject,
  });

  final ExamModel model;
  final String idSubject;

  @override
  State<DoExam> createState() => _DoExamState();
}

class _DoExamState extends State<DoExam> with WidgetsBindingObserver {
  SolveExamCubit? _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    unawaited(ScreenshotProtectionService.enableProtection());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(ScreenshotProtectionService.disableProtection());

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (_cubit == null) return;

    if (state == AppLifecycleState.resumed) {
      unawaited(_cubit!.onAppResumed());
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _cubit!.onAppBackgrounded(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _cubit = SolveExamCubit(
          repository: getIt<DoExamRepository>(),
        )..init(widget.model, idSubject: widget.idSubject);
        return _cubit!;
      },
      child: BlocConsumer<SolveExamCubit, SolveExamState>(
        listener: (context, state) {
          if (state.isBlockedBySubmission) {
            Navigator.of(context).pop(false);
            showMessageSnackBar(
              context,
              title: DoExamStrings.alreadySubmitted,
              type: MessageType.warning,
            );
            return;
          }

          if (state.isExamFinished) {
            Navigator.of(context).pop(true);
            showMessageSnackBar(
              context,
              title: DoExamStrings.examFinished,
              type: MessageType.success,
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<SolveExamCubit>();
          return PopScope(
            canPop: state.isExamFinished,
            onPopInvokedWithResult: (didPop, result) async {
              if (!didPop && !state.isExamFinished) {
                final shouldExit = await _showExitConfirmationDialog(context);
                if (shouldExit == true) {
                  await cubit.forceFinishExam(
                    status: ResultExamStatus.disposed,
                    source: 'manual_exit',
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            child: ExamView(
              exam: widget.model,
              mode: ExamMode.solving,
              loading: state.loading,
              currentQuestionIndex: state.currentQuestionIndex,
              totalQuestions: state.totalQuestions,
              remainingTime: state.remainingTime,
              solvingAnswers: state.userAnswers,
              questions: state.questions
                  .map((question) => ExamQuestionViewModel.fromResult(question))
                  .toList(growable: false),
              onAnswerChanged: cubit.selectAnswer,
              onNavigateQuestion: cubit.navigateToQuestion,
              onPrevious: cubit.previousQuestion,
              onNext: cubit.nextQuestion,
              onSubmit: () async {
                final success = await cubit.submitExam();
                if (!success) {
                  if (!mounted) return;
                  _showValidationDialog(this.context, cubit);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return AppDialogService.showConfirmDialog(
      context,
      title: DoExamStrings.exitExam,
      message: DoExamStrings.exitExamConfirm,
      confirmText: DoExamStrings.exit,
      destructive: true,
    );
  }

  void _showValidationDialog(BuildContext context, SolveExamCubit cubit) {
    AppDialogService.showInfoDialog(
      context,
      title: DoExamStrings.incompleteExam,
      message: DoExamStrings.unansweredText(cubit.unansweredQuestionsCount),
      actionText: AppStrings.ok,
    );
  }
}

