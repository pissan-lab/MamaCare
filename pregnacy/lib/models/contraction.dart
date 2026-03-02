enum ContractionPhase { latent, active, transition, unknown }

class Contraction {
  final String id;
  final String patientId;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationSeconds;
  final int? intervalSeconds; // gap since last contraction
  final ContractionPhase phase;
  final String? notes;

  Contraction({
    required this.id,
    required this.patientId,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    this.intervalSeconds,
    this.phase = ContractionPhase.unknown,
    this.notes,
  });

  bool get isActive => endTime == null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'durationSeconds': durationSeconds,
        'intervalSeconds': intervalSeconds,
        'phase': phase.name,
        'notes': notes,
      };

  factory Contraction.fromMap(Map<String, dynamic> map) => Contraction(
        id: map['id'],
        patientId: map['patientId'],
        startTime: DateTime.parse(map['startTime']),
        endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
        durationSeconds: map['durationSeconds'],
        intervalSeconds: map['intervalSeconds'],
        phase: ContractionPhase.values.firstWhere(
          (e) => e.name == map['phase'],
          orElse: () => ContractionPhase.unknown,
        ),
        notes: map['notes'],
      );
}
