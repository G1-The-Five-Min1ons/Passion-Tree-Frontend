class UpdateProfileRequest {
  final String location;
  final String bio;
  final String? avatarUrl;

  UpdateProfileRequest({
    required this.location,
    required this.bio,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'location': location,
    'bio': bio,
    'avatar_url': avatarUrl ?? '',
  };
}
