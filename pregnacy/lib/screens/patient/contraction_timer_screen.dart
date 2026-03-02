import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/contraction.dart';
import '../../services/patient_api_service.dart';
import '../../services/auth_service.dart';

class ContractionTimerScreen extends StatefulWidget {
  const ContractionTimerScreen({super.key});

  @override
  State<ContractionTimerScreen> createState() => _ContractionTimerScreenState();
}

class _ContractionTimerScreenState extends State<ContractionTimerScreen> {
  final _api = PatientApiService.instance;

  // ── Timer state ──
  bool _contracting = false;
  DateTime? _currentStart;
  DateTime? _lastEnd;
  int _elapsed = 0; // seconds
  Timer? _ticker;

  // ── History (API + local this session) ──
  List<Contraction> _history = [];
  bool _historyLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    try {
      final data = await _api.getContractions();
      setState(() {
        _history = data..sort((a, b) => b.startTime.compareTo(a.startTime));
        _historyLoading = false;
      });
    } catch (_) {
      setState(() => _historyLoading = false);
    }
  }

  void _toggle() async {
    if (_contracting) {
      // ── STOP ──
      _ticker?.cancel();
      final end = DateTime.now();
      final durationSec = end.difference(_currentStart!).inSeconds;
      final intervalSec = _lastEnd != null
          ? _currentStart!.difference(_lastEnd!).inSeconds
          : null;

      final c = Contraction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: AuthService.instance.currentUser?.id.toString() ?? '',
        startTime: _currentStart!,
        endTime: end,
        durationSeconds: durationSec,
        intervalSeconds: intervalSec,
      );

      setState(() {
        _contracting = false;
        _lastEnd = end;
        _elapsed = 0;
        _history.insert(0, c);
      });

      try {
        await _api.logContraction(c);
      } on PatientApiException catch (e) {
        _showError('Could not sync contraction (${e.statusCode})');
      }
    } else {
      // ── START ──
      _currentStart = DateTime.now();
      _elapsed = 0;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed++);
      });
      setState(() => _contracting = true);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  String _fmtSec(int? sec) {
    if (sec == null) return '—';
    final m = sec ~/ 60;
    final s = sec % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contraction Timer'),
        actions: [
          IconButton(
              onPressed: _fetchHistory,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh history'),
        ],
      ),
      body: Column(
        children: [
          // ── Timer panel ──
          Container(
            width: double.infinity,
            color: _contracting ? Colors.red.shade50 : Colors.green.shade50,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            child: Column(
              children: [
                Text(
                  _contracting ? 'Contracting…' : 'Waiting',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _contracting ? Colors.red : Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _fmtSec(_elapsed),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _contracting ? Colors.red.shade800 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _toggle,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 56),
                    backgroundColor:
                        _contracting ? Colors.red : Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    _contracting ? 'STOP' : 'START',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // ── Stats row ──
          if (_history.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('Last duration',
                      _fmtSec(_history.first.durationSeconds)),
                  _stat('Last interval',
                      _fmtSec(_history.first.intervalSeconds)),
                  _stat('Total today', () {
                    final now = DateTime.now();
                    return '${_history.where((c) => c.startTime.year == now.year && c.startTime.month == now.month && c.startTime.day == now.day).length}';
                  }()),
                ],
              ),
            ),

          // ── History list ──
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('History',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          Expanded(
            child: _historyLoading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? const Center(
                        child: Text('No contractions recorded.'))
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (_, i) {
                          final c = _history[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.8),
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12)),
                            ),
                            title: Text(
                              '${TimeOfDay.fromDateTime(c.startTime).format(context)}  '
                              '${c.startTime.day}/${c.startTime.month}',
                            ),
                            subtitle: Text(
                              'Duration: ${_fmtSec(c.durationSeconds)}'
                              '${c.intervalSeconds != null ? '   Interval: ${_fmtSec(c.intervalSeconds)}' : ''}',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      );
}
