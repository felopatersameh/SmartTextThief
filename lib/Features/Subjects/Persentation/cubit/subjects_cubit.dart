import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:smart_text_thief/Core/Services/Firebase/failure_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/exam_model.dart';
import 'package:smart_text_thief/Core/Utils/Models/subject_model.dart';
import 'package:smart_text_thief/Features/Subjects/Data/datasources/subjects_remote_data_source.dart';
import 'package:smart_text_thief/Features/Subjects/Data/repositories/subject_repository_impl.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/repositories/subject_repository.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/add_subject_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/delete_subject_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/get_subject_exams_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/get_subjects_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/join_subject_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/leave_subject_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/search_subjects_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/toggle_subject_open_use_case.dart';
import 'package:smart_text_thief/Features/Subjects/Domain/usecases/update_subject_use_case.dart';

part 'subjects_state.dart';

class SubjectCubit extends Cubit<SubjectState> {
  SubjectCubit({
    SubjectRepository? repository,
    SearchSubjectsUseCase? searchSubjectsUseCase,
  })  : _repository = repository ??
            SubjectRepositoryImpl(
              remoteDataSource: SubjectsRemoteDataSource(),
            ),
        _searchSubjectsUseCase = searchSubjectsUseCase ?? SearchSubjectsUseCase(),
        super(const SubjectState()) {
    _getSubjectsUseCase = GetSubjectsUseCase(_repository);
    _getSubjectExamsUseCase = GetSubjectExamsUseCase(_repository);
    _addSubjectUseCase = AddSubjectUseCase(_repository);
    _joinSubjectUseCase = JoinSubjectUseCase(_repository);
    _updateSubjectUseCase = UpdateSubjectUseCase(_repository);
    _deleteSubjectUseCase = DeleteSubjectUseCase(_repository);
    _toggleSubjectOpenUseCase = ToggleSubjectOpenUseCase(_repository);
    _leaveSubjectUseCase = LeaveSubjectUseCase(_repository);
  }

  final SubjectRepository _repository;
  final SearchSubjectsUseCase _searchSubjectsUseCase;

  late final GetSubjectsUseCase _getSubjectsUseCase;
  late final GetSubjectExamsUseCase _getSubjectExamsUseCase;
  late final AddSubjectUseCase _addSubjectUseCase;
  late final JoinSubjectUseCase _joinSubjectUseCase;
  late final UpdateSubjectUseCase _updateSubjectUseCase;
  late final DeleteSubjectUseCase _deleteSubjectUseCase;
  late final ToggleSubjectOpenUseCase _toggleSubjectOpenUseCase;
  late final LeaveSubjectUseCase _leaveSubjectUseCase;

  Future<void> init() async {
    emit(
      state.copyWith(
        loadingSubjects: true,
        error: null,
        action: null,
      ),
    );

    final response = await _getSubjectsUseCase();
    response.fold(
      (failure) => _emitFailure(
        failure.message,
        loadingSubjects: false,
        subjects: const [],
        selectedSubject: null,
        exams: const [],
      ),
      (subjects) => _emitSubjects(
        subjects: subjects.reversed.toList(),
        loadingSubjects: false,
        selectedSubject: null,
        exams: const [],
        error: null,
        action: null,
      ),
    );
  }

  Future<void> getExams(String subjectId) async {
    emit(
      state.copyWith(
        loadingExams: true,
        error: null,
        exams: []
      ),
    );

    final response = await _getSubjectExamsUseCase(subjectId);
    response.fold(
      (error) => _emitFailure(
        error,
        loadingExams: false,
        exams: const [],
      ),
      (exams) => emit(
        state.copyWith(
          loadingExams: false,
          exams: exams,
          error: null,
        ),
      ),
    );
  }

  Future<void> openSubjectDetails(SubjectModel model) async {
    final selected = _findSubjectById(model.subjectId) ?? model;
    emit(
      state.copyWith(
        selectedSubject: selected,
        exams: const [],
        loadingExams: true,
        error: null,
        action: null,
      ),
    );
    await getExams(selected.subjectId);
  }

  void selectSubject(SubjectModel model) {
    emit(
      state.copyWith(
        selectedSubject: _findSubjectById(model.subjectId) ?? model,
      ),
    );
  }

