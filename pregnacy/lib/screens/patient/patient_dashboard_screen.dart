// lib/screens/patient/patient_dashboard_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

// ─── Colours ───────────────────────────────────────────────────────────────
class AppColors {
  static const blush = Color(0xFFF5E6E0);
  static const rose = Color(0xFFD4847A);
  static const sidebar = Color(0xFF3D2C2C); // matches login page left panel
  static const deep = Color(0xFF3D2C2C);   // text color
  static const sage = Color(0xFF8AAB9B);
  static const cream = Color(0xFFFDF6F0);
  static const warm = Color(0xFFE8C9B8);
  static const text = Color(0xFF4A3535);
  static const muted = Color(0xFF9B8080);
}

// ─── Main Dashboard ─────────────────────────────────────────────────────────
class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;

  final _navItems = const [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.calendar_month_outlined, label: 'Appointments'),
    _NavItem(icon: Icons.favorite_border_rounded, label: 'Health'),
    _NavItem(icon: Icons.restaurant_menu_outlined, label: 'Nutrition'),
    _NavItem(icon: Icons.article_outlined, label: 'Birth Plan'),
    _NavItem(icon: Icons.folder_outlined, label: 'Documents'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, label: 'Messages'),
    _NavItem(icon: Icons.menu_book_outlined, label: 'Resources'),
  ];

  Widget get _body => _selectedIndex == 1
      ? _AppointmentsBody()
      : _selectedIndex == 2
          ? _HealthTrackerBody()
          : _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 700;

      if (isWide) {
        // ── Desktop / tablet: persistent sidebar ──────────────────────────
        return Scaffold(
          backgroundColor: AppColors.cream,
          body: Row(
            children: [
              _Sidebar(
                navItems: _navItems,
                selectedIndex: _selectedIndex,
                onItemTapped: (i) => setState(() => _selectedIndex = i),
              ),
              Expanded(child: _body),
            ],
          ),
        );
      }

      // ── Mobile: drawer + bottom-nav ────────────────────────────────────
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.sidebar,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.blush),
          title: RichText(
            text: const TextSpan(
              style: TextStyle(fontFamily: 'Georgia', fontSize: 20, color: Color(0xFFF5E6E0)),
              children: [
                TextSpan(text: 'Mama'),
                TextSpan(
                  text: 'Bloom',
                  style: TextStyle(color: AppColors.rose, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          backgroundColor: AppColors.sidebar,
          child: _Sidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemTapped: (i) {
              setState(() => _selectedIndex = i);
              Navigator.of(context).pop();
            },
          ),
        ),
        body: _body,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex > 3 ? 3 : _selectedIndex,
          backgroundColor: AppColors.sidebar,
          selectedItemColor: AppColors.rose,
          unselectedItemColor: Colors.white38,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded, size: 20), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined, size: 20), label: 'Appointments'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded, size: 20), label: 'Health'),
            BottomNavigationBarItem(icon: Icon(Icons.menu, size: 20), label: 'More'),
          ],
        ),
      );
    });
  }
}

// ─── Sidebar ────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _Sidebar extends StatelessWidget {
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontFamily: 'Georgia', fontSize: 26, color: Color(0xFFF5E6E0)),
                    children: [
                      TextSpan(text: 'Mama'),
                      TextSpan(
                        text: 'Bloom',
                        style: TextStyle(
                            color: AppColors.rose, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PREGNANCY CARE',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2.5,
                      color: AppColors.muted,
                      fontFamily: 'Georgia'),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 16),

          // Nav items
          ...List.generate(navItems.length, (i) {
            if (i == 4) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Text(
                      'MY JOURNEY',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Colors.white24,
                          fontFamily: 'Georgia'),
                    ),
                  ),
                  _SidebarItem(
                    item: navItems[i],
                    isSelected: selectedIndex == i,
                    onTap: () => onItemTapped(i),
                  ),
                ],
              );
            }
            return _SidebarItem(
              item: navItems[i],
              isSelected: selectedIndex == i,
              onTap: () => onItemTapped(i),
            );
          }),

          const Spacer(),
          const Divider(color: Colors.white10, height: 1),
          // Patient chip
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.rose,
                  child: const Text('A',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Georgia',
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Amara Osei',
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFF5E6E0),
                            fontWeight: FontWeight.w500)),
                    Text('Patient · Dr. Njenga',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.muted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem(
      {required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.rose.withOpacity(0.15) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.rose : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(item.icon,
                size: 18,
                color:
                    isSelected ? AppColors.blush : Colors.white.withOpacity(0.4)),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: TextStyle(
                  fontSize: 14,
                  color: isSelected
                      ? AppColors.blush
                      : Colors.white.withOpacity(0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard Body ──────────────────────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Topbar(),
          const SizedBox(height: 24),
          _WeekHeroCard(),
          const SizedBox(height: 16),
          _StatsRow(),
          const SizedBox(height: 16),
          _MiddleRow(),
          const SizedBox(height: 16),
          _QuickLinksRow(),
        ],
      ),
    );
  }
}

