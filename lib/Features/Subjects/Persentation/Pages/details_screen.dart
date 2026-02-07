import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../Config/Routes/app_router.dart';
import '../../../../Config/Routes/name_routes.dart';
import '../../../../Config/app_config.dart';
import '../../../../Core/LocalStorage/get_local_storage.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_icons.dart';
import '../../../../Core/Services/PDF/pdf_services.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../Widgets/centered_section.dart';
import '../Widgets/empty_list_exams.dart';
import '../Widgets/exam_card.dart';
import '../Widgets/subject_info_card.dart';
import '../cubit/subjects_cubit.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({
    super.key,
    required this.subjectModel,
  });

  final SubjectModel subjectModel;

  @override
  Widget build(BuildContext context) {
    context.read<SubjectCubit>().getExams(subjectModel.subjectId);

    return Scaffold(
      appBar: AppBar(
        title: Text(NameRoutes.subjectDetails.titleAppBar),
      ),
      body: BlocBuilder<SubjectCubit, SubjectState>(
        builder: (context, state) {
          Widget body;

          if (state.loadingExams) {
            body = const CenteredSection(
              child: CircularProgressIndicator(),
            );
          } else if (state.error != null) {
            body = CenteredSection(
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state.listDataOfExams.isEmpty) {
            body = const CenteredSection(
              child: EmptyListExams(),
            );
          } else {
            body = SliverPadding(
              padding: EdgeInsets.only(
                top: 20.h,
                right: 20.h,
                left: 20.h,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exam = state.listDataOfExams[index];

                    return ExamCard(
                      exam: exam,
                      againTest: () {
                        AppRouter.nextScreenNoPath(
                          context,
                          NameRoutes.doExam,
                          extra: exam,
                          pathParameters: {
                            "exam": exam.examId,
                            "id": exam.examIdSubject,
                          },
                        );
                      },
                      pdf: () async {
                        await ExamPdfUtil.createExamPdf(
                          examData: exam,
                          examInfo: subjectModel,
                        );
                      },
                      showQA: () {
                        final email =
                            GetLocalStorage.getEmailUser().split("@").first;

                        AppRouter.nextScreenNoPath(
                          context,
                          NameRoutes.result,
                          extra: {
                            "exam": exam,
                            "isEditMode": false,
                            "nameSubject": subjectModel.subjectName,
                          },
                          pathParameters: {
                            "exam": exam.examId,
                            "id": exam.examIdSubject,
                            "email": email,
                          },
                        );
                      },
                    );
                  },
                  childCount: state.listDataOfExams.length,
                ),
              ),
            );
          }

          return CustomScrollView(
            physics: AppConfig.physicsCustomScrollView,
            slivers: [
              SliverToBoxAdapter(
                child: SubjectInfoCard(
                  subjectModel: subjectModel,
                  examLength: state.listDataOfExams.length,
                ),
              ),
              body,
            ],
          );
        },
      ),
      floatingActionButton: subjectModel.isME
          ? FloatingActionButton(
              onPressed: () {
                AppRouter.nextScreenNoPath(
                  context,
                  NameRoutes.createExam,
                  extra: subjectModel,
                  pathParameters: {
                    "id": subjectModel.subjectId,
                  },
                );
              },
              backgroundColor: AppColors.colorPrimary,
              child: AppIcons.add,
            )
          : null,
    );
  }
}
