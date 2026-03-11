// lib/screens/patient/patient_dashboard_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mamacare/services/auth_service.dart';

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

  Widget get _body {
    switch (_selectedIndex) {
      case 1:  return const _AppointmentsBody();
      case 2:  return const _HealthTrackerBody();
      case 3:  return const _NutritionBody();
      case 4:  return const _BirthPlanBody();
      case 5:  return const _DocumentsBody();
      case 6:  return const _MessagesBody();
      case 7:  return const _ResourcesBody();
      default: return _DashboardBody();
    }
  }

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
          actions: const [
            // Notification bell
            Padding(
              padding: EdgeInsets.only(right: 4),
              child: _NotificationBell(),
            ),
            // Profile dropdown
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: _ProfileDropdown(),
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: AppColors.sidebar,
          child: _Sidebar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            showCloseButton: true,
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

// ─── Notification Bell ──────────────────────────────────────────────────────
class _NotificationBell extends StatelessWidget {
  final Color iconColor;
  final Color dotBorderColor;
  const _NotificationBell({
    this.iconColor = AppColors.blush,
    this.dotBorderColor = AppColors.sidebar,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: iconColor, size: 22),
          onPressed: () {},
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
              border: Border.all(color: dotBorderColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Profile Dropdown ─────────────────────────────────────────────────────────
class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 8,
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.rose,
        child: const Text('A',
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ),
      itemBuilder: (_) => [
        // ── User info header ──
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.rose,
                child: const Text('A',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Georgia',
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amara Osei',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deep)),
                    const SizedBox(height: 2),
                    const Text('patient@mamacare.com',
                        style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.blush,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Patient · Dr. Njenga',
                          style: TextStyle(fontSize: 10, color: AppColors.rose, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        // ── Menu items ──
        _menuItem('profile', Icons.person_outline_rounded, 'My Profile'),
        _menuItem('settings', Icons.settings_outlined, 'Settings'),
        _menuItem('help', Icons.help_outline_rounded, 'Help & Support'),
        const PopupMenuDivider(height: 1),
        _menuItem('signout', Icons.logout_rounded, 'Sign Out', color: AppColors.rose),
      ],
      onSelected: (value) {
        if (value == 'signout') {
          AuthService.instance.logout();
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label,
      {Color color = AppColors.deep}) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
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
  final bool showCloseButton;

  const _Sidebar({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemTapped,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: AppColors.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo row + optional close button
          Padding(
            padding: EdgeInsets.fromLTRB(24, showCloseButton ? 48 : 40, showCloseButton ? 8 : 24, 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                if (showCloseButton)
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.muted, size: 20),
                    splashRadius: 18,
                    tooltip: 'Close',
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
        // On mobile the AppBar already shows these; only render on desktop.
        if (!isMobile) ...[
          _NotificationBell(
            iconColor: AppColors.text,
            dotBorderColor: AppColors.cream,
          ),
          const SizedBox(width: 4),
          const _ProfileDropdown(),
        ],
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

// ═══════════════════════════════════════════════════════════════════════════════
// NUTRITION BODY (nav index 3)
// ═══════════════════════════════════════════════════════════════════════════════

class _NutritionBody extends StatelessWidget {
  const _NutritionBody();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final pad = isMobile ? 16.0 : 32.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text('Nutrition & Diet',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.deep)),
          const SizedBox(height: 4),
          const Text('Tracking your daily nutrients for a healthy pregnancy',
              style: TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 24),

          // Daily Nutrient Progress
          _NutritionSection(
            title: 'Daily Nutrient Goals',
            child: Column(children: const [
              _NutrientBar(label: 'Folic Acid', unit: '680 / 800 mcg', progress: 0.85, color: Color(0xFF8AAB9B)),
              SizedBox(height: 10),
              _NutrientBar(label: 'Iron',       unit: '22 / 27 mg',    progress: 0.81, color: Color(0xFFD4847A)),
              SizedBox(height: 10),
              _NutrientBar(label: 'Calcium',    unit: '850 / 1000 mg', progress: 0.85, color: Color(0xFF6B9BC3)),
              SizedBox(height: 10),
              _NutrientBar(label: 'Protein',    unit: '58 / 71 g',     progress: 0.82, color: Color(0xFFE8C9B8)),
              SizedBox(height: 10),
              _NutrientBar(label: 'Vitamin D',  unit: '12 / 15 mcg',   progress: 0.80, color: Color(0xFFC9A87A)),
            ]),
          ),
          const SizedBox(height: 20),

          // Today's Meal Plan
          _NutritionSection(
            title: "Today's Meal Plan",
            child: Column(children: const [
              _MealRow(meal: 'Breakfast', items: 'Oats porridge, boiled egg, orange juice', cal: '420 kcal', icon: Icons.wb_sunny_outlined, color: Color(0xFFE8C9B8)),
              _MealRow(meal: 'Lunch',     items: 'Brown rice, grilled chicken, steamed broccoli', cal: '620 kcal', icon: Icons.lunch_dining_outlined, color: Color(0xFF8AAB9B)),
              _MealRow(meal: 'Snack',     items: 'Greek yoghurt, banana, handful of almonds', cal: '280 kcal', icon: Icons.apple_outlined, color: Color(0xFFD4847A)),
              _MealRow(meal: 'Dinner',    items: 'Tilapia fish stew, kenkey, garden salad', cal: '580 kcal', icon: Icons.dinner_dining_outlined, color: Color(0xFF6B9BC3)),
            ]),
          ),
          const SizedBox(height: 20),

          // Foods to Avoid
          _NutritionSection(
            title: 'Foods to Avoid During Pregnancy',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _AvoidChip(label: 'Raw fish & sushi'),
                _AvoidChip(label: 'Unpasteurised dairy'),
                _AvoidChip(label: 'Alcohol'),
                _AvoidChip(label: 'High-mercury fish'),
                _AvoidChip(label: 'Raw sprouts'),
                _AvoidChip(label: 'Deli meats (cold)'),
                _AvoidChip(label: 'Excess caffeine'),
                _AvoidChip(label: 'Soft cheeses'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hydration
          _NutritionSection(
            title: 'Hydration Today',
            child: Row(
              children: [
                ...List.generate(8, (i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.water_drop_rounded,
                      size: 28,
                      color: i < 6 ? AppColors.rose : AppColors.warm.withOpacity(0.4)),
                )),
                const SizedBox(width: 8),
                const Text('6 / 8 glasses', style: TextStyle(fontSize: 13, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NutritionSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _NutritionSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blush),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.deep)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final String unit;
  final double progress;
  final Color color;
  const _NutrientBar({required this.label, required this.unit, required this.progress, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w500)),
            Text(unit, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.blush,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MealRow extends StatelessWidget {
  final String meal;
  final String items;
  final String cal;
  final IconData icon;
  final Color color;
  const _MealRow({required this.meal, required this.items, required this.cal, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(meal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.deep)),
              const SizedBox(height: 2),
              Text(items, style: const TextStyle(fontSize: 11, color: AppColors.muted), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
          Text(cal, style: const TextStyle(fontSize: 11, color: AppColors.muted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AvoidChip extends StatelessWidget {
  final String label;
  const _AvoidChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.rose.withOpacity(0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.rose.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.block_rounded, size: 12, color: AppColors.rose),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.rose, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BIRTH PLAN BODY (nav index 4)
// ═══════════════════════════════════════════════════════════════════════════════

class _BirthPlanBody extends StatefulWidget {
  const _BirthPlanBody();
  @override
  State<_BirthPlanBody> createState() => _BirthPlanBodyState();
}

class _BirthPlanBodyState extends State<_BirthPlanBody> {
  final Map<String, bool> _prefs = {
    'I want minimal interventions': true,
    'Partner present during labour': true,
    'Wireless monitoring preferred': false,
    'Freedom to move during labour': true,
    'Epidural if required': true,
    'Try breathing techniques first': true,
    'No episiotomy unless emergency': true,
    'Delayed cord clamping': true,
    'Skin-to-skin immediately': true,
    'Partner to cut cord': false,
    'Breastfeed immediately': true,
    'Baby to stay in room': true,
    'Vitamin K injection': true,
    'Newborn hearing screen': true,
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final pad = isMobile ? 16.0 : 32.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Birth Plan',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.deep)),
          const SizedBox(height: 4),
          const Text('Your personalised preferences for labour and delivery',
              style: TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.sage.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.sage.withOpacity(0.4)),
            ),
            child: Row(children: const [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.sage),
              SizedBox(width: 8),
              Expanded(child: Text('Share this plan with Dr. Njenga at your next visit.', style: TextStyle(fontSize: 12, color: AppColors.sage))),
            ]),
          ),
          const SizedBox(height: 20),

          _BirthSection(title: 'Labour Preferences', icon: Icons.self_improvement_outlined, color: const Color(0xFF8AAB9B), prefs: _prefs, keys: [
            'I want minimal interventions',
            'Partner present during labour',
            'Wireless monitoring preferred',
            'Freedom to move during labour',
          ], onChanged: (k, v) => setState(() => _prefs[k] = v)),

          const SizedBox(height: 16),
          _BirthSection(title: 'Pain Management', icon: Icons.medical_services_outlined, color: const Color(0xFFD4847A), prefs: _prefs, keys: [
            'Epidural if required',
            'Try breathing techniques first',
          ], onChanged: (k, v) => setState(() => _prefs[k] = v)),

          const SizedBox(height: 16),
          _BirthSection(title: 'Delivery Preferences', icon: Icons.child_care_outlined, color: const Color(0xFF6B9BC3), prefs: _prefs, keys: [
            'No episiotomy unless emergency',
            'Delayed cord clamping',
            'Partner to cut cord',
          ], onChanged: (k, v) => setState(() => _prefs[k] = v)),

          const SizedBox(height: 16),
          _BirthSection(title: 'Immediately After Birth', icon: Icons.favorite_border_rounded, color: const Color(0xFFC9A87A), prefs: _prefs, keys: [
            'Skin-to-skin immediately',
            'Breastfeed immediately',
            'Baby to stay in room',
          ], onChanged: (k, v) => setState(() => _prefs[k] = v)),

          const SizedBox(height: 16),
          _BirthSection(title: 'Newborn Care', icon: Icons.baby_changing_station_outlined, color: const Color(0xFF8AAB9B), prefs: _prefs, keys: [
            'Vitamin K injection',
            'Newborn hearing screen',
          ], onChanged: (k, v) => setState(() => _prefs[k] = v)),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _BirthSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Map<String, bool> prefs;
  final List<String> keys;
  final void Function(String, bool) onChanged;
  const _BirthSection({required this.title, required this.icon, required this.color, required this.prefs, required this.keys, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blush),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.deep)),
          ]),
          const SizedBox(height: 12),
          ...keys.map((k) => _BirthToggle(label: k, value: prefs[k] ?? false, onChanged: (v) => onChanged(k, v))),
        ],
      ),
    );
  }
}

class _BirthToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _BirthToggle({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.text))),
        Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppColors.rose),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DOCUMENTS BODY (nav index 5)
// ═══════════════════════════════════════════════════════════════════════════════

class _DocumentsBody extends StatelessWidget {
  const _DocumentsBody();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final pad = isMobile ? 16.0 : 32.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Documents & Records',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.deep)),
          const SizedBox(height: 4),
          const Text('Your medical files, test results and reports in one place',
              style: TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 24),

          _DocSection(title: 'Lab Results', badge: '4 files', icon: Icons.science_outlined, color: const Color(0xFF8AAB9B), files: const [
            _DocFile(name: 'Full Blood Count – July 2025',  date: '15 Jul 2025', kind: 'PDF'),
            _DocFile(name: 'Glucose Tolerance Test',        date: '28 Jun 2025', kind: 'PDF'),
            _DocFile(name: 'Urine Analysis',                date: '10 Jun 2025', kind: 'PDF'),
            _DocFile(name: 'HIV & Syphilis Screen',         date: '2 May 2025',  kind: 'PDF'),
          ]),
          const SizedBox(height: 16),

          _DocSection(title: 'Scan Reports', badge: '2 files', icon: Icons.monitor_heart_outlined, color: const Color(0xFF6B9BC3), files: const [
            _DocFile(name: 'Anomaly Scan – 20 Weeks',    date: '5 Jul 2025',  kind: 'IMG'),
            _DocFile(name: 'Dating Scan – 12 Weeks',     date: '14 Apr 2025', kind: 'IMG'),
          ]),
          const SizedBox(height: 16),

          _DocSection(title: 'Prescriptions', badge: '3 files', icon: Icons.medication_outlined, color: const Color(0xFFD4847A), files: const [
            _DocFile(name: 'Folic Acid 5mg – Repeat',      date: '20 Jul 2025', kind: 'PDF'),
            _DocFile(name: 'Iron Supplement 200mg',         date: '15 Jul 2025', kind: 'PDF'),
            _DocFile(name: 'Vitamin D 400IU – Repeat',      date: '10 Jun 2025', kind: 'PDF'),
          ]),
          const SizedBox(height: 16),

          _DocSection(title: 'Insurance & Referrals', badge: '2 files', icon: Icons.shield_outlined, color: const Color(0xFFC9A87A), files: const [
            _DocFile(name: 'NHIS Antenatal Referral',     date: '1 Apr 2025',  kind: 'PDF'),
            _DocFile(name: 'Specialist Referral – Cardio', date: '22 Mar 2025', kind: 'PDF'),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DocSection extends StatelessWidget {
  final String title;
  final String badge;
  final IconData icon;
  final Color color;
  final List<_DocFile> files;
  const _DocSection({required this.title, required this.badge, required this.icon, required this.color, required this.files});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.blush),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.deep))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
              child: Text(badge, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF5E6E0)),
          const SizedBox(height: 10),
          ...files.map((f) => _DocFileRow(file: f, accentColor: color)),
        ],
      ),
    );
  }
}

class _DocFile {
  final String name;
  final String date;
  final String kind;
  const _DocFile({required this.name, required this.date, required this.kind});
}

class _DocFileRow extends StatelessWidget {
  final _DocFile file;
  final Color accentColor;
  const _DocFileRow({required this.file, required this.accentColor});
  @override
  Widget build(BuildContext context) {
    final isPdf = file.kind == 'PDF';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        Icon(isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined, color: accentColor, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(file.name, style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w500)),
          Text(file.date, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(file.kind, style: TextStyle(fontSize: 10, color: accentColor, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Icon(Icons.download_rounded, color: AppColors.muted, size: 18),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MESSAGES BODY (nav index 6)
// ═══════════════════════════════════════════════════════════════════════════════

class _MessagesBody extends StatefulWidget {
  const _MessagesBody();
  @override
  State<_MessagesBody> createState() => _MessagesBodyState();
}

class _MessagesBodyState extends State<_MessagesBody> {
  int _activeThread = 0;
  final _controller = TextEditingController();

  final _threads = const [
    _Thread(name: 'Dr. Njenga', role: 'Obstetrician', avatar: 'N',
        preview: 'Your anomaly scan results look great!',
        time: '10:32 AM', unread: 2, color: Color(0xFF8AAB9B)),
    _Thread(name: 'Midwife Sara', role: 'Midwife', avatar: 'S',
        preview: 'Remember to take your iron supplement today.',
        time: 'Yesterday', unread: 0, color: Color(0xFF6B9BC3)),
    _Thread(name: 'MamaCare Support', role: 'App Support', avatar: 'M',
        preview: 'How can we help you today?',
        time: 'Mon', unread: 0, color: Color(0xFFD4847A)),
  ];

  final _messages = const [
    _Msg(text: 'Good morning Amara! How are you feeling today?', fromMe: false, time: '9:15 AM'),
    _Msg(text: 'Good morning Dr. Njenga, I\'ve been a bit tired but otherwise fine.', fromMe: true, time: '9:22 AM'),
    _Msg(text: 'That\'s normal at 24 weeks. Make sure you\'re resting enough and taking your supplements.', fromMe: false, time: '9:25 AM'),
    _Msg(text: 'Your anomaly scan results look great! Baby\'s growth is right on track 🎉', fromMe: false, time: '10:32 AM'),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, isMobile ? 16 : 24, isMobile ? 16 : 32, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Messages', style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.deep)),
            SizedBox(height: 4),
            Text('Stay connected with your care team', style: TextStyle(fontSize: 13, color: AppColors.muted)),
          ]),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: isMobile
              ? _MobileMessages(threads: _threads, messages: _messages, controller: _controller)
              : _DesktopMessages(threads: _threads, activeThread: _activeThread, messages: _messages, controller: _controller,
                  onThreadTap: (i) => setState(() => _activeThread = i)),
        ),
      ],
    );
  }
}

class _Thread {
  final String name, role, avatar, preview, time;
  final int unread;
  final Color color;
  const _Thread({required this.name, required this.role, required this.avatar, required this.preview, required this.time, required this.unread, required this.color});
}

class _Msg {
  final String text, time;
  final bool fromMe;
  const _Msg({required this.text, required this.fromMe, required this.time});
}

class _ThreadList extends StatelessWidget {
  final List<_Thread> threads;
  final int activeIndex;
  final ValueChanged<int> onTap;
  const _ThreadList({required this.threads, required this.activeIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(threads.length, (i) {
      final t = threads[i];
      final active = i == activeIndex;
      return GestureDetector(
        onTap: () => onTap(i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.rose.withOpacity(0.08) : Colors.white,
            border: Border(
              left: BorderSide(color: active ? AppColors.rose : Colors.transparent, width: 3),
              bottom: const BorderSide(color: Color(0xFFF5E6E0)),
            ),
          ),
          child: Row(children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(radius: 22, backgroundColor: t.color, child: Text(t.avatar, style: const TextStyle(color: Colors.white, fontFamily: 'Georgia', fontSize: 16))),
                if (t.unread > 0) Positioned(right: -2, top: -2,
                  child: Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
                    child: Center(child: Text('${t.unread}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                  )),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.deep)),
                Text(t.time, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ]),
              const SizedBox(height: 2),
              Text(t.role, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text(t.preview, style: const TextStyle(fontSize: 12, color: AppColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
          ]),
        ),
      );
    }));
  }
}

class _ChatArea extends StatelessWidget {
  final List<_Msg> messages;
  final TextEditingController controller;
  const _ChatArea({required this.messages, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final m = messages[i];
              return Align(
                alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: m.fromMe ? AppColors.rose : Colors.white,
                    borderRadius: BorderRadius.circular(16).copyWith(
                      bottomRight: m.fromMe ? Radius.zero : const Radius.circular(16),
                      bottomLeft: m.fromMe ? const Radius.circular(16) : Radius.zero,
                    ),
                    border: m.fromMe ? null : Border.all(color: AppColors.blush),
                  ),
                  child: Column(
                    crossAxisAlignment: m.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(m.text, style: TextStyle(fontSize: 13, color: m.fromMe ? Colors.white : AppColors.text)),
                      const SizedBox(height: 4),
                      Text(m.time, style: TextStyle(fontSize: 10, color: m.fromMe ? Colors.white60 : AppColors.muted)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Color(0xFFF5E6E0))),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.cream,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(color: AppColors.rose, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ]),
        ),
      ],
    );
  }
}

class _MobileMessages extends StatelessWidget {
  final List<_Thread> threads;
  final List<_Msg> messages;
  final TextEditingController controller;
  const _MobileMessages({required this.threads, required this.messages, required this.controller});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: threads.length,
      child: Column(
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            indicatorColor: AppColors.rose,
            labelColor: AppColors.rose,
            unselectedLabelColor: AppColors.muted,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabs: threads.map((t) => Tab(text: t.name)).toList(),
          ),
          Expanded(child: _ChatArea(messages: messages, controller: controller)),
        ],
      ),
    );
  }
}

class _DesktopMessages extends StatelessWidget {
  final List<_Thread> threads;
  final int activeThread;
  final List<_Msg> messages;
  final TextEditingController controller;
  final ValueChanged<int> onThreadTap;
  const _DesktopMessages({required this.threads, required this.activeThread, required this.messages, required this.controller, required this.onThreadTap});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
        width: 300,
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFF5E6E0)))),
          child: SingleChildScrollView(child: _ThreadList(threads: threads, activeIndex: activeThread, onTap: onThreadTap)),
        ),
      ),
      Expanded(child: _ChatArea(messages: messages, controller: controller)),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// RESOURCES BODY (nav index 7)
