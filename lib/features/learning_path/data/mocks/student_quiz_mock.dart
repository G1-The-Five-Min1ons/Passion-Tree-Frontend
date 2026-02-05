
import 'package:passion_tree_frontend/features/learning_path/domain/entities/student_quiz.dart';

final QuizStudent mockStudentQuiz = QuizStudent(
  title: 'Ecosystem',
  questions: [
    QuizQuestionStudent(
      question: '1. ภาวะความสัมพันธ์ของสิ่งมีชีวิตใดเป็นแบบ +/+',
      choices: ['คนกับคน', 'หมาป่ากับกวาง', 'กาฝากกับต้นไม้', 'ควายกับนกเอี้ยง'],
      correctIndex: 3,
       reason:
          'เป็นความสัมพันธ์ที่ได้ประโยชน์ทั้งคู่ '
          'นกเอี้ยงได้อาหาร ส่วนควายได้การทำความสะอาด',
    ),
    QuizQuestionStudent(
      question: '2. ป่าชนิดใดเป็นป่าแบบไม่ผลัดใบ',
      choices: ['ป่าดิบชื้น', 'ป่าเบญจพรรณ', 'ป่าเต็งรัง', 'ป่าหญ้า'],
      correctIndex: 0,
      reason:
          'เนื่องจากเป็นป่าที่ไม่มีการผลัดใบของต้นไม้พร้อมกัน '
          'จึงทำให้ป่ามีสีเขียวตลอดทั้งปี',
    
    ),
  ],
);
