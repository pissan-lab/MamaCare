import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/patient_api_service.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final _auth = AuthService.instance;
  final _api = PatientApiService.instance;

  bool _saving = false;
  bool _exporting = false;

  // Consent toggle map  (PUT /patient/preferences)
  late Map<String, bool> _prefs;

  @override
  void initState() {
    super.initState();
    final raw = _auth.currentUser?.preferences ?? {};
    _prefs = {
      'weight': raw['weight'] == true,
      'bloodPressure': raw['bloodPressure'] == true,
      'kickCounts': raw['kickCounts'] == true,
      'contractions': raw['contractions'] == true,
      'vitals': raw['vitals'] == true,
      'appointments': raw['appointments'] == true,
      'shareWithDoctor': raw['shareWithDoctor'] == true,
      'shareWithPartner': raw['shareWithPartner'] == true,
    };
  }

  void _toggle(String key) => setState(() => _prefs[key] = !(_prefs[key]!));

  // ── PUT /patient/preferences ─────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _api.updatePreferences(_prefs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Preferences saved'),
              backgroundColor: Colors.green),
        );
      }
    } on PatientApiException catch (e) {
      _showError('Could not save preferences (${e.statusCode})');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── GET /patient/export ──────────────────────────────────────────────────
  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final data = await _api.exportData();
      final pretty = const JsonEncoder.withIndent('  ').convert(data);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Your Data Export'),
            content: SingleChildScrollView(
              child: SelectableText(
                pretty,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close')),
            ],
          ),
        );
      }
    } on PatientApiException catch (e) {
      _showError('Export failed (${e.statusCode})');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── DELETE /patient/account ───────────────────────────────────────────────
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete ALL your data and your account.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _api.deleteAccount();
      await _auth.logout();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (_) => false);
      }
    } on PatientApiException catch (e) {
      _showError('Could not delete account (${e.statusCode})');
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Consent')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Data collection consent ──────────────────────────────────────
          const _SectionHeader('Data Collection Consent'),
          ...[
            ('weight', 'Allow collection of weight data'),
            ('bloodPressure', 'Allow collection of blood pressure'),
            ('kickCounts', 'Allow collection of kick counts'),
            ('contractions', 'Allow collection of contraction data'),
            ('vitals', 'Allow collection of all vital signs'),
            ('appointments', 'Allow collection of appointment data'),
          ].map(
            (entry) => SwitchListTile(
              title: Text(entry.$2),
              value: _prefs[entry.$1]!,
              onChanged: (_) => _toggle(entry.$1),
            ),
          ),

          const Divider(height: 32),

          // ── Sharing preferences ──────────────────────────────────────────
          const _SectionHeader('Sharing Preferences'),
          SwitchListTile(
            title: const Text('Share data with my doctor'),
            value: _prefs['shareWithDoctor']!,
            onChanged: (_) => _toggle('shareWithDoctor'),
          ),
          SwitchListTile(
            title: const Text('Share data with my partner'),
            value: _prefs['shareWithPartner']!,
            onChanged: (_) => _toggle('shareWithPartner'),
          ),

          const SizedBox(height: 16),

          // ── Save button ──────────────────────────────────────────────────
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save Preferences'),
          ),

          const Divider(height: 40),

          // ── GDPR controls ────────────────────────────────────────────────
          const _SectionHeader('Your Data Rights (GDPR)'),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export my data'),
            subtitle: const Text('Download a copy of all your stored data as JSON'),
            trailing: _exporting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.chevron_right),
            onTap: _exporting ? null : _export,
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined,
                color: Colors.red),
            title: const Text('Delete my account',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text(
                'Permanently remove all your data and close your account'),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: _deleteAccount,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: Theme.of(context).colorScheme.primary)),
      );
}
