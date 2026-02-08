import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Config/Routes/name_routes.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_icons.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../../../../Core/Utils/Models/subject_teacher.dart';
import '../../../../Core/Utils/Widget/add_subject_dialog.dart';
import '../../../../Core/Utils/generate_secure_code.dart';
import '../../../../Core/Utils/show_message_snack_bar.dart';
import '../../../Profile/Persentation/cubit/profile_cubit.dart';
import '../cubit/subjects_cubit.dart';
import '../Widgets/body_subject_page.dart';

class SubjectPage extends StatelessWidget {
  const SubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectCubit, SubjectState>(
      listenWhen: (prev, curr) =>
          prev.action != curr.action || prev.error != curr.error,
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
          final read = context.read<ProfileCubit>().state;
          return Scaffold(
            appBar: AppBar(
              title: Text(NameRoutes.subject.titleAppBar),
            ),
            body: state.loading
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: AppColors.colorPrimary,
                    ),
                  )
                : BodySubjectPage(state: state),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                final isStu = read.model?.isStu ?? false;
                final email = read.model?.userEmail ?? "";
                final name = read.model?.userName ?? "";

                if (isStu) {
                  _showJoinSubjectDialog(
                    context,
                    email: email,
                    name: name,
                  );
                } else {
                  _showAddSubjectDialog(
                    context,
                    email: email,
                    name: name,
                  );
                }
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
      onSubmit: (String nameSub) async {
        final String subjectId = generateSubjectId();
        final String joinCode = generateSubjectJoinCode();
        final SubjectModel model = SubjectModel(
          subjectId: subjectId,
          subjectCode: joinCode,
          subjectName: nameSub,
          subjectTeacher: SubjectTeacher(
            teacherEmail: email,
            teacherName: name,
          ),
          subjectEmailSts: [],
          subjectCreatedAt: DateTime.now(),
        );

        if (!context.mounted) return false;
        return await context.read<SubjectCubit>().addSubject(model);
      },
    ),
  );
}

void _showJoinSubjectDialog(BuildContext context,
    {required String email, required String name}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AddSubjectDialog(
      title: 'Join Subject',
      submitButtonText: 'Join',
      icon: AppIcons.quiz,
      messageLoading: "Joining....",
      nameField: "Code",
      nameFieldHint: "Enter Code",
      onSubmit: (String code) async {
        return await context.read<SubjectCubit>().joinSubject(code, email, name);
      },
    ),
  );
}
