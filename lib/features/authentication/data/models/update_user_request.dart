class UpdateUserRequest {
  final String username;
  final String firstName;
  final String lastName;

  UpdateUserRequest({
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
  };
}
