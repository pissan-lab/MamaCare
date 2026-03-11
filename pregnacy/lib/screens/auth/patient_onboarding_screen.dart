// lib/screens/auth/patient_onboarding_screen.dart

import 'package:flutter/material.dart';

class AppOnboardingColors {
  static const blush = Color(0xFFF5E6E0);
  static const rose  = Color(0xFFD4847A);
  static const deep  = Color(0xFF3D2C2C);
  static const sage  = Color(0xFF8AAB9B);
  static const cream = Color(0xFFFDF6F0);
  static const warm  = Color(0xFFE8C9B8);
  static const text  = Color(0xFF4A3535);
  static const muted = Color(0xFF9B8080);
}

class CheckItem {
  final String label;
  final String? emoji;
  bool selected;
  CheckItem({required this.label, this.emoji, this.selected = false});
}

class OnboardingData {
  final nameController  = TextEditingController();
  final phoneController = TextEditingController();
  final dobController   = TextEditingController();
  final lmpController   = TextEditingController();
  String? bloodType;
  bool firstPregnancy = true;

  final conditions = [
    CheckItem(label: 'Gestational Diabetes',     emoji: '🩸'),
    CheckItem(label: 'Hypertension',              emoji: '💓'),
    CheckItem(label: 'Anaemia',                   emoji: '💊'),
    CheckItem(label: 'Thyroid Disorder',          emoji: '🦋'),
    CheckItem(label: 'Asthma',                    emoji: '🫁'),
    CheckItem(label: 'Heart Condition',           emoji: '❤️'),
    CheckItem(label: 'Kidney Disease',            emoji: '🫘'),
    CheckItem(label: 'HIV/AIDS',                  emoji: '🔴'),
    CheckItem(label: 'Sickle Cell Disease',       emoji: '🧬'),
    CheckItem(label: 'Depression / Anxiety',      emoji: '🧠'),
    CheckItem(label: 'None of the above',         emoji: '✅'),
  ];

  final symptoms = [
    CheckItem(label: 'Nausea / Vomiting',   emoji: '🤢'),
    CheckItem(label: 'Fatigue',             emoji: '😴'),
    CheckItem(label: 'Headaches',           emoji: '🤕'),
    CheckItem(label: 'Back Pain',           emoji: '🔙'),
    CheckItem(label: 'Leg Swelling',        emoji: '🦵'),
    CheckItem(label: 'Heartburn',           emoji: '🔥'),
    CheckItem(label: 'Frequent Urination',  emoji: '🚽'),
    CheckItem(label: 'Dizziness',           emoji: '😵'),
    CheckItem(label: 'Mood Swings',         emoji: '🌊'),
    CheckItem(label: 'Insomnia',            emoji: '🌙'),
    CheckItem(label: 'Constipation',        emoji: '😣'),
    CheckItem(label: 'None currently',      emoji: '😊'),
  ];

  final medications = [
    CheckItem(label: 'Folic Acid',                emoji: '💚'),
    CheckItem(label: 'Iron Supplements',          emoji: '🟤'),
    CheckItem(label: 'Vitamin D',                 emoji: '☀️'),
    CheckItem(label: 'Calcium',                   emoji: '🦴'),
    CheckItem(label: 'Prenatal Multivitamin',     emoji: '💊'),
    CheckItem(label: 'Omega-3 / Fish Oil',        emoji: '🐟'),
    CheckItem(label: 'Magnesium',                 emoji: '⚡'),
    CheckItem(label: 'Blood Pressure Medication', emoji: '💉'),
    CheckItem(label: 'Insulin / Diabetes Meds',  emoji: '🩺'),
    CheckItem(label: 'Antidepressants',           emoji: '🧠'),
    CheckItem(label: 'None',                      emoji: '🚫'),
  ];

  final checkInPrefs = [
    CheckItem(label: 'Remind me to log symptoms daily',      emoji: '📝'),
    CheckItem(label: 'Send weekly baby development updates', emoji: '👶'),
    CheckItem(label: 'Remind me to take medications',        emoji: '⏰'),
    CheckItem(label: 'Track my weight weekly',               emoji: '⚖️'),
    CheckItem(label: 'Send appointment reminders',           emoji: '📅'),
    CheckItem(label: 'Log my mood daily',                    emoji: '🌸'),
    CheckItem(label: 'Kick count reminders (from wk 28)',    emoji: '🦶'),
    CheckItem(label: 'Weekly nutrition tips',                emoji: '🥗'),
    CheckItem(label: 'Mental wellness check-ins',            emoji: '🧘'),
  ];
}

