import 'package:flutter/material.dart';

class PostpartumScreen extends StatelessWidget {
  const PostpartumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postpartum Recovery')),
      body: const Center(
        // TODO: recovery milestones, newborn tracking, mental health check-ins
        child: Text('Postpartum — Coming Soon'),
      ),
    );
  }
}
