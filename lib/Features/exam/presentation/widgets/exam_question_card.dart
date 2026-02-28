import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Features/exam/presentation/widgets/exam_question_view_model.dart';
import 'package:smart_text_thief/Features/exam/domain/enums/exam_mode.dart';

class ExamQuestionCard extends StatefulWidget {
  const ExamQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.mode,
    this.currentAnswer,
    this.onAnswerChanged,
    this.onQuestionChanged,
    this.onCorrectAnswerChanged,
    this.onDelete,
    this.allowQuestionEditing = false,
  });

  final int index;
  final ExamQuestionViewModel question;
  final ExamMode mode;
  final String? currentAnswer;
  final ValueChanged<String>? onAnswerChanged;
  final ValueChanged<String>? onQuestionChanged;
  final ValueChanged<String>? onCorrectAnswerChanged;
  final VoidCallback? onDelete;
  final bool allowQuestionEditing;

  @override
  State<ExamQuestionCard> createState() => _ExamQuestionCardState();
}

class _ExamQuestionCardState extends State<ExamQuestionCard> {
  late final TextEditingController _questionController;
  String? _selectedCorrectAnswer;

  bool get _isResultMode =>
      widget.mode == ExamMode.studentResult ||
      widget.mode == ExamMode.teacherResult;

  bool get _isSolvingMode => widget.mode == ExamMode.solving;

  bool get _isEditablePreview =>
      widget.mode == ExamMode.preview && widget.allowQuestionEditing;

  String get _effectiveAnswer {
    if (_isSolvingMode) return widget.currentAnswer ?? '';
    return widget.question.studentAnswer;
  }

  bool get _hasStudentAnswer => _effectiveAnswer.trim().isNotEmpty;

