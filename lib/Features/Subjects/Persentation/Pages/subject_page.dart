import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';
import 'package:smart_text_thief/Core/Resources/app_icons.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_teacher.dart';
import 'package:smart_text_thief/Core/Utils/Widget/add_subject_dialog.dart';
import 'package:smart_text_thief/Core/Utils/generate_secure_code.dart';
import 'package:smart_text_thief/Core/Utils/show_message_snack_bar.dart';
import 'package:smart_text_thief/Features/Profile/Persentation/cubit/profile_cubit.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/body_subject_page.dart';

class SubjectPage extends StatelessWidget {
  const SubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectCubit, SubjectState>(
      listenWhen: (previous, current) =>
          previous.action != current.action || previous.error != current.error,
      listener: (context, state) {
        if (state.action == SubjectAction.added) {
          showMessageSnackBar(
            context,
            title: 'Subject added successfully!',
            type: MessageType.success,
          );
        }

        if (state.action == SubjectAction.joined) {
          showMessageSnackBar(
            context,
            title: 'Joined subject successfully!',
            type: MessageType.success,
          );
        }

        if (state.error != null) {
          showMessageSnackBar(
            context,
            title: state.error!,
            type: MessageType.error,
          );
        }
      },
      child: BlocBuilder<SubjectCubit, SubjectState>(
        builder: (context, state) {
          final profileState = context.read<ProfileCubit>().state;
          final isStudent = profileState.model?.isStu ?? false;
          final email = profileState.model?.userEmail ?? '';
          final name = profileState.model?.userName ?? '';

          return Scaffold(
            appBar: AppBar(
              title: Text(NameRoutes.subject.titleAppBar),
            ),
            body: state.loadingSubjects
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: AppColors.colorPrimary,
                    ),
                  )
                : BodySubjectPage(state: state),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (isStudent) {
                  _showJoinSubjectDialog(
                    context,
                    email: email,
                    name: name,
                  );
                  return;
                }

                _showAddSubjectDialog(
                  context,
                  email: email,
                  name: name,
                );
              },
              backgroundColor: AppColors.colorPrimary,
              child: AppIcons.add,
            ),
          );
        },
      ),
    );
  }
}

void _showAddSubjectDialog(
  BuildContext context, {
  required String name,
  required String email,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddSubjectDialog(
      title: 'Add New Subject',
      submitButtonText: 'Add Subject',
      onSubmit: (subjectName) async {
        final model = SubjectModel(
          subjectId: generateSubjectId(),
          subjectCode: generateSubjectJoinCode(),
          subjectName: subjectName,
          subjectTeacher: SubjectTeacher(
            teacherEmail: email,
            teacherName: name,
          ),
          subjectEmailSts: const [],
          subjectCreatedAt: DateTime.now(),
          subjectIsOpen: true,
        );

        if (!context.mounted) return false;
        return context.read<SubjectCubit>().addSubject(model);
      },
    ),
  );
}

void _showJoinSubjectDialog(
  BuildContext context, {
  required String email,
  required String name,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddSubjectDialog(
      title: 'Join Subject',
      submitButtonText: 'Join',
      icon: AppIcons.quiz,
      messageLoading: 'Joining....',
      nameField: 'Code',
      nameFieldHint: 'Enter Code',
      onSubmit: (code) async {
        return context.read<SubjectCubit>().joinSubject(code, email, name);
      },
    ),
  );
}
