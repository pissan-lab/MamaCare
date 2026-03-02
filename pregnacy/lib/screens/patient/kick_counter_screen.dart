import 'package:flutter/material.dart';
import '../../models/kick_count.dart';
import '../../services/patient_api_service.dart';
import '../../services/auth_service.dart';

class KickCounterScreen extends StatefulWidget {
  const KickCounterScreen({super.key});

  @override
  State<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends State<KickCounterScreen> {
  final _api = PatientApiService.instance;

  List<KickCount> _history = [];
  bool _historyLoading = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() { _historyLoading = true; _historyError = null; });
    try {
      final data = await _api.getKicks();
      setState(() {
        _history = data
          ..sort((a, b) => b.sessionStart.compareTo(a.sessionStart));
        _historyLoading = false;
      });
    } on PatientApiException catch (e) {
      setState(() {
        _historyError = 'Server error (${e.statusCode})';
        _historyLoading = false;
      });
    } catch (_) {
      setState(() {
        _historyError = 'Could not load sessions. Check your connection.';
        _historyLoading = false;
      });
    }
  }

  // â”€â”€â”€ Derived data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  int get _todayTotal {
    final today = DateTime.now();
    return _history
        .where((s) =>
            s.sessionStart.year == today.year &&
            s.sessionStart.month == today.month &&
            s.sessionStart.day == today.day)
        .fold(0, (sum, s) => sum + s.count);
  }

  /// Returns a map of {dayLabel: totalKicks} for the past 7 days.
  Map<String, int> get _last7Days {
    final now = DateTime.now();
    final result = <String, int>{};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final label = _dayAbbr(day.weekday);
      final total = _history
          .where((s) =>
              s.sessionStart.year == day.year &&
              s.sessionStart.month == day.month &&
              s.sessionStart.day == day.day)
          .fold(0, (sum, s) => sum + s.count);
      result[label] = total;
    }
    return result;
  }

  String _dayAbbr(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // â”€â”€â”€ Log session bottom sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _openLogSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LogSessionSheet(
        onSaved: _fetchHistory,
        api: _api,
      ),
    );
  }

  // â”€â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kick Count Tracker'),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _historyLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHistory,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _TodayCard(total: _todayTotal),
                  const SizedBox(height: 20),
                  _SessionList(
                    sessions: _history,
                    error: _historyError,
                    onRetry: _fetchHistory,
                  ),
                  const SizedBox(height: 20),
                  _WeeklyChart(data: _last7Days),
                  const SizedBox(height: 20),
                  const _EducationCard(),
                  const SizedBox(height: 16),
                  _LogButton(onTap: _openLogSheet),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// â”€â”€â”€ Today's Count Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TodayCard extends StatelessWidget {
  final int total;
  const _TodayCard({required this.total});

  static const _dailyTarget = 10;

  @override
  Widget build(BuildContext context) {
    final progress = (total / _dailyTarget).clamp(0.0, 1.0);
    final reached = total >= _dailyTarget;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: reached
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.pink.shade300, Colors.pink.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reached ? Icons.check_circle : Icons.child_care,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text("Today's Kick Count",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$total',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    '/ $_dailyTarget kicks',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reached
                  ? 'ðŸŽ‰ Daily target reached!'
                  : '${_dailyTarget - total} kicks to reach today\'s target',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ CTA Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LogButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.pink[400],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        icon: const Icon(Icons.add_circle_outline, size: 22),
        label: const Text('Log New Kick Session',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// â”€â”€â”€ 7-Day Bar Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WeeklyChart extends StatelessWidget {
  final Map<String, int> data;
  const _WeeklyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal =
        data.values.fold(0, (m, v) => v > m ? v : m).toDouble();
    final safeMax = maxVal == 0 ? 1.0 : maxVal;
    final today = _dayAbbr(DateTime.now().weekday);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.pink[400], size: 20),
                const SizedBox(width: 8),
                const Text('Kicks This Week',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: data.entries.map((e) {
                  final isToday = e.key == today;
                  final fraction = e.value / safeMax;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (e.value > 0)
                        Text(
                          '${e.value}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isToday
                                  ? Colors.pink[600]
                                  : Colors.grey[600]),
                        ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        width: 28,
                        height: (fraction * 80).clamp(4.0, 80.0),
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.pink[400]
                              : Colors.pink[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isToday
                              ? Colors.pink[600]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayAbbr(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

// â”€â”€â”€ Session List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SessionList extends StatelessWidget {
  final List<KickCount> sessions;
  final String? error;
  final VoidCallback onRetry;

  const _SessionList({
    required this.sessions,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: Colors.pink[400], size: 20),
                    const SizedBox(width: 8),
                    const Text('Kick Sessions',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (sessions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${sessions.length} total',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.pink[700],
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (error != null)
              _errorBanner(error!, onRetry)
            else if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.child_care,
                          size: 40, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('No sessions yet. Tap the button above to start!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sessions.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 56),
                itemBuilder: (context, i) {
                  final s = sessions[i];
                  final dur = s.duration;
                  final dateLabel =
                      '${s.sessionStart.day}/${s.sessionStart.month}/${s.sessionStart.year}';
                  final timeLabel = TimeOfDay.fromDateTime(s.sessionStart)
                      .format(context);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: s.targetReached
                                ? Colors.green[50]
                                : Colors.orange[50],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${s.count}',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: s.targetReached
                                      ? Colors.green[700]
                                      : Colors.orange[700]),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$dateLabel  $timeLabel',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                              ),
                              Text(
                                dur != null
                                    ? '${dur.inMinutes}m ${dur.inSeconds % 60}s  Â·  ${s.count}/${s.targetCount} kicks'
                                    : '${s.count}/${s.targetCount} kicks',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        if (s.targetReached)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius:
                                    BorderRadius.circular(20)),
                            child: Text('Goal',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800])),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _errorBanner(String msg, VoidCallback retry) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            TextButton.icon(
                onPressed: retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry')),
          ],
        ),
      );
}

// â”€â”€â”€ Education Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EducationCard extends StatelessWidget {
  const _EducationCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.pink[50],
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.pink[400], size: 20),
                const SizedBox(width: 8),
                Text('Why Kick Counts Matter',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink[800])),
              ],
            ),
            const SizedBox(height: 12),
            _bullet('Fetal movement is a sign of baby\'s wellbeing. '
                'Regular monitoring helps you notice changes early.'),
            const SizedBox(height: 8),
            _bullet('Cardiff Count-to-10 method: count kicks each day '
                'until you reach 10. Most healthy babies reach this '
                'within 2 hours.'),
            const SizedBox(height: 16),
            Text('Normal Patterns',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[800])),
            const SizedBox(height: 8),
            _patternRow(Icons.schedule, 'Best time to count',
                'After a meal or when baby is usually active'),
            const SizedBox(height: 6),
            _patternRow(Icons.repeat, 'Frequency',
                'Count at least once per day from week 28'),
            const SizedBox(height: 6),
            _patternRow(Icons.warning_amber_outlined, 'Contact your doctor if',
                'Fewer than 10 kicks in 2 hours, or a sudden decrease in activity'),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child:
                CircleAvatar(radius: 3, backgroundColor: Colors.pink[300]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: Colors.pink[900])),
          ),
        ],
      );

  Widget _patternRow(IconData icon, String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.pink[400]),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 13, color: Colors.pink[900]),
                children: [
                  TextSpan(
                      text: '$label: ',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      );
}

