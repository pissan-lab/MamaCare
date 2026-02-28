// lib/models/user_profile.dart

class UserProfile {
  final int? id;
  final String name;
  final String dueDate;
  final String lastPeriodDate;
  final String? pregnancyType;
  final String createdAt;

  UserProfile({
    this.id,
    required this.name,
    required this.dueDate,
    required this.lastPeriodDate,
    this.pregnancyType,
    required this.createdAt,
  });

  // Convert UserProfile to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'due_date': dueDate,
      'last_period_date': lastPeriodDate,
      'pregnancy_type': pregnancyType,
      'created_at': createdAt,
    };
  }

  // Create UserProfile from Map (when reading from database)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      dueDate: map['due_date'],
      lastPeriodDate: map['last_period_date'],
      pregnancyType: map['pregnancy_type'],
      createdAt: map['created_at'],
    );
  }

  // Create a copy of UserProfile with some fields changed
  UserProfile copyWith({
    int? id,
    String? name,
    String? dueDate,
    String? lastPeriodDate,
    String? pregnancyType,
    String? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dueDate: dueDate ?? this.dueDate,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      pregnancyType: pregnancyType ?? this.pregnancyType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}