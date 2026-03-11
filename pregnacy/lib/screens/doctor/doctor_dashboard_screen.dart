// lib/screens/doctor/doctor_dashboard_screen.dart
import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class DC {
  static const navy  = Color(0xFF1A2B4A);
  static const blue  = Color(0xFF3B6FD4);
  static const sky   = Color(0xFFE8EFFE);
  static const teal  = Color(0xFF3BBFAD);
  static const cream = Color(0xFFF4F7FF);
  static const white = Colors.white;
  static const text  = Color(0xFF1A2B4A);
  static const muted = Color(0xFF8A97B0);
  static const rose  = Color(0xFFD4847A);
  static const amber = Color(0xFFE8A44A);
  static const green = Color(0xFF4AAB72);
  static const card  = Color(0xFFFFFFFF);
}

// ─── Models ───────────────────────────────────────────────────────────────────
class Patient {
  final String id, name, initials, week, trimester, dueDate, lastVisit, phone;
  final int age;
  final String status;
  final double weight, bp_sys, bp_dia;
  final int heartRate;
  final List<String> conditions;
  final List<String> medications;
  final List<String> symptoms;
  final List<Appointment> appointments;
  final List<Message> messages;

  const Patient({
    required this.id, required this.name, required this.initials,
    required this.week, required this.trimester, required this.dueDate,
    required this.lastVisit, required this.phone, required this.age,
    required this.status, required this.weight, required this.bp_sys,
    required this.bp_dia, required this.heartRate,
    required this.conditions, required this.medications,
    required this.symptoms, required this.appointments, required this.messages,
  });
}

class Appointment {
  final String date, time, type, status;
  const Appointment({required this.date, required this.time, required this.type, required this.status});
}

class Message {
  final String sender, text, time;
  final bool fromPatient;
  const Message({required this.sender, required this.text, required this.time, required this.fromPatient});
}

// ─── Sample Data ──────────────────────────────────────────────────────────────
final assignedPatients = [
  Patient(
    id: 'P001', name: 'Amara Osei', initials: 'AO', age: 28,
    week: '24', trimester: '2nd', dueDate: 'June 17, 2026',
    lastVisit: 'Feb 28, 2026', phone: '+254 712 345 678',
    status: 'stable', weight: 68.2, bp_sys: 118, bp_dia: 76, heartRate: 148,
    conditions: ['None'],
    medications: ['Folic Acid', 'Iron Supplements', 'Vitamin D'],
    symptoms: ['Mild fatigue', 'Occasional heartburn'],
    appointments: [
      Appointment(date: 'Mar 10', time: '10:00 AM', type: 'Routine Check-up',  status: 'confirmed'),
      Appointment(date: 'Mar 18', time: '2:30 PM',  type: 'Anatomy Scan',      status: 'confirmed'),
    ],
    messages: [
      Message(sender: 'Amara Osei', text: 'Good morning doctor, I have been feeling dizzy since yesterday.', time: '8:42 AM', fromPatient: true),
      Message(sender: 'Dr. Njenga', text: 'Good morning Amara. Please monitor your blood pressure and rest well. Come in if it worsens.', time: '9:10 AM', fromPatient: false),
      Message(sender: 'Amara Osei', text: 'Thank you doctor. Should I take anything for the dizziness?', time: '9:15 AM', fromPatient: true),
    ],
  ),
  Patient(
    id: 'P002', name: 'Fatuma Wanjiru', initials: 'FW', age: 32,
    week: '34', trimester: '3rd', dueDate: 'Apr 2, 2026',
    lastVisit: 'Mar 1, 2026', phone: '+254 722 987 654',
    status: 'attention', weight: 78.5, bp_sys: 138, bp_dia: 89, heartRate: 152,
    conditions: ['Hypertension'],
    medications: ['Blood Pressure Medication', 'Folic Acid', 'Calcium'],
    symptoms: ['Leg swelling', 'Headaches', 'High BP'],
    appointments: [
      Appointment(date: 'Mar 7',  time: '9:00 AM',  type: 'BP Monitoring',    status: 'urgent'),
      Appointment(date: 'Mar 14', time: '11:00 AM', type: 'Routine Check-up', status: 'confirmed'),
    ],
    messages: [
      Message(sender: 'Fatuma Wanjiru', text: 'Doctor my head has been pounding since this morning and my feet are very swollen.', time: 'Yesterday', fromPatient: true),
      Message(sender: 'Dr. Njenga', text: 'Fatuma, please come in tomorrow morning first thing. We need to check your blood pressure urgently.', time: 'Yesterday', fromPatient: false),
    ],
  ),
  Patient(
    id: 'P003', name: 'Grace Muthoni', initials: 'GM', age: 25,
    week: '12', trimester: '1st', dueDate: 'Sep 10, 2026',
    lastVisit: 'Mar 3, 2026', phone: '+254 733 111 222',
    status: 'stable', weight: 61.0, bp_sys: 112, bp_dia: 70, heartRate: 144,
    conditions: ['Anaemia'],
    medications: ['Iron Supplements', 'Folic Acid', 'Prenatal Multivitamin'],
    symptoms: ['Nausea', 'Fatigue'],
    appointments: [
      Appointment(date: 'Mar 20', time: '1:00 PM', type: 'First Trimester Screen', status: 'confirmed'),
    ],
    messages: [
      Message(sender: 'Grace Muthoni', text: 'Hello doctor, is it normal to feel so tired all the time at 12 weeks?', time: 'Mar 3', fromPatient: true),
      Message(sender: 'Dr. Njenga', text: 'Yes Grace, fatigue is very common in the first trimester. Ensure you are taking your iron supplements and resting.', time: 'Mar 3', fromPatient: false),
    ],
  ),
  Patient(
    id: 'P004', name: 'Naomi Chebet', initials: 'NC', age: 30,
    week: '38', trimester: '3rd', dueDate: 'Mar 20, 2026',
    lastVisit: 'Mar 4, 2026', phone: '+254 744 333 555',
    status: 'critical', weight: 82.1, bp_sys: 145, bp_dia: 95, heartRate: 158,
    conditions: ['Gestational Diabetes', 'Hypertension'],
    medications: ['Insulin', 'Blood Pressure Medication', 'Folic Acid'],
    symptoms: ['High BP', 'High blood sugar', 'Reduced fetal movement'],
    appointments: [
      Appointment(date: 'Mar 6', time: '8:00 AM', type: 'Urgent Review', status: 'urgent'),
    ],
    messages: [
      Message(sender: 'Naomi Chebet', text: 'Doctor I have not felt the baby move much today. I am very worried.', time: '11:20 PM', fromPatient: true),
    ],
  ),
];

