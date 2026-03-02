// lib/screens/partner/partner_dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../models/kick_count.dart';
import '../../models/vital_signs.dart';
import '../../services/partner_api_service.dart';

/// Read-only shared view for a partner (spouse / support person).
/// All data is fetched from the partner API using the active session token.
class PartnerDashboardScreen extends StatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _api = PartnerApiService.instance;
  late final TabController _tabs;

  // per-tab state
  Map<String, dynamic>? _profile;
  List<KickCount> _kicks = [];
  List<VitalSigns> _vitals = [];
  List<Map<String, dynamic>> _appointments = [];

  bool _loadingProfile = true;
  bool _loadingKicks = true;
  bool _loadingVitals = true;
  bool _loadingAppointments = true;

  String? _profileError;
  String? _kicksError;
  String? _vitalsError;
  String? _appointmentsError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _fetchAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _fetchAll() {
    _fetchProfile();
    _fetchKicks();
    _fetchVitals();
    _fetchAppointments();
  }

  Future<void> _fetchProfile() async {
    setState(() { _loadingProfile = true; _profileError = null; });
    try {
      final p = await _api.getSharedProfile();
      setState(() { _profile = p; _loadingProfile = false; });
    } catch (e) {
      setState(() { _profileError = _msg(e); _loadingProfile = false; });
    }
  }

  Future<void> _fetchKicks() async {
    setState(() { _loadingKicks = true; _kicksError = null; });
    try {
      final k = await _api.getSharedKicks();
      setState(() { _kicks = k; _loadingKicks = false; });
    } catch (e) {
      setState(() { _kicksError = _msg(e); _loadingKicks = false; });
    }
  }

  Future<void> _fetchVitals() async {
    setState(() { _loadingVitals = true; _vitalsError = null; });
    try {
      final v = await _api.getSharedVitals();
      setState(() { _vitals = v; _loadingVitals = false; });
    } catch (e) {
      setState(() { _vitalsError = _msg(e); _loadingVitals = false; });
    }
  }

  Future<void> _fetchAppointments() async {
    setState(() { _loadingAppointments = true; _appointmentsError = null; });
    try {
      final a = await _api.getSharedAppointments();
      setState(() { _appointments = a; _loadingAppointments = false; });
    } catch (e) {
      setState(() {
        _appointmentsError = _msg(e);
        _loadingAppointments = false;
      });
    }
  }

  String _msg(Object e) => e is PartnerApiException
      ? e.statusCode == 403
          ? 'Access not granted for this data.'
          : 'Server error ${e.statusCode}'
      : 'Could not reach server.';

  int _pregnancyWeeks(String? lmp) {
    if (lmp == null) return 0;
    try {
      return DateTime.now().difference(DateTime.parse(lmp)).inDays ~/ 7;
    } catch (_) {
      return 0;
    }
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final patientName =
        (_profile?['name'] as String?) ?? 'Your Partner';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(patientName),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAll,
            tooltip: 'Refresh all',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline),   text: 'Profile'),
            Tab(icon: Icon(Icons.child_care),        text: 'Kicks'),
            Tab(icon: Icon(Icons.favorite_border),   text: 'Vitals'),
            Tab(icon: Icon(Icons.event_note_outlined), text: 'Appointments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ProfileTab(
            profile: _profile,
            loading: _loadingProfile,
            error: _profileError,
            onRetry: _fetchProfile,
            weeks: _pregnancyWeeks(_profile?['last_period_date'] as String?),
          ),
          _KicksTab(
            kicks: _kicks,
            loading: _loadingKicks,
            error: _kicksError,
            onRetry: _fetchKicks,
          ),
          _VitalsTab(
            vitals: _vitals,
            loading: _loadingVitals,
            error: _vitalsError,
            onRetry: _fetchVitals,
          ),
          _AppointmentsTab(
            appointments: _appointments,
            loading: _loadingAppointments,
            error: _appointmentsError,
            onRetry: _fetchAppointments,
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

Widget _loadingOrError({
  required bool loading,
  required String? error,
  required VoidCallback onRetry,
  required Widget child,
}) {
  if (loading) return const Center(child: CircularProgressIndicator());
  if (error != null) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            error.contains('Access not granted')
                ? Icon(Icons.lock_outline, size: 56, color: Colors.grey[400])
                : Icon(Icons.cloud_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.pink[400]),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
  return child;
}

Widget _emptyState(String message, {IconData icon = Icons.inbox}) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(fontSize: 15, color: Colors.grey[600])),
        ],
      ),
    );

