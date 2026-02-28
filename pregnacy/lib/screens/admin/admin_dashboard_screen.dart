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

  @override
  Widget build(BuildContext context) {
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
          : RefreshIndicator(
              onRefresh: _loadData,
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
                            'Welcome, ${_authService.currentUser?.name}! 👮',
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

                  // Stats Row
                  Row(
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
                  ),
                  const SizedBox(height: 24),

                  // Users Section
                  const Text(
                    'Registered Users',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user.role == UserRole.admin
                                ? Colors.deepPurple
                                : user.role == UserRole.doctor
                                    ? Colors.blue
                                    : Colors.pink,
                            child: Icon(
                              user.role == UserRole.admin
                                  ? Icons.admin_panel_settings
                                  : user.role == UserRole.doctor
                                      ? Icons.local_hospital
                                      : Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text('${user.email} • ${user.role.toString().split('.').last}'),
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
                  const SizedBox(height: 24),

                  // Audit Logs Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Audit Logs (Changes & Deletions)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DropdownButton<String>(
                        value: _filterAction,
                        items: [
                          const DropdownMenuItem(
                            value: 'ALL',
                            child: Text('All Actions'),
                          ),
                          const DropdownMenuItem(
                            value: 'LOGIN',
                            child: Text('Logins'),
                          ),
                          const DropdownMenuItem(
                            value: 'USER_CREATED',
                            child: Text('User Created'),
                          ),
                          const DropdownMenuItem(
                            value: 'USER_DEACTIVATED',
                            child: Text('Deletions'),
                          ),
                          const DropdownMenuItem(
                            value: 'DATA_UPDATED',
                            child: Text('Updates'),
                          ),
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
