import '../../domain/entities/course.dart';

final mockCourses = [
  Course(
    title: 'Biology 101',
    description: 'มุ่งเน้นให้ผู้เรียนเข้าใจความสัมพันธ์ของสิ่งมีชีวิต...',
    updatedAt: '2 days ago',
    students: 200,
    modules: 15,
  ),
  Course(
    title: 'Chemistry Basics',
    description: 'พื้นฐานปฏิกิริยาเคมีและโครงสร้างอะตอม',
    updatedAt: '5 days ago',
    students: 180,
    modules: 12,
  ),
];