// ─── Shared helpers ───────────────────────────────────────────────────────────
Color statusColor(String s) {
  if (s == 'critical') return const Color(0xFFE05252);
  if (s == 'attention') return DC.amber;
  return DC.green;
}

Color statusBg(String s) {
  if (s == 'critical') return const Color(0xFFFFECEC);
  if (s == 'attention') return const Color(0xFFFFF4E0);
  return const Color(0xFFE6F5ED);
}

String statusLabel(String s) {
  if (s == 'critical') return 'Critical';
  if (s == 'attention') return 'Needs Attention';
  return 'Stable';
}

Widget _statusBadge(String status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: statusBg(status), borderRadius: BorderRadius.circular(100)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor(status), shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(statusLabel(status), style: TextStyle(fontSize: 11, color: statusColor(status), fontWeight: FontWeight.w600)),
    ]),
  );
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  const _PageHeader({required this.title, required this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontFamily: 'Georgia', fontSize: 24, fontWeight: FontWeight.w400, color: DC.navy)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: DC.muted)),
            ]),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── Main Dashboard Screen ────────────────────────────────────────────────────
class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});
  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _tab = 0;

  final _tabs  = ['Dashboard', 'Patients', 'Schedule', 'Messages', 'Analytics'];
  final _icons = [
    Icons.grid_view_rounded,
    Icons.people_outline_rounded,
    Icons.calendar_month_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.bar_chart_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DC.cream,
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _BottomNav(
        currentIndex: _tab,
        tabs: _tabs,
        icons: _icons,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case 0: return const _HomeTab();
      case 1: return const _PatientsTab();
      case 2: return const _ScheduleTab();
      case 3: return const _MessagesTab();
      case 4: return const _AnalyticsTab();
      default: return const _HomeTab();
    }
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<String> tabs;
  final List<IconData> icons;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.tabs, required this.icons, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DC.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EFFE))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final active = currentIndex == i;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? DC.blue.withOpacity(0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icons[i], size: 22, color: active ? DC.blue : DC.muted),
                    ),
                    const SizedBox(height: 2),
                    Text(tabs[i],
                        style: TextStyle(
                            fontSize: 10,
                            color: active ? DC.blue : DC.muted,
                            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── TAB 0: Home ─────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final critical  = assignedPatients.where((p) => p.status == 'critical').length;
    final attention = assignedPatients.where((p) => p.status == 'attention').length;
    final todayAppts = assignedPatients
        .expand((p) => p.appointments)
        .where((a) => a.date == 'Mar 6' || a.date == 'Mar 7')
        .toList();

    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [DC.navy, Color(0xFF2A4A7A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 22, backgroundColor: DC.blue,
                child: const Text('NJ', style: TextStyle(color: Colors.white, fontFamily: 'Georgia', fontSize: 16))),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Dr. Njenga', style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)),
                Text("OB/GYN \u00b7 Nairobi Women's Hospital", style: TextStyle(fontSize: 12, color: Colors.white54)),
              ]),
              const Spacer(),
              Stack(children: [
                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                Positioned(right: 0, top: 0,
                  child: Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: DC.rose, shape: BoxShape.circle))),
              ]),
            ]),
            const SizedBox(height: 20),
            const Text('Good morning, Doctor \ud83d\udc4b',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 22, color: Colors.white, fontWeight: FontWeight.w300)),
            const SizedBox(height: 4),
            const Text('Thursday, March 5, 2026', style: TextStyle(fontSize: 13, color: Colors.white54)),
          ]),
        ),

        const SizedBox(height: 20),

        // Alert banner
        if (critical > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECEC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE05252).withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFE05252), size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  '$critical patient${critical > 1 ? "s" : ""} need${critical == 1 ? "s" : ""} urgent attention',
                  style: const TextStyle(fontSize: 13, color: Color(0xFFE05252), fontWeight: FontWeight.w600))),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFFE05252)),
              ]),
            ),
          ),

        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(child: _StatCard(value: '${assignedPatients.length}', label: 'My Patients', icon: Icons.people_outline_rounded, color: DC.blue)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(value: '$critical', label: 'Critical', icon: Icons.priority_high_rounded, color: const Color(0xFFE05252))),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(value: '$attention', label: 'Watch', icon: Icons.visibility_outlined, color: DC.amber)),
          ]),
        ),

        const SizedBox(height: 24),

        // Today's schedule
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
            Text("Today's Schedule", style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: DC.navy)),
            Text('View all', style: TextStyle(fontSize: 13, color: DC.blue)),
          ]),
        ),
        const SizedBox(height: 12),
        if (todayAppts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('No appointments today.', style: TextStyle(color: DC.muted, fontSize: 13)),
          )
        else
          ...assignedPatients
              .where((p) => p.appointments.any((a) => a.date == 'Mar 6' || a.date == 'Mar 7'))
              .map((p) {
            final appt = p.appointments.firstWhere((a) => a.date == 'Mar 6' || a.date == 'Mar 7');
            return _TodayApptCard(patient: p, appointment: appt);
          }),

        const SizedBox(height: 24),

        // Patients needing attention
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Patients Needing Attention', style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: DC.navy)),
        ),
        const SizedBox(height: 12),
        ...assignedPatients
            .where((p) => p.status == 'critical' || p.status == 'attention')
            .map((p) => _PatientCard(patient: p, compact: true)),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DC.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontFamily: 'Georgia', fontSize: 26, color: color, fontWeight: FontWeight.w400)),
        Text(label, style: const TextStyle(fontSize: 11, color: DC.muted)),
      ]),
    );
  }
}

