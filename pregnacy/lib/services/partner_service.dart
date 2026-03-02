import '../models/partner_access.dart';
import 'database_service.dart';

class PartnerService {
  final DatabaseService _db;

  PartnerService({required DatabaseService db}) : _db = db;

  /// Generate an invite code that a patient can share with their partner.
  Future<String> generateInviteCode({required String patientId}) async {
    // TODO: implement invite code generation + store in DB
    throw UnimplementedError('generateInviteCode not yet implemented');
  }

  /// Redeem an invite code and link partner to patient.
  Future<PartnerAccess?> redeemInviteCode({
    required String code,
    required String partnerUserId,
  }) async {
    // TODO: implement invite redemption
    throw UnimplementedError('redeemInviteCode not yet implemented');
  }

  /// Retrieve active partner access records for a patient.
  Future<List<PartnerAccess>> getPartnerAccess({required String patientId}) async {
    // TODO: implement DB query
    throw UnimplementedError('getPartnerAccess not yet implemented');
  }

  /// Revoke partner access.
  Future<void> revokeAccess({required String accessId}) async {
    // TODO: implement revoke logic
    throw UnimplementedError('revokeAccess not yet implemented');
  }

  /// Update the list of shared items for an existing access record.
  Future<void> updateSharedItems({
    required String accessId,
    required List<String> sharedItems,
  }) async {
    // TODO: implement update logic
    throw UnimplementedError('updateSharedItems not yet implemented');
  }
}
