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
  examStartedAt('startedAt'),
  examStatic('exam_static'),

  // 🔹 ExamResult subfields
  examResultEmailSt('examResult_emailSt'),
  examResultDegree('examResult_degree'),
  examResultQandA('examResult_Q&A'),
  typeExam('typeExam'),
  randomQuestions('randomQuestions'),
  numberOfQuestions('numberOfQuestions'),
  levelExam('levelExam'),
  time('time'),

  // 🔹 Subject fields
  subjectIdSubject('subject_idSubject'),
  subjectCodeSub('subject_codeSub'),
  subjectNameSubject('subject_nameSubject'),
  subjectTeacher('subject_teacher'),
  subjectEmailSts('subject_emailSts'),
  subjectCreatedAt('subject_createdAt'),

  // 🔹 Teacher object (inside Subject)
  teacherEmail('teacher_email'),
  teacherName('teacher_name'),

  // 🔹 ExamResultQA fields (added)
  questionId('questionId'),
  questionType('questionType'),
  questionText('questionText'),
  options('options'),
  correctAnswer('correctAnswer'),
  studentAnswer('studentAnswer'),
  score('score');

  final String key;
  const DataKey(this.key);
}