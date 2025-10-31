import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../Config/setting.dart';
import '../../../../Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/exam_result_q_a.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_fonts.dart';
import '../../../../Core/Utils/Widget/custom_text_app.dart';
import '../../cubit/do/do_exam_cubit.dart';

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Finish exam if not already finished (handles crashes, unexpected exits)
    if (_cubit != null && !_cubit!.state.isExamFinished) {
      _cubit!.forceFinishExam();
    }

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

    // If app goes to background or becomes inactive and exam is not finished
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (_cubit != null && !_cubit!.state.isExamFinished) {
        // Force finish exam when app goes to background (handles app crash, network loss, etc)
        _cubit!.forceFinishExam();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _cubit = DoExamCubit()..init(widget.model);
        return _cubit!;
      },
      child: BlocConsumer<DoExamCubit, DoExamState>(
        listener: (context, state) {
          if (state.isExamFinished) {
            // Handle exam finish - show result or navigate back
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Exam finished!')));
          }
        },
        builder: (context, state) {
          final cubit = BlocProvider.of<DoExamCubit>(context);
          final questions = widget.model.examStatic.examResultQA;

          // Safety check: handle empty questions
          if (questions.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: AppCustomText.generate(
                  text: 'Error',
                  textStyle: AppTextStyles.h5Bold,
                ),
              ),
              body: Center(
                child: AppCustomText.generate(
                  text: 'No questions available in this exam',
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
                  : Column(
                      children: [
                        _buildQuestionTimeline(questions, state, cubit),
                        _buildQuestionCard(currentQuestion, state, cubit),
                        _buildNavigationButtons(state, cubit),
                      ],
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
            ? Colors.red.withValues(alpha: 0.2)
            : AppColors.colorPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: duration.inSeconds < 60 ? Colors.red : AppColors.colorPrimary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: duration.inSeconds < 60
                ? Colors.red
                : AppColors.colorPrimary,
          ),
          const SizedBox(width: 8),
          AppCustomText.generate(
            text:
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            textStyle: AppTextStyles.h6Bold.copyWith(
              color: duration.inSeconds < 60
                  ? Colors.red
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
              text:
                  'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
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
      height: 80,
      padding: const EdgeInsets.all(16),
      color: AppColors.colorsBackGround2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final isAnswered = state.userAnswers.containsKey(question.questionId);
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
                    ? Colors.green.withValues(alpha: 0.3)
                    : AppColors.colorBackgroundCardProjects,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.colorPrimary
                      : isAnswered
                      ? Colors.green
                      : AppColors.colorUnActiveIcons,
                  width: isCurrent ? 3 : 1,
                ),
              ),
              child: Center(
                child: AppCustomText.generate(
                  text: '${index + 1}',
                  textStyle: AppTextStyles.bodyMediumBold.copyWith(
                    color: isCurrent || isAnswered
                        ? Colors.white
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
              textStyle: AppTextStyles.h6Bold,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
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
                            ? AppColors.colorPrimary.withValues(alpha: 0.2)
                            : AppColors.colorBackgroundCardProjects,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.colorPrimary
                              : Colors.transparent,
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
                                  : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppCustomText.generate(
                              text: option,
                              textStyle: AppTextStyles.bodyLargeMedium.copyWith(
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

  Widget _buildNavigationButtons(DoExamState state, DoExamCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.colorsBackGround2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorBackgroundCardProjects,
                foregroundColor: AppColors.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (state.currentQuestionIndex == state.totalQuestions - 1)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final success = await cubit.submitExam();
                  if (!success && mounted) {
                    _showValidationDialog(context, cubit);
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Submit Exam'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorsBackGround2,
        title: AppCustomText.generate(
          text: 'Exit Exam?',
          textStyle: AppTextStyles.h6Bold.copyWith(color: Colors.orange),
        ),
        content: AppCustomText.generate(
          text:
              'Are you sure you want to exit the exam? Your progress will be saved.',
          textStyle: AppTextStyles.bodyMediumMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AppCustomText.generate(
              text: 'Cancel',
              textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                color: AppColors.colorPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: AppCustomText.generate(
              text: 'Exit',
              textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showValidationDialog(BuildContext context, DoExamCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.colorsBackGround2,
        title: AppCustomText.generate(
          text: 'Incomplete Exam',
          textStyle: AppTextStyles.h6Bold.copyWith(color: Colors.orange),
        ),
        content: AppCustomText.generate(
          text:
              'You have ${cubit.unansweredQuestionsCount} unanswered question(s).\n\nPlease answer all questions before submitting.',
          textStyle: AppTextStyles.bodyMediumMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: AppCustomText.generate(
              text: 'OK',
              textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                color: AppColors.colorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