class _StepMeta {
  final String title;
  final String subtitle;
  final String emoji;
  const _StepMeta({required this.title, required this.subtitle, required this.emoji});
}

// ─── Main onboarding screen ───────────────────────────────────────────────────
class PatientOnboardingScreen extends StatefulWidget {
  const PatientOnboardingScreen({super.key});
  @override
  State<PatientOnboardingScreen> createState() => _PatientOnboardingScreenState();
}

class _PatientOnboardingScreenState extends State<PatientOnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  final _totalSteps = 5;
  final _data = OnboardingData();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  static const _steps = [
    _StepMeta(title: "Welcome,\nlet's get to know you", subtitle: 'Basic information to set up your profile', emoji: '🌸'),
    _StepMeta(title: 'Any pre-existing\nconditions?',   subtitle: 'Select all that apply — this helps your doctor', emoji: '🩺'),
    _StepMeta(title: "Current symptoms\nyou're feeling", subtitle: 'What have you been experiencing lately?', emoji: '🤰'),
    _StepMeta(title: 'Medications &\nsupplements',       subtitle: 'What are you currently taking?', emoji: '💊'),
    _StepMeta(title: 'Personalise your\ncheck-ins',      subtitle: 'How would you like us to support you?', emoji: '✨'),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  void _next() {
    if (_step < _totalSteps - 1) {
      _animCtrl.reverse().then((_) { setState(() => _step++); _animCtrl.forward(); });
    } else {
      Navigator.of(context).pushReplacementNamed('/patient-dashboard');
    }
  }

  void _back() {
    if (_step > 0) {
      _animCtrl.reverse().then((_) { setState(() => _step--); _animCtrl.forward(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: AppOnboardingColors.cream,
      body: isMobile ? _buildMobile() : Row(
        children: [
          _LeftPanel(step: _step, totalSteps: _totalSteps, meta: _steps[_step]),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: _RightPanel(
                step: _step, data: _data, onNext: _next, onBack: _back,
                totalSteps: _totalSteps, onChanged: () => setState(() {}),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            Container(
              color: AppOnboardingColors.deep,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    RichText(text: const TextSpan(
                      style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: Color(0xFFF5E6E0)),
                      children: [
                        TextSpan(text: 'Mama'),
                        TextSpan(text: 'Bloom', style: TextStyle(color: AppOnboardingColors.rose, fontStyle: FontStyle.italic)),
                      ],
                    )),
                    const Spacer(),
                    Text('${_step + 1} / $_totalSteps', style: const TextStyle(fontSize: 12, color: Colors.white38)),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: List.generate(_totalSteps, (i) {
                    final active = i == _step;
                    final done = i < _step;
                    return Expanded(child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: done ? AppOnboardingColors.sage : active ? AppOnboardingColors.rose : Colors.white24,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ));
                  })),
                  const SizedBox(height: 14),
                  Row(children: [
                    Text(_steps[_step].emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(
                      _steps[_step].title.replaceAll('\n', ' '),
                      style: const TextStyle(fontFamily: 'Georgia', fontSize: 18, fontWeight: FontWeight.w300, color: Colors.white, height: 1.3),
                    )),
                  ]),
                ],
              ),
            ),
            Expanded(child: _RightPanel(
              step: _step, data: _data, onNext: _next, onBack: _back,
              totalSteps: _totalSteps, onChanged: () => setState(() {}),
              mobilePadding: true,
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Left panel ───────────────────────────────────────────────────────────────
class _LeftPanel extends StatelessWidget {
  final int step;
  final int totalSteps;
  final _StepMeta meta;
  const _LeftPanel({required this.step, required this.totalSteps, required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: AppOnboardingColors.deep,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(text: const TextSpan(
            style: TextStyle(fontFamily: 'Georgia', fontSize: 24, color: Color(0xFFF5E6E0)),
            children: [
              TextSpan(text: 'Mama'),
              TextSpan(text: 'Bloom', style: TextStyle(color: AppOnboardingColors.rose, fontStyle: FontStyle.italic)),
            ],
          )),
          const SizedBox(height: 4),
          const Text('PREGNANCY CARE', style: TextStyle(fontSize: 10, letterSpacing: 2.5, color: AppOnboardingColors.muted)),
          const Spacer(),
          Text(meta.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 24),
          Text(meta.title, style: const TextStyle(fontFamily: 'Georgia', fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white, height: 1.3)),
          const SizedBox(height: 12),
          Text(meta.subtitle, style: const TextStyle(fontSize: 13, color: Colors.white38, height: 1.6)),
          const Spacer(),
          Row(children: List.generate(totalSteps, (i) {
            final active = i == step;
            final done = i < step;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              width: active ? 28 : 8, height: 8,
              decoration: BoxDecoration(
                color: done ? AppOnboardingColors.sage : active ? AppOnboardingColors.rose : Colors.white24,
                borderRadius: BorderRadius.circular(100),
              ),
            );
          })),
          const SizedBox(height: 12),
          Text('Step ${step + 1} of $totalSteps', style: const TextStyle(fontSize: 12, color: Colors.white38)),
        ],
      ),
    );
  }
}

// ─── Right panel ──────────────────────────────────────────────────────────────
class _RightPanel extends StatelessWidget {
  final int step;
  final OnboardingData data;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final int totalSteps;
  final VoidCallback onChanged;
  final bool mobilePadding;

  const _RightPanel({
    required this.step, required this.data, required this.onNext,
    required this.onBack, required this.totalSteps, required this.onChanged,
    this.mobilePadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = mobilePadding ? 20.0 : 48.0;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(h, h, h, 24),
            child: _buildStep(),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(h, 16, h, mobilePadding ? 20 : 36),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFF5E6E0))),
          ),
          child: Row(
            children: [
              if (step > 0)
                OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppOnboardingColors.warm),
                    foregroundColor: AppOnboardingColors.muted,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back'),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppOnboardingColors.deep,
                  foregroundColor: AppOnboardingColors.blush,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(step == totalSteps - 1 ? 'Complete Setup' : 'Continue →'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep() {
    switch (step) {
      case 0: return _Step1BasicInfo(data: data, onChanged: onChanged);
      case 1: return _CheckboxStep(label: 'Pre-existing Conditions', hint: 'Select everything that applies to your health history.', items: data.conditions, onChanged: onChanged);
      case 2: return _CheckboxStep(label: 'Current Symptoms', hint: 'What have you been experiencing? This helps your doctor prepare.', items: data.symptoms, onChanged: onChanged);
      case 3: return _CheckboxStep(label: 'Medications & Supplements', hint: 'Select everything you are currently taking.', items: data.medications, onChanged: onChanged);
      case 4: return _CheckboxStep(label: 'Check-in Preferences', hint: 'Choose how you would like MamaBloom to support you.', items: data.checkInPrefs, onChanged: onChanged);
      default: return const SizedBox();
    }
  }
}

// ─── Step 1 — Basic Info ──────────────────────────────────────────────────────
class _Step1BasicInfo extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onChanged;
  const _Step1BasicInfo({required this.data, required this.onChanged});
  @override
  State<_Step1BasicInfo> createState() => _Step1BasicInfoState();
}

class _Step1BasicInfoState extends State<_Step1BasicInfo> {
  final _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Personal Details'),
        const SizedBox(height: 20),
        _InputField(controller: widget.data.nameController, label: 'Full Name', hint: 'e.g. Amara Osei', icon: Icons.person_outline),
        const SizedBox(height: 16),
        _InputField(controller: widget.data.phoneController, label: 'Phone Number', hint: 'e.g. +254 700 000 000', icon: Icons.phone_outlined),
        const SizedBox(height: 16),
        isMobile
          ? Column(children: [
              _InputField(controller: widget.data.dobController, label: 'Date of Birth', hint: 'DD / MM / YYYY', icon: Icons.cake_outlined),
              const SizedBox(height: 16),
              _InputField(controller: widget.data.lmpController, label: 'Last Menstrual Period', hint: 'DD / MM / YYYY', icon: Icons.calendar_today_outlined),
            ])
          : Row(children: [
              Expanded(child: _InputField(controller: widget.data.dobController, label: 'Date of Birth', hint: 'DD / MM / YYYY', icon: Icons.cake_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _InputField(controller: widget.data.lmpController, label: 'Last Menstrual Period', hint: 'DD / MM / YYYY', icon: Icons.calendar_today_outlined)),
            ]),
        const SizedBox(height: 32),
        const _SectionHeader(title: 'Medical Details'),
        const SizedBox(height: 20),
        const Text('Blood Type', style: TextStyle(fontSize: 13, color: AppOnboardingColors.muted)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _bloodTypes.map((bt) {
            final selected = widget.data.bloodType == bt;
            return GestureDetector(
              onTap: () { setState(() => widget.data.bloodType = bt); widget.onChanged(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppOnboardingColors.deep : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: selected ? AppOnboardingColors.deep : AppOnboardingColors.warm, width: 1.5),
                ),
                child: Text(bt, style: TextStyle(fontSize: 13, color: selected ? AppOnboardingColors.blush : AppOnboardingColors.text)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        const Text('Is this your first pregnancy?', style: TextStyle(fontSize: 13, color: AppOnboardingColors.muted)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12, runSpacing: 10,
          children: [
            _ToggleChip(label: 'Yes, first time', selected: widget.data.firstPregnancy, onTap: () { setState(() => widget.data.firstPregnancy = true); widget.onChanged(); }),
            _ToggleChip(label: 'No, been here before', selected: !widget.data.firstPregnancy, onTap: () { setState(() => widget.data.firstPregnancy = false); widget.onChanged(); }),
          ],
        ),
      ],
    );
  }
}

// ─── Toggle chip ──────────────────────────────────────────────────────────────
class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppOnboardingColors.rose.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppOnboardingColors.rose : AppOnboardingColors.warm, width: 1.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: selected ? AppOnboardingColors.rose : AppOnboardingColors.muted, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}

// ─── Checkbox step ────────────────────────────────────────────────────────────
class _CheckboxStep extends StatefulWidget {
  final String label;
  final String hint;
  final List<CheckItem> items;
  final VoidCallback onChanged;
  const _CheckboxStep({required this.label, required this.hint, required this.items, required this.onChanged});
  @override
  State<_CheckboxStep> createState() => _CheckboxStepState();
}

class _CheckboxStepState extends State<_CheckboxStep> {
  int get selectedCount => widget.items.where((i) => i.selected).length;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: widget.label),
        const SizedBox(height: 6),
        Text(widget.hint, style: const TextStyle(fontSize: 13, color: AppOnboardingColors.muted, height: 1.5)),
        const SizedBox(height: 12),
        if (selectedCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: AppOnboardingColors.sage.withOpacity(0.15), borderRadius: BorderRadius.circular(100)),
            child: Text('$selectedCount selected', style: const TextStyle(fontSize: 12, color: AppOnboardingColors.sage, fontWeight: FontWeight.w600)),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: isMobile ? 4.5 : 3.6,
          ),
          itemCount: widget.items.length,
          itemBuilder: (context, i) {
            final item = widget.items[i];
            return _CheckboxTile(
              item: item,
              onTap: () { setState(() => item.selected = !item.selected); widget.onChanged(); },
            );
          },
        ),
      ],
    );
  }
}

