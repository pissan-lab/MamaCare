import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  final _lastPeriodCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dueDateCtrl.dispose();
    _lastPeriodCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      name: _nameCtrl.text.trim(),
      dueDate: _dueDateCtrl.text.trim(),
      lastPeriodDate: _lastPeriodCtrl.text.trim(),
      pregnancyType: null,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await DatabaseService.instance.insert('user_profile', profile.toMap());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Profile saved')),
      );
      // Navigate to Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error saving profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dueDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Due Date (YYYY-MM-DD)'
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter due date' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastPeriodCtrl,
                decoration: const InputDecoration(
                  labelText: 'Last Period Date (YYYY-MM-DD)'
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter last period date' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save & Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