Widget _infoRow(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );

// ─── Profile Tab ─────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final int weeks;

  const _ProfileTab({
    required this.profile,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.weeks,
  });

  @override
  Widget build(BuildContext context) {
    return _loadingOrError(
      loading: loading,
      error: error,
      onRetry: onRetry,
      child: profile == null
          ? _emptyState('No profile shared yet',
              icon: Icons.person_off_outlined)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.pink[100],
                            child: Text(
                              (profile!['name'] as String? ?? '?')
                                  .isNotEmpty
                                  ? (profile!['name'] as String)[0]
                                      .toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink[700]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile!['name'] as String? ?? 'Unknown',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.pink[50],
                                    borderRadius:
                                        BorderRadius.circular(20)),
                                child: Text(
                                  'Week $weeks',
                                  style: TextStyle(
                                      color: Colors.pink[700],
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      if (profile!['due_date'] != null)
                        _infoRow('Due Date',
                            profile!['due_date'] as String),
                      if (profile!['pregnancy_type'] != null)
                        _infoRow('Pregnancy Type',
                            profile!['pregnancy_type'] as String),
                      const SizedBox(height: 8),
                      // Shared items banner
                      if (profile!['shared_items'] != null) ...[
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text('Shared with you:',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black54)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            for (final item in (profile!['shared_items']
                                    as List<dynamic>))
                              _sharedItemChip(item as String),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _sharedItemChip(String item) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink.shade200),
        ),
        child: Text(
          item[0].toUpperCase() + item.substring(1),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.pink[700]),
        ),
      );
}

// ─── Kicks Tab ───────────────────────────────────────────────────────────────

