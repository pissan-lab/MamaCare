// lib/services/auth_service.dart

import 'dart:math';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import './database_service.dart';
import './system_log_service.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final _secureStorage = const FlutterSecureStorage();
  final _dbService = DatabaseService.instance;
  final _logService = SystemLogService.instance;

  User? _currentUser;
  
  AuthService._init();

  User? get currentUser => _currentUser;
  
  UserRole? get currentUserRole => _currentUser?.role;

  // Initialize auth on app start
  Future<void> initialize() async {
    await _loadSavedUser();
  }

  // Load saved user from secure storage
  Future<void> _loadSavedUser() async {
    try {
      final email = await _secureStorage.read(key: 'user_email');
      if (email != null) {
        final users = await _dbService.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
        );
        if (users.isNotEmpty) {
          _currentUser = User.fromMap(users.first);
        }
      }
    } catch (e) {
      print('❌ Error loading saved user: $e');
    }
  }

  // Login user (basic email/password check).  If multi-factor is enabled
  // for the account, the caller should invoke [sendMfaCode] and then
  // [verifyMfaCode] separately; the logic for deciding whether to prompt for
  // the code is left to the UI layer.
  Future<bool> login(String email, String password) async {
    try {
      final users = await _dbService.query(
        'users',
        where: 'email = ? AND password = ? AND is_active = 1',
        whereArgs: [email, password],
      );

      if (users.isEmpty) {
        print('❌ Invalid email or password');
        return false;
      }

      _currentUser = User.fromMap(users.first);
      
      // Update last login
      await _dbService.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [_currentUser!.id],
      );

      // Save to secure storage
      await _secureStorage.write(key: 'user_email', value: email);

      // Log login action
      await _logService.logAction(
        userId: _currentUser!.id.toString(),
        userRole: _currentUser!.role.toString().split('.').last,
        action: 'LOGIN',
        description: '${_currentUser!.name} logged in',
      );

      print('✅ Login successful for ${_currentUser!.email}');
      return true;
    } catch (e) {
      print('❌ Login error: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      if (_currentUser != null) {
        await _logService.logAction(
          userId: _currentUser!.id.toString(),
          userRole: _currentUser!.role.toString().split('.').last,
          action: 'LOGOUT',
          description: '${_currentUser!.name} logged out',
        );
      }

      await _secureStorage.delete(key: 'user_email');
      _currentUser = null;
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    }
  }

  // Register new user (admin only)
  Future<bool> registerUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? specialization,
    String? phoneNumber,
  }) async {
    try {
      // Check if email exists
      final existing = await _dbService.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );

      if (existing.isNotEmpty) {
        print('❌ Email already exists');
        return false;
      }

      final newUser = User(
        email: email,
        password: password,
        name: name,
        role: role,
        specialization: specialization,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _dbService.insert('users', newUser.toMap());

      // Log user creation
      await _logService.logAction(
        userId: _currentUser?.id.toString() ?? 'system',
        userRole: _currentUser?.role.toString().split('.').last ?? 'system',
        action: 'USER_CREATED',
        description: 'New user created: $name ($email)',
        affectedRecordType: 'users',
        newValue: email,
      );

      print('✅ User registered successfully');
      return true;
    } catch (e) {
      print('❌ Registration error: $e');
      return false;
    }
  }

  // Send a one-time code to the user's registered phone number or email.
  // In a production system you would integrate with an SMS/email provider.
  // Here we simply store the code in secure storage keyed by email so that the
  // UI layer can call [verifyMfaCode].
  Future<String> sendMfaCode(String email) async {
    final code = (100000 + (Random().nextInt(900000))).toString();
    await _secureStorage.write(key: 'mfa_code_$email', value: code);
    // TODO: actually deliver the code via SMS/email
    print('🔐 MFA code for $email: $code');
    return code;
  }

  /// Verify the one-time code generated by [sendMfaCode].
  Future<bool> verifyMfaCode(String email, String code) async {
    final stored = await _secureStorage.read(key: 'mfa_code_$email');
    final valid = stored != null && stored == code;
    if (valid) {
      await _secureStorage.delete(key: 'mfa_code_$email');
    }
    return valid;
  }

  // Get all users (admin only)
  Future<List<User>> getAllUsers() async {
    try {
      if (_currentUser?.role != UserRole.admin) {
        print('❌ Unauthorized: Only admins can view all users');
        return [];
      }

      final users = await _dbService.query('users');
      return users.map((u) => User.fromMap(u)).toList();
    } catch (e) {
      print('❌ Error fetching users: $e');
      return [];
    }
  }

  // Deactivate user (admin only)
  Future<bool> deactivateUser(int userId, String reason) async {
    try {
      if (_currentUser?.role != UserRole.admin) {
        print('❌ Unauthorized: Only admins can deactivate users');
        return false;
      }

      await _dbService.update(
        'users',
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [userId],
      );

      // Log deactivation
      await _logService.logAction(
        userId: _currentUser!.id.toString(),
        userRole: _currentUser!.role.toString().split('.').last,
        action: 'USER_DEACTIVATED',
        description: reason,
        affectedRecordId: userId.toString(),
        affectedRecordType: 'users',
      );

      print('✅ User deactivated');
      return true;
    } catch (e) {
      print('❌ Error deactivating user: $e');
      return false;
    }
  }

  // Check if user is admin
  bool isAdmin() => _currentUser?.role == UserRole.admin;

  // Check if user is doctor
  bool isDoctor() => _currentUser?.role == UserRole.doctor;

  // Check if user is patient
  bool isPatient() => _currentUser?.role == UserRole.patient;

  // Update the current user's privacy preferences.  `consent` is a map
  // whose keys indicate a particular category of data (e.g. "location",
  // "healthMetrics") and values are booleans.
  Future<bool> updatePreferences(Map<String, dynamic> consent) async {
    if (_currentUser == null) return false;
    final updated = _currentUser!.copyWith(preferences: consent);
    await _dbService.update(
      'users',
      {'preferences': jsonEncode(consent)},
      where: 'id = ?',
      whereArgs: [_currentUser!.id],
    );
    _currentUser = updated;
    return true;
  }

  // Request export of the current user's data.  The returned map can be
  // converted to JSON or sent to a file picker for download.
  Future<Map<String, dynamic>> exportCurrentUserData() async {
    if (_currentUser == null) return {};
    return await _dbService.exportUserData(_currentUser!.id!);
  }

  // Delete all data belonging to the current user; after calling this, the
  // user will be logged out. This implements the "delete my data"
  // requirement.
  Future<void> deleteAccount() async {
    if (_currentUser == null) return;
    await _dbService.deleteAllUserData(_currentUser!.id!);
    await logout();
  }

  // Check if user is logged in
  bool isLoggedIn() => _currentUser != null;
}
