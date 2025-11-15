import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/Core/Resources/resources.dart';
import '/Core/Utils/Models/subject_model.dart';
import '/Core/Utils/Widget/custom_text_app.dart';
import 'info_row.dart';

class SubjectInfoCard extends StatelessWidget {
  final SubjectModel subjectModel;
  final int? examLength;
  const SubjectInfoCard({
    super.key,
    required this.subjectModel,
    required this.examLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.colorPrimary.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(14.r),
        ),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: InfoRow(
                    icon: AppIcons.calendar,
                    label: 'Created on: ${subjectModel.createdAt}',
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(
                        icon: AppIcons.profile,
                        label:
                            'Teacher: ${subjectModel.subjectTeacher.teacherName}',
                      ),

                      InfoRow(
                        icon: AppIcons.email,
                        label:
                            'Email: ${subjectModel.subjectTeacher.teacherEmail}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: InfoRow(
                    icon: AppIcons.students,
                    label: 'Students: ${subjectModel.subjectEmailSts.length}',
                  ),
                ),
                Expanded(
                  child: InfoRow(
                    icon: AppIcons.exam,
                    label: 'Exams: $examLength',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                InfoRow(
                  icon: AppIcons.code,
                  label: 'code: ${subjectModel.subjectCode}',
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () =>
                      Clipboard.setData(
                        ClipboardData(text: subjectModel.subjectCode),
                      ).then((_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("subject Code copied")),
                        );
                      }),
                  child: Icon(AppIcons.copy, size: 20.w),
                ),
              ],
            ),

            SizedBox(height: 20.h),
            if(subjectModel.isME)
            _buildShowGraphButton(),
          ],
        ),
      ),
    );
  }

  Row _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppCustomText.generate(
            text: subjectModel.subjectName,
            textStyle: AppTextStyles.bodyLargeBold.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Icon(AppIcons.share, color: Colors.grey.shade600, size: 18.sp),
        ),
        SizedBox(width: 10.w),
      ],
    );
  }

  Widget _buildShowGraphButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: AppColors.colorPrimary.withValues(alpha: 0.86),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        icon: Icon(AppIcons.chart, size: 18.sp, color: Colors.white),
        label: Text(
          "Show Graph",
          style: AppTextStyles.bodyMediumBold.copyWith(
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
        onPressed: () {},
      ),
    );
  }
}
