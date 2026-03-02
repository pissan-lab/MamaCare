// lib/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Manages scheduling and cancelling local notifications.
/// Call [initialize] once from main.dart before the app starts.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _initialized = true;
  }

  // ─── Android notification channel ─────────────────────────────────────────

  static const _channel = AndroidNotificationDetails(
    'appointments_channel',
    'Appointment Reminders',
    channelDescription: 'Reminders for upcoming clinic appointments',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  // ─── Schedule reminders for an appointment ────────────────────────────────

  /// Schedules two notifications for [appointmentDateTime]:
  ///  • 24 hours before  (id: appointmentId * 10)
  ///  • 1 hour before    (id: appointmentId * 10 + 1)
  ///
  /// Silently skips if the remind time is already in the past.
  Future<void> scheduleAppointmentReminders({
    required int appointmentId,
    required String title,
    required DateTime appointmentDateTime,
  }) async {
    if (kIsWeb || !_initialized) return;

    final scheduledTz = tz.TZDateTime.from(appointmentDateTime, tz.local);

    await _scheduleIfFuture(
      id: appointmentId * 10,
      title: '📅 Appointment Tomorrow',
      body: '$title — tomorrow at ${_formatTime(appointmentDateTime)}',
      scheduledTime:
          scheduledTz.subtract(const Duration(hours: 24)),
    );

    await _scheduleIfFuture(
      id: appointmentId * 10 + 1,
      title: '🏥 Appointment in 1 Hour',
      body: '$title — in 1 hour at ${_formatTime(appointmentDateTime)}',
      scheduledTime:
          scheduledTz.subtract(const Duration(hours: 1)),
    );
  }

  Future<void> _scheduleIfFuture({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      NotificationDetails(android: _channel),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── Cancel reminders ──────────────────────────────────────────────────────

  Future<void> cancelAppointmentReminders(int appointmentId) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancel(appointmentId * 10);
    await _plugin.cancel(appointmentId * 10 + 1);
  }

  // ─── Immediate demo notification (for testing on device) ──────────────────

  Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;
    await _plugin.show(
      0,
      title,
      body,
      NotificationDetails(android: _channel),
    );
  }

  // ─── Helper ───────────────────────────────────────────────────────────────

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
