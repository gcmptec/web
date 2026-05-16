import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';


// ─── Who It's For ─────────────────────────────────────────────────
class WhoSection extends StatelessWidget {
  const WhoSection({super.key});

  static const _items = [
    ('🏢', 'Office Parks & Estates', 'Multi-tenant environments where security coverage is shared and response coordination matters.'),
    ('🏫', 'Schools & Universities', 'Protecting staff and students with rapid, informed response when every second counts.'),
    ('🏭', 'Warehouses & Facilities', 'Large premises with distributed staff who need a reliable way to call for help fast.'),
    ('🏪', 'Retail & SMEs', 'Small teams with no dedicated security officer — the panic button is your first line of defence.'),
    ('🏨', 'Hotels & Hospitality', 'Guest and staff safety managed from a single dashboard with full incident visibility.'),
    ('🏗️', 'Construction & Sites', 'Remote or high-risk worksites where lone workers need a direct line to help.'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 768;
    final crossAxis = mobile ? 1 : (width < 1024 ? 2 : 3);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Who It\'s For'),
          const SizedBox(height: 12),
          Text('Built for Botswana businesses',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'If your staff, assets, or premises are at risk — GCMP gives you and your responders the edge they need.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 44),
          GridView.count(
            crossAxisCount: crossAxis,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: mobile ? 3.0 : 2.3,
            children: _items
                .map((item) => _WhoCard(emoji: item.$1, title: item.$2, body: item.$3))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _WhoCard extends StatelessWidget {
  final String emoji, title, body;
  const _WhoCard({required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GcmpColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pilot Signup Section ─────────────────────────────────────────
class PilotSection extends StatefulWidget {
  const PilotSection({super.key});

  @override
  State<PilotSection> createState() => _PilotSectionState();
}

class _PilotSectionState extends State<PilotSection> {
  final _nameCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _role = '';
  bool _submitted = false;
  bool _loading = false;
  bool _error = false;

  final _roles = [
    'Operations Manager', 'Security Manager', 'HR Manager',
    'Facilities Manager', 'Business Owner / Director', 'Other',
  ];

  Future<void> _submitForm() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _companyCtrl.text.trim().isEmpty ||
        _role.isEmpty ||
        _phoneCtrl.text.trim().isEmpty) return;

    setState(() { _loading = true; _error = false; });
    try {
      await FirebaseFirestore.instance.collection('pilot_applications').add({
        'name': _nameCtrl.text.trim(),
        'company': _companyCtrl.text.trim(),
        'role': _role,
        'phone': _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      await FirebaseAnalytics.instance.logEvent(name: 'pilot_form_success');
      setState(() { _submitted = true; _loading = false; });
    } catch (_) {
      await FirebaseAnalytics.instance.logEvent(name: 'pilot_form_error');
      setState(() { _loading = false; _error = true; });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _companyCtrl.dispose();
    _phoneCtrl.dispose(); _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    return Container(
      decoration: BoxDecoration(
        color: GcmpColors.green.withOpacity(0.03),
        border: Border.symmetric(
          horizontal: BorderSide(color: GcmpColors.green.withOpacity(0.1)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: mobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  Widget _buildDesktop(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: _LeftCopy(context)),
      const SizedBox(width: 64),
      SizedBox(width: 400, child: _FormCard()),
    ],
  );

  Widget _buildMobile(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _LeftCopy(context),
      const SizedBox(height: 40),
      _FormCard(),
    ],
  );

  Widget _LeftCopy(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const SectionLabel('Free 60-Day Pilot'),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
            ),
            child: Text('1 Spot Remaining',
                style: GoogleFonts.inter(color: const Color(0xFFEF4444),
                    fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: mobile ? 32 : 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              height: 1.1,
              color: GcmpColors.textPrimary,
            ),
            children: const [
              TextSpan(text: 'Be the first to\ndeploy '),
              TextSpan(text: 'GCMP\n', style: TextStyle(color: GcmpColors.green)),
              TextSpan(text: 'in Botswana'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'We\'re looking for one business ready to run a free, fully-supported 60-day pilot. No cost. No commitment. Just real-world proof that your team can respond faster.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 36),
        ...[
          'Full platform access — panic button + dashboard — at no cost',
          'Hands-on onboarding and setup support from the founder',
          '60 days of real deployment data and incident reporting',
          'Direct input into the product roadmap',
          'No lock-in — decide at the end of 60 days',
        ].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(children: [
            const GreenCheck(),
            const SizedBox(width: 12),
            Expanded(child: Text(item,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GcmpColors.textPrimary.withOpacity(0.85)))),
          ]),
        )),
      ],
    );
  }

  Widget _FormCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: GcmpColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GcmpColors.green.withOpacity(0.15)),
      ),
      child: _submitted
          ? const _SuccessState()
          : _FormBody(
              nameCtrl: _nameCtrl,
              companyCtrl: _companyCtrl,
              phoneCtrl: _phoneCtrl,
              emailCtrl: _emailCtrl,
              role: _role,
              roles: _roles,
              loading: _loading,
              error: _error,
              onRoleChanged: (v) => setState(() => _role = v ?? ''),
              onSubmit: _submitForm,
            ),
    );
  }
}

class _FormBody extends StatelessWidget {
  final TextEditingController nameCtrl, companyCtrl, phoneCtrl, emailCtrl;
  final String role;
  final List<String> roles;
  final bool loading, error;
  final ValueChanged<String?> onRoleChanged;
  final VoidCallback onSubmit;

  const _FormBody({
    required this.nameCtrl, required this.companyCtrl,
    required this.phoneCtrl, required this.emailCtrl,
    required this.role, required this.roles,
    required this.loading, required this.error,
    required this.onRoleChanged, required this.onSubmit,
  });

  InputDecoration _dec(String label, String hint) => InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: GoogleFonts.inter(color: GcmpColors.textMuted, fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 0.5),
    hintStyle: GoogleFonts.inter(color: GcmpColors.textMuted.withOpacity(0.5), fontSize: 14),
    filled: true,
    fillColor: Colors.white.withOpacity(0.03),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.09))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.09))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: GcmpColors.green.withOpacity(0.4))),
  );

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Apply for the Pilot', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 6),
      Text('Takes 2 minutes. We\'ll follow up within 24 hours.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13)),
      const SizedBox(height: 24),
      TextField(controller: nameCtrl,
          style: const TextStyle(color: GcmpColors.textPrimary, fontSize: 14),
          decoration: _dec('FULL NAME', 'Your name')),
      const SizedBox(height: 14),
      TextField(controller: companyCtrl,
          style: const TextStyle(color: GcmpColors.textPrimary, fontSize: 14),
          decoration: _dec('COMPANY / ORGANISATION', 'Company name')),
      const SizedBox(height: 14),
      DropdownButtonFormField<String>(
        value: role.isEmpty ? null : role,
        hint: Text('Select your role...',
            style: GoogleFonts.inter(color: GcmpColors.textMuted.withOpacity(0.5), fontSize: 14)),
        items: roles.map((r) => DropdownMenuItem(value: r,
            child: Text(r, style: GoogleFonts.inter(color: GcmpColors.textPrimary, fontSize: 14)))).toList(),
        onChanged: onRoleChanged,
        dropdownColor: GcmpColors.surface,
        decoration: _dec('YOUR ROLE', ''),
        style: const TextStyle(color: GcmpColors.textPrimary),
      ),
      const SizedBox(height: 14),
      TextField(controller: phoneCtrl,
          style: const TextStyle(color: GcmpColors.textPrimary, fontSize: 14),
          decoration: _dec('PHONE / WHATSAPP', '+267 XX XXX XXX')),
      const SizedBox(height: 14),
      TextField(controller: emailCtrl,
          style: const TextStyle(color: GcmpColors.textPrimary, fontSize: 14),
          decoration: _dec('WORK EMAIL', 'you@company.co.bw')),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: loading
            ? Container(height: 52,
                decoration: BoxDecoration(color: GcmpColors.green,
                    borderRadius: BorderRadius.circular(9)),
                child: const Center(child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5,
                        color: Color(0xFF0A0A18)))))
            : GreenButton(label: 'Apply for Free Pilot →', onTap: onSubmit, large: true),
      ),
      if (error) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25)),
          ),
          child: Row(children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(
              'Something went wrong. Please try again or email us directly.',
              style: GoogleFonts.inter(color: const Color(0xFFEF4444), fontSize: 12),
            )),
          ]),
        ),
      ],
      const SizedBox(height: 12),
      Center(child: Text(
        'No payment. No commitment. Gaborone & surrounds only.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: GcmpColors.textMuted, fontSize: 12),
      )),
      const SizedBox(height: 8),
      Center(child: Text(
        'Your details stay private. We will never share or spam you.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: GcmpColors.textMuted.withOpacity(0.6), fontSize: 11),
      )),
    ]);
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState();

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 32),
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GcmpColors.green.withOpacity(0.12),
          border: Border.all(color: GcmpColors.green.withOpacity(0.3)),
        ),
        child: const Icon(Icons.check, color: GcmpColors.green, size: 28),
      ),
      const SizedBox(height: 20),
      Text('Application Received!', style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: 12),
      Text(
        'Thanks for applying. We\'ll be in touch within 24 hours to discuss next steps.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 32),
    ]);
  }
}
