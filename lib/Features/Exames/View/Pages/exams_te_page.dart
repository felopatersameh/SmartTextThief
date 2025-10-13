import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Config/setting.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_icons.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../../../../Core/Utils/Models/subject_teacher.dart';
import '../../../../Core/Utils/Models/user_model.dart';
import '../../../../Core/Utils/Widget/add_subject_dialog.dart';
import '../../../../Core/Utils/generate_secure_code.dart';
import '../../Controllers/cubit/exams_cubit.dart';
import '../Widgets/empty_list_subjects.dart';
import '../Widgets/exams_header_card.dart';
import '../Widgets/subjects_card.dart';

class ExamsTeachertPage extends StatelessWidget {
  final UserModel user;
  const ExamsTeachertPage({super.key, required this.user});

  void _showAddSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddSubjectDialog(
        title: 'Add New Subject',
        submitButtonText: 'Add Subject',
        onSubmit: (String name) async {
          final String subjectId = generateSubjectId();
          final String joinCode = generateSubjectJoinCode();
          final SubjectModel model = SubjectModel(
            subjectId: subjectId,
            subjectCode: joinCode,
            subjectName: name,
            subjectTeacher: SubjectTeacher(
              teacherEmail: user.userEmail,
              teacherName: user.userName,
            ),
            subjectEmailSts: [],
            subjectCreatedAt: DateTime.now(),
          );

          if (!context.mounted) return;
          await context.read<SubjectCubit>().addSubject(context, model);
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
              ? EmptyListSubjects()
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
                        child: SubjectsCard(
                          title: state.listData[index].subjectName,
                          date: state.listData[index].createdAt,
                          examsStudent:
                              state.listData[index].subjectEmailSts.length,
                          lengthStudent:
                              state.listData[index].subjectEmailSts.length,
                          openSubjectDetails: () {
                            // Handle subject details navigation
                          },
                        ),
                      ),
                      initialItemCount: state.listData.length,
                    ),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddSubjectDialog(context),
            backgroundColor: AppColors.colorPrimary,
            child: AppIcons.add,
          ),
        );
      },
    );
  }
}
