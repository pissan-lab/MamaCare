import 'package:flutter/material.dart';
import '../../services/patient_api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  final _api = PatientApiService.instance;
  final _notif = NotificationService.instance;

  List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  String? _error;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _notif.initialize();
    _fetch();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // â”€â”€â”€ Data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _api.getAppointments();
      data.sort((a, b) {
        final da = DateTime.tryParse(a['dateTime'] ?? '') ?? DateTime(0);
        final db = DateTime.tryParse(b['dateTime'] ?? '') ?? DateTime(0);
        return da.compareTo(db);
      });
      setState(() { _appointments = data; _loading = false; });
    } on PatientApiException catch (e) {
      setState(() { _error = 'Server error ${e.statusCode}'; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _addAppointment() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _AppointmentForm(),
    );
    if (result == null) return;
    try {
      final saved = await _api.addAppointment(result);

      // Schedule local notifications
      final dt = DateTime.tryParse(
          (saved['dateTime'] ?? result['dateTime']) as String? ?? '');
      final id = saved['id'] is int
          ? saved['id'] as int
          : result['dateTime'].hashCode.abs();
      if (dt != null) {
        await _notif.scheduleAppointmentReminders(
          appointmentId: id,
          title: (saved['title'] ?? result['title']) as String? ??
              'Appointment',
          appointmentDateTime: dt,
        );
      }

      _fetch();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment saved â€” reminders set!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on PatientApiException catch (e) {
      _showError('Could not save appointment (${e.statusCode})');
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );

  // â”€â”€â”€ Derived lists â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static DateTime _dt(Map<String, dynamic> a) =>
      DateTime.tryParse(a['dateTime'] ?? '') ?? DateTime(0);

  List<Map<String, dynamic>> get _upcoming {
    final now = DateTime.now();
    return _appointments.where((a) => _dt(a).isAfter(now)).toList();
  }

  List<Map<String, dynamic>> get _past {
    final now = DateTime.now();
    return _appointments
        .where((a) => !_dt(a).isAfter(now))
        .toList()
        .reversed
        .toList();
  }

  // â”€â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.pink[400],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _fetch,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh'),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Upcoming'),
                  if (_upcoming.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_upcoming.length}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Past'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _fetch)
              : TabBarView(
                  controller: _tabs,
                  children: [
                    _AppointmentList(
                      appointments: _upcoming,
                      isUpcoming: true,
                      emptyMessage: 'No upcoming appointments.\nTap + to add one.',
                      emptyIcon: Icons.event_available,
                    ),
                    _AppointmentList(
                      appointments: _past,
                      isUpcoming: false,
                      emptyMessage: 'No past appointments.',
                      emptyIcon: Icons.event_busy,
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAppointment,
        backgroundColor: Colors.pink[400],
        icon: const Icon(Icons.add),
        label: const Text('Add Appointment'),
      ),
    );
  }
}

// â”€â”€â”€ Appointment List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AppointmentList extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  final bool isUpcoming;
  final String emptyMessage;
  final IconData emptyIcon;

  const _AppointmentList({
    required this.appointments,
    required this.isUpcoming,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 14),
              Text(emptyMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount:
          isUpcoming ? appointments.length + 1 : appointments.length,
      itemBuilder: (context, index) {
        // Insert reminder banner as index 0 for upcoming tab
        if (isUpcoming && index == 0) {
          return _ReminderBanner(appointments: appointments);
        }
        final appt = appointments[isUpcoming ? index - 1 : index];
        return _AppointmentCard(appointment: appt, isUpcoming: isUpcoming);
      },
    );
  }
}

// â”€â”€â”€ Reminder Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ReminderBanner extends StatelessWidget {
  final List<Map<String, dynamic>> appointments;
  const _ReminderBanner({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Find the soonest appointment
    final next = appointments.isNotEmpty ? appointments.first : null;
    final nextDt = next != null
        ? DateTime.tryParse(next['dateTime'] ?? '') ?? DateTime(0)
        : null;

    if (nextDt == null) return const SizedBox.shrink();

    final diff = nextDt.difference(now);
    final String urgencyMsg;
    Color bannerColor;
    Color textColor;
    IconData icon;

    if (diff.inHours < 1) {
      urgencyMsg =
          'ðŸš¨ Your appointment is in less than 1 hour!';
      bannerColor = Colors.red[50]!;
      textColor = Colors.red[800]!;
      icon = Icons.alarm;
    } else if (diff.inHours < 24) {
      urgencyMsg =
          'â° Appointment today in ${diff.inHours}h ${diff.inMinutes % 60}m';
      bannerColor = Colors.orange[50]!;
      textColor = Colors.orange[800]!;
      icon = Icons.watch_later_outlined;
    } else if (diff.inDays == 1) {
      urgencyMsg = 'ðŸ“… Appointment tomorrow';
      bannerColor = Colors.blue[50]!;
      textColor = Colors.blue[800]!;
      icon = Icons.event;
    } else if (diff.inDays <= 7) {
      urgencyMsg = 'ðŸ“… Next appointment in ${diff.inDays} days';
      bannerColor = Colors.pink[50]!;
      textColor = Colors.pink[800]!;
      icon = Icons.event_note;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(urgencyMsg,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  next!['title'] as String? ?? 'Appointment',
                  style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Appointment Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isUpcoming;

  const _AppointmentCard({
    required this.appointment,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    final dt =
        DateTime.tryParse(appointment['dateTime'] ?? '');
    final title =
        (appointment['title'] as String?) ?? 'Appointment';
    final location = appointment['location'] as String?;
    final doctor = appointment['doctor_name'] as String?;
    final notes = appointment['notes'] as String?;

    final now = DateTime.now();
    final diff = dt != null ? dt.difference(now) : null;
    final isToday =
        dt != null && dt.day == now.day && dt.month == now.month && dt.year == now.year;
    final isTomorrow = dt != null &&
        dt.day == now.add(const Duration(days: 1)).day &&
        dt.month == now.add(const Duration(days: 1)).month &&
        dt.year == now.add(const Duration(days: 1)).year;

    Color cardBorder = Colors.transparent;
    String? urgencyLabel;
    if (isUpcoming && diff != null) {
      if (diff.inHours < 1) {
        cardBorder = Colors.red.shade300;
        urgencyLabel = 'NOW';
      } else if (isToday) {
        cardBorder = Colors.orange.shade300;
        urgencyLabel = 'TODAY';
      } else if (isTomorrow) {
        cardBorder = Colors.blue.shade300;
        urgencyLabel = 'TOMORROW';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: cardBorder != Colors.transparent
            ? Border.all(color: cardBorder, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date block
              Container(
                width: 52,
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? Colors.pink[50]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Text(
                      dt != null
                          ? _monthLabel(dt.month)
                          : '--',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUpcoming
                              ? Colors.pink[400]
                              : Colors.grey[500]),
                    ),
                    Text(
                      dt != null
                          ? dt.day.toString()
                          : '--',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isUpcoming
                              ? Colors.pink[700]
                              : Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                        if (urgencyLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  urgencyLabel == 'NOW'
                                      ? Colors.red[50]
                                      : urgencyLabel ==
                                              'TODAY'
                                          ? Colors.orange[50]
                                          : Colors.blue[50],
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                  color: cardBorder
                                      .withOpacity(0.5)),
                            ),
                            child: Text(urgencyLabel,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: cardBorder)),
                          ),
                      ],
                    ),
                    if (dt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(children: [
                          Icon(Icons.access_time,
                              size: 13,
                              color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Text(
                            TimeOfDay.fromDateTime(dt)
                                .format(context),
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600]),
                          ),
                        ]),
                      ),
                    if (doctor != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(children: [
                          Icon(Icons.person_outline,
                              size: 13,
                              color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Text(doctor,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600])),
                        ]),
                      ),
                    if (location != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Row(children: [
                          Icon(Icons.location_on_outlined,
                              size: 13,
                              color: Colors.grey[500]),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(location,
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600])),
                          ),
                        ]),
                      ),
                    if (notes != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Note: $notes',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic)),
                      ),
                  ],
                ),
              ),
              if (!isUpcoming)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check_circle,
                      color: Colors.green[300], size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
  ];

  String _monthLabel(int m) =>
      (m >= 1 && m <= 12) ? _months[m - 1] : '--';
}