// ─── Checkbox tile ────────────────────────────────────────────────────────────
class _CheckboxTile extends StatelessWidget {
  final CheckItem item;
  final VoidCallback onTap;
  const _CheckboxTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: item.selected ? AppOnboardingColors.rose.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: item.selected ? AppOnboardingColors.rose : const Color(0xFFEDD8D0), width: item.selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: item.selected ? AppOnboardingColors.rose : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: item.selected ? AppOnboardingColors.rose : AppOnboardingColors.warm, width: 1.5),
              ),
              child: item.selected ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
            ),
            const SizedBox(width: 8),
            if (item.emoji != null) ...[
              Text(item.emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(item.label,
                style: TextStyle(fontSize: 12, color: item.selected ? AppOnboardingColors.deep : AppOnboardingColors.text, fontWeight: item.selected ? FontWeight.w600 : FontWeight.normal),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Georgia', fontSize: 22, fontWeight: FontWeight.w400, color: AppOnboardingColors.deep)),
        const SizedBox(height: 6),
        Container(width: 40, height: 3, decoration: BoxDecoration(color: AppOnboardingColors.rose, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}

// ─── Input field ──────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  const _InputField({required this.controller, required this.label, required this.hint, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: AppOnboardingColors.muted)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14, color: AppOnboardingColors.deep),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppOnboardingColors.warm, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: AppOnboardingColors.muted),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDD8D0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEDD8D0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppOnboardingColors.rose, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
