import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'info_row.dart';

class SubjectInfoCard extends StatelessWidget {
  final SubjectModel subjectModel;
  final int? examLength;
  final VoidCallback? onToggleOpen;
  final VoidCallback? onDeleteSubject;
  final VoidCallback? onLeaveSubject;
  final VoidCallback? onOpenDashboard;

  const SubjectInfoCard({
    super.key,
    required this.subjectModel,
    required this.examLength,
    this.onToggleOpen,
    this.onDeleteSubject,
    this.onLeaveSubject,
    this.onOpenDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.colorPrimary.withValues(alpha: 0.15),
              AppColors.colorPrimary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: AppColors.textWhite.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            Divider(
              color: AppColors.textWhite.withValues(alpha: 0.08),
              thickness: 1,
              height: 1,
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                children: [
                  // Instructor Info
                  InfoRow(
                    icon: AppIcons.profile,
                    label: SubjectStrings.instructor,
                    value: subjectModel.subjectTeacher.teacherName,
                  ),

                  InfoRow(
                    icon: AppIcons.email,
                    label: SubjectStrings.email,
                    value: subjectModel.subjectTeacher.teacherEmail,
                  ),

                  SizedBox(height: 4.h),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: AppIcons.students,
                          label: SubjectStrings.students,
                          value: '${0}',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildStatCard(
                          icon: AppIcons.exam,
                          label: SubjectStrings.exams,
                          value: '$examLength',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildStatCard(
                          icon: AppIcons.calendar,
                          label: SubjectStrings.created,
                          value: subjectModel.createdAt,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  _buildStatusSection(),

                  SizedBox(height: 12.h),

                  // Code with Copy
                  _buildCodeSection(),

                  if (_hasActions) ...[
                    SizedBox(height: 12.h),
                    _buildActionsSection(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: AppCustomText.generate(
        text: subjectModel.subjectName,
        textStyle: AppTextStyles.bodyLargeBold.copyWith(
          color: AppColors.textWhite,
          fontSize: 16.sp,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.textWhite.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 18.sp),
          SizedBox(height: 4.h),
          AppCustomText.generate(
            text: value,
            textStyle: AppTextStyles.bodyMediumBold.copyWith(
              color: AppColors.textWhite,
              fontSize: 14.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          AppCustomText.generate(
            text: label,
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: AppColors.grey400,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(AppIcons.code, color: AppColors.colorPrimary, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCustomText.generate(
                  text: SubjectStrings.subjectCode,
                  textStyle: AppTextStyles.bodySmallMedium.copyWith(
                    color: AppColors.grey400,
                    fontSize: 10.sp,
                  ),
                ),
                AppCustomText.generate(
                  text: subjectModel.subjectCode,
                  textStyle: AppTextStyles.bodyMediumBold.copyWith(
                    color: AppColors.textWhite,
                    fontSize: 14.sp,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => InkWell(
              onTap: () => _copyCode(context),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  AppIcons.copy,
                  color: AppColors.colorPrimary,
                  size: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasActions =>
      onToggleOpen != null ||
      onDeleteSubject != null ||
      onLeaveSubject != null ||
      onOpenDashboard != null;

  Widget _buildStatusSection() {
    final isOpen = subjectModel.subjectIsOpen;
    final color = isOpen ? AppColors.success : AppColors.danger;
    final text = isOpen
        ? SubjectStrings.openForJoining
        : SubjectStrings.closedForJoining;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? AppIcons.lockOpenRounded : AppIcons.lockOutlineRounded,
            color: color,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          AppCustomText.generate(
            text: text,
            textStyle: AppTextStyles.bodySmallBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    if (subjectModel.isME) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  title:
                      subjectModel.subjectIsOpen
                          ? SubjectStrings.closeSubject
                          : SubjectStrings.openSubject,
                  onTap: onToggleOpen,
                  background: AppColors.amber.withValues(alpha: 0.18),
                  borderColor: AppColors.amber.withValues(alpha: 0.5),
                  textColor: AppColors.warningDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  title: SubjectStrings.deleteSubject,
                  onTap: onDeleteSubject,
                  background: AppColors.danger.withValues(alpha: 0.18),
                  borderColor: AppColors.danger.withValues(alpha: 0.5),
                  textColor: AppColors.dangerSoft,
                ),
              ),
            ],
          ),
          if (onOpenDashboard != null) ...[
            SizedBox(height: 8.h),
            _buildActionButton(
              title: SubjectStrings.subjectDashboard,
              onTap: onOpenDashboard,
              background: AppColors.colorPrimary.withValues(alpha: 0.18),
              borderColor: AppColors.colorPrimary.withValues(alpha: 0.5),
              textColor: AppColors.colorPrimary,
            ),
          
        ],
    ]);
      
    }

    return _buildActionButton(
      title: SubjectStrings.leaveSubject,
      onTap: onLeaveSubject,
      background: AppColors.danger.withValues(alpha: 0.18),
      borderColor: AppColors.danger.withValues(alpha: 0.5),
      textColor: AppColors.dangerSoft,
    );
  }

  Widget _buildActionButton({
    required String title,
    required VoidCallback? onTap,
    required Color background,
    required Color borderColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 11.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: AppCustomText.generate(
            text: title,
            textStyle: AppTextStyles.bodySmallBold.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: subjectModel.subjectCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.checkCircle, color: AppColors.textWhite, size: 18.sp),
            SizedBox(width: 8.w),
            Text(SubjectStrings.codeCopied, style: TextStyle(fontSize: 13.sp)),
          ],
        ),
        backgroundColor: AppColors.colorPrimary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }
}
