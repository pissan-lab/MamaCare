class KickCount {
  final String id;
  final String patientId;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final int count;
  final int targetCount; // usually 10
  final String? notes;

  KickCount({
    required this.id,
    required this.patientId,
    required this.sessionStart,
    this.sessionEnd,
    required this.count,
    this.targetCount = 10,
    this.notes,
  });

  bool get targetReached => count >= targetCount;

  Duration? get duration => sessionEnd != null
      ? sessionEnd!.difference(sessionStart)
      : null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'sessionStart': sessionStart.toIso8601String(),
        'sessionEnd': sessionEnd?.toIso8601String(),
        'count': count,
        'targetCount': targetCount,
        'notes': notes,
      };

  factory KickCount.fromMap(Map<String, dynamic> map) => KickCount(
        id: map['id'],
        patientId: map['patientId'],
        sessionStart: DateTime.parse(map['sessionStart']),
        sessionEnd: map['sessionEnd'] != null ? DateTime.parse(map['sessionEnd']) : null,
        count: map['count'],
        targetCount: map['targetCount'] ?? 10,
        notes: map['notes'],
      );
}
