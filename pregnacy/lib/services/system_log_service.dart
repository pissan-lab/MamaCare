// lib/services/system_log_service.dart

import 'package:mamacare/models/system_log.dart';
import './database_service.dart';

class SystemLogService {
  static final SystemLogService instance = SystemLogService._init();
  final _dbService = DatabaseService.instance;

  static final List<SystemLog> _demoLogs = [
    SystemLog(
      id: 1,
      userId: '1',
      userRole: 'admin',
      action: 'LOGIN',
      description: 'Admin User logged in',
      timestamp: '2026-03-12T08:30:00.000',
    ),
    SystemLog(
      id: 2,
      userId: '2',
      userRole: 'doctor',
      action: 'DATA_UPDATED',
      description: 'Dr. Smith updated prenatal care notes for Jane Doe',
      timestamp: '2026-03-12T09:15:00.000',
      affectedRecordId: '3',
      affectedRecordType: 'users',
      previousValue: 'Next visit in 4 weeks',
      newValue: 'Next visit in 2 weeks due to elevated BP',
    ),
    SystemLog(
      id: 3,
      userId: '4',
      userRole: 'doctor',
      action: 'LOGIN',
      description: 'Dr. Amina Yusuf logged in',
      timestamp: '2026-03-12T10:05:00.000',
    ),
    SystemLog(
      id: 4,
      userId: '1',
      userRole: 'admin',
      action: 'USER_CREATED',
      description: 'New user created: Aisha Kamau (patient2@mamacare.com)',
      timestamp: '2026-03-12T11:25:00.000',
      affectedRecordId: '5',
      affectedRecordType: 'users',
      newValue: 'patient2@mamacare.com',
    ),
    SystemLog(
      id: 5,
      userId: '1',
      userRole: 'admin',
      action: 'USER_CREATED',
      description: 'New user created: Miriam Otieno (patient3@mamacare.com)',
      timestamp: '2026-03-12T11:29:00.000',
      affectedRecordId: '6',
      affectedRecordType: 'users',
      newValue: 'patient3@mamacare.com',
    ),
    SystemLog(
      id: 6,
      userId: '1',
      userRole: 'admin',
      action: 'DATA_UPDATED',
      description: 'Admin User changed notification policy settings',
      timestamp: '2026-03-12T12:00:00.000',
      affectedRecordType: 'settings',
      previousValue: 'Daily summary at 7:00 AM',
      newValue: 'Daily summary at 8:00 AM',
    ),
    SystemLog(
      id: 7,
      userId: '1',
      userRole: 'admin',
      action: 'USER_DEACTIVATED',
      description: 'Archived inactive test patient account',
      timestamp: '2026-03-12T12:35:00.000',
      affectedRecordId: '99',
      affectedRecordType: 'users',
    ),
  ];

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
      if (logs.isEmpty) {
        return _applyFilters(_demoLogs,
            userId: userId,
            action: action,
            fromDate: fromDate,
            toDate: toDate);
      }

      return logs.map((l) => SystemLog.fromMap(l)).toList();
    } catch (e) {
      print('❌ Error fetching audit logs: $e');
      return _applyFilters(_demoLogs,
          userId: userId,
          action: action,
          fromDate: fromDate,
          toDate: toDate);
    }
  }

  List<SystemLog> _applyFilters(
    List<SystemLog> source, {
    String? userId,
    String? action,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return source.where((log) {
      if (userId != null && log.userId != userId) return false;
      if (action != null && log.action != action) return false;

      final timestamp = DateTime.tryParse(log.timestamp);
      if (timestamp != null && fromDate != null && timestamp.isBefore(fromDate)) {
        return false;
      }
      if (timestamp != null && toDate != null && timestamp.isAfter(toDate)) {
        return false;
      }

      return true;
    }).toList();
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
