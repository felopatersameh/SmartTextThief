import 'package:flutter/material.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Features/Exames/View/Widgets/exams_header_card.dart';
import 'package:smart_text_thief/Core/Utils/Widget/add_subject_dialog.dart';
import 'package:smart_text_thief/Core/Resources/app_icons.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';

import '../../../../Core/Utils/show_message_snack_bar.dart';
import '../Widgets/subjects_card.dart';

class ExamsTeachertPage extends StatelessWidget {
  const ExamsTeachertPage({super.key});

  void _showAddSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddSubjectDialog(
        title: 'Add New Subject',
        submitButtonText: 'Add Subject',
        onSubmit: (String name) async {
          await Future.delayed(Duration(seconds: 1));
          debugPrint('Subject Name: $name');
          if (!context.mounted) return;
          await showMessageSnackBar(
            context,
            title: 'Subject "$name" created successfully!',
            type: MessageType.success,
          );
          if (!context.mounted) return;
          Navigator.of(context).pop();

        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                title: 'General Exam',
                date: '2023-11-20',
                examsStudent: 10,
                lengthStudent: 20,
                openSubjectDetails: () {
                  // Handle subject details navigation
                },
              ),
            ),
            initialItemCount: 5,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubjectDialog(context),
        backgroundColor: AppColors.colorPrimary,
        child: AppIcons.add,
      ),
    );
  }
}
