// lib/screens/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:mamacare/services/auth_service.dart';
import 'package:mamacare/services/system_log_service.dart';
import 'package:mamacare/models/system_log.dart';
import 'package:mamacare/models/user.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _authService = AuthService.instance;
  final _logService = SystemLogService.instance;

  List<SystemLog> _auditLogs = [];
  List<User> _users = [];
  bool _isLoading = true;
  String _filterAction = 'ALL';
  int _selectedIndex = 0;

  final List<_AdminNavItem> _menuItems = const [
    _AdminNavItem(label: 'Dashboard', icon: Icons.dashboard_rounded),
    _AdminNavItem(label: 'Patients', icon: Icons.groups_rounded),
    _AdminNavItem(label: 'Doctors', icon: Icons.medical_services_rounded),
    _AdminNavItem(label: 'Appointments', icon: Icons.calendar_month_rounded),
    _AdminNavItem(label: 'Pregnancy Monitoring', icon: Icons.monitor_heart_rounded),
    _AdminNavItem(label: 'Notifications', icon: Icons.notifications_active_rounded),
    _AdminNavItem(label: 'Reports', icon: Icons.assessment_rounded),
    _AdminNavItem(label: 'Privacy Control', icon: Icons.privacy_tip_rounded),
    _AdminNavItem(label: 'Activity Logs', icon: Icons.history_rounded),
    _AdminNavItem(label: 'Settings', icon: Icons.settings_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final logs = await _logService.getAuditLogs();
    final users = await _authService.getAllUsers();

    setState(() {
      _auditLogs = logs;
      _users = users;
      _isLoading = false;
    });
  }

  List<SystemLog> get _filteredLogs {
    if (_filterAction == 'ALL') return _auditLogs;
    return _auditLogs.where((log) => log.action == _filterAction).toList();
  }

  List<User> get _patients =>
      _users.where((user) => user.role == UserRole.patient).toList();

  List<User> get _doctors =>
      _users.where((user) => user.role == UserRole.doctor).toList();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple[700],
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
                _loadData();
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
          : isWide
            ? Row(
                      children: [
                        Container(
                          width: 280,
                          color: Colors.grey[100],
                          child: ListView.separated(
                            itemCount: _menuItems.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _menuItems[index];
                              final isSelected = _selectedIndex == index;
                              return ListTile(
                                leading: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? Colors.deepPurple[700]
                                      : Colors.grey[700],
                                ),
                                title: Text(
                                  item.label,
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.deepPurple[700]
                                        : Colors.grey[900],
                                  ),
                                ),
                                selected: isSelected,
                                selectedTileColor: Colors.deepPurple[50],
                                onTap: () =>
                                    setState(() => _selectedIndex = index),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildSectionBody(),
                        ),
                      ],
                    )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: DropdownButtonFormField<int>(
                        value: _selectedIndex,
                        decoration: const InputDecoration(
                          labelText: 'Admin Section',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          _menuItems.length,
                          (index) => DropdownMenuItem<int>(
                            value: index,
                            child: Text(_menuItems[index].label),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedIndex = value);
                          }
                        },
                      ),
                    ),
                    Expanded(child: _buildSectionBody()),
                  ],
                ),

    );
  }

  Widget _buildSectionBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardSection();
      case 1:
        return _buildUsersSection(title: 'Patients', users: _patients);
      case 2:
        return _buildUsersSection(title: 'Doctors', users: _doctors);
      case 3:
        return _buildPlaceholderSection(
          title: 'Appointments',
          description: 'Manage and review all appointments from one place.',
          icon: Icons.calendar_month_rounded,
        );
      case 4:
        return _buildPlaceholderSection(
          title: 'Pregnancy Monitoring',
          description: 'Track monitoring data and identify high-risk cases.',
          icon: Icons.monitor_heart_rounded,
        );
      case 5:
        return _buildPlaceholderSection(
          title: 'Notifications',
          description: 'Send updates and reminders to patients and doctors.',
          icon: Icons.notifications_active_rounded,
        );
      case 6:
        return _buildPlaceholderSection(
          title: 'Reports',
          description: 'Generate administrative and clinical reports.',
          icon: Icons.assessment_rounded,
        );
      case 7:
        return _buildPlaceholderSection(
          title: 'Privacy Control',
          description: 'Review permissions, consent, and access controls.',
          icon: Icons.privacy_tip_rounded,
        );
      case 8:
        return _buildActivityLogsSection();
      case 9:
        return _buildPlaceholderSection(
          title: 'Settings',
          description: 'Configure global platform settings.',
          icon: Icons.settings_rounded,
        );
      default:
        return _buildDashboardSection();
    }
  }

  Widget _buildDashboardSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${_authService.currentUser?.name ?? 'Admin'}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'System Administrator Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            if (isNarrow) {
              return Column(
                children: [
                  _buildStatCard(
                    'Total Users',
                    _users.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'Total Actions',
                    _auditLogs.length.toString(),
                    Icons.history,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildStatCard(
                    'Changes Made',
                    _auditLogs
                        .where((log) =>
                            log.action == 'USER_CREATED' ||
                            log.action == 'USER_DEACTIVATED' ||
                            log.action == 'DATA_UPDATED')
                        .length
                        .toString(),
                    Icons.edit,
                    Colors.orange,
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Users',
                    _users.length.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Actions',
                    _auditLogs.length.toString(),
                    Icons.history,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Changes Made',
                    _auditLogs
                        .where((log) =>
                            log.action == 'USER_CREATED' ||
                            log.action == 'USER_DEACTIVATED' ||
                            log.action == 'DATA_UPDATED')
                        .length
                        .toString(),
                    Icons.edit,
                    Colors.orange,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUsersSection({required String title, required List<User> users}) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text('No $title found', style: TextStyle(color: Colors.grey[600])),
              ),
            ),
          )
        else
          Card(
            elevation: 2,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.role == UserRole.doctor
                        ? Colors.blue
                        : Colors.pink,
                    child: Icon(
                      user.role == UserRole.doctor
                          ? Icons.local_hospital
                          : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Chip(
                    label: Text(
                      user.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        color: user.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    backgroundColor:
                        user.isActive ? Colors.green[50] : Colors.red[50],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActivityLogsSection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Activity Logs',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _filterAction,
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('All Actions')),
                DropdownMenuItem(value: 'LOGIN', child: Text('Logins')),
                DropdownMenuItem(value: 'USER_CREATED', child: Text('User Created')),
                DropdownMenuItem(value: 'USER_DEACTIVATED', child: Text('Deletions')),
                DropdownMenuItem(value: 'DATA_UPDATED', child: Text('Updates')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterAction = value);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_filteredLogs.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No logs found',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          )
        else
          Card(
            elevation: 2,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredLogs.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final log = _filteredLogs[index];
                return _buildLogTile(log);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderSection({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 36, color: Colors.deepPurple[600]),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildLogTile(SystemLog log) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _getActionColor(log.action),
                child: Icon(
                  _getActionIcon(log.action),
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getActionColor(log.action).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.action,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getActionColor(log.action),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By: ${log.userRole.toUpperCase()} (${log.userId})',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (log.previousValue != null || log.newValue != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (log.previousValue != null)
                              Text(
                                'Before: ${log.previousValue}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red[700],
                                ),
                              ),
                            if (log.newValue != null)
                              Text(
                                'After: ${log.newValue}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green[700],
                                ),
                              ),
                          ],
                        ),
                      ),
                    Text(
                      _formatDateTime(log.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'LOGIN':
        return Colors.blue;
      case 'LOGOUT':
        return Colors.grey;
      case 'USER_CREATED':
        return Colors.green;
      case 'USER_DEACTIVATED':
        return Colors.red;
      case 'DATA_UPDATED':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'LOGIN':
        return Icons.login;
      case 'LOGOUT':
        return Icons.logout;
      case 'USER_CREATED':
        return Icons.person_add;
      case 'USER_DEACTIVATED':
        return Icons.delete;
      case 'DATA_UPDATED':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}

class _AdminNavItem {
  final String label;
  final IconData icon;

  const _AdminNavItem({required this.label, required this.icon});
}
