import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/auth/role_login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/doctor/doctor_dashboard_screen.dart';
import 'screens/patient/patient_dashboard_screen.dart';
import 'screens/privacy_settings_screen.dart';
import 'services/database_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // skip plugin initialization on web; the packages we rely on (sqflite,
  // flutter_secure_storage, etc.) are not supported by the web platform and
  // would otherwise crash before the app can render.
  if (!kIsWeb) {
    // Initialize database
    await DatabaseService.instance.database;

    // Initialize auth
    await AuthService.instance.initialize();

    // Initialize local notifications
    await NotificationService.instance.initialize();
  } else {
    // Web: use in-memory demo users (SQLite is not available on web).
    AuthService.instance.initializeWeb();
  }

  runApp(const PregnancyApp());
}

// ─── App Root ────────────────────────────────────────────────────────────────
class PregnancyApp extends StatefulWidget {
  const PregnancyApp({super.key});

  @override
  State<PregnancyApp> createState() => _PregnancyAppState();
}

class _PregnancyAppState extends State<PregnancyApp> {
  final _authService = AuthService.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MamaCare - Pregnancy Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE8809C)),
      ),
      home: _getHomeScreen(),
      routes: {
        '/login': (context) => const RoleLoginScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/patient-dashboard': (context) => const PatientDashboardScreen(),
        '/privacy': (context) => const PrivacySettingsScreen(),
      },
    );
  }

  Widget _getHomeScreen() {
    // If user is already logged in, go to their dashboard
    if (_authService.isLoggedIn()) {
      if (_authService.isAdmin()) {
        return const AdminDashboardScreen();
      } else if (_authService.isDoctor()) {
        return const DoctorDashboardScreen();
      } else if (_authService.isPatient()) {
        return const PatientDashboardScreen();
      }
    }
    // Otherwise, show login screen
    return const RoleLoginScreen();
  }
}

// ─── Data ────────────────────────────────────────────────────────────────────
class BabySize {
  final String fruit;
  final String emoji;
  final String size;
  const BabySize(this.fruit, this.emoji, this.size);
}

const Map<int, BabySize> babySizes = {
  4:  BabySize('Poppy Seed',       '🌱', '1 mm'),
  5:  BabySize('Sesame Seed',      '🌾', '2 mm'),
  6:  BabySize('Lentil',           '🫘', '6 mm'),
  7:  BabySize('Blueberry',        '🫐', '13 mm'),
  8:  BabySize('Raspberry',        '🍓', '16 mm'),
  9:  BabySize('Cherry',           '🍒', '23 mm'),
  10: BabySize('Strawberry',       '🍓', '31 mm'),
  11: BabySize('Lime',             '🍋', '41 mm'),
  12: BabySize('Plum',             '🍑', '53 mm'),
  13: BabySize('Lemon',            '🍋', '74 mm'),
  14: BabySize('Peach',            '🍑', '87 mm'),
  15: BabySize('Apple',            '🍎', '10 cm'),
  16: BabySize('Avocado',          '🥑', '11 cm'),
  17: BabySize('Pear',             '🍐', '13 cm'),
  18: BabySize('Bell Pepper',      '🫑', '14 cm'),
  19: BabySize('Mango',            '🥭', '15 cm'),
  20: BabySize('Banana',           '🍌', '26 cm'),
  21: BabySize('Carrot',           '🥕', '27 cm'),
  22: BabySize('Papaya',           '🧡', '28 cm'),
  23: BabySize('Grapefruit',       '🍊', '29 cm'),
  24: BabySize('Corn',             '🌽', '30 cm'),
  25: BabySize('Rutabaga',         '🟡', '34 cm'),
  26: BabySize('Scallion',         '🌿', '36 cm'),
  27: BabySize('Cauliflower',      '🥦', '37 cm'),
  28: BabySize('Eggplant',         '🍆', '38 cm'),
  29: BabySize('Butternut Squash', '🎃', '39 cm'),
  30: BabySize('Cabbage',          '🥬', '40 cm'),
  31: BabySize('Coconut',          '🥥', '41 cm'),
  32: BabySize('Jicama',           '🟤', '43 cm'),
  33: BabySize('Pineapple',        '🍍', '44 cm'),
  34: BabySize('Cantaloupe',       '🍈', '45 cm'),
  35: BabySize('Honeydew',         '🍈', '46 cm'),
  36: BabySize('Romaine Lettuce',  '🥬', '47 cm'),
  37: BabySize('Bunch of Chard',   '🌿', '48 cm'),
  38: BabySize('Leek',             '🌱', '49 cm'),
  39: BabySize('Watermelon',       '🍉', '50 cm'),
  40: BabySize('Watermelon',       '🍉', '51 cm'),
};

