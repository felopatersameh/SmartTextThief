enum DataKey {
  // 🔹 User fields
  userId('user_id'),
  photo('photo'),
  userTokensFCM('user_tokensFCM'),
  userName('user_name'),
  userEmail('user_email'),
  userPassword('user_password'),
  userPhone('user_phone'),
  userType('user_type'),
  userCreatedAt('user_createdAt'),
  userNotifications('user_notifications'),

  // 🔹 Exam fields
  examId('exam_id'),
  examIdSubject('exam_idSubject'),
  examIdTeacher('exam_idTeacher'),
  examExamResult('exam_ExamResult'),
  examCreatedAt('exam_createdAt'),
  examFinishAt('exam_FinishAt'),

  // 🔹 ExamResult subfields
  examResultEmailSt('examResult_emailSt'),
  examResultDegree('examResult_degree'),
  examResultQandA('examResult_Q&A'),

  // 🔹 Subject fields
  subjectIdSubject('subject_idSubject'),
  subjectCodeSub('subject_codeSub'),
  subjectNameSubject('subject_nameSubject'),
  subjectTeacher('subject_teacher'),
  subjectEmailSts('subject_emailSts'),
  subjectCreatedAt('subject_createdAt'),

  // 🔹 Teacher object (inside Subject)
  teacherEmail('teacher_email'),
  teacherName('teacher_name');

  final String key;
  const DataKey(this.key);
}