// ─── Topbar ──────────────────────────────────────────────────────────────────
class _Topbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: isMobile ? 22.0 : 36.0,
                      fontWeight: FontWeight.w300,
                      color: AppColors.deep),
                  children: const [
                    TextSpan(text: 'Good morning, '),
                    TextSpan(
                      text: 'Amara ',
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: AppColors.rose),
                    ),
                    TextSpan(text: '\ud83c\udf38'),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tuesday, March 3, 2026 · Here\'s your pregnancy overview today',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.warm, width: 1.5),
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.text, size: 20),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.rose,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Week Hero Card ───────────────────────────────────────────────────────────
class _WeekHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      padding: EdgeInsets.all(isMobile ? 20.0 : 36.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2C2C), Color(0xFF2C1F1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: isMobile
          ? _WeekHeroMobile()
          : Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT WEEK',
                  style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2.5,
                      color: AppColors.rose,
                      fontFamily: 'Georgia'),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
                    children: [
                      TextSpan(
                          text: '24',
                          style: TextStyle(
                              fontSize: 72, fontWeight: FontWeight.w300)),
                      TextSpan(
                          text: '  / 40 weeks',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white54,
                              fontWeight: FontWeight.w300)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your baby is now the size of an ear of corn. Facial features are becoming more defined and they can hear your voice.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white54,
                      height: 1.6,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),

          // Right: progress + due date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Trimester badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.rose.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                  border:
                      Border.all(color: AppColors.rose.withOpacity(0.4)),
                ),
                child: const Text(
                  '2ND TRIMESTER',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: AppColors.warm),
                ),
              ),
              const SizedBox(height: 20),

              // Progress ring
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _RingPainter(progress: 24 / 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          '60%',
                          style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                        Text(
                          'complete',
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white38,
                              letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Due date chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: AppColors.sage, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('Due date: ',
                        style:
                            TextStyle(fontSize: 13, color: Colors.white54)),
                    const Text('June 17, 2026',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Mobile-only compact week card
class _WeekHeroMobile extends StatelessWidget {
  const _WeekHeroMobile();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT WEEK',
                      style: TextStyle(fontSize: 10, letterSpacing: 2, color: AppColors.rose, fontFamily: 'Georgia')),
                  const SizedBox(height: 4),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: 'Georgia', color: Colors.white),
                      children: [
                        TextSpan(text: '24', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300)),
                        TextSpan(text: ' / 40 wks', style: TextStyle(fontSize: 15, color: Colors.white54, fontWeight: FontWeight.w300)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.rose.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.rose.withOpacity(0.4)),
                    ),
                    child: const Text('2ND TRIMESTER',
                        style: TextStyle(fontSize: 9, letterSpacing: 1.2, color: AppColors.warm)),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 90, height: 90,
              child: CustomPaint(
                painter: _RingPainter(progress: 24 / 40),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('60%', style: TextStyle(fontFamily: 'Georgia', fontSize: 20, color: Colors.white, fontWeight: FontWeight.w300)),
                      Text('done', style: TextStyle(fontSize: 9, color: Colors.white38, letterSpacing: 0.8)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Your baby is now the size of an ear of corn. Facial features are becoming more defined and they can hear your voice.',
          style: TextStyle(fontSize: 12, color: Colors.white54, height: 1.5, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 6, color: AppColors.sage),
              SizedBox(width: 6),
              Text('Due date: ', style: TextStyle(fontSize: 12, color: Colors.white54)),
              Text('June 17, 2026', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final fgPaint = Paint()
      ..color = AppColors.rose
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    const item0 = _StatCard(icon: '\u2696\ufe0f', iconBg: Color(0xFFFAE8E6), label: 'Weight', value: '68.2', unit: 'kg', note: '\u2191 0.4 kg since last visit');
    const item1 = _StatCard(icon: '\ud83d\udc93', iconBg: Color(0xFFE6F0EC), label: 'Baby Heart Rate', value: '148', unit: 'bpm', note: 'Recorded Feb 28 · Normal');
    const item2 = _StatCard(icon: '\ud83e\ude78', iconBg: Color(0xFFFAF0E8), label: 'Blood Pressure', value: '118/76', unit: 'mmHg', note: 'Healthy · Checked Mar 1');
    if (isMobile) {
      return Column(
        children: [
          Row(children: [
            Expanded(child: item0),
            const SizedBox(width: 12),
            Expanded(child: item1),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: item2),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: item0),
        const SizedBox(width: 16),
        Expanded(child: item1),
        const SizedBox(width: 16),
        Expanded(child: item2),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final Color iconBg;
  final String label;
  final String value;
  final String unit;
  final String note;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.unit,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final pad = isMobile ? 14.0 : 24.0;
    final iconSize = isMobile ? 36.0 : 44.0;
    final iconFs = isMobile ? 16.0 : 20.0;
    final valFs = isMobile ? 22.0 : 28.0;
    final unitFs = isMobile ? 12.0 : 14.0;
    final noteFs = isMobile ? 10.0 : 12.0;
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.rose.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(icon, style: TextStyle(fontSize: iconFs))),
          ),
          SizedBox(height: isMobile ? 10.0 : 16.0),
          Text(label.toUpperCase(),
              style: TextStyle(fontSize: 9, letterSpacing: 1.6, color: AppColors.muted)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: valFs,
                  fontWeight: FontWeight.w400,
                  color: AppColors.deep),
              children: [
                TextSpan(text: value),
                TextSpan(
                    text: ' $unit',
                    style: TextStyle(fontSize: unitFs, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(note,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: noteFs, color: AppColors.muted)),
        ],
      ),
    );
  }
}

// ─── Middle Row ───────────────────────────────────────────────────────────────
class _MiddleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final appointmentsCard = Expanded(
      flex: isMobile ? 1 : 3,
      child: _buildAppointmentsCard(),
    );
    final babyCard = Expanded(
      flex: isMobile ? 1 : 2,
      child: _buildBabyCard(),
    );
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppointmentsCard(),
          const SizedBox(height: 16),
          _buildBabyCard(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildAppointmentsCard()),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: _buildBabyCard()),
      ],
    );
  }

  Widget _buildAppointmentsCard() {
    return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.rose.withOpacity(0.1)),
          ),
      child: _AppointmentsCardContent(),
    );
  }

  Widget _buildBabyCard() {
    return Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.rose.withOpacity(0.1)),
          ),
      child: _BabyCardContent(),
    );
  }

}

