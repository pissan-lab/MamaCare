import 'package:flutter/material.dart';

/// Specialist reminders and risk flags for high-risk pregnancies.
class HighRiskScreen extends StatelessWidget {
  const HighRiskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('High-Risk Pregnancy')),
      body: const Center(
        // TODO: risk condition list, specialist reminders, flag alerts
        child: Text('High-Risk Pregnancy — Coming Soon'),
      ),
    );
  }
}
