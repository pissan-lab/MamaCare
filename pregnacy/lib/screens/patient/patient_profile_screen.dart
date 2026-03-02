// lib/screens/patient/patient_profile_screen.dart

import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/patient_api_service.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _api = PatientApiService.instance;
  final _formKey = GlobalKey<FormState>();

  UserProfile? _profile;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _pregnancyTypeCtrl = TextEditingController();
  DateTime? _dueDate;
  DateTime? _lastPeriodDate;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _pregnancyTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await _api.getProfile();
      _nameCtrl.text = profile.name;
      _pregnancyTypeCtrl.text = profile.pregnancyType ?? '';
      _dueDate = DateTime.tryParse(profile.dueDate);
      _lastPeriodDate = DateTime.tryParse(profile.lastPeriodDate);
      setState(() { _profile = profile; _loading = false; });
    } on PatientApiException catch (e) {
      setState(() { _error = 'Server error ${e.statusCode}'; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null || _lastPeriodDate == null) {
      _showError('Please fill in all date fields');
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = UserProfile(
        id: _profile?.id,
        name: _nameCtrl.text.trim(),
        dueDate: _dueDate!.toIso8601String(),
        lastPeriodDate: _lastPeriodDate!.toIso8601String(),
        pregnancyType: _pregnancyTypeCtrl.text.trim().isEmpty
            ? null
            : _pregnancyTypeCtrl.text.trim(),
        createdAt: _profile?.createdAt ?? DateTime.now().toIso8601String(),
      );
      final result = await _api.updateProfile(updated);
      setState(() { _profile = result; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated'),
              backgroundColor: Colors.green),
        );
      }
    } on PatientApiException catch (e) {
      _showError('Could not save profile (${e.statusCode})');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate(bool isDueDate) async {
    final initial = isDueDate
        ? (_dueDate ?? DateTime.now().add(const Duration(days: 60)))
        : (_lastPeriodDate ?? DateTime.now().subtract(const Duration(days: 14)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) {
          _dueDate = picked;
        } else {
          _lastPeriodDate = picked;
        }
      });
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));

  String _fmtDate(DateTime? dt) => dt == null
      ? 'Not set'
      : '${dt.day}/${dt.month}/${dt.year}';

  // Derived pregnancy week from last period date
  String get _pregnancyWeek {
    if (_lastPeriodDate == null) return 'Unknown';
    final weeks = DateTime.now().difference(_lastPeriodDate!).inDays ~/ 7;
    if (weeks > 42 || weeks < 0) return 'N/A';
    return 'Week $weeks';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Profile'),
        actions: [
          IconButton(onPressed: _fetch, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _fetch, child: const Text('Retry')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Current pregnancy week badge ──────────────────
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _pregnancyWeek,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Name ──────────────────────────────────────────
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder()),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // ── Pregnancy type ────────────────────────────────
                        DropdownButtonFormField<String>(
                          value: _pregnancyTypeCtrl.text.isEmpty
                              ? null
                              : _pregnancyTypeCtrl.text,
                          decoration: const InputDecoration(
                              labelText: 'Pregnancy Type',
                              border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(
                                value: 'singleton', child: Text('Singleton')),
                            DropdownMenuItem(
                                value: 'twins', child: Text('Twins')),
                            DropdownMenuItem(
                                value: 'triplets',
                                child: Text('Triplets or more')),
                            DropdownMenuItem(
                                value: 'high-risk',
                                child: Text('High-risk')),
                          ],
                          onChanged: (v) =>
                              setState(() => _pregnancyTypeCtrl.text = v ?? ''),
                        ),
                        const SizedBox(height: 16),

                        // ── Last period date ──────────────────────────────
                        _DateField(
                          label: 'Last Menstrual Period (LMP)',
                          value: _fmtDate(_lastPeriodDate),
                          onTap: () => _pickDate(false),
                        ),
                        const SizedBox(height: 16),

                        // ── Due date ──────────────────────────────────────
                        _DateField(
                          label: 'Estimated Due Date (EDD)',
                          value: _fmtDate(_dueDate),
                          onTap: () => _pickDate(true),
                        ),
                        const SizedBox(height: 28),

                        // ── Save ──────────────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            child: _saving
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text('Save Profile'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ─── Date picker tile ─────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: InputDecorator(
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value),
              const Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      );
}