class _TodayApptCard extends StatelessWidget {
  final Patient patient;
  final Appointment appointment;
  const _TodayApptCard({required this.patient, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isUrgent = appointment.status == 'urgent';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUrgent ? const Color(0xFFFFECEC) : DC.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isUrgent ? const Color(0xFFE05252).withOpacity(0.3) : Colors.transparent),
          boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isUrgent ? const Color(0xFFE05252) : DC.blue,
            child: Text(patient.initials, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Georgia')),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patient.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DC.navy)),
            Text('${appointment.type} \u00b7 ${appointment.time}', style: const TextStyle(fontSize: 12, color: DC.muted)),
          ])),
          if (isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE05252), borderRadius: BorderRadius.circular(100)),
              child: const Text('URGENT', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ]),
      ),
    );
  }
}

// ─── TAB 1: Patients ─────────────────────────────────────────────────────────
class _PatientsTab extends StatefulWidget {
  const _PatientsTab();
  @override
  State<_PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<_PatientsTab> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Critical', 'Attention', 'Stable'];
    final filtered = _filter == 'All'
        ? assignedPatients
        : assignedPatients.where((p) => statusLabel(p.status).contains(_filter)).toList();

    return Column(children: [
      _PageHeader(title: 'My Patients', subtitle: '${assignedPatients.length} assigned to you'),
      const SizedBox(height: 16),

      // Search bar
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: DC.white, borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DC.sky),
          ),
          child: const TextField(
            style: TextStyle(fontSize: 14, color: DC.navy),
            decoration: InputDecoration(
              hintText: 'Search patient...', border: InputBorder.none,
              icon: Icon(Icons.search_rounded, color: DC.muted, size: 20),
              hintStyle: TextStyle(color: DC.muted, fontSize: 14),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),

      // Filter chips
      SizedBox(
        height: 36,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final active = _filter == filters[i];
            return GestureDetector(
              onTap: () => setState(() => _filter = filters[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? DC.navy : DC.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: active ? DC.navy : DC.sky),
                ),
                child: Text(filters[i],
                    style: TextStyle(
                        fontSize: 12,
                        color: active ? Colors.white : DC.muted,
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),

      Expanded(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: filtered.map((p) => _PatientCard(patient: p, compact: false)).toList(),
        ),
      ),
    ]);
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final bool compact;
  const _PatientCard({required this.patient, required this.compact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _PatientDetailScreen(patient: patient))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DC.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                radius: 22, backgroundColor: DC.blue.withOpacity(0.15),
                child: Text(patient.initials, style: const TextStyle(color: DC.blue, fontFamily: 'Georgia', fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(patient.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: DC.navy)),
                Text('Week ${patient.week} \u00b7 ${patient.trimester} Trimester \u00b7 Due ${patient.dueDate}',
                    style: const TextStyle(fontSize: 12, color: DC.muted)),
              ])),
              _statusBadge(patient.status),
            ]),
            if (!compact) ...[
              const SizedBox(height: 12),
              const Divider(color: DC.sky, height: 1),
              const SizedBox(height: 12),
              Row(children: [
                _MiniStat(label: 'Weight', value: '${patient.weight}kg'),
                _MiniStat(label: 'BP', value: '${patient.bp_sys.toInt()}/${patient.bp_dia.toInt()}'),
                _MiniStat(label: 'FHR', value: '${patient.heartRate}bpm'),
                _MiniStat(label: 'Last Visit', value: patient.lastVisit),
              ]),
            ],
            const SizedBox(height: 4),
            const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('View Records', style: TextStyle(fontSize: 12, color: DC.blue, fontWeight: FontWeight.w600)),
              Icon(Icons.chevron_right_rounded, color: DC.blue, size: 16),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DC.navy)),
      Text(label, style: const TextStyle(fontSize: 10, color: DC.muted)),
    ]));
  }
}

