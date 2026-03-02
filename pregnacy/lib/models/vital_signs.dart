class VitalSigns {
  final String id;
  final String patientId;
  final DateTime recordedAt;
  final double? systolic;       // mmHg
  final double? diastolic;      // mmHg
  final double? heartRate;      // bpm
  final double? weight;         // kg
  final double? temperature;    // °C
  final double? oxygenSaturation; // %
  final double? bloodGlucose;   // mmol/L
  final String? notes;

  VitalSigns({
    required this.id,
    required this.patientId,
    required this.recordedAt,
    this.systolic,
    this.diastolic,
    this.heartRate,
    this.weight,
    this.temperature,
    this.oxygenSaturation,
    this.bloodGlucose,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'patientId': patientId,
        'recordedAt': recordedAt.toIso8601String(),
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
        'weight': weight,
        'temperature': temperature,
        'oxygenSaturation': oxygenSaturation,
        'bloodGlucose': bloodGlucose,
        'notes': notes,
      };

  factory VitalSigns.fromMap(Map<String, dynamic> map) => VitalSigns(
        id: map['id'],
        patientId: map['patientId'],
        recordedAt: DateTime.parse(map['recordedAt']),
        systolic: map['systolic']?.toDouble(),
        diastolic: map['diastolic']?.toDouble(),
        heartRate: map['heartRate']?.toDouble(),
        weight: map['weight']?.toDouble(),
        temperature: map['temperature']?.toDouble(),
        oxygenSaturation: map['oxygenSaturation']?.toDouble(),
        bloodGlucose: map['bloodGlucose']?.toDouble(),
        notes: map['notes'],
      );
}
