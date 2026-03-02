// lib/screens/doctor/patient_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/kick_count.dart';
import '../../models/contraction.dart';
import '../../models/vital_signs.dart';
import '../../services/doctor_api_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
    this.patientName = 'Patient',
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  final _api = DoctorApiService.instance;
  late final TabController _tabs;

  // per-tab state
  UserProfile? _profile;
  List<KickCount> _kicks = [];
  List<VitalSigns> _vitals = [];
  List<Contraction> _contractions = [];

  bool _loadingProfile = true;
  bool _loadingKicks = true;
  bool _loadingVitals = true;
  bool _loadingContractions = true;

  String? _profileError;
  String? _kicksError;
  String? _vitalsError;
  String? _contractionsError;

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
    _fetchContractions();
  }

  Future<void> _fetchProfile() async {
    setState(() { _loadingProfile = true; _profileError = null; });
    try {
      final p = await _api.getPatientProfile(widget.patientId);
      setState(() { _profile = p; _loadingProfile = false; });
    } catch (e) {
      setState(() { _profileError = _msg(e); _loadingProfile = false; });
    }
  }

  Future<void> _fetchKicks() async {
    setState(() { _loadingKicks = true; _kicksError = null; });
    try {
      final k = await _api.getPatientKicks(widget.patientId);
      setState(() { _kicks = k; _loadingKicks = false; });
    } catch (e) {
      setState(() { _kicksError = _msg(e); _loadingKicks = false; });
    }
  }

  Future<void> _fetchVitals() async {
    setState(() { _loadingVitals = true; _vitalsError = null; });
    try {
      final v = await _api.getPatientVitals(widget.patientId);
      setState(() { _vitals = v; _loadingVitals = false; });
    } catch (e) {
      setState(() { _vitalsError = _msg(e); _loadingVitals = false; });
    }
  }

  Future<void> _fetchContractions() async {
    setState(() { _loadingContractions = true; _contractionsError = null; });
    try {
      final c = await _api.getPatientContractions(widget.patientId);
      setState(() { _contractions = c; _loadingContractions = false; });
    } catch (e) {
      setState(() { _contractionsError = _msg(e); _loadingContractions = false; });
    }
  }

  String _msg(Object e) => e is DoctorApiException
      ? 'Server error ${e.statusCode}'
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.patientName),
        backgroundColor: Colors.blue[700],
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
            Tab(icon: Icon(Icons.person_outline), text: 'Profile'),
            Tab(icon: Icon(Icons.child_care),    text: 'Kicks'),
            Tab(icon: Icon(Icons.favorite_border), text: 'Vitals'),
            Tab(icon: Icon(Icons.timer_outlined), text: 'Contractions'),
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
            weeks: _pregnancyWeeks(_profile?.lastPeriodDate),
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
          _ContractionsTab(
            contractions: _contractions,
            loading: _loadingContractions,
            error: _contractionsError,
            onRetry: _fetchContractions,
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ────────────────────────────────────────────────────────────

Widget _loadingOrError(
    {required bool loading,
    required String? error,
    required VoidCallback onRetry,
    required Widget child}) {
  if (loading) return const Center(child: CircularProgressIndicator());
  if (error != null) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
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

Widget _emptyState(String message) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 56, color: Colors.grey[400]),
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

// ─── Profile Tab ───────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final UserProfile? profile;
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
          ? _emptyState('No profile data available')
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
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              profile!.name.isNotEmpty
                                  ? profile!.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile!.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text('Week $weeks',
                                    style: TextStyle(
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      _infoRow('Due Date', profile!.dueDate),
                      _infoRow('Last Period Date', profile!.lastPeriodDate),
                      _infoRow('Pregnancy Type',
                          profile!.pregnancyType ?? 'Standard'),
                      _infoRow('Profile Created', profile!.createdAt),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── Kicks Tab ────────────────────────────────────────────────────────────────

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
          ? _emptyState('No kick sessions recorded')
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${k.sessionStart.year}-${k.sessionStart.month.toString().padLeft(2, '0')}-${k.sessionStart.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text('Duration: $durLabel',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600])),
                              Text(
                                  'Target: ${k.count}/${k.targetCount} kicks',
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
                                borderRadius: BorderRadius.circular(20)),
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

// ─── Vitals Tab ───────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    return _loadingOrError(
      loading: loading,
      error: error,
      onRetry: onRetry,
      child: vitals.isEmpty
          ? _emptyState('No vitals recorded')
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
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              '${v.recordedAt.year}-${v.recordedAt.month.toString().padLeft(2, '0')}-${v.recordedAt.day.toString().padLeft(2, '0')}  ${v.recordedAt.hour.toString().padLeft(2, '0')}:${v.recordedAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            if (v.systolic != null && v.diastolic != null)
                              _vitalChip(
                                  '${v.systolic!.toStringAsFixed(0)}/${v.diastolic!.toStringAsFixed(0)} mmHg',
                                  Icons.bloodtype,
                                  Colors.red),
                            if (v.heartRate != null)
                              _vitalChip(
                                  '${v.heartRate!.toStringAsFixed(0)} bpm',
                                  Icons.favorite,
                                  Colors.pink),
                            if (v.weight != null)
                              _vitalChip(
                                  '${v.weight!.toStringAsFixed(1)} kg',
                                  Icons.monitor_weight,
                                  Colors.blue),
                            if (v.temperature != null)
                              _vitalChip(
                                  '${v.temperature!.toStringAsFixed(1)} °C',
                                  Icons.thermostat,
                                  Colors.orange),
                            if (v.oxygenSaturation != null)
                              _vitalChip(
                                  '${v.oxygenSaturation!.toStringAsFixed(0)}% SpO₂',
                                  Icons.air,
                                  Colors.teal),
                            if (v.bloodGlucose != null)
                              _vitalChip(
                                  '${v.bloodGlucose!.toStringAsFixed(1)} mmol/L',
                                  Icons.science,
                                  Colors.purple),
                          ],
                        ),
                        if (v.notes != null && v.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Note: ${v.notes}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600])),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _vitalChip(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
  }
}

