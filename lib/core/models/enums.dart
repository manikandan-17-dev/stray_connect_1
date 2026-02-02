/// User roles in the StrayCare Connect app
enum UserRole {
  citizen('citizen', 'Citizen', '👤', 'Report stray animals in your area'),
  volunteer('volunteer', 'Volunteer', '🤝', 'Rescue and help stray animals'),
  ngo('ngo', 'NGO Organization', '🐾', 'Manage rescue operations'),
  vet('vet', 'Veterinary Doctor', '🏥', 'Provide medical care');

  final String value;
  final String displayName;
  final String emoji;
  final String description;

  const UserRole(this.value, this.displayName, this.emoji, this.description);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.citizen,
    );
  }
}

/// Report status flow
enum ReportStatus {
  reported('reported', 'Reported', '📝'),
  accepted('accepted', 'Accepted', '✅'),
  rescueInProgress('rescue_in_progress', 'Rescue in Progress', '🚑'),
  atClinic('at_clinic', 'At Clinic', '🏥'),
  resolved('resolved', 'Resolved', '✔️');

  final String value;
  final String displayName;
  final String emoji;

  const ReportStatus(this.value, this.displayName, this.emoji);

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.reported,
    );
  }
}

/// Animal types
enum AnimalType {
  dog('dog', 'Dog', '🐕'),
  cat('cat', 'Cat', '🐈'),
  cow('cow', 'Cow', '🐄'),
  bird('bird', 'Bird', '🐦'),
  other('other', 'Other', '🦮');

  final String value;
  final String displayName;
  final String emoji;

  const AnimalType(this.value, this.displayName, this.emoji);

  static AnimalType fromString(String value) {
    return AnimalType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AnimalType.other,
    );
  }
}

/// Animal condition
enum AnimalCondition {
  injured('injured', 'Injured', '🤕'),
  sick('sick', 'Sick', '🤒'),
  accident('accident', 'Accident', '🚗'),
  aggressive('aggressive', 'Aggressive', '😠'),
  pregnant('pregnant', 'Pregnant', '🤰'),
  newborn('newborn', 'Newborn', '👶');

  final String value;
  final String displayName;
  final String emoji;

  const AnimalCondition(this.value, this.displayName, this.emoji);

  static AnimalCondition fromString(String value) {
    return AnimalCondition.values.firstWhere(
      (condition) => condition.value == value,
      orElse: () => AnimalCondition.injured,
    );
  }
}

/// Emergency level
enum EmergencyLevel {
  low('low', 'Low', '✅'),
  medium('medium', 'Medium', '⚠️'),
  critical('critical', 'Critical', '🚨');

  final String value;
  final String displayName;
  final String emoji;

  const EmergencyLevel(this.value, this.displayName, this.emoji);

  static EmergencyLevel fromString(String value) {
    return EmergencyLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => EmergencyLevel.medium,
    );
  }
}
