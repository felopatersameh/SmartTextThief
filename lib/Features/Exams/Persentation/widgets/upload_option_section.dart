// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../Core/Resources/app_colors.dart';
import '../../../../../../Core/Resources/app_fonts.dart';
import '../../../../../../Core/Utils/Widget/custom_text_app.dart';
import '../../../../../Core/Utils/Enums/upload_option.dart';
import '../Manager/create/exam_cubit.dart';

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
              text: "Upload Files",
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
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text("Choose Files"),
                    onPressed: () => cubit.pickFiles(context),
                  ),
                  if (state.uploadedFiles.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    TextButton.icon(
                      onPressed: () => cubit.clearAllFiles(),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Clear All"),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
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
                      text: "Uploaded Files (${state.uploadedFiles.length})",
                      textStyle: AppTextStyles.bodySmallMedium.copyWith(
                        color: AppColors.colorPrimary.withOpacity(0.7),
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
          Divider(color: AppColors.colorPrimary.withOpacity(0.4), height: 12.h),
          RadioListTile<UploadOption>(
            value: UploadOption.text,
            groupValue: state.uploadOption,
            activeColor: AppColors.colorPrimary,
            contentPadding: EdgeInsets.zero,
            title: AppCustomText.generate(
              text: "Enter Text Manually",
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
                  hintText: 'Enter or paste exam content here...',
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

class InformationFileModel {
  final String name;
  final String path;
  final FilesType type;
  final int size;

  InformationFileModel({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
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
        return Icons.picture_as_pdf;
      case FilesType.image:
        return Icons.image;
    }
  }

  Color _getFileColor() {
    switch (file.type) {
      case FilesType.pdf:
        return Colors.red;
      case FilesType.image:
        return Colors.blue;
    }
  }

  String _getFileTypeLabel() {
    switch (file.type) {
      case FilesType.pdf:
        return 'PDF';
      case FilesType.image:
        return 'Image';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.colorPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.colorPrimary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _getFileColor().withOpacity(0.1),
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
                        color: _getFileColor().withOpacity(0.15),
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
                        color: Colors.grey,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.red,
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
