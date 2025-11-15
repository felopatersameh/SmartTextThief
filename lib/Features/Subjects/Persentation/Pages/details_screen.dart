import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/LocalStorage/get_local_storage.dart';
import '../../../../Config/Routes/app_router.dart';
import '../../../../Config/Routes/name_routes.dart';

import '../../../../Config/app_config.dart';
import '../../../../Core/Resources/app_colors.dart';
import '../../../../Core/Resources/app_icons.dart';
import '../../../../Core/Services/PDF/pdf_services.dart';
import '../../../../Core/Utils/Models/subject_model.dart';
import '../cubit/subjects_cubit.dart';
import '../Widgets/centered_section.dart';
import '../Widgets/empty_list_exams.dart';
import '../Widgets/exam_card.dart';
import '../Widgets/subject_info_card.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.subjectModel});
  final SubjectModel subjectModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(NameRoutes.subjectDetails.titleAppBar)),
      body: FutureBuilder(
        future: context.read<SubjectCubit>().getExams(subjectModel.subjectId),
        builder: (context, snapshot) {
          Widget body;

          if (snapshot.connectionState == ConnectionState.waiting) {
            body = const CenteredSection(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            body = CenteredSection(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            final exams = snapshot.data ?? [];
            if (exams.isEmpty) {
              body = const CenteredSection(child: EmptyListExams());
            } else {
              body = SliverPadding(
                padding: EdgeInsetsGeometry.only(
                  top: 20.h,
                  right: 20.h,
                  left: 20.h,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final exam = exams[index];
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
                        final email = GetLocalStorage.getEmailUser()
                            .split("@")
                            .first;
                        
                        AppRouter.nextScreenNoPath(
                          context,
                          NameRoutes.result,
                          extra: {"exam": exam, "isEditMode": false,"nameSubject":subjectModel.subjectName},
                          pathParameters: {
                            "exam": exam.examId,
                            "id": exam.examIdSubject,
                            "email": email,
                          },
                        );
                      },
                    );
                  }, childCount: exams.length),
                ),
              );
            }
          }

          return CustomScrollView(
            physics: AppConfig.physicsCustomScrollView,
            slivers: [
              SliverToBoxAdapter(
                child: SubjectInfoCard(
                  subjectModel: subjectModel,
                  examLength: snapshot.data?.length ?? 0,
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
                  pathParameters: {"id": subjectModel.subjectId},
                );
              },
              backgroundColor: AppColors.colorPrimary,
              child: AppIcons.add,
            )
          : null,
    );
  }
}
