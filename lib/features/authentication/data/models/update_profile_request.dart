import 'package:passion_tree_frontend/core/config/account_preference_defaults.dart';

class UpdateProfileRequest {
  final String? location;
  final String? bio;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? timeZone;
  final String? dateFormat;

  UpdateProfileRequest({
    this.location,
    this.bio,
    this.avatarUrl,
    this.phoneNumber,
    this.timeZone,
    this.dateFormat,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // Only include fields that are explicitly provided
    if (location != null) json['location'] = location;
    if (bio != null) json['bio'] = bio;
    if (avatarUrl != null) json['avatar_url'] = avatarUrl;
    if (phoneNumber != null) json['phone_number'] = phoneNumber;
    
    // Include timezone and date format with defaults if not provided
    json['time_zone'] = timeZone ?? AccountPreferenceDefaults.timeZoneApiValue;
    json['date_format'] = dateFormat ?? AccountPreferenceDefaults.dateFormatApiValue;

    return json;
  }
}
