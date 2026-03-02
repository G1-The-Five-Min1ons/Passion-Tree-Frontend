class DiscordLoginRequest {
  final String code;

  DiscordLoginRequest({required this.code});

  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }
}
