// lib/services/doctor_api_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../models/kick_count.dart';
import '../models/contraction.dart';
import '../models/vital_signs.dart';
import 'api_service.dart';

/// Covers every doctor-facing REST endpoint.
/// All methods throw [DoctorApiException] on non-2xx responses.
class DoctorApiService {
  static final DoctorApiService instance = DoctorApiService._init();

  final ApiService _api = ApiService.instance;
  final _storage = const FlutterSecureStorage();

  DoctorApiService._init();

  // ─── Auth header ──────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _decode(String body) =>
      jsonDecode(body) as Map<String, dynamic>;

  List<dynamic> _decodeList(String body) => jsonDecode(body) as List<dynamic>;

  void _assertOk(int statusCode, String body) {
    if (statusCode < 200 || statusCode >= 300) {
      throw DoctorApiException(statusCode, body);
    }
  }

  // ─── Patient List ─────────────────────────────────────────────────────────

  /// GET /doctor/patients
  /// Returns a list of patients assigned to the logged-in doctor.
  Future<List<Map<String, dynamic>>> getPatients() async {
    final res =
        await _api.get('/doctor/patients', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body).cast<Map<String, dynamic>>();
  }

  // ─── Per-patient read-only endpoints ──────────────────────────────────────

  /// GET /doctor/patients/:id/profile
  Future<UserProfile> getPatientProfile(String patientId) async {
    final res = await _api.get(
      '/doctor/patients/$patientId/profile',
      headers: await _headers(),
    );
    _assertOk(res.statusCode, res.body);
    return UserProfile.fromMap(_decode(res.body));
  }

  /// GET /doctor/patients/:id/kicks
  Future<List<KickCount>> getPatientKicks(String patientId) async {
    final res = await _api.get(
      '/doctor/patients/$patientId/kicks',
      headers: await _headers(),
    );
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => KickCount.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /doctor/patients/:id/vitals
  Future<List<VitalSigns>> getPatientVitals(String patientId) async {
    final res = await _api.get(
      '/doctor/patients/$patientId/vitals',
      headers: await _headers(),
    );
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => VitalSigns.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /doctor/patients/:id/contractions
  Future<List<Contraction>> getPatientContractions(String patientId) async {
    final res = await _api.get(
      '/doctor/patients/$patientId/contractions',
      headers: await _headers(),
    );
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => Contraction.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class DoctorApiException implements Exception {
  final int statusCode;
  final String body;
  DoctorApiException(this.statusCode, this.body);

  @override
  String toString() => 'DoctorApiException($statusCode): $body';
}
