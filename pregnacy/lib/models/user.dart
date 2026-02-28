// lib/models/user.dart

import 'dart:convert';

enum UserRole { admin, doctor, patient }

/// A model representing a user account.  The optional `preferences` map can be
/// used to store consent flags (e.g. whether the user allows collection of
/// activity data) or other privacy-related settings.  The data is serialized to
/// JSON when stored in the database.
class User {
  final int? id;
  final String email;
  final String password; // Note: In production, never store plain passwords
  final String name;
  final UserRole role;
  final String? specialization; // For doctors
  final String? phoneNumber;
  final bool isActive;
  final String createdAt;
  final String? lastLogin;
  final Map<String, dynamic>? preferences;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.specialization,
    this.phoneNumber,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': role.toString().split('.').last,
      'specialization': specialization,
      'phone_number': phoneNumber,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'last_login': lastLogin,
      'preferences': preferences != null ? jsonEncode(preferences) : null,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      name: map['name'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
      ),
      specialization: map['specialization'],
      phoneNumber: map['phone_number'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
      lastLogin: map['last_login'],
      preferences: map['preferences'] != null
          ? jsonDecode(map['preferences'] as String)
          : null,
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? password,
    String? name,
    UserRole? role,
    String? specialization,
    String? phoneNumber,
    bool? isActive,
    String? createdAt,
    String? lastLogin,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      specialization: specialization ?? this.specialization,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferences: preferences ?? this.preferences,
    );
  }
}
