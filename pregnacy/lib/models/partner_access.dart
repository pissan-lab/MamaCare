class PartnerAccess {
  final String id;
  final String patientId;
  final String partnerUserId;
  final String inviteCode;
  final List<String> sharedItems; // e.g. ['kicks', 'vitals', 'appointments']
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  PartnerAccess({
    required this.id,
    required this.patientId,
    required this.partnerUserId,
    required this.inviteCode,
    required this.sharedItems,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'partnerUserId': partnerUserId,
        'inviteCode': inviteCode,
        'sharedItems': sharedItems.join(','),
        'isActive': isActive ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory PartnerAccess.fromMap(Map<String, dynamic> map) => PartnerAccess(
        id: map['id'],
        patientId: map['patientId'],
        partnerUserId: map['partnerUserId'],
        inviteCode: map['inviteCode'],
        sharedItems: (map['sharedItems'] as String).split(','),
        isActive: map['isActive'] == 1,
        createdAt: DateTime.parse(map['createdAt']),
        expiresAt: map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
      );
}
