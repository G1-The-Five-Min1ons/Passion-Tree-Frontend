class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String role;
  final String? bio;
  final String? location;
  final String? avatarUrl;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.bio,
    this.location,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
    if (bio != null) 'bio': bio,
    if (location != null) 'location': location,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
  };
}
