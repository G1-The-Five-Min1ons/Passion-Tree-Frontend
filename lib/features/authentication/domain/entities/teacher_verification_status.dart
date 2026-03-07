import 'package:equatable/equatable.dart';

class TeacherVerificationStatus extends Equatable {
  final String phoneNumber;
  final bool hasPhoneNumber;
  final bool hasApplied;
  final String applicationStatus;
  final bool isVerified;

  const TeacherVerificationStatus({
    required this.phoneNumber,
    required this.hasPhoneNumber,
    required this.hasApplied,
    required this.applicationStatus,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [
    phoneNumber,
    hasPhoneNumber,
    hasApplied,
    applicationStatus,
    isVerified,
  ];
}
