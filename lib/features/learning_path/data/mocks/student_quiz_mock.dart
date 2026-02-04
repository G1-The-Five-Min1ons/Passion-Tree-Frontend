
import 'package:passion_tree_frontend/features/learning_path/domain/entities/student_quiz.dart';

final QuizStudent mockStudentQuiz = QuizStudent(
  title: 'Ecosystem',
  questions: [
    QuizQuestionStudent(
      question: '1. ภาวะความสัมพันธ์ของสิ่งมีชีวิตใดเป็นแบบ +/+',
      choices: ['คนกับคน', 'ควายกับหมี', 'ป่าดิบชื้น', 'ควายกับนกเอี้ยง'],
      correctIndex: 3,
    ),
    QuizQuestionStudent(
      question: '2. ป่าชนิดใดเป็นป่าแบบไม่ผลัดใบ',
      choices: ['ป่าดิบชื้น', 'ป่าเบญจพรรณ', 'ป่าเต็งรัง', 'ป่าหญ้า'],
      correctIndex: 0,
    ),
  ],
);
