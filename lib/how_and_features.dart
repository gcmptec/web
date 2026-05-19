import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';

// â”€â”€â”€ How It Works â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevealWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('How It Works'),
                const SizedBox(height: 12),
                Text('Three steps. One platform.',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(
                    'From the moment an incident is triggered to your first responder arriving on scene — fully informed.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 52),
          RevealWrapper(
            delay: const Duration(milliseconds: 200),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: mobile
                    ? Column(children: [
                        _StepCard(number: '01', icon: Icons.warning_amber_rounded,
                            title: 'Panic Button Triggered',
                            body: 'A staff member or guard triggers the smart panic button — mobile or physical device — the moment an incident occurs.',
                            isLast: false, mobile: true, isActive: true),
                        _StepCard(number: '02', icon: Icons.send_rounded,
                            title: 'Alert + Context Sent Instantly',
                            body: 'First responders receive not just a location — but a live snapshot of the scene so they know exactly what they\'re walking into.',
                            isLast: false, mobile: true),
                        _StepCard(number: '03', icon: Icons.dashboard_outlined,
                            title: 'Monitor From Your Dashboard',
                            body: 'Security and operations managers track every incident in real time — logs, status, and full response history in one place.',
                            isLast: true, mobile: true),
                      ])
                    : Row(children: [
                        _StepCard(number: '01', icon: Icons.warning_amber_rounded,
                            title: 'Panic Button Triggered',
                            body: 'A staff member or guard triggers the smart panic button — mobile or physical device — the moment an incident occurs.',
                            isLast: false, mobile: false, isActive: true),
                        _StepCard(number: '02', icon: Icons.send_rounded,
                            title: 'Alert + Context Sent Instantly',
                            body: 'First responders receive not just a location — but a live snapshot of the scene so they know exactly what they\'re walking into.',
                            isLast: false, mobile: false),
                        _StepCard(number: '03', icon: Icons.dashboard_outlined,
                            title: 'Monitor From Your Dashboard',
                            body: 'Security and operations managers track every incident in real time — logs, status, and full response history in one place.',
                            isLast: true, mobile: false),
                      ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number, title, body;
  final IconData icon;
  final bool isLast, mobile, isActive;

  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
    required this.isLast,
    required this.mobile,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = isLast
        ? null
        : (mobile
            ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))
            : Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.05))));

    Widget card = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isActive
                ? GcmpColors.green.withValues(alpha: 0.03)
                : GcmpColors.card,
            border: border,
            boxShadow: isActive
                ? [BoxShadow(color: GcmpColors.green.withValues(alpha: 0.08), blurRadius: 20)]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STEP $number',
                style: GoogleFonts.inter(
                  color: GcmpColors.green.withValues(alpha: isActive ? 1.0 : 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: GcmpColors.green.withValues(alpha: isActive ? 0.10 : 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GcmpColors.green.withValues(alpha: isActive ? 0.25 : 0.1),
                  ),
                  boxShadow: isActive
                      ? [BoxShadow(color: GcmpColors.green.withValues(alpha: 0.10), blurRadius: 12)]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: GcmpColors.green.withValues(alpha: isActive ? 1.0 : 0.4),
                  size: 22,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: GcmpColors.textPrimary.withValues(alpha: isActive ? 1.0 : 0.7)),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: GcmpColors.textSecondary.withValues(alpha: isActive ? 1.0 : 0.5)),
              ),
            ],
          ),
        ),
        if (isActive)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [GcmpColors.green, Colors.transparent],
                ),
              ),
            ),
          ),
      ],
    );

    return mobile ? card : Expanded(child: card);
  }
}

// â”€â”€â”€ Features Section â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RevealWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('The Platform'),
                const SizedBox(height: 12),
                Text('Two core capabilities.\nOne unified system.',
                    style: Theme.of(context).textTheme.displayMedium),
              ],
            ),
          ),
          const SizedBox(height: 52),
          if (mobile)
            Column(children: [
              RevealWrapper(
                delay: const Duration(milliseconds: 150),
                child: _FeatureCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Smart Panic Button',
                  body: 'A discreet, reliable alert trigger for your staff. Works on mobile and physical hardware. Sends the alert with live scene context attached — not a blank location ping.',
                  tags: const ['Mobile app', 'Instant alert', 'Scene capture', 'GPS location'],
                ),
              ),
              const SizedBox(height: 20),
              RevealWrapper(
                delay: const Duration(milliseconds: 300),
                child: _FeatureCard(
                  icon: Icons.monitor_outlined,
                  title: 'Real-Time Monitoring Dashboard',
                  body: 'A web dashboard giving security managers full visibility — live incident feed, guard status, alert history, and response tracking. Built for Botswana businesses.',
                  tags: const ['Web dashboard', 'Live incident feed', 'Response tracking', 'Audit log'],
                ),
              ),
            ])
          else
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: RevealWrapper(
                  delay: const Duration(milliseconds: 150),
                  child: _FeatureCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'Smart Panic Button',
                    body: 'A discreet, reliable alert trigger for your staff. Works on mobile and physical hardware. Sends the alert with live scene context attached — not a blank location ping.',
                    tags: const ['Mobile app', 'Instant alert', 'Scene capture', 'GPS location'],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: RevealWrapper(
                  delay: const Duration(milliseconds: 300),
                  child: _FeatureCard(
                    icon: Icons.monitor_outlined,
                    title: 'Real-Time Monitoring Dashboard',
                    body: 'A web dashboard giving security managers full visibility — live incident feed, guard status, alert history, and response tracking. Built for Botswana businesses.',
                    tags: const ['Web dashboard', 'Live incident feed', 'Response tracking', 'Audit log'],
                  ),
                ),
              ),
            ]),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title, body;
  final List<String> tags;

  const _FeatureCard({required this.icon, required this.title,
      required this.body, required this.tags});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: GcmpColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hover
                    ? GcmpColors.green.withValues(alpha: 0.30)
                    : GcmpColors.green.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 32),
                if (_hover)
                  BoxShadow(color: GcmpColors.green.withValues(alpha: 0.05), blurRadius: 20),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                FeatureIconBox(widget.icon),
                const SizedBox(width: 14),
                Expanded(child: Text(widget.title,
                    style: Theme.of(context).textTheme.headlineMedium)),
              ]),
              const SizedBox(height: 16),
              Text(widget.body, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              Wrap(spacing: 8, runSpacing: 8,
                  children: widget.tags.map((t) => GreenTag(t)).toList()),
            ]),
          ),
          // Inset top accent line
          Positioned(
            top: 0, left: 24, right: 24,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    GcmpColors.green.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