class _AppointmentsCardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upcoming Appointments',
                        style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 18,
                            color: AppColors.deep)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View all \u2192',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.rose)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _AppointmentItem(
                  day: '10',
                  month: 'Mar',
                  title: 'Routine Prenatal Check-up',
                  meta: 'Dr. Njenga · 10:00 AM · NWH',
                  badgeText: 'Confirmed',
                  badgeColor: const Color(0xFF4A8A72),
                  badgeBg: const Color(0xFFE6F0EC),
                ),
                _AppointmentItem(
                  day: '18',
                  month: 'Mar',
                  title: 'Anatomy Ultrasound Scan',
                  meta: 'Radiology · 2:30 PM · In-person',
                  badgeText: 'Confirmed',
                  badgeColor: const Color(0xFF4A8A72),
                  badgeBg: const Color(0xFFE6F0EC),
                ),
                _AppointmentItem(
                  day: '2',
                  month: 'Apr',
                  title: 'Glucose Tolerance Test',
                  meta: 'Lab · 8:00 AM · Fasting required',
                  badgeText: 'Reminder Set',
                  badgeColor: AppColors.rose,
                  badgeBg: const Color(0xFFFAE8E6),
                  isLast: true,
                ),
              ],
    );
  }
}

class _BabyCardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Baby This Week',
                    style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        color: AppColors.deep)),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF5E6E0), Color(0xFFFCE8DE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text('\ud83c\udf3d', style: TextStyle(fontSize: 60)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('SIZE COMPARISON',
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.8,
                        color: AppColors.muted)),
                const SizedBox(height: 4),
                const Text('~30 cm · ~600 g — an ear of corn',
                    style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 15,
                        color: AppColors.deep)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.blush,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '\ud83c\udf1f Lungs are developing airways. Your baby may respond to loud sounds and finds your voice soothing.',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.text,
                        height: 1.5,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ],
    );
  }
}