// ─── Patient Detail Screen ────────────────────────────────────────────────────
class _PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const _PatientDetailScreen({required this.patient});
  @override
  State<_PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<_PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    return Scaffold(
      backgroundColor: DC.cream,
      appBar: AppBar(
        backgroundColor: DC.navy,
        foregroundColor: Colors.white,
        title: Text(p.name, style: const TextStyle(fontFamily: 'Georgia', fontSize: 18)),
        actions: [_statusBadge(p.status), const SizedBox(width: 12)],
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          indicatorColor: DC.rose,
          tabs: const [Tab(text: 'Health'), Tab(text: 'Appointments'), Tab(text: 'Messages')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _HealthRecordsTab(patient: p),
        _PatientAppointmentsTab(patient: p),
        _ChatTab(patient: p),
      ]),
    );
  }
}

class _HealthRecordsTab extends StatefulWidget {
  final Patient patient;
  const _HealthRecordsTab({required this.patient});

  @override
  State<_HealthRecordsTab> createState() => _HealthRecordsTabState();
}

class _HealthRecordsTabState extends State<_HealthRecordsTab> {
  final List<Map<String, String>> _clinicalNotes = [];

  void _showClinicalNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(children: [
            const Icon(Icons.edit_note_rounded, color: DC.navy),
            const SizedBox(width: 8),
            const Text('Add Clinical Note',
                style: TextStyle(fontFamily: 'Georgia', color: DC.navy, fontSize: 18)),
          ]),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: controller,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Type your recommendation or clinical observation…',
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: DC.navy, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final note = controller.text.trim();
                if (note.isEmpty) return;
                final now = DateTime.now();
                final stamp =
                    '${now.day}/${now.month}/${now.year}  ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
                setState(() => _clinicalNotes.insert(0, {'note': note, 'time': stamp}));
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text('Save Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DC.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Pregnancy summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DC.navy, Color(0xFF2A4A7A)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Week ${p.week} of 40 \u00b7 ${p.trimester} Trimester',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Due ${p.dueDate}',
                style: const TextStyle(fontFamily: 'Georgia', fontSize: 20, color: Colors.white)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: int.parse(p.week) / 40,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(DC.teal),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text('${int.parse(p.week)} / 40 weeks', style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ]),
        ),
        const SizedBox(height: 20),

        // Vitals
        const Text('Latest Vitals', style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: DC.navy)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2,
          children: [
            _VitalCard(label: 'Weight', value: '${p.weight} kg', icon: '\u2696\ufe0f', ok: true),
            _VitalCard(label: 'Blood Pressure', value: '${p.bp_sys.toInt()}/${p.bp_dia.toInt()}', icon: '\ud83d\udc93', ok: p.bp_sys < 140),
            _VitalCard(label: 'Fetal Heart Rate', value: '${p.heartRate} bpm', icon: '\u{1FAC0}', ok: p.heartRate < 160),
            _VitalCard(label: 'Age', value: '${p.age} yrs', icon: '\ud83d\uddd3\ufe0f', ok: true),
          ],
        ),
        const SizedBox(height: 20),

        _RecordSection(title: 'Pre-existing Conditions', emoji: '\ud83e\ude7a', items: p.conditions),
        const SizedBox(height: 16),
        _RecordSection(title: 'Current Medications', emoji: '\ud83d\udc8a', items: p.medications),
        const SizedBox(height: 16),
        _RecordSection(title: 'Reported Symptoms', emoji: '\ud83d\udccb', items: p.symptoms),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showClinicalNoteDialog,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Clinical Note'),
            style: ElevatedButton.styleFrom(
              backgroundColor: DC.navy, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        if (_clinicalNotes.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('Clinical Notes',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: DC.navy)),
          const SizedBox(height: 12),
          ..._clinicalNotes.map((n) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DC.navy.withOpacity(0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.edit_note_rounded, size: 16, color: DC.navy),
                const SizedBox(width: 6),
                Text(n['time']!,
                    style: const TextStyle(fontSize: 11, color: Colors.black45,
                        fontStyle: FontStyle.italic)),
              ]),
              const SizedBox(height: 8),
              Text(n['note']!,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5)),
            ]),
          )),
        ],
      ]),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label, value, icon;
  final bool ok;
  const _VitalCard({required this.label, required this.value, required this.icon, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok ? DC.white : const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ok ? DC.sky : const Color(0xFFE05252).withOpacity(0.3)),
      ),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ok ? DC.navy : const Color(0xFFE05252))),
          Text(label, style: const TextStyle(fontSize: 10, color: DC.muted)),
        ])),
      ]),
    );
  }
}

