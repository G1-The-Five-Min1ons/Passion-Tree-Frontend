import 'package:passion_tree_frontend/core/config/account_preference_defaults.dart';

class UpdateProfileRequest {
  final String location;
  final String bio;
  final String? avatarUrl;
  final String? phoneNumber;
  final String timeZone;
  final String dateFormat;

  UpdateProfileRequest({
    required this.location,
    required this.bio,
    this.avatarUrl,
    this.phoneNumber,
    this.timeZone = AccountPreferenceDefaults.timeZoneApiValue,
    this.dateFormat = AccountPreferenceDefaults.dateFormatApiValue,
  });

  Map<String, dynamic> toJson() => {
    'location': location,
    'bio': bio,
    'avatar_url': avatarUrl ?? '',
    'phone_number': phoneNumber ?? '',
    'time_zone': timeZone,
    'date_format': dateFormat,
  };
}
