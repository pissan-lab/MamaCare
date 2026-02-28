// lib/models/doctor_patient_assignment.dart

class DoctorPatientAssignment {
  final int? id;
  final int doctorId;
  final String doctorName;
  final int patientId;
  final String patientName;
  final String assignedDate;
  final String? notes;

  DoctorPatientAssignment({
    this.id,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.assignedDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'patient_id': patientId,
      'patient_name': patientName,
      'assigned_date': assignedDate,
      'notes': notes,
    };
  }

  factory DoctorPatientAssignment.fromMap(Map<String, dynamic> map) {
    return DoctorPatientAssignment(
      id: map['id'],
      doctorId: map['doctor_id'],
      doctorName: map['doctor_name'],
      patientId: map['patient_id'],
      patientName: map['patient_name'],
      assignedDate: map['assigned_date'],
      notes: map['notes'],
    );
  }
}
