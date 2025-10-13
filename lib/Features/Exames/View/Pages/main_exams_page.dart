import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_text_thief/Features/Profile/cubit/profile_cubit.dart';

import 'exams_st_page.dart';
import 'exams_te_page.dart';

class MainExamsPage extends StatelessWidget {
  const MainExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final read = context.read<ProfileCubit>().state;
    if (read.model!.isStu) {
      return ExamsStudentPage();
    }
   else if (read.model!.iste) {
      return ExamsTeachertPage();
    }
    return Container(child: null);
  }
}
