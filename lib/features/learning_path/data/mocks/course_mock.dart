import 'package:passion_tree_frontend/features/learning_path/domain/entities/course.dart';


final mockCourses = [
  Course(
    title: 'Biology 101',
    description: 'มุ่งเน้นให้ผู้เรียนเข้าใจความสัมพันธ์ของสิ่งมีชีวิต...',
    instructor: 'ดร.บีเค ',
    students: 200,
    modules: 15,
    rating: 4.8,
    imageAsset: 'assets/images/courses/biology_101.png',
    category: 'Science',
  ),
  Course(
    title: 'Microbiology',
    description: 'เรียนเกี่ยวกับสิ่งมีชีวิตขนาดเล็กที่มองไม่เห็นด้วยตาเปล่า...',
    instructor: 'อ.อะตอม',
    students: 180,
    modules: 12,
    rating: 4.8,
    imageAsset: 'assets/images/courses/microbiology.png',
    category: 'Science',
  ),
  Course(
    title: 'Genetics',
    description: 'ศึกษาพันธุศาสตร์และการถ่ายทอดลักษณะทางพันธุกรรม...',
    instructor: 'ดร.จีโนม',
    students: 220,
    modules: 18,
    rating: 4.9,
    imageAsset: 'assets/images/courses/genetics.png',
    category: 'Science',
  ),
  Course(
    title: 'Criminal Law',
    description: 'มุ่งเน้นให้ผู้เรียนเข้าใจหลักกฎหมายอาญาและองค์ประกอบความผิด...',
    instructor: 'อ.เอิร์ธ',
    students: 150,
    modules: 10,
    rating: 4.7,
    imageAsset: 'assets/images/courses/law.png',
    category: 'Law',
  ),
  Course(
    title: 'Cybersecurity',
    description: 'เน้นให้ผู้เรียนเข้าใจหลักการรักษาความปลอดภัยไซเบอร์และภัยคุกคามดิจิทัล...',
    instructor: 'ดร.แอนนาโตมี่',
    students: 300,
    modules: 20,
    rating: 4.9,
    imageAsset: 'assets/images/courses/cybersecurity.png',
    category: 'Technology',
  ),
  Course(
    title: 'C++',
    description: 'เน้นให้ผู้เรียนเข้าใจโครงสร้างภาษาและแนวคิดการเขียนโปรแกรมใน C++..',
    instructor: 'อ.ฟลอร่า',
    students: 130,
    modules: 8,
    rating: 4.6,
    imageAsset: 'assets/images/courses/tech.png',
    category: 'Technology',
  ),
  Course(
    title: 'Cell Biology',
    description:'เรียนเกี่ยวกับสิ่งมีชีวิตขนาดเล็กที่มองไม่เห็นด้วยตาเปล่า เช่น แบคทีเรีย...',
    instructor: 'ดร.ดีพ',
    students: 250,
    modules: 16,
    rating: 4.8,
    imageAsset: 'assets/images/courses/cell.png',
    category: 'Science',
  ),
  Course(
    title: 'Chemistry',
    description: 'มุ่งเน้นให้ผู้เรียนเข้าใจองค์ประกอบและปฏิกิริยาต่างๆทางเคมี...',
    instructor: 'อ.ลอว์เรนซ์',
    students: 170,
    modules: 14,
    rating: 4.7,
    imageAsset: 'assets/images/courses/chemistry.png',
    category: 'Science',
  ),
  
  
];

/// คอร์สยอดนิยม
final popularCourses = mockCourses.take(3).toList();

/// คอร์สทั้งหมด
final allCourses = mockCourses;
