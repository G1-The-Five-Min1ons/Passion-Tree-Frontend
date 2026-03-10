class ApplyTeacherRequest {
  final String phoneNumber;
  final String reason;
  final String teachingHistory;

  ApplyTeacherRequest({
    required this.phoneNumber,
    required this.reason,
    required this.teachingHistory,
  });

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'reason': reason,
      'teaching_history': teachingHistory,
    };
  }
}
