class VerifyEmailRequest {
  final String code;

  VerifyEmailRequest({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}
