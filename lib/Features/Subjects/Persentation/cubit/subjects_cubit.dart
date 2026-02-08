import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '/Core/Utils/Models/exam_model.dart';
import '../../../../Core/Utils/Models/subject_model.dart';

import '../../Data/subjects_sources.dart';

part 'subjects_state.dart';
class SubjectCubit extends Cubit<SubjectState> {
  SubjectCubit() : super(const SubjectState());

  Future<void> init(String email, bool stu) async {
    emit(state.copyWith(loading: true));

    final response = await SubjectsSources.getSubjects(email, stu);
    response.fold(
      (error) => emit(
        state.copyWith(
          loading: false,
          error: error.message,
          listDataOfSubjects: const [],
        ),
      ),
      (list) => emit(
        state.copyWith(
          loading: false,
          listDataOfSubjects: list.reversed.toList(),
        ),
      ),
    );
  }

  // ✅ Exams بدون return
  Future<void> getExams(String subjectId) async {
    emit(state.copyWith(loadingExams: true));

    final response = await SubjectsSources.getExam(subjectId);
    response.fold(
      (error) => emit(
        state.copyWith(
          loadingExams: false,
          error: error,
          listDataOfExams: const [],
        ),
      ),
      (list) => emit(
        state.copyWith(
          loadingExams: false,
          listDataOfExams: list,
        ),
      ),
    );
  }

  Future<bool> addSubject(SubjectModel model) async {
    final response = await SubjectsSources.addSubject(model);
    bool isDone = false;

    response.fold(
      (error) {
        isDone = false;
        emit(
          state.copyWith(error: error.message),
        );
      },
      (_) {
        final newList = [model, ...state.listDataOfSubjects];
        isDone = true;
        emit(
          state.copyWith(
            listDataOfSubjects: newList,
            action: SubjectAction.added,
          ),
        );
      },
    );
    return isDone;
  }

  Future<bool> joinSubject(
    String code,
    String email,
    String name,
  ) async {
    final response = await SubjectsSources.joinSubject(code, email, name);
    bool isDone = false;

    response.fold(
      (error) {
        isDone = false;
        emit(state.copyWith(error: error.message));
      },
      (model) {
        final newList = [model, ...state.listDataOfSubjects];
        isDone = true;
        emit(
          state.copyWith(
            listDataOfSubjects: newList,
            action: SubjectAction.joined,
          ),
        );
      },
    );
    return isDone;
  }

  Future<void> removeSubject(SubjectModel model) async {
    final response = await SubjectsSources.removeSubject(model.subjectId);

    response.fold(
      (error) => emit(state.copyWith(error: error.message)),
      (_) {
        final newList = List<SubjectModel>.from(state.listDataOfSubjects)
          ..removeWhere((e) => e.subjectId == model.subjectId);

        emit(
          state.copyWith(
            listDataOfSubjects: newList,
            action: SubjectAction.removed,
          ),
        );
      },
    );
  }

  Future<void> updateSubject(SubjectModel model) async {
    final response = await SubjectsSources.updateSubject(model);

    response.fold(
      (error) => emit(state.copyWith(error: error.message)),
      (_) {
        final newList = state.listDataOfSubjects
            .map((e) => e.subjectId == model.subjectId ? model : e)
            .toList();

        emit(
          state.copyWith(
            listDataOfSubjects: newList,
            action: SubjectAction.updated,
          ),
        );
      },
    );
  }

  Future<void> searchSubject(String query) async {
    final search = query.toLowerCase().trim();

    if (search.isEmpty) {
      emit(state.copyWith(filteredSubjects: state.listDataOfSubjects));
      return;
    }

    final filtered = state.listDataOfSubjects.where((subject) {
      return subject.subjectName.toLowerCase().contains(search) ||
          subject.subjectCode.toLowerCase().contains(search) ||
          subject.subjectTeacher.teacherEmail
              .toLowerCase()
              .contains(search) ||
          subject.subjectTeacher.teacherName
              .toLowerCase()
              .contains(search) ||
          subject.subjectEmailSts
              .any((e) => e.toLowerCase().contains(search));
    }).toList();

    emit(state.copyWith(filteredSubjects: filtered));
  }
}