// â”€â”€â”€ Error View â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.pink[400]),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Add-appointment form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AppointmentForm extends StatefulWidget {
  const _AppointmentForm();

  @override
  State<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<_AppointmentForm> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _doctorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (t != null) setState(() => _selectedTime = t);
  }

  Map<String, dynamic>? _build() {
    if (_titleCtrl.text.trim().isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) return null;
    final dt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    return {
      'title': _titleCtrl.text.trim(),
      'dateTime': dt.toIso8601String(),
      'location': _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      'doctor_name': _doctorCtrl.text.trim().isEmpty
          ? null
          : _doctorCtrl.text.trim(),
      'notes': _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      'patientId':
          AuthService.instance.currentUser?.id.toString() ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            const Text('New Appointment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _field(_titleCtrl, 'Clinic / Appointment Title *',
                Icons.medical_services_outlined),
            const SizedBox(height: 12),

            // Date + Time row
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today,
                      size: 16),
                  label: Text(
                    _selectedDate == null
                        ? 'Date *'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                        color: _selectedDate == null
                            ? Colors.grey[600]
                            : Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time,
                      size: 16),
                  label: Text(
                    _selectedTime == null
                        ? 'Time *'
                        : _selectedTime!.format(context),
                    style: TextStyle(
                        color: _selectedTime == null
                            ? Colors.grey[600]
                            : Colors.black),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),

            _field(_doctorCtrl, 'Doctor / Midwife name',
                Icons.person_outline),
            const SizedBox(height: 12),
            _field(_locationCtrl, 'Location / Hospital',
                Icons.location_on_outlined),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Notes',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),

            // Reminder note
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pink[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(Icons.notifications_outlined,
                    size: 16, color: Colors.pink[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'ll receive reminders 24 hours and 1 hour before this appointment.',
                    style: TextStyle(
                        fontSize: 12, color: Colors.pink[700]),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.pink[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final data = _build();
                  if (data == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please fill in title, date and time (*)')),
                    );
                  } else {
                    Navigator.pop(context, data);
                  }
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Save & Set Reminder',
                    style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
