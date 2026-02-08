import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Config/app_config.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';
import 'package:smart_text_thief/Core/Resources/app_fonts.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/cubit/create_exam_cubit.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/widgets/create_button.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/widgets/exam_date_section.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/widgets/level_dropdown.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/widgets/question_numbers_row.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/widgets/type_exam_field.dart';
import 'package:smart_text_thief/Features/Exams/create_exam/presentation/widgets/upload_option_section.dart';

class CreateExamScreen extends StatelessWidget {
  final SubjectModel subject;
  const CreateExamScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateExamCubit(subject: subject),
      child: Scaffold(
        appBar: AppBar(title: Text(NameRoutes.createExam.titleAppBar)),
        body: CustomScrollView(
          physics: AppConfig.physicsCustomScrollView,
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: const _CreateExamBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateExamBody extends StatelessWidget {
  const _CreateExamBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateExamCubit, CreateExamState>(
      builder: (context, state) {
        final cubit = context.read<CreateExamCubit>();
        return Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LevelDropdown(state: state),
            ExamField(
              hint: 'Enter exam Name',
              initialValue: state.name,
              title: "Name of Exam",
              onChanged: cubit.changeName,
            ),
            ExamField(
              hint: 'e.g., Religious, Scientific, Training, etc.',
              initialValue: state.content,
              title: "Content Context",
              onChanged: cubit.changeContent,
            ),
            Row(
              children: [
                Checkbox(
                  value: state.canOpenQuestions,
                  activeColor: AppColors.colorPrimary,
                  onChanged: (val) => context
                      .read<CreateExamCubit>()
                      .toggleCanOpenQuestions(val ?? false),
                ),
                Expanded(
                  child: Text(
                    "Can each open exam have questions unordered?",
                    style: AppTextStyles.bodyMediumMedium,
                  ),
                ),
              ],
            ),
            QuestionNumbersRow(state: state),
            SizedBox(height: 5.h),
            ExamDateSection(
              startDate: state.startDate,
              endDate: state.endDate,
              onStartChanged: (date) => cubit.changeStartDate(date),
              onEndChanged: (date) => cubit.changeEndDate(date),
            ),
            SizedBox(height: 5.h),
            UploadOptionSection(state: state),
            SizedBox(height: 5.h),
            const Spacer(),
            CreateButton(
              onPress: cubit.state.loadingCreating
                  ? null
                  : () async => await cubit.submitExam(context),
              text:
                  cubit.state.loadingCreating ? "Creating...." : "Create Exam",
            ),
            if (state.loadingCreating)
              LinearProgressIndicator(color: AppColors.colorPrimary),
            // SizedBox(height: 18.h),
          ],
        );
      },
    );
  }
}
