import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Config/Routes/app_router.dart';
import 'package:smart_text_thief/Config/Routes/name_routes.dart';
import 'package:smart_text_thief/Config/setting.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/cubit/subjects_cubit.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/empty_list_subjects.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/exams_header_card.dart';
import 'package:smart_text_thief/Features/Subjects/Persentation/widgets/subjects_card.dart';

class BodySubjectPage extends StatelessWidget {
  const BodySubjectPage({
    super.key,
    required this.state,
  });

  final SubjectState state;

  @override
  Widget build(BuildContext context) {
    final displayList = state.visibleSubjects;

    if (state.subjects.isEmpty) {
      return const EmptyListSubjects();
    }

    return CustomScrollView(
      physics: AppConfig.physicsCustomScrollView,
      shrinkWrap: true,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ExamsHeaderCard(
              onChanged: context.read<SubjectCubit>().searchSubject,
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No subjects found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
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
              (context, index) {
                final model = displayList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: SubjectsCard(
                    model: model,
                    openSubjectDetails: () {
                      context.read<SubjectCubit>().selectSubject(model);
                      AppRouter.nextScreenNoPath(
                        context,
                        NameRoutes.subjectDetails,
                        pathParameters: {'id': model.subjectId},
                        extra: model,
                      );
                    },
                  ),
                );
              },
              childCount: displayList.length,
            ),
          ),
      ],
    );
  }
}
