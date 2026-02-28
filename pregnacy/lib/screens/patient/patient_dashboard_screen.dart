// lib/screens/patient/patient_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:mamacare/models/user_profile.dart';
import 'package:mamacare/services/database_service.dart';
import 'package:mamacare/services/auth_service.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final _dbService = DatabaseService.instance;
  final _authService = AuthService.instance;
  UserProfile? _userProfile;
  Map<String, dynamic>? _recentVitals;
  int _todayKickCount = 0;
  int _totalContractions = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // Load user profile
      final profiles = await _dbService.query('user_profile');
      if (profiles.isNotEmpty) {
        _userProfile = UserProfile.fromMap(profiles.first);
      }

      // Load today's kick count
      final today = DateTime.now().toString().split(' ')[0];
      final kickCounts = await _dbService.query(
        'kick_counts',
        where: 'date = ?',
        whereArgs: [today],
      );
      _todayKickCount = kickCounts.isNotEmpty
          ? kickCounts.fold(0, (sum, item) => sum + (item['count'] as int))
          : 0;

      // Load today's contractions
      final contractions = await _dbService.query(
        'contractions',
        where: 'date = ?',
        whereArgs: [today],
      );
      _totalContractions = contractions.length;

      // Load recent vital signs
      final vitals = await _dbService.query(
        'vital_signs',
        where: 'date = ?',
        whereArgs: [today],
      );
      if (vitals.isNotEmpty) {
        _recentVitals = vitals.last;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _calculatePregnancyWeeks() {
    if (_userProfile == null) return 'N/A';
    try {
      final lastPeriod = DateTime.parse(_userProfile!.lastPeriodDate);
      final weeks = DateTime.now().difference(lastPeriod).inDays ~/ 7;
      return '$weeks weeks';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pregnancy Dashboard'),
          elevation: 0,
          backgroundColor: Colors.pink[400],
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text('Privacy Settings'),
                  value: 'privacy',
                ),
                const PopupMenuItem(
                  child: Text('Export Data'),
                  value: 'export',
                ),
                const PopupMenuItem(
                  child: Text('Delete My Account'),
                  value: 'delete',
                ),
                const PopupMenuItem(
                  child: Text('Logout'),
                  value: 'logout',
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'privacy':
                    Navigator.of(context).pushNamed('/privacy');
                    break;
                  case 'export':
                    final data = await _authService.exportCurrentUserData();
                    print('Exported user data: $data');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data exported to console')),
                    );
                    break;
                  case 'delete':
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Account'),
                        content: const Text(
                            'This will permanently delete all of your data. Are you sure?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(c, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(c, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await _authService.deleteAccount();
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                    break;
                  case 'logout':
                    _authService.logout();
                    Navigator.of(context).pushReplacementNamed('/login');
                    break;
                }
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Welcome Card
                    if (_userProfile != null)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${_userProfile!.name}! 👋',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pregnancy Progress: ${_calculatePregnancyWeeks()}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Due Date: ${_userProfile!.dueDate}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.pink[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(
                          title: 'Today\'s Kicks',
                          value: _todayKickCount.toString(),
                          icon: Icons.favorite,
                          color: Colors.red[400]!,
                        ),
                        _buildStatCard(
                          title: 'Contractions',
                          value: _totalContractions.toString(),
                          icon: Icons.whatshot,
                          color: Colors.orange[400]!,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Vital Signs Section
                    if (_recentVitals != null)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Today\'s Vital Signs',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildVitalRow(
                                'Weight',
                                '${_recentVitals!['weight'] ?? 'N/A'} kg',
                                Icons.monitor_weight,
                              ),
                              const Divider(),
                              _buildVitalRow(
                                'Blood Pressure',
                                '${_recentVitals!['blood_pressure_systolic'] ?? 0}/${_recentVitals!['blood_pressure_diastolic'] ?? 0} mmHg',
                                Icons.favorite_border,
                              ),
                              const Divider(),
                              _buildVitalRow(
                                'Glucose Level',
                                '${_recentVitals!['glucose_level'] ?? 'N/A'} mg/dL',
                                Icons.healing,
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showKickCountDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Log Kicks'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[400],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showContractionDialog(),
                            icon: const Icon(Icons.timer),
                            label: const Text('Log Contraction'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[400],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showVitalsDialog(),
                        icon: const Icon(Icons.medical_services),
                        label: const Text('Log Vital Signs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[400],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
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
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVitalRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.pink[400], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showKickCountDialog() {
    final countController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Kick Count'),
        content: TextField(
          controller: countController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter number of kicks',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (countController.text.isNotEmpty) {
                try {
                  final today = DateTime.now().toString().split(' ')[0];
                  await _dbService.insert('kick_counts', {
                    'date': today,
                    'count': int.parse(countController.text),
                    'start_time': DateTime.now().toString(),
                    'end_time': DateTime.now().toString(),
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    _loadDashboardData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Kicks logged successfully')),
                    );
                  }
                } catch (e) {
                  print('❌ Error logging kicks: $e');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showContractionDialog() {
    final notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Contraction'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Enter duration (minutes) or notes',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final today = DateTime.now().toString().split(' ')[0];
                await _dbService.insert('contractions', {
                  'date': today,
                  'start_time': DateTime.now().toString(),
                  'duration': notesController.text.isNotEmpty
                      ? int.tryParse(notesController.text) ?? 0
                      : 0,
                  'intensity': 'moderate',
                  'notes': notesController.text,
                });
                if (mounted) {
                  Navigator.pop(context);
                  _loadDashboardData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Contraction logged')),
                  );
                }
              } catch (e) {
                print('❌ Error logging contraction: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showVitalsDialog() {
    final weightController = TextEditingController();
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final glucoseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Vital Signs'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: systolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Systolic BP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: diastolicController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Diastolic BP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: glucoseController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Glucose Level',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final today = DateTime.now().toString().split(' ')[0];
                await _dbService.insert('vital_signs', {
                  'date': today,
                  'weight': double.tryParse(weightController.text),
                  'blood_pressure_systolic':
                      int.tryParse(systolicController.text),
                  'blood_pressure_diastolic':
                      int.tryParse(diastolicController.text),
                  'glucose_level': double.tryParse(glucoseController.text),
                });
                if (mounted) {
                  Navigator.pop(context);
                  _loadDashboardData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Vital signs logged')),
                  );
                }
              } catch (e) {
                print('❌ Error logging vitals: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
