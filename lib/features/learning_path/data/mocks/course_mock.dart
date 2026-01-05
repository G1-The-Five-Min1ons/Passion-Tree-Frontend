import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';

final mockCourses = [
  Course(
    title: 'Biology 101',
    description: 'มุ่งเน้นให้ผู้เรียนเข้าใจความสัมพันธ์ของสิ่งมีชีวิต...',
    instructor: 'ดร.บีเค ',
    students: 200,
    modules: 15,
    imageAsset: 'assets/images/courses/biology_101.png',
  ),
  Course(
    title: 'Microbiology',
    description: 'เรียนเกี่ยวกับสิ่งมีชีวิตขนาดเล็กที่มองไม่เห็นด้วยตาเปล่า...',
    instructor: 'อ.อะตอม',
    students: 180,
    modules: 12,
    imageAsset: 'assets/images/courses/microbiology.png',
  ),
];

