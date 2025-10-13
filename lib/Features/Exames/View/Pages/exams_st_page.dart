import 'package:flutter/material.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Features/Exames/View/Widgets/exam_card.dart';
import 'package:smart_text_thief/Features/Exames/View/Widgets/exams_header_card.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';
import 'package:smart_text_thief/Core/Resources/app_icons.dart';
import 'package:smart_text_thief/Core/Utils/Widget/TextField/build_text_field.dart';
import 'package:smart_text_thief/Core/Resources/app_fonts.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Core/Utils/show_message_snack_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamsStudentPage extends StatefulWidget {
  const ExamsStudentPage({super.key});

  @override
  State<ExamsStudentPage> createState() => _ExamsStudentPageState();
}

class _ExamsStudentPageState extends State<ExamsStudentPage> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _showJoinSubjectDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.colorPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        AppIcons.school,
                        color: AppColors.colorPrimary,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppCustomtext(
                        text: 'Join Subject',
                        textStyle: AppTextStyles.bodyLargeBold.copyWith(
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Subject Code Field
                AppCustomtext(
                  text: 'Subject Code',
                  textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  controller: _codeController,
                  hint: 'Enter subject code',
                  prefixIcon: Icon(AppIcons.quiz),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter subject code';
                    }
                    return null;
                  },
                  keyboard: TextInputType.text,
                ),
                SizedBox(height: 24.h),

                // Join Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _joinSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: AppCustomtext(
                      text: 'Join Subject',
                      textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinSubject() async {
    if (_formKey.currentState!.validate()) {
      final code = _codeController.text.trim();

      // Show loading message
      await showMessageSnackBar(
        context,
        title: 'Joining subject...',
        type: MessageType.loading,
        onLoading: () async {

          if (code == 'TEST123') {
            if (!mounted) return;
            showMessageSnackBar(
              context,
              title: 'Successfully joined the subject!',
              type: MessageType.success,
            );
            Navigator.of(context).pop();
          } else {
            if (!mounted) return;
            showMessageSnackBar(
              context,
              title: 'Invalid subject code. Please try again.',
              type: MessageType.error,
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: AppConfig.physicsCustomScrollView,
        shrinkWrap: true,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ExamsHeaderCard(),
            ),
          ),
          SliverAnimatedList(
            itemBuilder: (context, index, animation) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ExamCard(
                title: 'General Exam',
                date: '2023-11-20',
                type: 'Essay Questions',
              ),
            ),
            initialItemCount: 5,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showJoinSubjectDialog,
        backgroundColor: AppColors.colorPrimary,
        child: AppIcons.add,
      ),
    );
  }
}
