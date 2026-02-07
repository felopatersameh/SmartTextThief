import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../Core/Resources/app_colors.dart';
import '../../../../../Core/Resources/app_fonts.dart';
import '../../../../../Core/Utils/Models/exam_result_q_a.dart';
import '../../../../../Core/Utils/Widget/custom_text_app.dart';

class QuestionsList extends StatelessWidget {
  final List<ExamResultQA> questions;
  final bool isEditMode;
  final List<ExamResultQA>? studentAnswers;
  final Function(int, ExamResultQA) onUpdate;
  final Function(int) onDelete;

  const QuestionsList({
    super.key,
    required this.questions,
    required this.isEditMode,
    this.studentAnswers,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: questions.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final question = questions[index];
        final studentAnswer =
            studentAnswers != null && index < studentAnswers!.length
                ? studentAnswers![index]
                : null;

        return _QuestionCard(
          question: question,
          index: index,
          isEditMode: isEditMode,
          studentAnswer: studentAnswer,
          onUpdate: (updatedQuestion) => onUpdate(index, updatedQuestion),
          onDelete: () => onDelete(index),
        );
      },
    );
  }
}

// ==================== Question Card ====================
class _QuestionCard extends StatefulWidget {
  final ExamResultQA question;
  final int index;
  final bool isEditMode;
  final ExamResultQA? studentAnswer;
  final Function(ExamResultQA) onUpdate;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.isEditMode,
    this.studentAnswer,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late final TextEditingController _questionController;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.question.questionText,
    );
    _selectedAnswer = widget.question.correctAnswer;
  }

  @override
  void didUpdateWidget(covariant _QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.questionText != widget.question.questionText &&
        _questionController.text != widget.question.questionText) {
      _questionController.value = _questionController.value.copyWith(
        text: widget.question.questionText,
        selection: TextSelection.collapsed(
          offset: widget.question.questionText.length,
        ),
        composing: TextRange.empty,
      );
    }
    if (oldWidget.question.correctAnswer != widget.question.correctAnswer) {
      _selectedAnswer = widget.question.correctAnswer;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  bool _isCorrect() {
    if (widget.studentAnswer == null) return false;
    return widget.studentAnswer!.studentAnswer.trim().toLowerCase() ==
        widget.question.correctAnswer.trim().toLowerCase();
  }

  int _getScore() {
    return _isCorrect() ? 1 : 0;
  }

  void _changeCorrectAnswer(String newAnswer) {
    setState(() {
      _selectedAnswer = newAnswer;
    });
    final updatedQuestion = widget.question.copyWith(correctAnswer: newAnswer);
    widget.onUpdate(updatedQuestion);
  }

  @override
  Widget build(BuildContext context) {
    final isCorrect = _isCorrect();
    final score = _getScore();
    final options = widget.question.options;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.isEditMode
            ? AppColors.colorsBackGround2
            : (isCorrect
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.isEditMode
              ? AppColors.colorPrimary.withValues(alpha: 0.3)
              : (isCorrect ? Colors.green : Colors.red),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.colorPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: AppCustomText.generate(
                  text: "Q${widget.index + 1}",
                  textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                    color: AppColors.colorPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (!widget.isEditMode) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: AppCustomText.generate(
                    text: "Score: $score/1",
                    textStyle: AppTextStyles.bodySmallMedium.copyWith(
                      color: isCorrect ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (widget.isEditMode) ...[
                IconButton(
                  onPressed: widget.onDelete,
                  icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),

          // Question
          AppCustomText.generate(
            text: "Question:",
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.textCoolGray,
              fontSize: 11.sp,
            ),
          ),
          SizedBox(height: 6.h),
          widget.isEditMode
              ? TextField(
                  controller: _questionController,
                  maxLines: null,
                  style: AppTextStyles.bodyMediumMedium.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.colorTextFieldBackGround,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    final updatedQuestion = widget.question.copyWith(
                      questionText: value,
                    );
                    widget.onUpdate(updatedQuestion);
                  },
                )
              : AppCustomText.generate(
                  text: widget.question.questionText,
                  textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
          SizedBox(height: 12.h),

          // Options
          if (options.isNotEmpty) ...[
            AppCustomText.generate(
              text: widget.isEditMode
                  ? "Options (Tap to select correct answer):"
                  : "Options:",
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textCoolGray,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 8.h),
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isCorrectAnswer = option == _selectedAnswer;
              final isStudentAnswer =
                  widget.studentAnswer?.studentAnswer == option;

              Color backgroundColor;
              Color borderColor;
              Color textColor;

              if (widget.isEditMode) {
                // Edit Mode
                backgroundColor = isCorrectAnswer
                    ? Colors.green.withValues(alpha: 0.2)
                    : AppColors.colorTextFieldBackGround;
                borderColor = isCorrectAnswer
                    ? Colors.green
                    : AppColors.colorPrimary.withValues(alpha: 0.3);
                textColor =
                    isCorrectAnswer ? Colors.green : AppColors.textWhite;
              } else {
                // View Results Mode
                if (isCorrectAnswer && isStudentAnswer) {
                  // Correct answer and student selected it
                  backgroundColor = Colors.green.withValues(alpha: 0.2);
                  borderColor = Colors.green;
                  textColor = Colors.green;
                } else if (isCorrectAnswer) {
                  // Correct answer but student didn't select it
                  backgroundColor = Colors.green.withValues(alpha: 0.1);
                  borderColor = Colors.green;
                  textColor = Colors.green;
                } else if (isStudentAnswer) {
                  // Wrong answer but student selected it
                  backgroundColor = Colors.red.withValues(alpha: 0.2);
                  borderColor = Colors.red;
                  textColor = Colors.red;
                } else {
                  // Normal option
                  backgroundColor = AppColors.colorTextFieldBackGround;
                  borderColor = AppColors.colorPrimary.withValues(alpha: 0.3);
                  textColor = AppColors.textWhite;
                }
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: widget.isEditMode
                      ? () => _changeCorrectAnswer(option)
                      : null,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCorrectAnswer || isStudentAnswer
                                ? (isCorrectAnswer ? Colors.green : Colors.red)
                                : Colors.transparent,
                            border: Border.all(
                              color: isCorrectAnswer || isStudentAnswer
                                  ? (isCorrectAnswer
                                      ? Colors.green
                                      : Colors.red)
                                  : AppColors.textCoolGray,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: AppCustomText.generate(
                              text: String.fromCharCode(
                                65 + index,
                              ), // A, B, C, D
                              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                                color: isCorrectAnswer || isStudentAnswer
                                    ? Colors.white
                                    : AppColors.textCoolGray,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: AppCustomText.generate(
                            text: option,
                            textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                              color: textColor,
                              fontWeight: isCorrectAnswer || isStudentAnswer
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isCorrectAnswer && !widget.isEditMode) ...[
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20.sp,
                          ),
                        ],
                        if (!isCorrectAnswer &&
                            isStudentAnswer &&
                            !widget.isEditMode) ...[
                          Icon(Icons.cancel, color: Colors.red, size: 20.sp),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],

          // For questions without options (Text Answer)
          if (options.isEmpty) ...[
            AppCustomText.generate(
              text: "Correct Answer:",
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.textCoolGray,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: AppCustomText.generate(
                text: widget.question.correctAnswer,
                textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                  color: Colors.green,
                ),
              ),
            ),

            // Student Answer (if viewing results)
            if (!widget.isEditMode && widget.studentAnswer != null) ...[
              SizedBox(height: 12.h),
              AppCustomText.generate(
                text: "Student Answer:",
                textStyle: AppTextStyles.bodySmallMedium.copyWith(
                  color: AppColors.textCoolGray,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: AppCustomText.generate(
                  text: widget.studentAnswer!.studentAnswer,
                  textStyle: AppTextStyles.bodyMediumMedium.copyWith(
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
