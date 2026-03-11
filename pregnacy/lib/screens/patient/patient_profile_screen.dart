// lib/screens/patient/patient_profile_screen.dart

import 'package:flutter/material.dart';

// ___ Colour palette ___________________________________________________________
class _PC {
  static const rose    = Color(0xFFD4847A);
  static const sidebar = Color(0xFF3D2C2C);
  static const deep    = Color(0xFF3D2C2C);
  static const cream   = Color(0xFFFDF6F0);
  static const warm    = Color(0xFFE8C9B8);
  static const text    = Color(0xFF4A3535);
  static const muted   = Color(0xFF9B8080);
}

// ___ Profile Screen ___________________________________________________________
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _editing = false;
  bool _saving  = false;

  final _nameCtrl      = TextEditingController(text: 'Aisha Kamau');
  final _dobCtrl       = TextEditingController(text: '14 / 06 / 1996');
  final _phoneCtrl     = TextEditingController(text: '+254 712 345 678');
  final _emailCtrl     = TextEditingController(text: 'patient@mamacare.com');
  final _addressCtrl   = TextEditingController(text: 'Westlands, Nairobi, Kenya');
  final _emergencyCtrl = TextEditingController(text: 'James Kamau — +254 720 123 456');
  String _maritalStatus = 'Married';

  @override
  void dispose() {
    for (final c in [_nameCtrl, _dobCtrl, _phoneCtrl, _emailCtrl, _addressCtrl, _emergencyCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() { _saving = false; _editing = false; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully'),
        backgroundColor: _PC.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: _PC.cream,
      appBar: AppBar(
        backgroundColor: _PC.sidebar,
        foregroundColor: const Color(0xFFF5E6E0),
        elevation: 0,
        titleSpacing: 0,
        title: const Text('My Profile',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 18, color: Color(0xFFF5E6E0))),
        actions: [
          if (!_editing)
            TextButton.icon(
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit_outlined, color: _PC.rose, size: 16),
              label: const Text('Edit', style: TextStyle(color: _PC.rose, fontWeight: FontWeight.w600)),
            )
          else
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel', style: TextStyle(color: _PC.warm)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar card
              Center(
                child: Column(children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: _PC.rose,
                        child: const Text('A',
                            style: TextStyle(fontFamily: 'Georgia', fontSize: 36,
                                color: Colors.white, fontWeight: FontWeight.w400)),
                      ),
                      if (_editing)
                        Positioned(
                          right: 0, bottom: 0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                                color: _PC.rose, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt_outlined,
                                size: 14, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Aisha Kamau',
                      style: TextStyle(fontFamily: 'Georgia', fontSize: 20,
                          fontWeight: FontWeight.w400, color: _PC.deep)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFD4847A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('Patient \u00b7 Dr. Njenga',
                        style: TextStyle(fontSize: 12, color: _PC.rose,
                            fontWeight: FontWeight.w500)),
                  ),
                ]),
              ),
              const SizedBox(height: 28),

              // Personal Details
              const _SectionHeader(label: 'Personal Details', icon: Icons.person_outline_rounded),
              const SizedBox(height: 12),
              _ProfileField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.badge_outlined,
                editing: _editing,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              _ProfileField(
                controller: _dobCtrl,
                label: 'Age / Date of Birth',
                icon: Icons.cake_outlined,
                hint: 'DD / MM / YYYY',
                editing: _editing,
                keyboardType: TextInputType.datetime,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              _MaritalStatusField(
                value: _maritalStatus,
                editing: _editing,
                onChanged: (v) => setState(() => _maritalStatus = v),
              ),
              const SizedBox(height: 20),

              // Contact Details
              const _SectionHeader(label: 'Contact Details', icon: Icons.contact_phone_outlined),
              const SizedBox(height: 12),
              _ProfileField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                editing: _editing,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              _ProfileField(
                controller: _emailCtrl,
                label: 'Email Address',
                icon: Icons.email_outlined,
                editing: _editing,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              _ProfileField(
                controller: _addressCtrl,
                label: 'Address / Location',
                icon: Icons.location_on_outlined,
                editing: _editing,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Emergency Contact
              const _SectionHeader(label: 'Emergency Contact', icon: Icons.emergency_outlined),
              const SizedBox(height: 12),
              _ProfileField(
                controller: _emergencyCtrl,
                label: 'Emergency Contact Person',
                icon: Icons.contact_emergency_outlined,
                hint: 'Name \u2014 Phone number',
                editing: _editing,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 28),

              // Save button
              if (_editing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _PC.rose,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save Changes',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ___ Section Header ___________________________________________________________
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: _PC.rose),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: _PC.rose, letterSpacing: 0.5)),
      const SizedBox(width: 10),
      const Expanded(child: Divider(color: Color(0xFFE8C9B8))),
    ]);
  }
}

// ___ Profile Field ____________________________________________________________
class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool editing;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.editing,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: editing
              ? const Color(0xFFD4847A).withOpacity(0.4)
              : const Color(0xFFF5E6E0),
        ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 14, vertical: editing ? 4 : 14),
      child: editing
          ? TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              style: const TextStyle(fontSize: 14, color: _PC.text),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 12, color: _PC.muted),
                prefixIcon: Icon(icon, size: 18, color: _PC.rose),
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 13, color: _PC.warm),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: _PC.rose),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontSize: 11,
                                color: _PC.muted,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 3),
                        Text(
                            controller.text.isEmpty ? '\u2014' : controller.text,
                            style: const TextStyle(
                                fontSize: 14, color: _PC.text),
                            maxLines: maxLines,
                            overflow: TextOverflow.ellipsis),
                      ]),
                ),
              ],
            ),
    );
  }
}

// ___ Marital Status Field _____________________________________________________
class _MaritalStatusField extends StatelessWidget {
  final String value;
  final bool editing;
  final ValueChanged<String> onChanged;
  const _MaritalStatusField(
      {required this.value,
      required this.editing,
      required this.onChanged});

  static const _options = [
    'Single', 'Married', 'Divorced', 'Widowed', 'Prefer not to say',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: editing
              ? const Color(0xFFD4847A).withOpacity(0.4)
              : const Color(0xFFF5E6E0),
        ),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: 14, vertical: editing ? 4 : 14),
      child: editing
          ? DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(
                labelText: 'Marital Status',
                labelStyle: TextStyle(fontSize: 12, color: _PC.muted),
                prefixIcon: Icon(Icons.favorite_border_rounded,
                    size: 18, color: _PC.rose),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              items: _options
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o,
                          style: const TextStyle(
                              fontSize: 14, color: _PC.text))))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            )
          : Row(children: [
              const Icon(Icons.favorite_border_rounded,
                  size: 18, color: _PC.rose),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Marital Status',
                          style: TextStyle(
                              fontSize: 11,
                              color: _PC.muted,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 3),
                      Text(value,
                          style: const TextStyle(
                              fontSize: 14, color: _PC.text)),
                    ]),
              ),
            ]),
    );
  }
}
