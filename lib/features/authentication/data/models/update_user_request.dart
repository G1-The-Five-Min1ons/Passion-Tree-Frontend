class UpdateUserRequest {
  final String firstName;
  final String lastName;

  UpdateUserRequest({
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
  };
}
