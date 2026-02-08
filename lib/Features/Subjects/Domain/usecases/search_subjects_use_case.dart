import '../../../../Core/Utils/Models/subject_model.dart';

class SearchSubjectsUseCase {
  List<SubjectModel> call(
    List<SubjectModel> subjects,
    String query,
  ) {
    final search = query.toLowerCase().trim();
    if (search.isEmpty) return subjects;

    return subjects.where((subject) {
      return subject.subjectName.toLowerCase().contains(search) ||
          subject.subjectCode.toLowerCase().contains(search) ||
          subject.subjectTeacher.teacherEmail.toLowerCase().contains(search) ||
          subject.subjectTeacher.teacherName.toLowerCase().contains(search) ||
          subject.subjectEmailSts.any((email) => email.toLowerCase().contains(search));
    }).toList();
  }
}
