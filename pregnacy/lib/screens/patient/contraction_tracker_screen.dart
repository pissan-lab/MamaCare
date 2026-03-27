import 'package:flutter/material.dart';
import '../../models/contraction.dart';

class ContractionTrackerScreen extends StatefulWidget {
  const ContractionTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ContractionTrackerScreen> createState() => _ContractionTrackerScreenState();
}

class _ContractionTrackerScreenState extends State<ContractionTrackerScreen> {
  List<Contraction> contractions = [];

  bool get _suggestsLabor {
    if (contractions.length < 3) return false;
    final recentContractions = contractions.take(10).toList();
    if (recentContractions.length < 3) return false;

    int averageInterval = 0;
    int averageDuration = 0;
    int validIntervals = 0;
    int validDurations = 0;

    for (var c in recentContractions) {
      if (c.intervalSeconds != null) {
        averageInterval += c.intervalSeconds!;
        validIntervals++;
      }
      if (c.durationSeconds != null) {
        averageDuration += c.durationSeconds!;
        validDurations++;
      }
    }

    if (validIntervals > 0) averageInterval ~/= validIntervals;
    if (validDurations > 0) averageDuration ~/= validDurations;

    bool isRegular = averageInterval >= 200 && averageInterval <= 400;
    bool isStrongLong = averageDuration >= 45;

    return isRegular && isStrongLong;
  }

  void _logContraction() {
    setState(() {
      final now = DateTime.now();
      final intervalSeconds = contractions.isNotEmpty
          ? now.difference(contractions.first.startTime).inSeconds
          : null;
      contractions.insert(
        0,
        Contraction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          patientId: 'patient123',
          startTime: now.subtract(const Duration(seconds: 55)),
          endTime: now,
          durationSeconds: 55,
          intervalSeconds: intervalSeconds,
        ),
      );
    });
  }

  String _formatDuration(int? seconds) {
    if (seconds == null) return '—';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildSummaryStats() {
    if (contractions.isEmpty) return const SizedBox.shrink();

    final avgInterval = contractions
        .where((c) => c.intervalSeconds != null)
        .map((c) => c.intervalSeconds!)
        .fold<int>(0, (a, b) => a + b);
    final validCount =
        contractions.where((c) => c.intervalSeconds != null).length;
    final avgIntervalDisplay =
        validCount > 0 ? _formatDuration(avgInterval ~/ validCount) : '—';

    final avgDuration = contractions
        .where((c) => c.durationSeconds != null)
        .map((c) => c.durationSeconds!)
        .fold<int>(0, (a, b) => a + b);
    final validDurCount =
        contractions.where((c) => c.durationSeconds != null).length;
    final avgDurationDisplay =
        validDurCount > 0 ? _formatDuration(avgDuration ~/ validDurCount) : '—';

    return Row(
      children: [
        _buildStatChip(Icons.timer_outlined, 'Avg Duration', avgDurationDisplay),
        const SizedBox(width: 8),
        _buildStatChip(Icons.swap_horiz, 'Avg Interval', avgIntervalDisplay),
        const SizedBox(width: 8),
        _buildStatChip(Icons.format_list_numbered, 'Total', '${contractions.length}'),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.pink.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.pink.shade400, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade800,
                    fontSize: 14)),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.pink.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    if (contractions.isEmpty) return const SizedBox.shrink();
    final recent = contractions.take(6).toList().reversed.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Timeline',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey.shade700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: recent.map((c) {
              final dur = c.durationSeconds ?? 30;
              final barHeight = (dur / 120 * 50).clamp(12.0, 50.0);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: _suggestsLabor
                              ? Colors.orange.shade400
                              : Colors.pink.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(c.startTime),
                        style: const TextStyle(fontSize: 9),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Contraction Tracker',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Summary stats ────────────────────────────────────────────
            _buildSummaryStats(),

            if (contractions.isNotEmpty) ...[
              const SizedBox(height: 16),

              // ── Pattern visuals (timeline bar chart) ──────────────────
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildTimeline(),
                ),
              ),

              const SizedBox(height: 12),

              // ── Labor pattern indicator ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _suggestsLabor
                      ? Colors.orange.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _suggestsLabor
                        ? Colors.orange.shade300
                        : Colors.green.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _suggestsLabor
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: _suggestsLabor
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _suggestsLabor
                                ? 'Pattern May Suggest Labor'
                                : 'Pattern Looks Irregular',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _suggestsLabor
                                  ? Colors.orange.shade900
                                  : Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _suggestsLabor
                                ? 'Contractions appear regular (~5 min apart, ~1 min long). Consider calling your clinician.'
                                : 'Contractions are irregular. May be Braxton Hicks or early latent phase.',
                            style: TextStyle(
                              fontSize: 12,
                              color: _suggestsLabor
                                  ? Colors.orange.shade800
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Recorded contractions list ─────────────────────────────
            Text(
              'Recorded Contractions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (contractions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border,
                          size: 48, color: Colors.pink.shade200),
                      const SizedBox(height: 12),
                      Text('No contractions logged yet.',
                          style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text('Tap the button below to start.',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: contractions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final c = contractions[index];
                  final isFirst = index == 0;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: isFirst
                          ? Border.all(color: Colors.pink.shade200, width: 1.5)
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isFirst
                                ? Colors.pink.shade100
                                : Colors.grey.shade100,
                            child: Text(
                              '${contractions.length - index}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isFirst
                                    ? Colors.pink.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_formatTime(c.startTime)}  →  ${c.endTime != null ? _formatTime(c.endTime!) : "Ongoing"}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Duration: ${_formatDuration(c.durationSeconds)}   ·   Interval: ${_formatDuration(c.intervalSeconds)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          if (isFirst)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Latest',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.pink.shade600,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),

            // ── Advice block ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_hospital_outlined,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'When to contact your clinician',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildAdviceBullet(
                      'Contractions every 5 minutes for at least 1 hour (5-1-1 rule)'),
                  _buildAdviceBullet(
                      'Each contraction lasts 45–60 seconds or longer'),
                  _buildAdviceBullet(
                      'Water breaks or you notice spotting'),
                  _buildAdviceBullet(
                      'Baby\'s movements feel reduced or unusual'),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton.icon(
            onPressed: _logContraction,
            icon: const Icon(Icons.add_circle_outline, size: 22),
            label: const Text(
              'Log Contraction',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdviceBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 7, color: Colors.blue.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style:
                    TextStyle(fontSize: 13, color: Colors.blue.shade800)),
          ),
        ],
      ),
    );
  }
}
