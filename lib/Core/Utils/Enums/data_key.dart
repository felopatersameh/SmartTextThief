enum DataKey {
  // Newly requested fields
  readIn('readIn'),
  readOut('readOut'),
  updatedAt('updatedAt'),
  createdAt('createdAt'),
  body('body'),
  token('token'),
  titleTopic('titleTopic'),
  topicId('topicId'),
  id('id'),
  id_('_id'),

  // 🔹 User fields
  photo('photo'),
  name('name'),
  email('email'),
  role('role'),

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
  examResultEmailSt('examResult_emailSt'), //!

  examResultDegree('examResult_degree'), //!

  examResultQandA('examResult_Q&A'), //!

  type('type'),
  isRandom('isRandom'),
  questionCount('questionCount'),
  levelExam('levelExam'),
  timeMinutes('timeMinutes'),
  startAt('startAt'),
  endAt('endAt'),
  questions('questions'),
  text('text'),
  correctAnswer('correctAnswer'),
  options('options'),
  choice('choice'),

  geminiModel('geminiModel'), //!

  // 🔹 Subject fields
  code('code'),
  instructorInfo('instructorInfo'),
  status('status'),

  // 🔹 ExamResultQA fields (added)
  questionId('questionId'),
  questionType('questionType'),
  questionText('questionText'),
  studentAnswer('studentAnswer'),
  score('score'),
  evaluated('evaluated');

  final String key;
  const DataKey(this.key);
}