// â”€â”€â”€ Log Session Bottom Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _LogSessionSheet extends StatefulWidget {
  final VoidCallback onSaved;
  final PatientApiService api;

  const _LogSessionSheet({required this.onSaved, required this.api});

  @override
  State<_LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends State<_LogSessionSheet> {
  int _count = 0;
  DateTime? _sessionStart;
  bool _saving = false;
  static const _target = 10;

  void _tap() {
    setState(() {
      _sessionStart ??= DateTime.now();
      _count++;
    });
  }

  void _reset() => setState(() { _count = 0; _sessionStart = null; });

  Future<void> _save() async {
    if (_sessionStart == null || _count == 0) return;
    setState(() => _saving = true);

    final session = KickCount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId:
          AuthService.instance.currentUser?.id.toString() ?? '',
      sessionStart: _sessionStart!,
      sessionEnd: DateTime.now(),
      count: _count,
      targetCount: _target,
    );

    try {
      await widget.api.logKickSession(session);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Session saved â€” $_count kicks in '
              '${session.duration?.inMinutes ?? 0} min'),
          backgroundColor: Colors.green,
        ),
      );
    } on PatientApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Save failed (${e.statusCode})'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reached = _count >= _target;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Log Kick Session',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '$_count / $_target kicks',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:
                      reached ? Colors.green[600] : Colors.pink[500]),
            ),
            if (_sessionStart != null)
              Text(
                'Started ${TimeOfDay.fromDateTime(_sessionStart!).format(context)}',
                style:
                    TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            if (reached)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('ðŸŽ‰ Target reached!',
                    style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 28),

            // Tap button
            GestureDetector(
              onTap: _tap,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: reached
                      ? Colors.green[400]
                      : Colors.pink[400],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (reached
                              ? Colors.green[400]!
                              : Colors.pink[400]!)
                          .withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('TAP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed:
                        (_saving || _count == 0) ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving...' : 'Save Session',
                        style: const TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
