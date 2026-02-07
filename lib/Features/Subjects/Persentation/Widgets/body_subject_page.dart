import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final displayList = state.filteredSubjects ?? state.listDataOfSubjects;

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
              child: ExamsHeaderCard(
                onChanged: (value) =>
                    context.read<SubjectCubit>().searchSubject(value),
              ),
            ),
          ),
          if (displayList.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No subjects found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SubjectsCard(
                    model: displayList[index],
                    openSubjectDetails: () {
                      AppRouter.nextScreenNoPath(
                        context,
                        pathParameters: {"id": displayList[index].subjectId},
                        NameRoutes.subjectDetails,
                        extra: displayList[index],
                      );
                    },
                  ),
                ),
                childCount: displayList.length,
              ),
            ),
        ],
      );
    }
  }
}