  bool get _isCorrectResult => widget.question.isCorrect(_effectiveAnswer);

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.text);
    _selectedCorrectAnswer = widget.question.correctAnswer;
  }

  @override
  void didUpdateWidget(covariant ExamQuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.text != widget.question.text &&
        _questionController.text != widget.question.text) {
      _questionController.value = _questionController.value.copyWith(
        text: widget.question.text,
        selection: TextSelection.collapsed(offset: widget.question.text.length),
        composing: TextRange.empty,
      );
    }
    if (oldWidget.question.correctAnswer != widget.question.correctAnswer) {
      _selectedCorrectAnswer = widget.question.correctAnswer;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.question.options;
    final hasOptions = options.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor(), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),
          _buildQuestionText(),
          SizedBox(height: 12.h),
          if (hasOptions) ...[
            _buildSectionLabel(
              _isEditablePreview
                  ? ViewExamStrings.optionsEditMode
                  : ViewExamStrings.options,
            ),
            SizedBox(height: 8.h),
            ...options.asMap().entries.map((entry) {
              return _buildOptionItem(
                optionIndex: entry.key,
                option: entry.value,
              );
            }),
          ] else ...[
            _buildShortAnswerSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final scoreValue = _isCorrectResult ? '1/1' : '0/1';

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.colorPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: AppCustomText.generate(
            text: DashboardStrings.questionLabel(widget.index),
            textStyle: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.colorPrimary,
            ),
          ),
        ),
        const Spacer(),
        if (_isResultMode && _hasStudentAnswer)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _isCorrectResult
                  ? AppColors.green.withValues(alpha: 0.2)
                  : AppColors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppCustomText.generate(
              text: '${ViewExamStrings.score}: $scoreValue',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: _isCorrectResult ? AppColors.green : AppColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_isResultMode && !_hasStudentAnswer)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: AppCustomText.generate(
              text: 'Pending',
              textStyle: AppTextStyles.bodySmallMedium.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        if (_isEditablePreview && widget.onDelete != null)
          IconButton(
            onPressed: widget.onDelete,
            icon: Icon(
              AppIcons.delete,
              color: AppColors.red,
              size: 20.sp,
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(ViewExamStrings.questionLabel),
        SizedBox(height: 6.h),
        if (_isEditablePreview)
          TextField(
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
            onChanged: widget.onQuestionChanged,
          )
        else
          AppCustomText.generate(
            text: widget.question.text,
            textStyle: AppTextStyles.bodyMediumMedium.copyWith(
              color: AppColors.textWhite,
            ),
          ),
      ],
    );
  }

  Widget _buildOptionItem({
    required int optionIndex,
    required String option,
  }) {
    // Never highlight the correct answer while the student is solving.
    final isCorrectAnswer = !_isSolvingMode && option == _selectedCorrectAnswer;
    final isStudentAnswer = _effectiveAnswer == option;
    final isSolvingSelected = _isSolvingMode && (widget.currentAnswer == option);

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (_isSolvingMode) {
      backgroundColor = isSolvingSelected
          ? AppColors.colorPrimary.withValues(alpha: 0.2)
          : AppColors.colorTextFieldBackGround;
      borderColor = isSolvingSelected
          ? AppColors.colorPrimary
          : AppColors.colorPrimary.withValues(alpha: 0.3);
      textColor = isSolvingSelected ? AppColors.textWhite : AppColors.textCoolGray;
    } else if (_isResultMode) {
      if (isCorrectAnswer && isStudentAnswer) {
        backgroundColor = AppColors.green.withValues(alpha: 0.2);
        borderColor = AppColors.green;
        textColor = AppColors.green;
      } else if (isCorrectAnswer) {
        backgroundColor = AppColors.green.withValues(alpha: 0.1);
        borderColor = AppColors.green;
        textColor = AppColors.green;
      } else if (isStudentAnswer) {
        backgroundColor = AppColors.red.withValues(alpha: 0.2);
        borderColor = AppColors.red;
        textColor = AppColors.red;
      } else {
        backgroundColor = AppColors.colorTextFieldBackGround;
        borderColor = AppColors.colorPrimary.withValues(alpha: 0.3);
        textColor = AppColors.textWhite;
      }
    } else {
      backgroundColor = isCorrectAnswer
          ? AppColors.green.withValues(alpha: 0.2)
          : AppColors.colorTextFieldBackGround;
      borderColor = isCorrectAnswer
          ? AppColors.green
          : AppColors.colorPrimary.withValues(alpha: 0.3);
      textColor = isCorrectAnswer ? AppColors.green : AppColors.textWhite;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GestureDetector(
        onTap: () {
          if (_isSolvingMode) {
            widget.onAnswerChanged?.call(option);
            return;
          }
          if (_isEditablePreview) {
            setState(() {
              _selectedCorrectAnswer = option;
            });
            widget.onCorrectAnswerChanged?.call(option);
          }
        },
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
                  color: (isCorrectAnswer || isStudentAnswer || isSolvingSelected)
                      ? (isCorrectAnswer ? AppColors.green : AppColors.colorPrimary)
                      : AppColors.transparent,
                  border: Border.all(
                    color: (isCorrectAnswer || isStudentAnswer || isSolvingSelected)
                        ? (isCorrectAnswer
                            ? AppColors.green
                            : AppColors.colorPrimary)
                        : AppColors.textCoolGray,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AppCustomText.generate(
                    text: String.fromCharCode(65 + optionIndex),
                    textStyle: AppTextStyles.bodySmallMedium.copyWith(
                      color:
                          (isCorrectAnswer || isStudentAnswer || isSolvingSelected)
                              ? AppColors.textWhite
                              : AppColors.textCoolGray,
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
                    fontWeight: (isCorrectAnswer ||
                            isStudentAnswer ||
                            isSolvingSelected)
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortAnswerSection() {
    if (_isSolvingMode) {
      return TextFormField(
        key: ValueKey('${widget.mode.name}_${widget.question.id}'),
        initialValue: widget.currentAnswer ?? '',
        minLines: 6,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onChanged: (value) => widget.onAnswerChanged?.call(value),
        enableInteractiveSelection: false,
        contextMenuBuilder: (context, editableTextState) {
          return const SizedBox.shrink();
        },
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
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    final studentAnswer = _effectiveAnswer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(ViewExamStrings.correctAnswer),
        SizedBox(height: 6.h),
        _buildAnswerBox(
          text: widget.question.correctAnswer,
          color: AppColors.green,
        ),
        if (_isResultMode && _hasStudentAnswer) ...[
          SizedBox(height: 12.h),
          _buildSectionLabel(ViewExamStrings.studentAnswer),
          SizedBox(height: 6.h),
          _buildAnswerBox(
            text: studentAnswer,
            color: _isCorrectResult ? AppColors.green : AppColors.red,
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerBox({required String text, required Color color}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color),
      ),
      child: AppCustomText.generate(
        text: text,
        textStyle: AppTextStyles.bodyMediumMedium.copyWith(color: color),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return AppCustomText.generate(
      text: text,
      textStyle: AppTextStyles.bodySmallMedium.copyWith(
        color: AppColors.textCoolGray,
      ),
    );
  }

  Color _backgroundColor() {
    if (!_isResultMode) return AppColors.colorsBackGround2;
    if (!_hasStudentAnswer) return AppColors.colorsBackGround2;
    return _isCorrectResult
        ? AppColors.green.withValues(alpha: 0.1)
        : AppColors.red.withValues(alpha: 0.1);
  }

  Color _borderColor() {
    if (!_isResultMode) return AppColors.colorPrimary.withValues(alpha: 0.3);
    if (!_hasStudentAnswer) return AppColors.colorPrimary.withValues(alpha: 0.3);
    return _isCorrectResult ? AppColors.green : AppColors.red;
  }
}