class _AppointmentItem extends StatelessWidget {
  final String day;
  final String month;
  final String title;
  final String meta;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;
  final bool isLast;

  const _AppointmentItem({
    required this.day,
    required this.month,
    required this.title,
    required this.meta,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(day,
                        style: const TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            color: AppColors.deep,
                            fontWeight: FontWeight.w400)),
                    Text(month.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: AppColors.rose)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.deep)),
                    const SizedBox(height: 3),
                    Text(meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(badgeText,
                    style: TextStyle(
                        fontSize: 11,
                        color: badgeColor,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: AppColors.blush, height: 1),
      ],
    );
  }
}

// ─── Quick Links Row ──────────────────────────────────────────────────────────
class _QuickLinksRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    const c0 = _QuickLinkCard(icon: '\ud83d\udcdd', iconBg: Color(0xFFFAE8E6), title: 'Log Symptoms', subtitle: 'Track how you feel today');
    const c1 = _QuickLinkCard(icon: '\ud83d\udc8a', iconBg: Color(0xFFE6F0EC), title: 'Medications', subtitle: 'Folic acid · Iron · Vitamin D');
    const c2 = _QuickLinkCard(icon: '\ud83c\udf93', iconBg: Color(0xFFFAF0E8), title: 'Birth Prep Classes', subtitle: 'Next class: March 15');
    if (isMobile) {
      return Column(
        children: [
          c0,
          const SizedBox(height: 10),
          c1,
          const SizedBox(height: 10),
          c2,
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: c0),
        const SizedBox(width: 16),
        Expanded(child: c1),
        const SizedBox(width: 16),
        Expanded(child: c2),
      ],
    );
  }
}

class _QuickLinkCard extends StatefulWidget {
  final String icon;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _QuickLinkCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_QuickLinkCard> createState() => _QuickLinkCardState();
}

class _QuickLinkCardState extends State<_QuickLinkCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? AppColors.rose
                : AppColors.rose.withOpacity(0.1),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.rose.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(widget.icon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.deep)),
                  const SizedBox(height: 3),
                  Text(widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// APPOINTMENTS BODY (nav index 1)
// ═══════════════════════════════════════════════════════════════════════════════

enum _ScheduleStatus { scheduled, completed, action }

class _AppointmentsBody extends StatelessWidget {
  const _AppointmentsBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appointments', style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w400, color: Color(0xFF3D2C2C))),
          const SizedBox(height: 4),
          const Text('Manage your upcoming visits and medical schedule', style: TextStyle(fontSize: 13, color: Color(0xFF9B8080))),
          const SizedBox(height: 24),

          // Upcoming Appointments
          _ApptSection(title: 'Upcoming Appointments', badge: '3 upcoming', children: const [
            _ListApptCard(
              title: 'Antenatal Check-up',
              doctor: 'Dr. Amara Osei',
              date: 'Mon, 24 Jul 2025',
              time: '9:00 AM',
              type: 'In-person',
              typeColor: Color(0xFF8AAB9B),
              icon: Icons.medical_services_outlined,
            ),
            _ListApptCard(
              title: 'Ultrasound Scan',
              doctor: 'Dr. Kwame Asante',
              date: 'Thu, 27 Jul 2025',
              time: '11:30 AM',
              type: 'Imaging',
              typeColor: Color(0xFFD4847A),
              icon: Icons.monitor_heart_outlined,
            ),
            _ListApptCard(
              title: 'Nutrition Counselling',
              doctor: 'Dietician Esi Mensah',
              date: 'Tue, 1 Aug 2025',
              time: '2:00 PM',
              type: 'Telehealth',
              typeColor: Color(0xFF6B9BC3),
              icon: Icons.restaurant_outlined,
            ),
          ]),

          const SizedBox(height: 24),

          // Lab & Test Schedule
          _ApptSection(title: 'Lab & Test Schedule', badge: null, children: [
            _TestScheduleRow(label: 'Glucose Tolerance Test', date: '28 Jul 2025', status: _ScheduleStatus.scheduled),
            _TestScheduleRow(label: 'Full Blood Count (FBC)', date: '15 Jul 2025', status: _ScheduleStatus.completed),
            _TestScheduleRow(label: 'Group B Strep Screen', date: '10 Aug 2025', status: _ScheduleStatus.scheduled),
            _TestScheduleRow(label: 'Anomaly Scan',          date: '5 Jul 2025',  status: _ScheduleStatus.completed),
            _TestScheduleRow(label: 'HIV & Syphilis Screen', date: '22 Aug 2025', status: _ScheduleStatus.action),
          ]),

          const SizedBox(height: 24),

          // Appointment Reminders
          _ApptSection(title: 'Appointment Reminders', badge: null, children: const [
            _ReminderRow(label: '24h before each appointment',   enabled: true),
            _ReminderRow(label: '1 hour before appointments',    enabled: true),
            _ReminderRow(label: 'Medication reminders (daily)',  enabled: false),
            _ReminderRow(label: 'Lab result notifications',      enabled: true),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ApptSection extends StatelessWidget {
  final String title;
  final String? badge;
  final List<Widget> children;

  const _ApptSection({required this.title, required this.badge, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF3D2C2C))),
            if (badge != null) ...[
              const SizedBox(width: 10),
              _ApptBadge(label: badge!),
            ],
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _ApptBadge extends StatelessWidget {
  final String label;
  const _ApptBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFD4847A).withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFFD4847A), fontWeight: FontWeight.w600)),
    );
  }
}

