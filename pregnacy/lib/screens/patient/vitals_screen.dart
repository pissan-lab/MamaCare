import 'package:flutter/material.dart';
import '../../models/vital_signs.dart';
import '../../services/patient_api_service.dart';
import '../../services/auth_service.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final _api = PatientApiService.instance;
  List<VitalSigns> _vitals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final data = await _api.getVitals();
      setState(() {
        _vitals = data..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
        _loading = false;
      });
    } on PatientApiException catch (e) {
      setState(() {
        _error = 'Server error ${e.statusCode}';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openLogForm() async {
    final result = await showModalBottomSheet<VitalSigns>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _VitalsForm(),
    );
    if (result != null) {
      try {
        await _api.recordVitals(result);
        _fetch();
      } on PatientApiException catch (e) {
        _showError('Could not save vitals (${e.statusCode})');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Signs'),
        actions: [
          IconButton(
              onPressed: _fetch, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _vitals.isEmpty
                  ? const Center(child: Text('No vitals recorded yet.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _vitals.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, i) => _VitalTile(_vitals[i]),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openLogForm,
        icon: const Icon(Icons.add),
        label: const Text('Log Vitals'),
      ),
    );
  }
}

// ─── Tile ────────────────────────────────────────────────────────────────────

class _VitalTile extends StatelessWidget {
  final VitalSigns v;
  const _VitalTile(this.v);

  String _fmt(double? val, String unit) =>
      val != null ? '${val.toStringAsFixed(1)} $unit' : '—';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '${v.recordedAt.day}/${v.recordedAt.month}/${v.recordedAt.year}  '
        '${v.recordedAt.hour.toString().padLeft(2, '0')}:'
        '${v.recordedAt.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Wrap(
        spacing: 12,
        children: [
          if (v.systolic != null && v.diastolic != null)
            _chip('BP', '${v.systolic!.toInt()}/${v.diastolic!.toInt()} mmHg'),
          if (v.weight != null) _chip('Wt', _fmt(v.weight, 'kg')),
          if (v.heartRate != null) _chip('HR', _fmt(v.heartRate, 'bpm')),
          if (v.temperature != null) _chip('Temp', _fmt(v.temperature, '°C')),
          if (v.oxygenSaturation != null) _chip('SpO₂', _fmt(v.oxygenSaturation, '%')),
          if (v.bloodGlucose != null) _chip('BG', _fmt(v.bloodGlucose, 'mmol/L')),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) => Chip(
        label: Text('$label: $value', style: const TextStyle(fontSize: 12)),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
}

// ─── Log-vitals form ─────────────────────────────────────────────────────────

class _VitalsForm extends StatefulWidget {
  const _VitalsForm();

  @override
  State<_VitalsForm> createState() => _VitalsFormState();
}

class _VitalsFormState extends State<_VitalsForm> {
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _wtCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _bgCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    for (final c in [_sysCtrl, _diaCtrl, _wtCtrl, _hrCtrl, _tempCtrl, _spo2Ctrl, _bgCtrl, _notesCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  VitalSigns _build() {
    final user = AuthService.instance.currentUser;
    return VitalSigns(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: user?.id.toString() ?? '',
      recordedAt: DateTime.now(),
      systolic: double.tryParse(_sysCtrl.text),
      diastolic: double.tryParse(_diaCtrl.text),
      weight: double.tryParse(_wtCtrl.text),
      heartRate: double.tryParse(_hrCtrl.text),
      temperature: double.tryParse(_tempCtrl.text),
      oxygenSaturation: double.tryParse(_spo2Ctrl.text),
      bloodGlucose: double.tryParse(_bgCtrl.text),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16, right: 16, top: 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log Vital Signs', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field(_sysCtrl, 'Systolic (mmHg)')),
              const SizedBox(width: 8),
              Expanded(child: _field(_diaCtrl, 'Diastolic (mmHg)')),
            ]),
            _field(_wtCtrl, 'Weight (kg)'),
            _field(_hrCtrl, 'Heart Rate (bpm)'),
            _field(_tempCtrl, 'Temperature (°C)'),
            _field(_spo2Ctrl, 'SpO₂ (%)'),
            _field(_bgCtrl, 'Blood Glucose (mmol/L)'),
            _field(_notesCtrl, 'Notes', numeric: false),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _build()),
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {bool numeric = true}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextField(
          controller: c,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
              labelText: label, border: const OutlineInputBorder()),
        ),
      );
}
