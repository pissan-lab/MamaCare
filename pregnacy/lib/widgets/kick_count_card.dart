import 'package:flutter/material.dart';
import '../models/kick_count.dart';

class KickCountCard extends StatelessWidget {
  final KickCount kickCount;

  const KickCountCard({
    Key? key,
    required this.kickCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kick Count Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Count: ${kickCount.count} / ${kickCount.targetCount}'),
                Icon(
                  kickCount.targetReached ? Icons.check_circle : Icons.pending,
                  color: kickCount.targetReached ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Started: _formatDate(kickCount.sessionStart)'),
            if (kickCount.sessionEnd != null) ...[
              const SizedBox(height: 4),
              Text('Ended: _formatDate(kickCount.sessionEnd!)'),
            ],
            if (kickCount.duration != null) ...[
              const SizedBox(height: 4),
              Text('Duration: ${kickCount.duration!.inMinutes} minutes'),
            ],
            if (kickCount.notes != null && kickCount.notes!.isNotEmpty) ...[
              const Divider(),
              Text('Notes: ${kickCount.notes}'),
            ],
          ],
        ),
      ),
    );
  }
}
