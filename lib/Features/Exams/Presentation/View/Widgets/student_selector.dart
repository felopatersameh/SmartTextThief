import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Features/Exams/shared/Enums/student_result_level.dart';
import 'package:smart_text_thief/Features/Exams/shared/Models/Results/exam_result_model.dart';

class StudentSelector extends StatelessWidget {
  const StudentSelector({
    super.key,
    required this.examResults,
    required this.selectedEmail,
    required this.onSelect,
  });

  final List<ExamResultModel> examResults;
  final String? selectedEmail;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = examResults.cast<ExamResultModel?>().firstWhere(
          (item) => item?.student.email == (selectedEmail ?? ''),
          orElse: () => null,
        );
    final selectedLabel = selected == null
        ? 'No Selection'
        : _displayStudentIdentity(selected.student.name, selected.student.email);

    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => _showStudentsBottomSheet(context),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.colorTextFieldBackGround,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.colorPrimary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppCustomText.generate(
                  text: '${ViewExamStrings.selectStudent}: $selectedLabel',
                  textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              Icon(
                AppIcons.expandMore,
                color: AppColors.colorPrimary,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStudentsBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.colorsBackGround2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                  child: AppCustomText.generate(
                    text: ViewExamStrings.selectStudent,
                    textStyle: AppTextStyles.h6SemiBold.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                Divider(
                  color: AppColors.colorPrimary.withValues(alpha: 0.3),
                  height: 1,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(12.w),
                    children: [
                      _buildNoSelectionTile(context),
                      ...examResults
                          .map((result) => _buildStudentTile(context, result)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoSelectionTile(BuildContext context) {
    final isSelected = (selectedEmail ?? '').trim().isEmpty;
    return ListTile(
      onTap: () {
        onSelect('');
        Navigator.of(context).pop();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      tileColor: isSelected
          ? AppColors.colorPrimary.withValues(alpha: 0.2)
          : AppColors.colorTextFieldBackGround,
      title: AppCustomText.generate(
        text: 'No Selection',
        textStyle: AppTextStyles.bodyMediumMedium.copyWith(
          color: AppColors.textWhite,
        ),
      ),
      trailing:
          isSelected ? Icon(AppIcons.checkCircle, color: AppColors.colorPrimary) : null,
    );
  }

  Widget _buildStudentTile(BuildContext context, ExamResultModel result) {
    final studentEmail = result.student.email;
    final isSelected = selectedEmail == studentEmail;
    final level = StudentResultLevel.fromScore(
      degree: result.score.degree,
      total: result.score.total,
    );

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: ListTile(
        onTap: () {
          onSelect(studentEmail);
          Navigator.of(context).pop();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        tileColor: isSelected
            ? AppColors.colorPrimary.withValues(alpha: 0.2)
            : AppColors.colorTextFieldBackGround,
        title: AppCustomText.generate(
          text: _displayStudentIdentity(result.student.name, studentEmail),
          textStyle: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.textWhite,
          ),
        ),
        subtitle: AppCustomText.generate(
          text:
              'Score: ${result.score.degree}/${result.score.total}  |  Level: ${level.label}',
          textStyle: AppTextStyles.bodySmallMedium.copyWith(
            color: AppColors.textCoolGray,
          ),
        ),
        trailing: isSelected
            ? Icon(AppIcons.checkCircle, color: AppColors.colorPrimary)
            : null,
      ),
    );
  }

  String _displayStudentIdentity(String name, String email) {
    final short = _shortName(name);
    if (short.isEmpty) return email;
    return '$short - $email';
  }

  String _shortName(String fullName) {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    final takeCount = words.length >= 3 ? 3 : (words.length >= 2 ? 2 : 1);
    return words.take(takeCount).join(' ');
  }
}

