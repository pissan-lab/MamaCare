// lib/screens/doctor/doctor_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:mamacare/services/auth_service.dart';
import 'package:mamacare/services/database_service.dart';
import 'package:mamacare/models/doctor_patient_assignment.dart';
import 'package:mamacare/models/user_profile.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final _authService = AuthService.instance;
  final _dbService = DatabaseService.instance;

  List<DoctorPatientAssignment> _assignedPatients = [];
  Map<int, UserProfile?> _patientProfiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedPatients();
  }

  Future<void> _loadAssignedPatients() async {
    setState(() => _isLoading = true);

    try {
      // Get doctor's assigned patients
      final assignments = await _dbService.query(
        'doctor_patient_assignments',
        where: 'doctor_id = ?',
        whereArgs: [_authService.currentUser?.id],
      );

      _assignedPatients =
          assignments.map((a) => DoctorPatientAssignment.fromMap(a)).toList();

      // Load patient profiles
      for (var assignment in _assignedPatients) {
        final profiles = await _dbService.query(
          'user_profile',
          where: 'id = ?',
          whereArgs: [assignment.patientId],
        );
        if (profiles.isNotEmpty) {
          _patientProfiles[assignment.patientId] =
              UserProfile.fromMap(profiles.first);
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading patients: $e');
      setState(() => _isLoading = false);
    }
  }

  String _calculateWeeks(String lastPeriodDate) {
    try {
      final date = DateTime.parse(lastPeriodDate);
      final weeks = DateTime.now().difference(date).inDays ~/ 7;
      return '$weeks weeks';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text('Refresh'),
                value: 'refresh',
              ),
              const PopupMenuItem(
                child: Text('Logout'),
                value: 'logout',
              ),
            ],
            onSelected: (value) {
              if (value == 'refresh') {
                _loadAssignedPatients();
              } else if (value == 'logout') {
                _authService.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAssignedPatients,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Dr. ${_authService.currentUser?.name}! 👨‍⚕️',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Assigned Patients',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (_authService.currentUser?.specialization != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Chip(
                                label: Text(
                                  _authService.currentUser!.specialization!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.blue[100],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Patients',
                          _assignedPatients.length.toString(),
                          Icons.person,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Avg. Weeks',
                          _calculateAverageWeeks(),
                          Icons.calendar_today,
                          Colors.pink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Patients List
                  if (_assignedPatients.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No patients assigned yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _assignedPatients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final assignment = _assignedPatients[index];
                        final profile = _patientProfiles[assignment.patientId];

                        return Card(
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.pink[100],
                              child: Icon(
                                Icons.pregnant_woman,
                                color: Colors.pink[600],
                                size: 32,
                              ),
                            ),
                            title: Text(
                              assignment.patientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                if (profile != null)
                                  Text(
                                    'Pregnancy Progress: ${_calculateWeeks(profile.lastPeriodDate)}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  )
                                else
                                  Text(
                                    'Loading profile...',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  'Assigned: ${_formatDate(assignment.assignedDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey[400],
                              size: 16,
                            ),
                            onTap: () {
                              _showPatientDetails(assignment, profile);
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateAverageWeeks() {
    if (_patientProfiles.isEmpty) return '0';
    int total = 0;
    int count = 0;
    _patientProfiles.forEach((_, profile) {
      if (profile != null) {
        try {
          final weeks = DateTime.now()
              .difference(DateTime.parse(profile.lastPeriodDate))
              .inDays ~/
              7;
          total += weeks;
          count++;
        } catch (e) {
          // Skip invalid dates
        }
      }
    });
    return count > 0 ? (total ~/ count).toString() : '0';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showPatientDetails(
    DoctorPatientAssignment assignment,
    UserProfile? profile,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    assignment.patientName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),
              if (profile != null) ...[
                _buildDetailRow('Due Date', profile.dueDate),
                _buildDetailRow('Last Period', profile.lastPeriodDate),
                _buildDetailRow('Pregnancy Stage', profile.pregnancyType ?? 'Not specified'),
                _buildDetailRow('Progress', _calculateWeeks(profile.lastPeriodDate)),
              ] else
                const Text('Patient profile not found'),
              if (assignment.notes != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Notes:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(assignment.notes!),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: View patient health records
                      },
                      icon: const Icon(Icons.description),
                      label: const Text('View Records'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Add notes/comments
                      },
                      icon: const Icon(Icons.note_add),
                      label: const Text('Add Notes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