  Future<bool> addSubject(String name) async {
    final response = await _addSubjectUseCase(name);
    return response.fold(
      (failure) {
        _emitFailure(failure.message);
        return false;
      },
      (model) {
        _emitSubjects(
          subjects: [model, ...state.subjects],
          action: SubjectAction.added,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> joinSubject(
    String code,
    String email,
    String name,
  ) async {
    final response = await _joinSubjectUseCase(code, email, name);
    return response.fold(
      (failure) {
        _emitFailure(failure.message);
        return false;
      },
      (model) {
        _emitSubjects(
          subjects: _upsertSubject(model),
          action: SubjectAction.joined,
          error: null,
        );
        return true;
      },
    );
  }

  Future<void> removeSubject(SubjectModel model) async {
    await _runBoolOperation(
      operation: () => _deleteSubjectUseCase(model),
      onSuccess: () {
        final updatedSubjects = _removeSubject(model.subjectId);
        final selectedSubject = _selectedOrNull(updatedSubjects);
        _emitSubjects(
          subjects: updatedSubjects,
          selectedSubject: selectedSubject,
          exams: selectedSubject == null ? const [] : state.exams,
          action: SubjectAction.removed,
          error: null,
        );
      },
    );
  }

  Future<void> toggleSubjectOpen(SubjectModel model, bool isOpen) async {
    final baseSubject = _findSubjectById(model.subjectId) ?? model;
    await _runBoolOperation(
      operation: () => _toggleSubjectOpenUseCase(baseSubject, isOpen),
      onSuccess: () {
        final updatedModel = baseSubject.copyWith(subjectIsOpen: isOpen);
        _emitSubjects(
          subjects: _replaceSubject(updatedModel),
          selectedSubject: updatedModel,
          action: SubjectAction.updated,
          error: null,
        );
      },
    );
  }

  Future<void> leaveSubject(SubjectModel model, String studentEmail) async {
    await _runBoolOperation(
      operation: () => _leaveSubjectUseCase(model, studentEmail),
      onSuccess: () {
        final updatedSubjects = _removeSubject(model.subjectId);
        _emitSubjects(
          subjects: updatedSubjects,
          selectedSubject: _selectedOrNull(updatedSubjects),
          exams: const [],
          action: SubjectAction.removed,
          error: null,
        );
      },
    );
  }

  Future<void> updateSubject(SubjectModel model) async {
    await _runBoolOperation(
      operation: () => _updateSubjectUseCase(model),
      onSuccess: () {
        _emitSubjects(
          subjects: _replaceSubject(model),
          selectedSubject: state.selectedSubject?.subjectId == model.subjectId
              ? model
              : state.selectedSubject,
          action: SubjectAction.updated,
          error: null,
        );
      },
    );
  }

  void searchSubject(String query) {
    emit(
      state.copyWith(
        searchQuery: query,
        filteredSubjects: _searchSubjectsUseCase(state.subjects, query),
      ),
    );
  }

  Future<void> _runBoolOperation({
    required Future<Either<FailureModel, bool>> Function() operation,
    required void Function() onSuccess,
  }) async {
    final response = await operation();
    response.fold(
      (failure) => _emitFailure(failure.message),
      (_) => onSuccess(),
    );
  }

  List<SubjectModel> _replaceSubject(SubjectModel model) {
    return [
      for (final item in state.subjects)
        if (item.subjectId == model.subjectId) model else item,
    ];
  }

  List<SubjectModel> _removeSubject(String subjectId) {
    return [
      for (final item in state.subjects)
        if (item.subjectId != subjectId) item,
    ];
  }

  List<SubjectModel> _upsertSubject(SubjectModel model) {
    final index = state.subjects.indexWhere((e) => e.subjectId == model.subjectId);
    if (index == -1) return [model, ...state.subjects];

    final updated = List<SubjectModel>.from(state.subjects);
    updated[index] = model;
    return updated;
  }

  SubjectModel? _findSubjectById(String subjectId) {
    for (final subject in state.subjects) {
      if (subject.subjectId == subjectId) return subject;
    }
    return null;
  }

  SubjectModel? _selectedOrNull(List<SubjectModel> subjects) {
    final selectedId = state.selectedSubject?.subjectId;
    if (selectedId == null) return null;

    for (final item in subjects) {
      if (item.subjectId == selectedId) return item;
    }
    return null;
  }

  void _emitSubjects({
    required List<SubjectModel> subjects,
    bool? loadingSubjects,
    bool? loadingExams,
    List<ExamModel>? exams,
    Object? selectedSubject = _selectedSubjectNotChanged,
    String? error,
    SubjectAction? action,
  }) {
    final nextSelected = selectedSubject == _selectedSubjectNotChanged
        ? _selectedOrNull(subjects)
        : selectedSubject as SubjectModel?;

    emit(
      state.copyWith(
        loadingSubjects: loadingSubjects,
        loadingExams: loadingExams,
        subjects: subjects,
        filteredSubjects: _searchSubjectsUseCase(subjects, state.searchQuery),
        exams: exams,
        selectedSubject: nextSelected,
        error: error,
        action: action,
      ),
    );
  }

  void _emitFailure(
    String message, {
    bool? loadingSubjects,
    bool? loadingExams,
    List<SubjectModel>? subjects,
    Object? selectedSubject = _selectedSubjectNotChanged,
    List<ExamModel>? exams,
  }) {
    final nextSelected = selectedSubject == _selectedSubjectNotChanged
        ? state.selectedSubject
        : selectedSubject as SubjectModel?;

    emit(
      state.copyWith(
        loadingSubjects: loadingSubjects,
        loadingExams: loadingExams,
        subjects: subjects,
        filteredSubjects: subjects == null
            ? null
            : _searchSubjectsUseCase(subjects, state.searchQuery),
        selectedSubject: nextSelected,
        exams: exams,
        error: message,
        action: null,
      ),
    );
  }
}

const _selectedSubjectNotChanged = Object();
