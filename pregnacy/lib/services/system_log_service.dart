// lib/services/system_log_service.dart

import 'package:mamacare/models/system_log.dart';
import './database_service.dart';

class SystemLogService {
  static final SystemLogService instance = SystemLogService._init();
  final _dbService = DatabaseService.instance;

  SystemLogService._init();

  // Log user actions
  Future<void> logAction({
    required String userId,
    required String userRole,
    required String action,
    required String description,
    String? affectedRecordId,
    String? affectedRecordType,
    String? previousValue,
    String? newValue,
  }) async {
    try {
      final log = SystemLog(
        userId: userId,
        userRole: userRole,
        action: action,
        description: description,
        timestamp: DateTime.now().toIso8601String(),
        affectedRecordId: affectedRecordId,
        affectedRecordType: affectedRecordType,
        previousValue: previousValue,
        newValue: newValue,
      );

      await _dbService.insert('system_logs', log.toMap());
      print('✅ Action logged: $action');
    } catch (e) {
      print('❌ Error logging action: $e');
    }
  }

  // Get all audit logs (admin only)
  Future<List<SystemLog>> getAuditLogs({
    String? userId,
    String? action,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      String where = '1=1';
      List<dynamic> whereArgs = [];

      if (userId != null) {
        where += ' AND user_id = ?';
        whereArgs.add(userId);
      }

      if (action != null) {
        where += ' AND action = ?';
        whereArgs.add(action);
      }

      if (fromDate != null) {
        where += ' AND timestamp >= ?';
        whereArgs.add(fromDate.toIso8601String());
      }

      if (toDate != null) {
        where += ' AND timestamp <= ?';
        whereArgs.add(toDate.toIso8601String());
      }

      final logs = await _dbService.query(
        'system_logs',
        where: where,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );

      return logs.map((l) => SystemLog.fromMap(l)).toList();
    } catch (e) {
      print('❌ Error fetching audit logs: $e');
      return [];
    }
  }

  // Get user's action history
  Future<List<SystemLog>> getUserHistory(String userId) async {
    return await getAuditLogs(userId: userId);
  }

  // Get changes to specific record
  Future<List<SystemLog>> getRecordChanges(String recordId) async {
    try {
      final logs = await _dbService.query(
        'system_logs',
        where: 'affected_record_id = ?',
        whereArgs: [recordId],
      );

      return logs.map((l) => SystemLog.fromMap(l)).toList();
    } catch (e) {
      print('❌ Error fetching record changes: $e');
      return [];
    }
  }
}
