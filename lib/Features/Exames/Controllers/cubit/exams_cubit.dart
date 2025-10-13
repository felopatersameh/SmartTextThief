import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';

import '../../../../Core/Utils/show_message_snack_bar.dart';
import '../../Data/exam_te_sources.dart';

part 'exams_state.dart';

class SubjectCubit extends Cubit<SubjectState> {
  SubjectCubit() : super(SubjectState());

  Future<void> init(String email, bool stu) async {
    emit(state.copyWith(loading: true));
    final resonse = await ExamTeSources.getSubjects(email, stu);
    resonse.fold(
      (error) async => emit(
        state.copyWith(error: error.message, listData: [], loading: false),
      ),
      (list) async => emit(state.copyWith(listData: list, loading: false)),
    );
  }

  Future<void> addSubject(BuildContext context, SubjectModel model) async {
    final oldList = state.listData;
    final resonse = await ExamTeSources.addSubject(model);
    resonse.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listData: oldList));
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
        emit(state.copyWith(listData: newlistData));

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

  Future<void> removeSubject(BuildContext context, SubjectModel model) async {
    final list = state.listData;
    final resonse = await ExamTeSources.removeSubject(model.subjectId);
    resonse.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listData: list));
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
        emit(state.copyWith(listData: list));

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
    final list = state.listData;
    final resonse = await ExamTeSources.updateSubject(model);
    resonse.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listData: list));
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
        emit(state.copyWith(listData: list));
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
