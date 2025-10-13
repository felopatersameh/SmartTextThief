import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Resources/app_colors.dart';
import '../../Resources/app_fonts.dart';
import '../../Resources/app_icons.dart';
import 'custom_text_app.dart';
import 'TextField/build_text_field.dart';
import '../show_message_snack_bar.dart';

class AddSubjectDialog extends StatefulWidget {
  final Function(String name)? onSubmit;
  final String? title;
  final String? submitButtonText;

  const AddSubjectDialog({
    super.key,
    this.onSubmit,
    this.title,
    this.submitButtonText,
  });

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();

      // Show loading message
      await showMessageSnackBar(
        context,
        title: 'Creating subject...',
        type: MessageType.loading,
        onLoading: () async {
          if (widget.onSubmit != null) {
          await widget.onSubmit!(name);
          }

        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = AppColors.colorPrimary;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.colorsBackGround2,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: primary.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: AppColors.colorTextFieldBackGround.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient background
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: 0.15),
                      primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(AppIcons.school, color: primary, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: AppCustomtext(
                        text: widget.title ?? 'Add New Subject',
                        textStyle: AppTextStyles.bodyLargeBold.copyWith(
                          color: AppColors.textWhite,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.colorTextFieldBackGround.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.colorUnActiveIcons.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: AppColors.textCoolGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Subject Name Field
              AppCustomtext(
                text: 'Subject Name',
                textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                  color: AppColors.textWhite,
                ),
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _nameController,
                hint: 'Enter subject name',
                prefixIcon: Icon(AppIcons.school, color: primary),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter subject name';
                  }
                  return null;
                },
                keyboard: TextInputType.name,
              ),
              SizedBox(height: 32.h),

              // Submit Button with gradient
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: AppCustomtext(
                    text: widget.submitButtonText ?? 'Add Subject',
                    textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                      color: AppColors.textWhite,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
