// lib/services/partner_api_service.dart

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/kick_count.dart';
import '../models/vital_signs.dart';
import 'api_service.dart';

/// Covers every partner-facing REST endpoint.
/// All methods throw [PartnerApiException] on non-2xx responses.
class PartnerApiService {
  static final PartnerApiService instance = PartnerApiService._init();

  final ApiService _api = ApiService.instance;
  final _storage = const FlutterSecureStorage();

  PartnerApiService._init();

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
      throw PartnerApiException(statusCode, body);
    }
  }

  // ─── Accept Invite ────────────────────────────────────────────────────────

  /// POST /partner/accept-invite
  /// Body: { "invite_code": "XXXX-XXXX" }
  /// Returns the activated partner access object.
  Future<Map<String, dynamic>> acceptInvite(String inviteCode) async {
    final res = await _api.post(
      '/partner/accept-invite',
      headers: await _headers(),
      body: jsonEncode({'invite_code': inviteCode}),
    );
    _assertOk(res.statusCode, res.body);
    return _decode(res.body);
  }

  // ─── Shared data (read-only) ───────────────────────────────────────────────

  /// GET /partner/shared-profile
  Future<Map<String, dynamic>> getSharedProfile() async {
    final res =
        await _api.get('/partner/shared-profile', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decode(res.body);
  }

  /// GET /partner/shared-kicks
  Future<List<KickCount>> getSharedKicks() async {
    final res =
        await _api.get('/partner/shared-kicks', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => KickCount.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /partner/shared-vitals
  Future<List<VitalSigns>> getSharedVitals() async {
    final res =
        await _api.get('/partner/shared-vitals', headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body)
        .map((e) => VitalSigns.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /partner/shared-appointments
  Future<List<Map<String, dynamic>>> getSharedAppointments() async {
    final res = await _api.get('/partner/shared-appointments',
        headers: await _headers());
    _assertOk(res.statusCode, res.body);
    return _decodeList(res.body).cast<Map<String, dynamic>>();
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class PartnerApiException implements Exception {
  final int statusCode;
  final String body;
  PartnerApiException(this.statusCode, this.body);

  @override
  String toString() => 'PartnerApiException($statusCode): $body';
}