const List<String> weeklyTips = [
  'Stay hydrated — aim for 8–10 glasses of water daily 💧',
  'Gentle walks can help with fatigue and mood 🌸',
  'Talk or sing to your baby — they can hear you! 🎵',
  'Keep up with your prenatal appointments 📅',
  'Sleep on your left side for better circulation 🌙',
  'Eat small, frequent meals to ease nausea 🍽️',
];

const List<Map<String, String>> moodOptions = [
  {'emoji': '😊', 'label': 'Great'},
  {'emoji': '😐', 'label': 'Okay'},
  {'emoji': '😴', 'label': 'Tired'},
  {'emoji': '🤢', 'label': 'Nauseous'},
  {'emoji': '😰', 'label': 'Anxious'},
  {'emoji': '🥰', 'label': 'Grateful'},
];

// ─── Colors ──────────────────────────────────────────────────────────────────
const kPink       = Color(0xFFE8809C);
const kPinkLight  = Color(0xFFFFC8D8);
const kPinkPale   = Color(0xFFFFF0F5);
const kLavender   = Color(0xFFD4B0E8);
const kBlue       = Color(0xFFB5D5F5);
const kGreen      = Color(0xFFC8E6C9);
const kTextDark   = Color(0xFF5A3D4A);
const kTextMid    = Color(0xFF9A7080);
const kTextLight  = Color(0xFFB08090);
const kCardBg     = Color(0xFFFFFAFC);

// ─── Helpers ─────────────────────────────────────────────────────────────────
int getTrimester(int week) {
  if (week <= 13) return 1;
  if (week <= 27) return 2;
  return 3;
}

Map<String, dynamic> trimesterInfo(int t) {
  switch (t) {
    case 1:
      return {
        'label': 'First Trimester',
        'weeks': 'Weeks 1–13',
        'color': const Color(0xFFF8C8D4),
        'emoji': '🌱',
        'tip':   'Your baby\'s major organs are forming. Rest and take your prenatal vitamins!',
      };
    case 2:
      return {
        'label': 'Second Trimester',
        'weeks': 'Weeks 14–27',
        'color': kBlue,
        'emoji': '🌸',
        'tip':   'The golden trimester! Energy often returns and baby starts to move.',
      };
    default:
      return {
        'label': 'Third Trimester',
        'weeks': 'Weeks 28–40',
        'color': kGreen,
        'emoji': '🌟',
        'tip':   'Almost there! Baby is gaining weight and getting ready to meet you.',
      };
  }
}

int daysUntilDue(DateTime dueDate) {
  final diff = dueDate.difference(DateTime.now()).inDays;
  return diff < 0 ? 0 : diff;
}

