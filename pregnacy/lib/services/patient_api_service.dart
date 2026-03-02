// lib/services/patient_api_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../models/kick_count.dart';
import '../models/contraction.dart';
import '../models/vital_signs.dart';
import 'api_service.dart';

/// Covers every patient-facing REST endpoint.
/// All methods throw [PatientApiException] on non-2xx responses.
class PatientApiService {
  static final PatientApiService instance = PatientApiService._init();

  final ApiService _api = ApiService.instance;
  final _storage = const FlutterSecureStorage();

  PatientApiService._init();

  // ─── Auth header ──────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _decode(String body) =>
      jsonDecode(body) as Map<String, dynamic>;

  List<dynamic> _decodeList(String body) => jsonDecode(body) as List<dynamic>;

  void _assertOk(int statusCode, String body) {
    if (statusCode < 200 || statusCode >= 300) {
      throw PatientApiException(statusCode, body);
    }
  }

  // ─── Profile ──────────────────────────────────────────────────────────────

  /// GET /patient/profile
  Future<UserProfile> getProfile() async {
    final res = await _api.get('/patient/profile', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return UserProfile.fromMap(_decode(res.body));
  }

  /// PUT /patient/profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final res = await _api.put(
      '/patient/profile',
      headers: await _headers(),
      body: jsonEncode(profile.toMap()),
    );
    _assertOk(res.statusCode, res.body);
    return UserProfile.fromMap(_decode(res.body));
  }

  // ─── Kick counts ──────────────────────────────────────────────────────────

  /// GET /patient/kicks
  Future<List<KickCount>> getKicks() async {
    final res = await _api.get('/patient/kicks', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => KickCount.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /patient/kicks
  Future<KickCount> logKickSession(KickCount session) async {
    final res = await _api.post(
      '/patient/kicks',
      headers: await _headers(),
      body: jsonEncode(session.toMap()),
    );
    _assertOk(res.statusCode, res.body);
    return KickCount.fromMap(_decode(res.body));
  }

  // ─── Contractions ─────────────────────────────────────────────────────────

  /// GET /patient/contractions
  Future<List<Contraction>> getContractions() async {
    final res =
        await _api.get('/patient/contractions', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => Contraction.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /patient/contractions
  Future<Contraction> logContraction(Contraction contraction) async {
    final res = await _api.post(
      '/patient/contractions',
      headers: await _headers(),
      body: jsonEncode(contraction.toMap()),
    );
    _assertOk(res.statusCode, res.body);
    return Contraction.fromMap(_decode(res.body));
  }

  // ─── Vitals ───────────────────────────────────────────────────────────────

  /// GET /patient/vitals
  Future<List<VitalSigns>> getVitals() async {
    final res = await _api.get('/patient/vitals', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => VitalSigns.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /patient/vitals
  Future<VitalSigns> recordVitals(VitalSigns vitals) async {
    final res = await _api.post(
      '/patient/vitals',
      headers: await _headers(),
      body: jsonEncode(vitals.toMap()),
    );
    _assertOk(res.statusCode, res.body);
    return VitalSigns.fromMap(_decode(res.body));
  }

  // ─── Appointments ─────────────────────────────────────────────────────────

  /// GET /patient/appointments
  Future<List<Map<String, dynamic>>> getAppointments() async {
    final res =
        await _api.get('/patient/appointments', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body).cast<Map<String, dynamic>>();
  }

  /// POST /patient/appointments
  Future<Map<String, dynamic>> addAppointment(
      Map<String, dynamic> appointment) async {
    final res = await _api.post(
      '/patient/appointments',
      headers: await _headers(),
      body: jsonEncode(appointment),
    );
    _assertOk(res.statusCode, res.body);
    return _decode(res.body);
  }

  // ─── Account / GDPR ───────────────────────────────────────────────────────

  /// DELETE /patient/account — hard-deletes all data and the account.
  Future<void> deleteAccount() async {
    final res =
        await _api.delete('/patient/account', headers: await _headers());
    _assertOk(res.statusCode, res.body);
  }

  /// GET /patient/export — returns a JSON blob of all patient data.
  Future<Map<String, dynamic>> exportData() async {
    final res =
        await _api.get('/patient/export', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decode(res.body);
  }

  // ─── Preferences ──────────────────────────────────────────────────────────

  /// PUT /patient/preferences
  Future<void> updatePreferences(Map<String, dynamic> prefs) async {
    final res = await _api.put(
      '/patient/preferences',
      headers: await _headers(),
      body: jsonEncode(prefs),
    );
    _assertOk(res.statusCode, res.body);
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class PatientApiException implements Exception {
  final int statusCode;
  final String body;
  PatientApiException(this.statusCode, this.body);

  @override
  String toString() => 'PatientApiException($statusCode): $body';
}
