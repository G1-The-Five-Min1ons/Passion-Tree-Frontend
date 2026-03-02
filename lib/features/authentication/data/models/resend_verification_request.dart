class ResendVerificationRequest {
  final String email;

  ResendVerificationRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
