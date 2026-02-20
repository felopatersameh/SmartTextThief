import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Config/di/service_locator.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Dialog/app_dialog_service.dart';
import 'package:smart_text_thief/Core/Services/screenshot_protection_service.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_result_q_a.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Core/Utils/show_message_snack_bar.dart';
import 'package:smart_text_thief/Features/Exams/do_exam/data/repositories/do_exam_repository.dart';
import 'package:smart_text_thief/Features/Exams/do_exam/presentation/cubit/do_exam_cubit.dart';

class DoExam extends StatefulWidget {
  const DoExam({super.key, required this.model});
  final ExamModel model;
  @override
  State<DoExam> createState() => _DoExamState();
}

class _DoExamState extends State<DoExam> with WidgetsBindingObserver {
  DoExamCubit? _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Hide navigation bar and set immersive mode when entering exam
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

    // Restore navigation bar when exiting exam
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
      _cubit!.onAppBackgrounded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _cubit = DoExamCubit(
          repository: getIt<DoExamRepository>(),
        )..init(widget.model);
        return _cubit!;
      },
      child: BlocConsumer<DoExamCubit, DoExamState>(
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
          final cubit = BlocProvider.of<DoExamCubit>(context);
          final questions = state.questions;
          final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

          // Safety check: handle empty questions
          if (questions.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: AppCustomText.generate(
                  text: DoExamStrings.error,
                  textStyle: AppTextStyles.h5Bold,
                ),
              ),
              body: Center(
                child: AppCustomText.generate(
                  text: DoExamStrings.noQuestionsAvailable,
                  textStyle: AppTextStyles.h6Bold,
                ),
              ),
            );
          }

          final currentQuestion = questions[state.currentQuestionIndex];

          return PopScope(
            canPop: state.isExamFinished,
            onPopInvokedWithResult: (didPop, p0) async {
              if (!didPop && !state.isExamFinished) {
                // Show confirmation dialog
                final shouldExit = await _showExitConfirmationDialog(
                  context,
                  cubit,
                );
                if (shouldExit == true) {
                  await cubit.forceFinishExam();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: AppCustomText.generate(
                  text: NameRoutes.doExam.titleAppBar,
                  textStyle: AppTextStyles.h5Bold,
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.colorsBackGround2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [_buildTimer(state), _buildProgressBar(state)],
                    ),
                  ),
                ),
              ),
              body: state.loading
                  ? const Center(child: CircularProgressIndicator())
                  : SafeArea(
                      child: GestureDetector(
                        onTap: () => FocusScope.of(context).unfocus(),
                        child: Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: isKeyboardVisible
                                  ? const SizedBox.shrink()
                                  : _buildQuestionTimeline(
                                      questions, state, cubit),
                            ),
                            _buildQuestionCard(currentQuestion, state, cubit),
                            _buildNavigationButtons(
                              state,
                              cubit,
                              compact: isKeyboardVisible,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimer(DoExamState state) {
    final duration = state.remainingTime;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: duration.inSeconds < 60
            ? AppColors.red.withValues(alpha: 0.2)
            : AppColors.colorPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              duration.inSeconds < 60 ? AppColors.red : AppColors.colorPrimary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            AppIcons.timer,
            color: duration.inSeconds < 60
                ? AppColors.red
                : AppColors.colorPrimary,
          ),
          const SizedBox(width: 8),
          AppCustomText.generate(
            text: DoExamStrings.timerText(
              minutes.toString().padLeft(2, '0'),
              seconds.toString().padLeft(2, '0'),
            ),
            textStyle: AppTextStyles.h6Bold.copyWith(
              color: duration.inSeconds < 60
                  ? AppColors.red
                  : AppColors.colorPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(DoExamState state) {
    final progress = (state.currentQuestionIndex + 1) / state.totalQuestions;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCustomText.generate(
              text: DoExamStrings.questionProgress(
                state.currentQuestionIndex + 1,
                state.totalQuestions,
              ),
              textStyle: AppTextStyles.bodyMediumMedium,
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.colorBackgroundCardProjects,
                valueColor: AlwaysStoppedAnimation(AppColors.colorPrimary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTimeline(
    List<ExamResultQA> questions,
    DoExamState state,
    DoExamCubit cubit,
  ) {
    return Container(
      height: 80.h,
      padding: const EdgeInsets.all(16),
      color: AppColors.colorsBackGround2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final answer = state.userAnswers[question.questionId];
          final isAnswered = answer != null && answer.trim().isNotEmpty;
          final isCurrent = index == state.currentQuestionIndex;

          return GestureDetector(
            onTap: () => cubit.navigateToQuestion(index),
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.colorPrimary
                    : isAnswered
                        ? AppColors.green.withValues(alpha: 0.3)
                        : AppColors.colorBackgroundCardProjects,
                borderRadius: BorderRadius.circular(8),
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
                  text: (index + 1).toString(),
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

  Widget _buildQuestionCard(
    ExamResultQA question,
    DoExamState state,
    DoExamCubit cubit,
  ) {
    final currentAnswer = state.userAnswers[question.questionId];
    final isShortAnswer = question.questionType == AppConstants.shortAnswerType;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.colorsBackGround2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCustomText.generate(
              text: question.questionText,
              // maxLines:question.questionText.length ,
              textStyle: AppTextStyles.h6Bold,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isShortAnswer
                  ? _buildShortAnswerField(question, currentAnswer, cubit)
                  : ListView.builder(
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final option = question.options[index];
                        final isSelected = currentAnswer == option;

                        return GestureDetector(
                          onTap: () =>
                              cubit.selectAnswer(question.questionId, option),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.colorPrimary
                                      .withValues(alpha: 0.2)
                                  : AppColors.colorBackgroundCardProjects,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.colorPrimary
                                    : AppColors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.colorPrimary
                                          : AppColors.textCoolGray,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? AppColors.colorPrimary
                                        : AppColors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          AppIcons.check,
                                          size: 16,
                                          color: AppColors.textWhite,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AppCustomText.generate(
                                    text: option,
                                    textStyle:
                                        AppTextStyles.bodyLargeMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : AppColors.textCoolGray,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortAnswerField(
    ExamResultQA question,
    String? currentAnswer,
    DoExamCubit cubit,
  ) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(bottom: keyboardInset > 0 ? 12 : 0),
          child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: TextFormField(
                key: ValueKey(
                    '${AppConstants.shortAnswerType}_${question.questionId}'),
                initialValue: currentAnswer ?? '',
                minLines: 6,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                scrollPadding: EdgeInsets.only(bottom: keyboardInset + 140),
                onChanged: (value) =>
                    cubit.selectAnswer(question.questionId, value),

                // 👇 Disable every interaction
                enableInteractiveSelection: false,
                contextMenuBuilder: (context, editableTextState) {
                  return const SizedBox.shrink();
                },
                enableSuggestions: false,
                autocorrect: false,
                showCursor: true,
                cursorColor: const Color.fromARGB(255, 48, 44, 44),

                style: AppTextStyles.bodyLargeMedium.copyWith(
                  color: AppColors.textWhite,
                ),
                decoration: InputDecoration(
                  hintText: DoExamStrings.writeAnswerHere,
                  hintStyle: AppTextStyles.bodyMediumMedium.copyWith(
                    color: AppColors.textCoolGray,
                  ),
                  filled: true,
                  fillColor: AppColors.colorBackgroundCardProjects,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              )),
        );
      },
    );
  }

  Widget _buildNavigationButtons(
    DoExamState state,
    DoExamCubit cubit, {
    bool compact = false,
  }) {
    final buttonVerticalPadding = compact ? 12.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
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
              onPressed: state.currentQuestionIndex == 0
                  ? null
                  : cubit.previousQuestion,
              icon: const Icon(AppIcons.arrowBackMaterial),
              label: const Text(DoExamStrings.previous),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorBackgroundCardProjects,
                foregroundColor: AppColors.textWhite,
                padding: EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(width: compact ? 12 : 16),
          if (state.currentQuestionIndex == state.totalQuestions - 1)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await cubit.submitExam();
                  if (!success && mounted) {
                    _showValidationDialog(context, cubit);
                  }
                },
                icon: const Icon(AppIcons.checkCircle),
                label: const Text(DoExamStrings.submitExam),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: AppColors.textWhite,
                  padding:
                      EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ElevatedButton.icon(
                onPressed: cubit.nextQuestion,
                icon: const Icon(AppIcons.arrowForwardMaterial),
                label: const Text(DoExamStrings.next),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPrimary,
                  foregroundColor: AppColors.textWhite,
                  padding:
                      EdgeInsets.symmetric(vertical: buttonVerticalPadding),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog(
    BuildContext context,
    DoExamCubit cubit,
  ) {
    return AppDialogService.showConfirmDialog(
      context,
      title: DoExamStrings.exitExam,
      message: DoExamStrings.exitExamConfirm,
      confirmText: DoExamStrings.exit,
      destructive: true,
    );
  }

  void _showValidationDialog(BuildContext context, DoExamCubit cubit) {
    AppDialogService.showInfoDialog(
      context,
      title: DoExamStrings.incompleteExam,
      message: DoExamStrings.unansweredText(cubit.unansweredQuestionsCount),
      actionText: AppStrings.ok,
    );
  }
}
