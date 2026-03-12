import 'package:passion_tree_frontend/features/authentication/domain/entities/teacher_verification_status.dart';

class TeacherVerificationStatusModel {
  final String phoneNumber;
  final bool hasPhoneNumber;
  final bool hasApplied;
  final String applicationStatus;
  final bool isVerified;

  TeacherVerificationStatusModel({
    required this.phoneNumber,
    required this.hasPhoneNumber,
    required this.hasApplied,
    required this.applicationStatus,
    required this.isVerified,
  });

  factory TeacherVerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return TeacherVerificationStatusModel(
      phoneNumber: json['phone_number'] as String? ?? '',
      hasPhoneNumber: json['has_phone_number'] as bool? ?? false,
      hasApplied: json['has_applied'] as bool? ?? false,
      applicationStatus: json['application_status'] as String? ?? 'none',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  TeacherVerificationStatus toEntity() {
    return TeacherVerificationStatus(
      phoneNumber: phoneNumber,
      hasPhoneNumber: hasPhoneNumber,
      hasApplied: hasApplied,
      applicationStatus: applicationStatus,
      isVerified: isVerified,
    );
  }
}
