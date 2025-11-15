import 'package:flutter/material.dart';

import '../../../../Config/setting.dart';

import '../cubit/subjects_cubit.dart';
import 'empty_list_subjects.dart';
import 'exams_header_card.dart';
import 'subjects_card.dart';

class BodySubjectPage extends StatelessWidget {
  final SubjectState state;
  const BodySubjectPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.listDataOfSubjects.isEmpty) {
      return EmptyListSubjects();
    } else {
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
              child: SubjectsCard(
                model: state.listDataOfSubjects[index],
                openSubjectDetails: () {
                  AppRouter.nextScreenNoPath(
                    context,
                    pathParameters: {
                      "id": state.listDataOfSubjects[index].subjectId,
                    },
                    NameRoutes.subjectDetails,
                    extra: state.listDataOfSubjects[index],
                  );
                },
              ),
            ),
            initialItemCount: state.listDataOfSubjects.length,
          ),
        ],
      );
    }
  }
}
