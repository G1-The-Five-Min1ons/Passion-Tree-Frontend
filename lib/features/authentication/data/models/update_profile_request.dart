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

    // Only include non-null fields that are explicitly provided
    // This allows the backend to distinguish between:
    // 1. Not updating a field (field not present)
    // 2. Setting a field to empty (field present with empty value)
    // 3. Setting a field to a specific value (field present with value)
    
    if (location != null) json['location'] = location;
    if (bio != null) json['bio'] = bio;
    if (avatarUrl != null) json['avatar_url'] = avatarUrl;
    if (phoneNumber != null) json['phone_number'] = phoneNumber;
    
    // Only include timezone and date format when explicitly provided.
    // This prevents accidental overwrites when performing partial updates.
    if (timeZone != null) json['time_zone'] = timeZone;
    if (dateFormat != null) json['date_format'] = dateFormat;

    return json;
  }
}
