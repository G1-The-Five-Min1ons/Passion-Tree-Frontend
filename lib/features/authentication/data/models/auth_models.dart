class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? bio;
  final String? location;
  final String? avatarUrl;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
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
    if (bio != null) 'bio': bio,
    if (location != null) 'location': location,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
  };
}

class LoginRequest {
  final String identifier;
  final String password;

  LoginRequest({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'password': password,
  };
}

class User {
  final String userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final int heartCount;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.heartCount,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: json['user_id'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    role: json['role'] as String,
    heartCount: json['heart_count'] as int,
    isEmailVerified: json['is_email_verified'] as bool,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'username': username,
    'email': email,
    'first_name': firstName,
    'last_name': lastName,
    'role': role,
    'heart_count': heartCount,
    'is_email_verified': isEmailVerified,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class Profile {
  final String profileId;
  final String? avatarUrl;
  final String? rankName;
  final int learningStreak;
  final int learningCount;
  final String? location;
  final String? bio;
  final int level;
  final int xp;
  final int hourLearned;
  final String userId;

  Profile({
    required this.profileId,
    this.avatarUrl,
    this.rankName,
    required this.learningStreak,
    required this.learningCount,
    this.location,
    this.bio,
    required this.level,
    required this.xp,
    required this.hourLearned,
    required this.userId,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    profileId: json['Profile_ID'] as String,
    avatarUrl: json['Avatar_URL'] as String?,
    rankName: json['Rank_Name'] as String?,
    learningStreak: json['Learning_streak'] as int,
    learningCount: json['Learning_count'] as int,
    location: json['Location'] as String?,
    bio: json['Bio'] as String?,
    level: json['Level'] as int,
    xp: json['XP'] as int,
    hourLearned: json['Hour_learned'] as int,
    userId: json['user_id'] as String,
  );

  Map<String, dynamic> toJson() => {
    'Profile_ID': profileId,
    'Avatar_URL': avatarUrl,
    'Rank_Name': rankName,
    'Learning_streak': learningStreak,
    'Learning_count': learningCount,
    'Location': location,
    'Bio': bio,
    'Level': level,
    'XP': xp,
    'Hour_learned': hourLearned,
    'user_id': userId,
  };
}

class RegisterResponse {
  final bool success;
  final String message;
  final String userId;
  final String? token;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.userId,
    this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      userId: data?['user_id'] as String,
      token: data?['token'] as String?,
    );
  }
}

class LoginResponse {
  final bool success;
  final String token;

  LoginResponse({
    required this.success,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      success: json['success'] as bool,
      token: data['token'] as String,
    );
  }
}

class VerifyEmailRequest {
  final String code;

  VerifyEmailRequest({required this.code});

  Map<String, dynamic> toJson() => {'code': code};
}

class ResendVerificationRequest {
  final String email;

  ResendVerificationRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class ResetPasswordRequest {
  final String code;
  final String newPassword;

  ResetPasswordRequest({
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'new_password': newPassword,
  };
}

class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'old_password': oldPassword,
    'new_password': newPassword,
  };
}

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      error: json['error'] as String?,
    );
  }
}
