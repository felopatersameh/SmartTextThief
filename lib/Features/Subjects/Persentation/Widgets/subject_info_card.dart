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
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            Divider(
              color: Colors.white.withValues(alpha: 0.08),
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
                    label: 'Instructor',
                    value: subjectModel.subjectTeacher.teacherName,
                  ),

                  InfoRow(
                    icon: AppIcons.email,
                    label: 'Email',
                    value: subjectModel.subjectTeacher.teacherEmail,
                  ),

                  SizedBox(height: 4.h),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: AppIcons.students,
                          label: 'Students',
                          value: '${subjectModel.subjectEmailSts.length}',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildStatCard(
                          icon: AppIcons.exam,
                          label: 'Exams',
                          value: '$examLength',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildStatCard(
                          icon: AppIcons.calendar,
                          label: 'Created',
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
          color: Colors.white,
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
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.colorPrimary, size: 18.sp),
          SizedBox(height: 4.h),
          AppCustomText.generate(
            text: value,
            textStyle: AppTextStyles.bodyMediumBold.copyWith(
              color: Colors.white,
              fontSize: 14.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          AppCustomText.generate(
            text: label,
            textStyle: AppTextStyles.bodySmallMedium.copyWith(
              color: Colors.grey.shade400,
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
        color: Colors.white.withValues(alpha: 0.05),
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
                  text: 'Subject Code',
                  textStyle: AppTextStyles.bodySmallMedium.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 10.sp,
                  ),
                ),
                AppCustomText.generate(
                  text: subjectModel.subjectCode,
                  textStyle: AppTextStyles.bodyMediumBold.copyWith(
                    color: Colors.white,
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
                  color: Colors.white.withValues(alpha: 0.1),
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
    final color = isOpen ? Colors.green : Colors.red;
    final text = isOpen ? 'Open for joining' : 'Closed for joining';
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
            isOpen ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
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
                      subjectModel.subjectIsOpen ? 'Close Subject' : 'Open Subject',
                  onTap: onToggleOpen,
                  background: Colors.amber.withValues(alpha: 0.18),
                  borderColor: Colors.amber.withValues(alpha: 0.5),
                  textColor: Colors.amber.shade300,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildActionButton(
                  title: 'Delete Subject',
                  onTap: onDeleteSubject,
                  background: Colors.red.withValues(alpha: 0.18),
                  borderColor: Colors.red.withValues(alpha: 0.5),
                  textColor: Colors.red.shade300,
                ),
              ),
            ],
          ),
          if (onOpenDashboard != null) ...[
            SizedBox(height: 8.h),
            _buildActionButton(
              title: 'Subject Dashboard',
              onTap: onOpenDashboard,
              background: AppColors.colorPrimary.withValues(alpha: 0.18),
              borderColor: AppColors.colorPrimary.withValues(alpha: 0.5),
              textColor: AppColors.colorPrimary,
            ),
          
        ],
    ]);
      
    }

    return _buildActionButton(
      title: 'Leave Subject',
      onTap: onLeaveSubject,
      background: Colors.red.withValues(alpha: 0.18),
      borderColor: Colors.red.withValues(alpha: 0.5),
      textColor: Colors.red.shade300,
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
            Icon(Icons.check_circle, color: Colors.white, size: 18.sp),
            SizedBox(width: 8.w),
            Text('Code copied', style: TextStyle(fontSize: 13.sp)),
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
