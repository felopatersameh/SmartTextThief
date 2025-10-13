
import 'package:flutter/material.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Features/Exames/exam_card.dart';
import 'package:smart_text_thief/Features/Exames/exams_header_card.dart';

class ExamsPage extends StatelessWidget {
  const ExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
    );
  }
}
