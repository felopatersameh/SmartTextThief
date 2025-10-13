import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../Core/Resources/app_colors.dart';
import '../../../Profile/cubit/profile_cubit.dart';
import '../../Controllers/cubit/exams_cubit.dart';
import 'exams_st_page.dart';
import 'exams_te_page.dart';

class MainExamsPage extends StatelessWidget {
  const MainExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectCubit, SubjectState>(
      builder: (context, state) {
        if (state.loading == true) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: AppColors.colorPrimary,
            ),
          );
        } else {
          final read = context.read<ProfileCubit>().state;
          if (read.model!.isStu) {
            return ExamsStudentPage(user: read.model!);
          } else if (read.model!.iste) {
            return ExamsTeachertPage(user: read.model!);
          }
          return Container(child: null);
        }
      },
    );
  }
}
