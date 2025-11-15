import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '/Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';

import '../../../../Core/Utils/show_message_snack_bar.dart';
import '../../Data/subjects_sources.dart';

part 'subjects_state.dart';

class SubjectCubit extends Cubit<SubjectState> {
  SubjectCubit() : super(SubjectState());

  Future<void> init(String email, bool stu) async {
    emit(state.copyWith(loading: true));
    final response = await SubjectsSources.getSubjects(email, stu);
    response.fold(
      (error) async => emit(
        state.copyWith(
          error: error.message,
          listDataOfSubjects: [],
          loading: false,
        ),
      ),
      (list) async => emit(
        state.copyWith(
          listDataOfSubjects: list.reversed.toList(),
          loading: false,
        ),
      ),
    );
  }

  Future<List<ExamModel>> getExams(String idSubject) async {
    emit(state.copyWith(loadingExams: true));
    List<ExamModel> listDataOfExams = [];
    final response = await SubjectsSources.getExam(idSubject);
    response.fold(
      (error) async {
        emit(
          state.copyWith(
            error: error,
            listDataOfExams: [],
            loadingExams: false,
          ),
        );
        listDataOfExams = [];
      },
      (list) async {
        final reversedList = list.reversed.toList();
        emit(
          state.copyWith(listDataOfExams: reversedList, loadingExams: false),
        );
        listDataOfExams = reversedList;
      },
    );
    return listDataOfExams;
  }

  Future<void> addSubject(BuildContext context, SubjectModel model) async {
    final oldList = state.listDataOfSubjects;
    final response = await SubjectsSources.addSubject(model);
    response.fold(
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
        final newListData = [model, ...oldList];
        emit(state.copyWith(listDataOfSubjects: newListData));

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
    String name,
  ) async {
    final oldList = state.listDataOfSubjects;
    final response = await SubjectsSources.joinSubject(code, email,name);
    response.fold(
      (error) async {
        emit(state.copyWith(error: error.message, listDataOfSubjects: oldList));
        await showMessageSnackBar(
          context,
          title: error.message,
          type: MessageType.error,
        );
      },
      (model) async {
        final newListData = [model, ...oldList];
        emit(state.copyWith(listDataOfSubjects: newListData));

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
    final response = await SubjectsSources.removeSubject(model.subjectId);
    response.fold(
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

        // await NotificationServices.subscribeToTopic(
        //   model.subscribeToTopicForMembers,
        // );
        // final length = model.subjectEmailSts.isNotEmpty;
        // final String and = length
        //     ? "and ${model.subjectEmailSts.length} members"
        //     : "";
        // final NotificationModel notification = NotificationModel(
        //   id: "join_${model.subjectId}",
        //   type: NotificationType.joinedSubject,
        //   body: "$name has Leaved ${model.subjectName} $and",
        //   createdAt: DateTime.now().millisecondsSinceEpoch,
        // );
        // await NotificationServices.sendNotificationToTopic(
        //   title: notification.title,
        //   body: notification.body,
        //   topic: model.subscribeToTopicForAdmin,
        //   data: notification.toJson(),
        // );

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
    final response = await SubjectsSources.updateSubject(model);
    response.fold(
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