// ─── Home Dashboard ──────────────────────────────────────────────────────────
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard>
    with SingleTickerProviderStateMixin {
  int currentWeek = 20;
  String? selectedMood;
  late String dailyTip;
  final DateTime dueDate = DateTime(2025, 8, 20);
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    dailyTip = weeklyTips[Random().nextInt(weeklyTips.length)];
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tri     = trimesterInfo(getTrimester(currentWeek));
    final baby    = babySizes[currentWeek] ?? babySizes[20]!;
    final days    = daysUntilDue(dueDate);
    final progress = currentWeek / 40.0;

    return Scaffold(
      backgroundColor: kPinkPale,
      body: Stack(
        children: [
          // ── Background blobs ──
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  kPinkLight.withOpacity(0.5),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 80, left: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  kBlue.withOpacity(0.35),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Main content ──
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      child: Column(
                        children: [
                          _buildHeroCard(progress, days, tri),
                          const SizedBox(height: 14),
                          _buildBabySizeCard(baby),
                          const SizedBox(height: 14),
                          _buildTrimesterBanner(tri),
                          const SizedBox(height: 14),
                          _buildMoodCard(),
                          const SizedBox(height: 14),
                          _buildTipCard(),
                          const SizedBox(height: 14),
                          _buildQuickStats(),
                          const SizedBox(height: 14),
                          _buildMilestones(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom nav ──
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        border: Border(
          bottom: BorderSide(color: kPinkLight.withOpacity(0.4), width: 1),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HELLO, MAMA 🌸',
                style: TextStyle(
                  fontSize: 10, letterSpacing: 3,
                  color: kPink, fontFamily: 'Courier',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'My Pregnancy Journey',
                style: TextStyle(
                  fontSize: 20, color: Color(0xFF7A3D5A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RoleLoginScreen()),
              );
            },
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: kPinkLight,
              child: const Text('👤', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Card ────────────────────────────────────────────────────────────────
  Widget _buildHeroCard(double progress, int days, Map<String, dynamic> tri) {
    return _GlassCard(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF0F8), Color(0xFFF0EAFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('YOUR JOURNEY'),
                    Text(
                      'Week $currentWeek',
                      style: const TextStyle(
                        fontSize: 48, color: Color(0xFFC2547A),
                        fontWeight: FontWeight.w300, height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (tri['color'] as Color).withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tri['label'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF7A4060)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '📅 $days days until due date',
                      style: const TextStyle(fontSize: 13, color: kTextMid),
                    ),
                  ],
                ),
              ),
              // Progress ring
              SizedBox(
                width: 100, height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: _RingPainter(progress: progress),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600,
                            color: Color(0xFFC2547A),
                          ),
                        ),
                        const Text(
                          'done',
                          style: TextStyle(fontSize: 10, color: kTextLight, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('WEEK 1', style: TextStyle(fontSize: 10, color: kTextLight, fontFamily: 'Courier')),
              Text('WEEK 40', style: TextStyle(fontSize: 10, color: kTextLight, fontFamily: 'Courier')),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kPink,
              inactiveTrackColor: kPinkLight,
              thumbColor: kPink,
              overlayColor: kPink.withOpacity(0.15),
              trackHeight: 4,
            ),
            child: Slider(
              min: 4, max: 40,
              value: currentWeek.toDouble(),
              onChanged: (v) => setState(() => currentWeek = v.round()),
            ),
          ),
          const Center(
            child: Text(
              'Drag to explore your journey ✨',
              style: TextStyle(fontSize: 12, color: kTextLight),
            ),
          ),
        ],
      ),
    );
  }

  // ── Baby Size Card ───────────────────────────────────────────────────────────
  Widget _buildBabySizeCard(BabySize baby) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('BABY THIS WEEK'),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 76, height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE4EC), Color(0xFFFFD6F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPink.withOpacity(0.2),
                      blurRadius: 16, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(baby.emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Size of a ${baby.fruit}',
                      style: const TextStyle(
                        fontSize: 18, color: Color(0xFFC2547A),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'About ${baby.size} long',
                      style: const TextStyle(fontSize: 13, color: kTextMid),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your baby is growing beautifully and reaching exciting new milestones every day 💕',
                      style: TextStyle(fontSize: 13, color: kTextMid, height: 1.5),
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

  // ── Trimester Banner ─────────────────────────────────────────────────────────
  Widget _buildTrimesterBanner(Map<String, dynamic> tri) {
    final color = tri['color'] as Color;
    return _GlassCard(
      color: color.withOpacity(0.2),
      borderColor: color.withOpacity(0.5),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(tri['emoji'] as String,
                  style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tri['label'] as String,
                    style: const TextStyle(fontSize: 15, color: Color(0xFF7A4060))),
                const SizedBox(height: 2),
                Text(tri['weeks'] as String,
                    style: const TextStyle(fontSize: 12, color: kTextMid)),
                const SizedBox(height: 6),
                Text(tri['tip'] as String,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF7A6070), height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mood Card ────────────────────────────────────────────────────────────────
  Widget _buildMoodCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('HOW ARE YOU FEELING TODAY?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: moodOptions.map((m) {
              final isSelected = selectedMood == m['label'];
              return GestureDetector(
                onTap: () => setState(() => selectedMood = m['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFE4EC)
                        : Colors.white.withOpacity(0.5),
                    border: Border.all(
                      color: isSelected ? kPink : kPinkLight.withOpacity(0.5),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [BoxShadow(color: kPink.withOpacity(0.2), blurRadius: 8)]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m['emoji']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 4),
                      Text(m['label']!,
                          style: const TextStyle(fontSize: 10, color: kTextMid, letterSpacing: 0.5)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (selectedMood != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kPinkLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Logged: feeling ${selectedMood!.toLowerCase()} today 💗',
                style: const TextStyle(
                  fontSize: 13, color: Color(0xFF9A6070), fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tip Card ─────────────────────────────────────────────────────────────────
  Widget _buildTipCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel("TODAY'S TIP"),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  dailyTip,
                  style: const TextStyle(
                    fontSize: 14, color: Color(0xFF8A6070), height: 1.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick Stats ──────────────────────────────────────────────────────────────
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _GlassCard(
            child: Column(
              children: [
                Text(
                  '${40 - currentWeek}',
                  style: const TextStyle(
                    fontSize: 36, color: Color(0xFFC2547A), fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'WEEKS LEFT',
                  style: TextStyle(fontSize: 10, color: kTextLight,
                      letterSpacing: 2, fontFamily: 'Courier'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GlassCard(
            child: Column(
              children: [
                Text(
                  '${currentWeek * 7}',
                  style: const TextStyle(
                    fontSize: 36, color: Color(0xFF8080C2), fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'DAYS ALONG',
                  style: TextStyle(fontSize: 10, color: kTextLight,
                      letterSpacing: 2, fontFamily: 'Courier'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Milestones ───────────────────────────────────────────────────────────────
  Widget _buildMilestones() {
    final items = [
      {'week': '${min(currentWeek + 2, 40)}', 'icon': '👶', 'label': 'Growth check'},
      {'week': '${min(currentWeek + 4, 40)}', 'icon': '🏥', 'label': 'Prenatal appointment'},
      {'week': '${min(currentWeek + 6, 40)}', 'icon': '📋', 'label': 'Lab results review'},
    ];
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('UPCOMING MILESTONES'),
          const SizedBox(height: 6),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE4EC), Color(0xFFFFD6F0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(item['icon']!,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['label']!,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF7A4060))),
                            const SizedBox(height: 2),
                            Text('Around Week ${item['week']}',
                                style: const TextStyle(fontSize: 12, color: kTextMid)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kPink.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'W${item['week']}',
                          style: const TextStyle(
                            fontSize: 11, color: kPink, fontFamily: 'Courier',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < items.length - 1)
                  Divider(color: kPinkLight.withOpacity(0.4), height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Bottom Nav ───────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'emoji': '🏠', 'label': 'Home'},
      {'emoji': '📅', 'label': 'Calendar'},
      {'emoji': '📓', 'label': 'Journal'},
      {'emoji': '👤', 'label': 'Profile'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: Border(top: BorderSide(color: kPinkLight.withOpacity(0.4))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final active = _navIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _navIndex = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item['emoji']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 3),
                Text(
                  item['label']!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1,
                    fontFamily: 'Courier',
                    color: active ? kPink : const Color(0xFFC0A0B0),
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 3),
                if (active)
                  Container(
                    width: 4, height: 4,
                    decoration: const BoxDecoration(
                      color: kPink, shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Shared section label ─────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10, letterSpacing: 3, color: Color(0xFFE8A0B4),
        fontFamily: 'Courier', fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── Glass Card Widget ───────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;

  const _GlassCard({
    required this.child,
    this.gradient,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? (color ?? kCardBg) : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? const Color(0xFFFFD0E4).withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDCA0B4).withOpacity(0.08),
            blurRadius: 20, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Progress Ring Painter ───────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    // Background ring
    paint.color = const Color(0xFFFFE4EC);
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    paint.color = const Color(0xFFE8809C);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}