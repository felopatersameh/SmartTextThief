import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Features/Exames/Controllers/cubit/exams_cubit.dart';

import '../../../../Config/setting.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_icons.dart';
import '../../../../Core/Utils/Models/user_model.dart';
import '../../../../Core/Utils/Widget/add_subject_dialog.dart';
import '../Widgets/empty_list_exams.dart';
import '../Widgets/exam_card.dart';
import '../Widgets/exams_header_card.dart';

class ExamsStudentPage extends StatelessWidget {
  final UserModel user;
  const ExamsStudentPage({super.key, required this.user});

  void _showJoinSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddSubjectDialog(
        title: 'Join Subject',
        submitButtonText: 'Join',
        icon: AppIcons.quiz,
        messageLoading: "Joining....",
        nameField: "Code",
        nameFieldHint: "Enter Code",
        onSubmit: (String code) async {
          // await context.read<ExamsCubit>().addSubject(context, model);

          // showMessageSnackBar(
          //     context,
          //     title: 'Invalid subject code. Please try again.',
          //     type: MessageType.error,
          //   );

          // if (!context.mounted) return;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectCubit, SubjectState>(
      builder: (context, state) {
        return Scaffold(
          body: state.listData.isEmpty
              ? EmptyListExams()
              : CustomScrollView(
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
            onPressed: () => _showJoinSubjectDialog(context),
            backgroundColor: AppColors.colorPrimary,
            child: AppIcons.add,
          ),
        );
      },
    );
  }
}
