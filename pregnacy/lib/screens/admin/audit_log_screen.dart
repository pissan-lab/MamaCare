import 'package:flutter/material.dart';

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Log')),
      body: const Center(
        // TODO: fetch and display system_log entries with filtering
        child: Text('Audit Log — Coming Soon'),
      ),
    );
  }
}
