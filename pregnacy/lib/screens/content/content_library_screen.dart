import 'package:flutter/material.dart';
import '../../models/health_content.dart';

class ContentLibraryScreen extends StatelessWidget {
  const ContentLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<ContentStage>(
              decoration: const InputDecoration(
                labelText: 'Filter by Stage',
                border: OutlineInputBorder(),
              ),
              items: ContentStage.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (stage) {
                // TODO: filter articles by stage via ContentService
              },
            ),
          ),
          const Expanded(
            child: Center(
              // TODO: display filtered article list
              child: Text('Content Library — Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}
