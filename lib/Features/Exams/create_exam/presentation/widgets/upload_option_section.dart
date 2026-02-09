// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Enums/upload_option.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/data/models/information_file_model.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/cubit/create_exam_cubit.dart';

class UploadOptionSection extends StatelessWidget {
  const UploadOptionSection({super.key, required this.state});
  final CreateExamState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateExamCubit>();
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.colorPrimary, width: 1.2),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioListTile<UploadOption>(
            value: UploadOption.file,
            groupValue: state.uploadOption,
            activeColor: AppColors.colorPrimary,
            contentPadding: EdgeInsets.zero,
            title: AppCustomText.generate(
              text: CreateExamStrings.uploadFiles,
              textStyle: AppTextStyles.bodyMediumBold.copyWith(
                color: AppColors.colorPrimary,
              ),
            ),
            onChanged: (val) => cubit.changeUploadOption(val!),
          ),
          if (state.uploadOption == UploadOption.file) ...[
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 6.h),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    icon: const Icon(
                      AppIcons.uploadFile,
                      color: AppColors.textWhite,
                    ),
                    label: const Text(CreateExamStrings.chooseFiles),
                    onPressed: () => cubit.pickFiles(context),
                  ),
                  if (state.uploadedFiles.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    TextButton.icon(
                      onPressed: () => cubit.clearAllFiles(),
                      icon: const Icon(AppIcons.deleteOutline, size: 18),
                      label: const Text(CreateExamStrings.clearAll),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (state.uploadedFiles.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 16.w, top: 8.h, right: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCustomText.generate(
                      text: CreateExamStrings.uploadedFilesCount(
                        state.uploadedFiles.length,
                      ),
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.colorPrimary.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...List.generate(
                      state.uploadedFiles.length,
                      (index) => _FileItemCard(
                        file: state.uploadedFiles[index],
                        index: index,
                        onRemove: () => cubit.removeFile(index),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          Divider(
            color: AppColors.colorPrimary.withValues(alpha: 0.4),
            height: 12.h,
          ),
          RadioListTile<UploadOption>(
            value: UploadOption.text,
            groupValue: state.uploadOption,
            activeColor: AppColors.colorPrimary,
            contentPadding: EdgeInsets.zero,
            title: AppCustomText.generate(
              text: CreateExamStrings.enterTextManually,
              textStyle: AppTextStyles.bodyMediumBold.copyWith(
                color: AppColors.colorPrimary,
              ),
            ),
            onChanged: (val) => cubit.changeUploadOption(val!),
          ),
          if (state.uploadOption == UploadOption.text)
            Padding(
              padding: EdgeInsets.only(left: 16.w, top: 6.h),
              child: TextFormField(
                initialValue: state.uploadText,
                onChanged: cubit.changeTextUpload,
                minLines: 3,
                maxLines: 6,
                style: AppTextStyles.bodyMediumMedium,
                decoration: InputDecoration(
                  hintText: CreateExamStrings.enterOrPasteExamContent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: AppColors.colorPrimary,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FileItemCard extends StatelessWidget {
  final InformationFileModel file;
  final int index;
  final VoidCallback onRemove;

  const _FileItemCard({
    required this.file,
    required this.index,
    required this.onRemove,
  });

  IconData _getFileIcon() {
    switch (file.type) {
      case FilesType.pdf:
        return AppIcons.pictureAsPdf;
      case FilesType.image:
        return AppIcons.image;
    }
  }

  Color _getFileColor() {
    switch (file.type) {
      case FilesType.pdf:
        return AppColors.danger;
      case FilesType.image:
        return AppColors.blue;
    }
  }

  String _getFileTypeLabel() {
    switch (file.type) {
      case FilesType.pdf:
        return CreateExamStrings.fileTypePdf;
      case FilesType.image:
        return CreateExamStrings.fileTypeImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.colorPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.colorPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _getFileColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(_getFileIcon(), color: _getFileColor(), size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCustomText.generate(
                  text: file.name,
                  textStyle: AppTextStyles.bodySmallMedium.copyWith(
                    color: AppColors.colorPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getFileColor().withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: AppCustomText.generate(
                        text: _getFileTypeLabel(),
                        textStyle: AppTextStyles.bodySmallMedium.copyWith(
                          color: _getFileColor(),
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AppCustomText.generate(
                      text: file.sizeFormatted,
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.grey,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(AppIcons.close),
            color: AppColors.danger,
            iconSize: 20.sp,
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