class _KicksTab extends StatelessWidget {
  final List<KickCount> kicks;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const _KicksTab({
    required this.kicks,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _loadingOrError(
      loading: loading,
      error: error,
      onRetry: onRetry,
      child: kicks.isEmpty
          ? _emptyState('No kick sessions shared yet',
              icon: Icons.child_care)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: kicks.length,
              itemBuilder: (_, i) {
                final k = kicks[i];
                final dur = k.duration;
                final durLabel = dur != null
                    ? '${dur.inMinutes}m ${dur.inSeconds % 60}s'
                    : 'In progress';
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: k.targetReached
                                ? Colors.green[50]
                                : Colors.orange[50],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${k.count}',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: k.targetReached
                                      ? Colors.green[700]
                                      : Colors.orange[700]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${k.sessionStart.year}-'
                                '${k.sessionStart.month.toString().padLeft(2, '0')}-'
                                '${k.sessionStart.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text('Duration: $durLabel',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600])),
                              Text(
                                  'Kicks: ${k.count} / ${k.targetCount}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        if (k.targetReached)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius:
                                    BorderRadius.circular(20)),
                            child: Text('Goal met',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800])),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Vitals Tab ──────────────────────────────────────────────────────────────

class _VitalsTab extends StatelessWidget {
  final List<VitalSigns> vitals;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const _VitalsTab({
    required this.vitals,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  Widget _chip(String label, IconData icon, MaterialColor color) =>
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color.shade700),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.shade800)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _loadingOrError(
      loading: loading,
      error: error,
      onRetry: onRetry,
      child: vitals.isEmpty
          ? _emptyState('No vitals shared yet',
              icon: Icons.favorite_border)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vitals.length,
              itemBuilder: (_, i) {
                final v = vitals[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${v.recordedAt.year}-'
                            '${v.recordedAt.month.toString().padLeft(2, '0')}-'
                            '${v.recordedAt.day.toString().padLeft(2, '0')}  '
                            '${v.recordedAt.hour.toString().padLeft(2, '0')}:'
                            '${v.recordedAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            if (v.systolic != null &&
                                v.diastolic != null)
                              _chip(
                                  '${v.systolic!.toStringAsFixed(0)}/${v.diastolic!.toStringAsFixed(0)} mmHg',
                                  Icons.bloodtype,
                                  Colors.red),
                            if (v.heartRate != null)
                              _chip(
                                  '${v.heartRate!.toStringAsFixed(0)} bpm',
                                  Icons.favorite,
                                  Colors.pink),
                            if (v.weight != null)
                              _chip(
                                  '${v.weight!.toStringAsFixed(1)} kg',
                                  Icons.monitor_weight,
                                  Colors.blue),
                            if (v.temperature != null)
                              _chip(
                                  '${v.temperature!.toStringAsFixed(1)} °C',
                                  Icons.thermostat,
                                  Colors.orange),
                            if (v.oxygenSaturation != null)
                              _chip(
                                  '${v.oxygenSaturation!.toStringAsFixed(0)}% SpO₂',
                                  Icons.air,
                                  Colors.teal),
                            if (v.bloodGlucose != null)
                              _chip(
                                  '${v.bloodGlucose!.toStringAsFixed(1)} mmol/L',
                                  Icons.science,
                                  Colors.purple),
                          ],
                        ),
                        if (v.notes != null &&
                            v.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Note: ${v.notes}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600])),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Appointments Tab ─────────────────────────────────────────────────────────

class _AppointmentsTab extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const _AppointmentsTab({
    required this.appointments,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _loadingOrError(
      loading: loading,
      error: error,
      onRetry: onRetry,
      child: appointments.isEmpty
          ? _emptyState('No appointments shared yet',
              icon: Icons.event_busy_outlined)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appointments.length,
              itemBuilder: (_, i) {
                final a = appointments[i];
                final title =
                    (a['title'] as String?) ?? 'Appointment';
                final date = (a['date'] as String?) ?? '';
                final time = (a['time'] as String?) ?? '';
                final location = a['location'] as String?;
                final doctor = a['doctor_name'] as String?;
                final status =
                    (a['status'] as String?) ?? 'scheduled';
                final isUpcoming = status == 'scheduled';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          decoration: BoxDecoration(
                            color: isUpcoming
                                ? Colors.pink[50]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 8),
                          child: Column(
                            children: [
                              Text(
                                date.length >= 7
                                    ? _monthLabel(date)
                                    : '',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isUpcoming
                                        ? Colors.pink[400]
                                        : Colors.grey[500]),
                              ),
                              Text(
                                date.length >= 10
                                    ? date.substring(8, 10)
                                    : '',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isUpcoming
                                        ? Colors.pink[700]
                                        : Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(title,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.bold)),
                                  ),
                                  _statusChip(status),
                                ],
                              ),
                              if (time.isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4),
                                  child: Row(children: [
                                    Icon(Icons.access_time,
                                        size: 13,
                                        color: Colors.grey[500]),
                                    const SizedBox(width: 3),
                                    Text(time,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600])),
                                  ]),
                                ),
                              if (doctor != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 3),
                                  child: Row(children: [
                                    Icon(Icons.person_outline,
                                        size: 13,
                                        color: Colors.grey[500]),
                                    const SizedBox(width: 3),
                                    Text(doctor,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600])),
                                  ]),
                                ),
                              if (location != null)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 3),
                                  child: Row(children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 13,
                                        color: Colors.grey[500]),
                                    const SizedBox(width: 3),
                                    Text(location,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600])),
                                  ]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _monthLabel(String date) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    try {
      final m = int.parse(date.substring(5, 7));
      return months[m - 1];
    } catch (_) {
      return '';
    }
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'scheduled':
        bg = Colors.pink.shade50;
        fg = Colors.pink.shade700;
        break;
      case 'completed':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case 'cancelled':
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: fg),
      ),
    );
  }
}
