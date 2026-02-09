import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Services/Dialog/app_dialog_service.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_teacher.dart';
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
            title: SubjectStrings.subjectAddedSuccessfully,
            type: MessageType.success,
          );
        }

        if (state.action == SubjectAction.joined) {
          showMessageSnackBar(
            context,
            title: SubjectStrings.subjectJoinedSuccessfully,
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
              onPressed: () async {
                if (isStudent) {
                  await _showJoinSubjectDialog(
                    context,
                    email: email,
                    name: name,
                  );
                  return;
                }

                await _showAddSubjectDialog(
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

Future<void> _showAddSubjectDialog(
  BuildContext context, {
  required String name,
  required String email,
}) async {
  final subjectName = await AppDialogService.showInputDialog(
    context,
    title: SubjectStrings.addNewSubject,
    hintText: SubjectStrings.pleaseEnterSubjectName,
    confirmText: SubjectStrings.addSubject,
    validator: (value) {
      if (value.trim().isEmpty) return SubjectStrings.pleaseEnterSubjectName;
      return null;
    },
  );

  if (subjectName == null || subjectName.trim().isEmpty || !context.mounted) {
    return;
  }

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

  await showMessageSnackBar(
    context,
    title: SubjectStrings.creatingSubject,
    type: MessageType.loading,
    onLoading: () async {
      await context.read<SubjectCubit>().addSubject(model);
    },
  );
}

Future<void> _showJoinSubjectDialog(
  BuildContext context, {
  required String email,
  required String name,
}) async {
  final code = await AppDialogService.showInputDialog(
    context,
    title: SubjectStrings.joinSubject,
    hintText: SubjectStrings.enterCode,
    confirmText: SubjectStrings.join,
    validator: (value) {
      if (value.trim().isEmpty) return SubjectStrings.pleaseEnterCode;
      return null;
    },
  );

  if (code == null || code.trim().isEmpty || !context.mounted) {
    return;
  }

  await showMessageSnackBar(
    context,
    title: SubjectStrings.joining,
    type: MessageType.loading,
    onLoading: () async {
      await context.read<SubjectCubit>().joinSubject(code, email, name);
    },
  );
}
