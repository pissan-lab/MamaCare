// lib/screens/doctor/patient_list_screen.dart

import 'package:flutter/material.dart';
import '../../services/doctor_api_service.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _api = DoctorApiService.instance;

  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final patients = await _api.getPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } on DoctorApiException catch (e) {
      setState(() {
        _error = 'Server error ${e.statusCode}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not reach server. Check your connection.';
        _isLoading = false;
      });
    }
  }

  int _pregnancyWeeks(String? lastPeriodDate) {
    if (lastPeriodDate == null) return 0;
    try {
      return DateTime.now()
              .difference(DateTime.parse(lastPeriodDate))
              .inDays ~/
          7;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Patients'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadPatients,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No patients assigned yet',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPatients,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _patients.length,
        itemBuilder: (context, index) => _PatientCard(
          patient: _patients[index],
          weeks: _pregnancyWeeks(_patients[index]['last_period_date'] as String?),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientDetailScreen(
                patientId: _patients[index]['id'].toString(),
                patientName: (_patients[index]['name'] as String?) ?? 'Patient',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Patient Card ─────────────────────────────────────────────────────────────

class _PatientCard extends StatelessWidget {
  final Map<String, dynamic> patient;
  final int weeks;
  final VoidCallback onTap;

  const _PatientCard({
    required this.patient,
    required this.weeks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = (patient['name'] as String?) ?? 'Unknown';
    final email = (patient['email'] as String?) ?? '';
    final pregnancyType =
        (patient['pregnancy_type'] as String?) ?? 'Standard';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue[100],
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800]),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    if (email.isNotEmpty)
                      Text(email,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[600])),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chip(
                          label: 'Week $weeks',
                          color: Colors.blue.shade50,
                          textColor: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        _chip(
                          label: pregnancyType,
                          color: Colors.pink.shade50,
                          textColor: Colors.pink.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
      {required String label,
      required Color color,
      required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