// ═══════════════════════════════════════════════════════════════════════════════

class _ResourcesBody extends StatelessWidget {
  const _ResourcesBody();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final pad = isMobile ? 16.0 : 32.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resources & Learning',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 26, fontWeight: FontWeight.w400, color: AppColors.deep)),
          const SizedBox(height: 4),
          const Text('Evidence-based guides, articles and videos for your pregnancy journey',
              style: TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 24),

          // Featured
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3D2C2C), Color(0xFF6B4545)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.rose.withOpacity(0.25), borderRadius: BorderRadius.circular(100)),
                child: const Text('FEATURED', style: TextStyle(fontSize: 10, color: AppColors.rose, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 10),
              const Text('Understanding Your Third Trimester', style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)),
              const SizedBox(height: 6),
              const Text('Everything you need to know about weeks 28–40: baby\'s development, common symptoms and what to expect at your prenatal visits.',
                  style: TextStyle(fontSize: 12, color: Colors.white60), maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Row(children: [
                const Text('Read article · 6 min', style: TextStyle(fontSize: 12, color: AppColors.warm)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(color: AppColors.rose, borderRadius: BorderRadius.circular(100)),
                  child: const Text('Read', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 20),

          // Category grid
          const Text('Browse by Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.deep)),
          const SizedBox(height: 12),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: const [
              _CategoryCard(label: 'Pregnancy', icon: Icons.pregnant_woman_outlined, color: Color(0xFF8AAB9B)),
              _CategoryCard(label: 'Nutrition', icon: Icons.restaurant_menu_outlined, color: Color(0xFFD4847A)),
              _CategoryCard(label: 'Baby Care', icon: Icons.child_care_outlined, color: Color(0xFF6B9BC3)),
              _CategoryCard(label: 'Mental Health', icon: Icons.self_improvement_outlined, color: Color(0xFFC9A87A)),
            ],
          ),
          const SizedBox(height: 20),

          // Article list
          const Text('Latest Articles', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.deep)),
          const SizedBox(height: 12),
          const _ArticleCard(
            title: 'Iron-Rich Foods for Pregnancy Anaemia',
            category: 'Nutrition', readTime: '4 min', color: Color(0xFFD4847A), icon: Icons.restaurant_menu_outlined,
            summary: 'Learn how to boost your iron levels naturally through diet during pregnancy.',
          ),
          const SizedBox(height: 10),
          const _ArticleCard(
            title: 'Managing Pregnancy Anxiety',
            category: 'Mental Health', readTime: '5 min', color: Color(0xFFC9A87A), icon: Icons.self_improvement_outlined,
            summary: 'Practical techniques to ease worry and promote calm throughout your pregnancy.',
          ),
          const SizedBox(height: 10),
          const _ArticleCard(
            title: 'Preparing Your Breast for Breastfeeding',
            category: 'Baby Care', readTime: '3 min', color: Color(0xFF6B9BC3), icon: Icons.child_care_outlined,
            summary: 'Simple tips to get ready for a successful breastfeeding experience.',
          ),
          const SizedBox(height: 10),
          const _ArticleCard(
            title: 'Safe Exercises During Pregnancy',
            category: 'Pregnancy', readTime: '7 min', color: Color(0xFF8AAB9B), icon: Icons.fitness_center_outlined,
            summary: 'Stay active safely with these midwife-approved exercises for each trimester.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _CategoryCard({required this.label, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color))),
      ]),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final String category;
  final String readTime;
  final Color color;
  final IconData icon;
  final String summary;
  const _ArticleCard({required this.title, required this.category, required this.readTime, required this.color, required this.icon, required this.summary});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blush),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
              child: Text(category, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text(readTime, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ]),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.deep)),
          const SizedBox(height: 4),
          Text(summary, style: const TextStyle(fontSize: 12, color: AppColors.muted), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.muted),
      ]),
    );
  }
}