class _RecordSection extends StatelessWidget {
  final String title, emoji;
  final List<String> items;
  const _RecordSection({required this.title, required this.emoji, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DC.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$emoji  $title', style: const TextStyle(fontFamily: 'Georgia', fontSize: 15, color: DC.navy)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: items.map((item) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: DC.sky, borderRadius: BorderRadius.circular(100)),
          child: Text(item, style: const TextStyle(fontSize: 12, color: DC.blue)),
        )).toList()),
      ]),
    );
  }
}

class _PatientAppointmentsTab extends StatelessWidget {
  final Patient patient;
  const _PatientAppointmentsTab({required this.patient});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...patient.appointments.map((a) {
          final isUrgent = a.status == 'urgent';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUrgent ? const Color(0xFFFFECEC) : DC.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isUrgent ? const Color(0xFFE05252).withOpacity(0.3) : DC.sky),
            ),
            child: Row(children: [
              Container(
                width: 52, padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFE05252) : DC.navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(children: [
                  Text(a.date.split(' ')[1],
                      style: const TextStyle(fontFamily: 'Georgia', fontSize: 20, color: Colors.white)),
                  Text(a.date.split(' ')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.white70, letterSpacing: 1)),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(a.type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DC.navy)),
                Text(a.time, style: const TextStyle(fontSize: 12, color: DC.muted)),
              ])),
              if (isUrgent)
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFE05252)),
            ]),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Schedule Appointment'),
          style: OutlinedButton.styleFrom(
            foregroundColor: DC.blue,
            side: const BorderSide(color: DC.blue),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _ChatTab extends StatefulWidget {
  final Patient patient;
  const _ChatTab({required this.patient});
  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: widget.patient.messages.map((m) {
            final isDoctor = !m.fromPatient;
            return Align(
              alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: isDoctor ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDoctor ? DC.navy : DC.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isDoctor ? const Radius.circular(4) : null,
                        bottomLeft:  !isDoctor ? const Radius.circular(4) : null,
                      ),
                      boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.06), blurRadius: 6)],
                    ),
                    child: Text(m.text,
                        style: TextStyle(fontSize: 13, color: isDoctor ? Colors.white : DC.text, height: 1.5)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
                    child: Text(m.time, style: const TextStyle(fontSize: 10, color: DC.muted)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        color: DC.white,
        child: Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: DC.cream, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: DC.sky),
              ),
              child: TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                  hintText: 'Reply to patient...', border: InputBorder.none,
                  hintStyle: TextStyle(color: DC.muted, fontSize: 13),
                ),
                style: const TextStyle(fontSize: 13, color: DC.navy),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _ctrl.clear()),
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(color: DC.navy, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ]),
      ),
    ]);
  }
}

