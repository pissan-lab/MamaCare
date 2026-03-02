import 'package:flutter/material.dart';

/// Compassionate resources and support for pregnancy loss.
class LossSupportScreen extends StatelessWidget {
  const LossSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support & Resources')),
      body: const Center(
        // TODO: grief resources, support groups, medically reviewed guides
        child: Text('Loss Support — Coming Soon'),
      ),
    );
  }
}
