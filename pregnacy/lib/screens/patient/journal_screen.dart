import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pregnancy Journal')),
      body: const Center(
        // TODO: list journal entries, search, filter by date
        child: Text('Journal — Coming Soon'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: open new journal entry form
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