class _ListApptCard extends StatelessWidget {
  final String title;
  final String doctor;
  final String date;
  final String time;
  final String type;
  final Color typeColor;
  final IconData icon;

  const _ListApptCard({
    required this.title, required this.doctor, required this.date,
    required this.time, required this.type, required this.typeColor, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5E6E0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: typeColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF3D2C2C))),
                const SizedBox(height: 2),
                Text(doctor, style: const TextStyle(fontSize: 12, color: Color(0xFF9B8080))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date, style: const TextStyle(fontSize: 11, color: Color(0xFF3D2C2C), fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF9B8080))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(type, style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestScheduleRow extends StatelessWidget {
  final String label;
  final String date;
  final _ScheduleStatus status;
  const _TestScheduleRow({required this.label, required this.date, required this.status});

  @override
  Widget build(BuildContext context) {
    final (clr, lbl) = switch (status) {
      _ScheduleStatus.scheduled => (const Color(0xFF6B9BC3), 'Scheduled'),
      _ScheduleStatus.completed => (const Color(0xFF8AAB9B), 'Completed'),
      _ScheduleStatus.action    => (const Color(0xFFD4847A), 'Action Needed'),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5E6E0)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF3D2C2C)))),
          Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF9B8080))),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: clr.withOpacity(0.12), borderRadius: BorderRadius.circular(100)),
            child: Text(lbl, style: TextStyle(fontSize: 11, color: clr, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatefulWidget {
  final String label;
  final bool enabled;
  const _ReminderRow({required this.label, required this.enabled});
  @override
  State<_ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends State<_ReminderRow> {
  late bool _on;
  @override
  void initState() { super.initState(); _on = widget.enabled; }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5E6E0)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(widget.label, style: const TextStyle(fontSize: 13, color: Color(0xFF3D2C2C)))),
          Switch.adaptive(
            value: _on,
            onChanged: (v) => setState(() => _on = v),
            activeColor: const Color(0xFFD4847A),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// HEALTH TRACKER BODY (nav index 2)
// ═══════════════════════════════════════════════════════════════════════════════

class _HealthTrackerBody extends StatelessWidget {
  const _HealthTrackerBody();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final pad = isMobile ? 16.0 : 28.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Tracker', style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w400, color: Color(0xFF3D2C2C))),
          const SizedBox(height: 4),
          const Text('Monitor your daily health metrics and trends', style: TextStyle(fontSize: 13, color: Color(0xFF9B8080))),
          const SizedBox(height: 24),

          // Vital Signs
          _TrackerSection(
            title: 'Vital Signs',
            emoji: '💓',
            child: GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.2 : 1.4,
              children: const [
                _VitalTile(label: 'Blood Pressure', value: '118/76', unit: 'mmHg', icon: Icons.favorite_outline, color: Color(0xFFD4847A)),
                _VitalTile(label: 'Weight', value: '68.2', unit: 'kg', icon: Icons.monitor_weight_outlined, color: Color(0xFF8AAB9B)),
                _VitalTile(label: 'Heart Rate', value: '82', unit: 'bpm', icon: Icons.monitor_heart_outlined, color: Color(0xFF6B9BC3)),
                _VitalTile(label: 'Temperature', value: '36.8', unit: '°C', icon: Icons.thermostat_outlined, color: Color(0xFFE8C9B8)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Wellness
          _TrackerSection(
            title: 'Wellness',
            emoji: '🌸',
            child: GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12, mainAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.2 : 1.4,
              children: const [
                _VitalTile(label: 'Sleep', value: '7.5', unit: 'hrs', icon: Icons.bedtime_outlined, color: Color(0xFF7B68EE)),
                _VitalTile(label: 'Water', value: '1.8', unit: 'L', icon: Icons.water_drop_outlined, color: Color(0xFF6B9BC3)),
                _VitalTile(label: 'Steps', value: '4,230', unit: 'steps', icon: Icons.directions_walk_outlined, color: Color(0xFF8AAB9B)),
                _VitalTile(label: 'Mood', value: 'Good', unit: '😊', icon: Icons.sentiment_satisfied_outlined, color: Color(0xFFD4847A)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Symptoms Log
          _TrackerSection(
            title: 'Symptoms Log',
            emoji: '📋',
            action: 'Log Today',
            child: Column(children: const [
              _SymptomChip(label: 'Mild nausea', time: '8:00 AM', color: Color(0xFFD4847A)),
              _SymptomChip(label: 'Back pain', time: '12:30 PM', color: Color(0xFF8AAB9B)),
              _SymptomChip(label: 'Fatigue', time: '3:00 PM', color: Color(0xFF6B9BC3)),
            ]),
          ),

          const SizedBox(height: 20),

          // Medications
          _TrackerSection(
            title: 'Medications',
            emoji: '💊',
            child: Column(children: const [
              _MedRow(name: 'Folic Acid 5mg', time: '8:00 AM', taken: true),
              _MedRow(name: 'Iron 65mg', time: '12:00 PM', taken: true),
              _MedRow(name: 'Vitamin D 1000IU', time: '8:00 PM', taken: false),
            ]),
          ),

          const SizedBox(height: 20),

          // History
          _TrackerSection(
            title: 'Recent History',
            emoji: '📊',
            child: Column(children: const [
              _HistoryRow(date: 'Today', bp: '118/76', weight: '68.2 kg', mood: '😊'),
              _HistoryRow(date: 'Yesterday', bp: '120/78', weight: '68.1 kg', mood: '😌'),
              _HistoryRow(date: '2 days ago', bp: '122/80', weight: '68.3 kg', mood: '😴'),
              _HistoryRow(date: '3 days ago', bp: '119/77', weight: '68.0 kg', mood: '😊'),
            ]),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _TrackerSection extends StatelessWidget {
  final String title;
  final String emoji;
  final String? action;
  final Widget child;

  const _TrackerSection({required this.title, required this.emoji, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5E6E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF3D2C2C))),
            const Spacer(),
            if (action != null)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4847A), padding: EdgeInsets.zero, minimumSize: const Size(0, 0)),
                child: Text(action!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _VitalTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  const _VitalTile({required this.label, required this.value, required this.unit, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(unit, style: const TextStyle(fontSize: 11, color: Color(0xFF9B8080))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9B8080))),
        ],
      ),
    );
  }
}

class _SymptomChip extends StatelessWidget {
  final String label;
  final String time;
  final Color color;
  const _SymptomChip({required this.label, required this.time, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF3D2C2C)))),
        Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF9B8080))),
      ]),
    );
  }
}

class _MedRow extends StatelessWidget {
  final String name;
  final String time;
  final bool taken;
  const _MedRow({required this.name, required this.time, required this.taken});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: taken ? const Color(0xFF8AAB9B).withOpacity(0.07) : const Color(0xFFF5E6E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(taken ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 18, color: taken ? const Color(0xFF8AAB9B) : const Color(0xFFD4847A)),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 13, color: Color(0xFF3D2C2C)))),
        Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF9B8080))),
      ]),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String date;
  final String bp;
  final String weight;
  final String mood;
  const _HistoryRow({required this.date, required this.bp, required this.weight, required this.mood});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        SizedBox(width: isMobile ? 80 : 110, child: Text(date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF3D2C2C)))),
        Expanded(child: Text('BP: $bp', style: const TextStyle(fontSize: 11, color: Color(0xFF9B8080)))),
        if (!isMobile) Expanded(child: Text(weight, style: const TextStyle(fontSize: 11, color: Color(0xFF9B8080)))),
        Text(mood, style: const TextStyle(fontSize: 16)),
      ]),
    );
  }
}
