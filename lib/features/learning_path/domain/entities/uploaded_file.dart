class UploadedFileItem {
  final String name;
  final int size;
  final String? path; // เป็น nullable

  const UploadedFileItem({required this.name, required this.size, this.path});
}