// ─── Contractions Tab ─────────────────────────────────────────────────────────

class _ContractionsTab extends StatelessWidget {
  final List<Contraction> contractions;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  const _ContractionsTab({
    required this.contractions,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  Color _phaseColor(ContractionPhase phase) {
    switch (phase) {
      case ContractionPhase.latent:
        return Colors.green.shade400;
      case ContractionPhase.active:
        return Colors.orange.shade400;
      case ContractionPhase.transition:
        return Colors.red.shade400;
      case ContractionPhase.unknown:
        return Colors.grey.shade400;
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '—';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return _loadingOrError(
      loading: loading,
      error: error,
      onRetry: onRetry,
      child: contractions.isEmpty
          ? _emptyState('No contractions recorded')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contractions.length,
              itemBuilder: (_, i) {
                final c = contractions[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _phaseColor(c.phase),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${c.startTime.year}-${c.startTime.month.toString().padLeft(2, '0')}-${c.startTime.day.toString().padLeft(2, '0')}  ${c.startTime.hour.toString().padLeft(2, '0')}:${c.startTime.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _phaseColor(c.phase)
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      c.phase.name[0].toUpperCase() +
                                          c.phase.name.substring(1),
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: _phaseColor(c.phase)
                                              .withOpacity(0.9)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _metaChip(
                                      'Duration',
                                      _formatDuration(c.durationSeconds)),
                                  const SizedBox(width: 10),
                                  _metaChip(
                                      'Interval',
                                      _formatDuration(c.intervalSeconds)),
                                ],
                              ),
                              if (c.notes != null && c.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Note: ${c.notes}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600])),
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

  Widget _metaChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ',
            style:
                TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