// ─── TAB 2: Schedule ─────────────────────────────────────────────────────────
class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab();

  @override
  Widget build(BuildContext context) {
    final allAppts = <MapEntry<Patient, Appointment>>[];
    for (final p in assignedPatients) {
      for (final a in p.appointments) { allAppts.add(MapEntry(p, a)); }
    }

    const days  = ['Thu','Fri','Sat','Sun','Mon','Tue','Wed','Thu','Fri','Sat','Sun','Mon','Tue','Wed'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PageHeader(title: 'Schedule', subtitle: '${allAppts.length} upcoming appointments'),
      const SizedBox(height: 16),

      // Calendar strip
      SizedBox(
        height: 72,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: 14,
          itemBuilder: (_, i) {
            final date = i + 5;
            final active = i == 0;
            return Container(
              width: 50, margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: active ? DC.navy : DC.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: active ? DC.navy : DC.sky),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(days[i], style: TextStyle(fontSize: 11, color: active ? Colors.white54 : DC.muted)),
                Text('$date', style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: active ? Colors.white : DC.navy)),
              ]),
            );
          },
        ),
      ),
      const SizedBox(height: 16),

      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: allAppts.length,
          itemBuilder: (_, i) {
            final p = allAppts[i].key;
            final a = allAppts[i].value;
            final isUrgent = a.status == 'urgent';
            final timeParts = a.time.split(' ');
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUrgent ? const Color(0xFFFFECEC) : DC.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isUrgent ? const Color(0xFFE05252).withOpacity(0.4) : DC.sky),
              ),
              child: Row(children: [
                Column(children: [
                  Text(timeParts[0],
                      style: TextStyle(fontFamily: 'Georgia', fontSize: 16,
                          color: isUrgent ? const Color(0xFFE05252) : DC.blue, fontWeight: FontWeight.w600)),
                  Text(timeParts.length > 1 ? timeParts[1] : '',
                      style: const TextStyle(fontSize: 10, color: DC.muted)),
                ]),
                const SizedBox(width: 16),
                Container(width: 1, height: 40, color: DC.sky),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DC.navy)),
                  Text('${p.name} \u00b7 ${a.date}', style: const TextStyle(fontSize: 12, color: DC.muted)),
                ])),
                CircleAvatar(
                  radius: 16, backgroundColor: DC.sky,
                  child: Text(p.initials, style: const TextStyle(color: DC.blue, fontSize: 11, fontFamily: 'Georgia')),
                ),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

