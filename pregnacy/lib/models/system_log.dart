// lib/models/system_log.dart

class SystemLog {
  final int? id;
  final String userId;
  final String userRole;
  final String action;
  final String description;
  final String timestamp;
  final String? affectedRecordId;
  final String? affectedRecordType;
  final String? previousValue;
  final String? newValue;

  SystemLog({
    this.id,
    required this.userId,
    required this.userRole,
    required this.action,
    required this.description,
    required this.timestamp,
    this.affectedRecordId,
    this.affectedRecordType,
    this.previousValue,
    this.newValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_role': userRole,
      'action': action,
      'description': description,
      'timestamp': timestamp,
      'affected_record_id': affectedRecordId,
      'affected_record_type': affectedRecordType,
      'previous_value': previousValue,
      'new_value': newValue,
    };
  }

  factory SystemLog.fromMap(Map<String, dynamic> map) {
    return SystemLog(
      id: map['id'],
      userId: map['user_id'],
      userRole: map['user_role'],
      action: map['action'],
      description: map['description'],
      timestamp: map['timestamp'],
      affectedRecordId: map['affected_record_id'],
      affectedRecordType: map['affected_record_type'],
      previousValue: map['previous_value'],
      newValue: map['new_value'],
    );
  }
}
