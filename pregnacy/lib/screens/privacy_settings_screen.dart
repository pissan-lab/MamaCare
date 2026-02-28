import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _auth = AuthService.instance;
  Map<String, dynamic> _prefs = {};

  @override
  void initState() {
    super.initState();
    _prefs = _auth.currentUser?.preferences ?? {};
  }

  void _toggle(String key) {
    setState(() {
      _prefs[key] = !(_prefs[key] == true);
    });
  }

  Future<void> _save() async {
    await _auth.updatePreferences(_prefs);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Allow collection of weight data'),
            value: _prefs['weight'] == true,
            onChanged: (_) => _toggle('weight'),
          ),
          SwitchListTile(
            title: const Text('Allow collection of blood pressure'),
            value: _prefs['bloodPressure'] == true,
            onChanged: (_) => _toggle('bloodPressure'),
          ),
          SwitchListTile(
            title: const Text('Allow collection of kick counts'),
            value: _prefs['kickCounts'] == true,
            onChanged: (_) => _toggle('kickCounts'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