// ─── TAB 3: Messages ─────────────────────────────────────────────────────────
class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _PageHeader(title: 'Messages', subtitle: 'From your assigned patients only'),
      const SizedBox(height: 16),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: assignedPatients.map((p) {
            final last  = p.messages.last;
            final unread = p.messages.where((m) => m.fromPatient).length;
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _PatientDetailScreen(patient: p))),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: DC.white, borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Row(children: [
                  Stack(children: [
                    CircleAvatar(
                      radius: 22, backgroundColor: DC.sky,
                      child: Text(p.initials, style: const TextStyle(color: DC.blue, fontFamily: 'Georgia', fontSize: 15)),
                    ),
                    Positioned(bottom: 0, right: 0,
                      child: Container(width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: statusColor(p.status), shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ))),
                  ]),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DC.navy)),
                    Text(last.text, style: const TextStyle(fontSize: 12, color: DC.muted),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(last.time, style: const TextStyle(fontSize: 11, color: DC.muted)),
                    const SizedBox(height: 4),
                    if (unread > 0)
                      Container(
                        width: 20, height: 20,
                        decoration: const BoxDecoration(color: DC.blue, shape: BoxShape.circle),
                        child: Center(child: Text('$unread',
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700)))),
                  ]),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}

// ─── TAB 4: Analytics ────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    final stable    = assignedPatients.where((p) => p.status == 'stable').length;
    final attention = assignedPatients.where((p) => p.status == 'attention').length;
    final critical  = assignedPatients.where((p) => p.status == 'critical').length;
    final total     = assignedPatients.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Analytics & Reports', style: TextStyle(fontFamily: 'Georgia', fontSize: 24, color: DC.navy)),
        const Text('Based on your assigned patients', style: TextStyle(fontSize: 13, color: DC.muted)),
        const SizedBox(height: 20),

        // Patient status breakdown
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DC.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Patient Status Breakdown', style: TextStyle(fontFamily: 'Georgia', fontSize: 16, color: DC.navy)),
            const SizedBox(height: 16),
            _BarRow(label: 'Stable',           value: stable,    total: total, color: DC.green),
            const SizedBox(height: 10),
            _BarRow(label: 'Needs Attention',  value: attention, total: total, color: DC.amber),
            const SizedBox(height: 10),
            _BarRow(label: 'Critical',         value: critical,  total: total, color: const Color(0xFFE05252)),
          ]),
        ),
        const SizedBox(height: 16),

        // Trimester breakdown
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: DC.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Trimester Distribution', style: TextStyle(fontFamily: 'Georgia', fontSize: 16, color: DC.navy)),
            const SizedBox(height: 16),
            _BarRow(label: '1st Trimester', value: 1, total: total, color: DC.teal),
            const SizedBox(height: 10),
            _BarRow(label: '2nd Trimester', value: 1, total: total, color: DC.blue),
            const SizedBox(height: 10),
            _BarRow(label: '3rd Trimester', value: 2, total: total, color: DC.navy),
          ]),
        ),
        const SizedBox(height: 16),

        Row(children: [
          Expanded(child: _SummaryCard(title: 'Avg. Weeks', value: '27', subtitle: 'Across all patients', icon: Icons.timeline_rounded, color: DC.blue)),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(
            title: 'Upcoming Appts',
            value: '${assignedPatients.expand((p) => p.appointments).length}',
            subtitle: 'Next 30 days',
            icon: Icons.calendar_today_rounded, color: DC.teal,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _SummaryCard(title: 'High BP Patients', value: '2', subtitle: 'Need monitoring', icon: Icons.favorite_border_rounded, color: const Color(0xFFE05252))),
          const SizedBox(width: 12),
          Expanded(child: _SummaryCard(title: 'Due This Month', value: '1', subtitle: 'Naomi Chebet', icon: Icons.child_friendly_outlined, color: DC.amber)),
        ]),
      ]),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final int value, total;
  final Color color;
  const _BarRow({required this.label, required this.value, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: DC.text)),
        Text('$value / $total', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct, backgroundColor: DC.sky,
          valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8,
        ),
      ),
    ]);
  }
}

class _SummaryCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DC.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: DC.navy.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontFamily: 'Georgia', fontSize: 28, color: color, fontWeight: FontWeight.w400)),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DC.navy)),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: DC.muted)),
      ]),
    );
  }
}
