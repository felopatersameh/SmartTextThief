import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';

import '../../../Core/Utils/show_message_snack_bar.dart';
import '../Data/subjects_sources.dart';

part 'subjects_state.dart';

class SubjectCubit extends Cubit<SubjectState> {
  SubjectCubit() : super(SubjectState());

  Future<void> init(String email, bool stu) async {
    emit(state.copyWith(loading: true));
    final resonse = await SubjectsSources.getSubjects(email, stu);
    resonse.fold(
      (error) async => emit(
        state.copyWith(
          error: error.message,
          listDataOfSubjects: [],
          loading: false,
        ),
      ),
      (list) async =>
          emit(state.copyWith(listDataOfSubjects: list, loading: false)),
    );
  }

  Future<List<ExamModel>> getExams(String idSubject) async {
    emit(state.copyWith(loadinExams: true));
    List<ExamModel> listDataOfExams = [];
    final resonse = await SubjectsSources.getExam(idSubject);
    resonse.fold(
      (error) async {
        emit(
          state.copyWith(error: error, listDataOfExams: [], loadinExams: false),
        );
        listDataOfExams = [];
      },
      (list) async {
        emit(state.copyWith(listDataOfExams: list, loadinExams: false));
        listDataOfExams = list;
      },
    );
    return listDataOfExams;
  }

  Future<void> addSubject(BuildContext context, SubjectModel model) async {
    final oldList = state.listDataOfSubjects;
    final resonse = await SubjectsSources.addSubject(model);
    resonse.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listDataOfSubjects: oldList));
        await showMessageSnackBar(
          context,
          title: error.message,
          type: MessageType.error,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      (name) async {
        final newlistData = [model, ...oldList];
        emit(state.copyWith(listDataOfSubjects: newlistData));

        if (!context.mounted) return;
        Navigator.of(context).pop();

        await showMessageSnackBar(
          context,
          title: 'Subject "$name" created successfully!',
          type: MessageType.success,
        );
      },
    );
  }

  Future<void> joinSubject(
    BuildContext context,
    String code,
    String email,
  ) async {
    final oldList = state.listDataOfSubjects;
    final resonse = await SubjectsSources.joinSubject(code, email);
    resonse.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listDataOfSubjects: oldList));
        await showMessageSnackBar(
          context,
          title: error.message,
          type: MessageType.error,
        );
      },
      (model) async {
        final newlistData = [model, ...oldList];
        emit(state.copyWith(listDataOfSubjects: newlistData));

        if (!context.mounted) return;
        Navigator.of(context).pop();

        await showMessageSnackBar(
          context,
          title: 'join Subject "${model.subjectName}" successfully!',
          type: MessageType.success,
        );
      },
    );
  }

  Future<void> removeSubject(BuildContext context, SubjectModel model) async {
    final list = state.listDataOfSubjects;
    final resonse = await SubjectsSources.removeSubject(model.subjectId);
    resonse.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listDataOfSubjects: list));
        await showMessageSnackBar(
          context,
          title: error.message,
          type: MessageType.error,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      (name) async {
        list.removeWhere((p0) => p0.subjectId == model.subjectId);
        emit(state.copyWith(listDataOfSubjects: list));

        if (!context.mounted) return;
        Navigator.of(context).pop();

        await showMessageSnackBar(
          context,
          title: 'Subject "${model.subjectName}" removed successfully!',
          type: MessageType.success,
        );
      },
    );
  }

  Future<void> updateSubject(BuildContext context, SubjectModel model) async {
    final list = state.listDataOfSubjects;
    final resonse = await SubjectsSources.updateSubject(model);
    resonse.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listDataOfSubjects: list));
        await showMessageSnackBar(
          context,
          title: error.message,
          type: MessageType.error,
        );
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      (name) async {
        final index = list.indexWhere(
          ((p0) => p0.subjectId == model.subjectId),
        );
        list.setRange(index, (index + 1), [model]);
        emit(state.copyWith(listDataOfSubjects: list));
        if (!context.mounted) return;
        Navigator.of(context).pop();

        await showMessageSnackBar(
          context,
          title: 'updated successfully!',
          type: MessageType.success,
        );
      },
    );
  }
}
