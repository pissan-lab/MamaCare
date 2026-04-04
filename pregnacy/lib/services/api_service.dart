// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// API Service for Django Backend Integration
/// Handles all HTTP requests to the Django backend running at http://127.0.0.1:8000/
/// Provides CRUD operations for all data models
class ApiService {
  static final ApiService instance = ApiService._init();
  final String baseUrl;
  String? _authToken;

  ApiService._init({this.baseUrl = 'http://127.0.0.1:8000'});

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Get default headers with authentication
  Map<String, String> _getHeaders({Map<String, String>? additional}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Token $_authToken';
    }
    headers.addAll(additional ?? {});
    return headers;
  }

  /// Generic GET request
  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    final url = Uri.parse('$baseUrl$path');
    return http.get(url, headers: _getHeaders(additional: headers));
  }

  /// Generic POST request
  Future<http.Response> post(String path,
      {Map<String, String>? headers, Object? body}) {
    final url = Uri.parse('$baseUrl$path');
    return http.post(url, 
        headers: _getHeaders(additional: headers), 
        body: body is String ? body : jsonEncode(body));
  }

  /// Generic PUT request
  Future<http.Response> put(String path,
      {Map<String, String>? headers, Object? body}) {
    final url = Uri.parse('$baseUrl$path');
    return http.put(url, 
        headers: _getHeaders(additional: headers), 
        body: body is String ? body : jsonEncode(body));
  }

  /// Generic PATCH request
  Future<http.Response> patch(String path,
      {Map<String, String>? headers, Object? body}) {
    final url = Uri.parse('$baseUrl$path');
    return http.patch(url, 
        headers: _getHeaders(additional: headers), 
        body: body is String ? body : jsonEncode(body));
  }

  /// Generic DELETE request
  Future<http.Response> delete(String path, {Map<String, String>? headers}) {
    final url = Uri.parse('$baseUrl$path');
    return http.delete(url, headers: _getHeaders(additional: headers));
  }

  // ============== AUTHENTICATION ==============

  /// User login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/api/auth/login/',
        body: {'email': email, 'password': password});
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        setAuthToken(data['token']);
      }
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// User registration
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final response = await post('/api/auth/register/',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
        });
    
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['access'] != null) {
        setAuthToken(data['access']);
      }
      return data;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  /// User logout
  Future<void> logout() async {
    await post('/api/auth/logout/');
    _authToken = null;
  }

  // ============== USER OPERATIONS ==============

  /// Get all users (admin only)
  Future<List<dynamic>> getAllUsers() async {
    final response = await get('/api/users/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>> getUser(int userId) async {
    final response = await get('/api/users/$userId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await get('/api/users/me/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch current user');
    }
  }

  /// Create new user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await post('/api/users/', body: userData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  /// Update user
  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> userData) async {
    final response = await put('/api/users/$userId/', body: userData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  /// Delete user
  Future<void> deleteUser(int userId) async {
    final response = await delete('/api/users/$userId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  // ============== USER PROFILE OPERATIONS ==============

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await get('/api/profiles/$userId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  /// Create user profile
  Future<Map<String, dynamic>> createUserProfile(Map<String, dynamic> profileData) async {
    final response = await post('/api/profiles/', body: profileData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user profile: ${response.body}');
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(int profileId, Map<String, dynamic> profileData) async {
    final response = await put('/api/profiles/$profileId/', body: profileData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user profile: ${response.body}');
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(int profileId) async {
    final response = await delete('/api/profiles/$profileId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user profile');
    }
  }

  // ============== VITAL SIGNS OPERATIONS ==============

  /// Get all vital signs for a patient
  Future<List<dynamic>> getVitalSigns(int patientId) async {
    final response = await get('/api/vital-signs/?patient_id=$patientId');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch vital signs');
    }
  }

  /// Get vital signs by ID
  Future<Map<String, dynamic>> getVitalSignsById(int vitalSignsId) async {
    final response = await get('/api/vital-signs/$vitalSignsId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch vital signs');
    }
  }

  /// Create vital signs record
  Future<Map<String, dynamic>> createVitalSigns(Map<String, dynamic> vitalsData) async {
    final response = await post('/api/vital-signs/', body: vitalsData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create vital signs: ${response.body}');
    }
  }

  /// Update vital signs record
  Future<Map<String, dynamic>> updateVitalSigns(int vitalSignsId, Map<String, dynamic> vitalsData) async {
    final response = await put('/api/vital-signs/$vitalSignsId/', body: vitalsData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update vital signs: ${response.body}');
    }
  }

  /// Delete vital signs record
  Future<void> deleteVitalSigns(int vitalSignsId) async {
    final response = await delete('/api/vital-signs/$vitalSignsId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete vital signs');
    }
  }

  // ============== KICK COUNT OPERATIONS ==============

  /// Get all kick counts for a patient
  Future<List<dynamic>> getKickCounts(int patientId) async {
    final response = await get('/api/kick-counts/?patient_id=$patientId');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch kick counts');
    }
  }

  /// Get kick count by ID
  Future<Map<String, dynamic>> getKickCountById(int kickCountId) async {
    final response = await get('/api/kick-counts/$kickCountId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch kick count');
    }
  }

  /// Create kick count record
  Future<Map<String, dynamic>> createKickCount(Map<String, dynamic> kickData) async {
    final response = await post('/api/kick-counts/', body: kickData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create kick count: ${response.body}');
    }
  }

  /// Update kick count record
  Future<Map<String, dynamic>> updateKickCount(int kickCountId, Map<String, dynamic> kickData) async {
    final response = await put('/api/kick-counts/$kickCountId/', body: kickData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update kick count: ${response.body}');
    }
  }

  /// Delete kick count record
  Future<void> deleteKickCount(int kickCountId) async {
    final response = await delete('/api/kick-counts/$kickCountId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete kick count');
    }
  }

  // ============== CONTRACTION OPERATIONS ==============

  /// Get all contractions for a patient
  Future<List<dynamic>> getContractions(int patientId) async {
    final response = await get('/api/contractions/?patient_id=$patientId');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch contractions');
    }
  }

  /// Get contraction by ID
  Future<Map<String, dynamic>> getContractionById(int contractionId) async {
    final response = await get('/api/contractions/$contractionId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch contraction');
    }
  }

  /// Create contraction record
  Future<Map<String, dynamic>> createContraction(Map<String, dynamic> contractionData) async {
    final response = await post('/api/contractions/', body: contractionData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create contraction: ${response.body}');
    }
  }

  /// Update contraction record
  Future<Map<String, dynamic>> updateContraction(int contractionId, Map<String, dynamic> contractionData) async {
    final response = await put('/api/contractions/$contractionId/', body: contractionData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update contraction: ${response.body}');
    }
  }

  /// Delete contraction record
  Future<void> deleteContraction(int contractionId) async {
    final response = await delete('/api/contractions/$contractionId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete contraction');
    }
  }

  // ============== HEALTH CONTENT OPERATIONS ==============

  /// Get all health content
  Future<List<dynamic>> getHealthContent() async {
    final response = await get('/api/health-content/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch health content');
    }
  }

  /// Get health content by ID
  Future<Map<String, dynamic>> getHealthContentById(int contentId) async {
    final response = await get('/api/health-content/$contentId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch health content');
    }
  }

  /// Create health content (admin only)
  Future<Map<String, dynamic>> createHealthContent(Map<String, dynamic> contentData) async {
    final response = await post('/api/health-content/', body: contentData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create health content: ${response.body}');
    }
  }

  /// Update health content (admin only)
  Future<Map<String, dynamic>> updateHealthContent(int contentId, Map<String, dynamic> contentData) async {
    final response = await put('/api/health-content/$contentId/', body: contentData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update health content: ${response.body}');
    }
  }

  /// Delete health content (admin only)
  Future<void> deleteHealthContent(int contentId) async {
    final response = await delete('/api/health-content/$contentId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete health content');
    }
  }

  // ============== DOCTOR-PATIENT ASSIGNMENT OPERATIONS ==============

  /// Get assignments for a doctor
  Future<List<dynamic>> getDoctorAssignments(int doctorId) async {
    final response = await get('/api/doctor-patient-assignments/?doctor_id=$doctorId');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch doctor assignments');
    }
  }

  /// Get assignment by ID
  Future<Map<String, dynamic>> getAssignmentById(int assignmentId) async {
    final response = await get('/api/doctor-patient-assignments/$assignmentId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch assignment');
    }
  }

  /// Create assignment
  Future<Map<String, dynamic>> createAssignment(Map<String, dynamic> assignmentData) async {
    final response = await post('/api/doctor-patient-assignments/', body: assignmentData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create assignment: ${response.body}');
    }
  }

  /// Update assignment
  Future<Map<String, dynamic>> updateAssignment(int assignmentId, Map<String, dynamic> assignmentData) async {
    final response = await put('/api/doctor-patient-assignments/$assignmentId/', body: assignmentData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update assignment: ${response.body}');
    }
  }

  /// Delete assignment
  Future<void> deleteAssignment(int assignmentId) async {
    final response = await delete('/api/doctor-patient-assignments/$assignmentId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete assignment');
    }
  }

  // ============== PARTNER ACCESS OPERATIONS ==============

  /// Get partner access records
  Future<List<dynamic>> getPartnerAccess(int patientId) async {
    final response = await get('/api/partner-access/?patient_id=$patientId');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch partner access');
    }
  }

  /// Get partner access by ID
  Future<Map<String, dynamic>> getPartnerAccessById(int accessId) async {
    final response = await get('/api/partner-access/$accessId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch partner access');
    }
  }

  /// Create partner access
  Future<Map<String, dynamic>> createPartnerAccess(Map<String, dynamic> accessData) async {
    final response = await post('/api/partner-access/', body: accessData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create partner access: ${response.body}');
    }
  }

  /// Update partner access
  Future<Map<String, dynamic>> updatePartnerAccess(int accessId, Map<String, dynamic> accessData) async {
    final response = await put('/api/partner-access/$accessId/', body: accessData);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update partner access: ${response.body}');
    }
  }

  /// Delete partner access
  Future<void> deletePartnerAccess(int accessId) async {
    final response = await delete('/api/partner-access/$accessId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete partner access');
    }
  }

  // ============== SYSTEM LOG OPERATIONS ==============

  /// Get system logs (admin only)
  Future<List<dynamic>> getSystemLogs() async {
    final response = await get('/api/system-logs/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch system logs');
    }
  }

  /// Get system log by ID
  Future<Map<String, dynamic>> getSystemLogById(int logId) async {
    final response = await get('/api/system-logs/$logId/');
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch system log');
    }
  }

  /// Create system log
  Future<Map<String, dynamic>> createSystemLog(Map<String, dynamic> logData) async {
    final response = await post('/api/system-logs/', body: logData);
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create system log: ${response.body}');
    }
  }

  /// Delete system log
  Future<void> deleteSystemLog(int logId) async {
    final response = await delete('/api/system-logs/$logId/');
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete system log');
    }
  }

}
