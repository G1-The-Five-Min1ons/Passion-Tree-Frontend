class SelectRoleRequest {
  final String role;

  SelectRoleRequest({required this.role});

  Map<String, dynamic> toJson() => {'role': role};
}
