import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onPilotTap;
  final VoidCallback onHowTap;

  const HeroSection({super.key, required this.onPilotTap, required this.onHowTap});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _entered = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Green radial glow — top centre
          Positioned(
            top: 0, left: 0, right: 0,
            child: IgnorePointer(
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1),
                    radius: 1.2,
                    colors: [GcmpColors.green.withValues(alpha: 0.07), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          // Blue-tinted glow — top right
          Positioned(
            top: 60, right: -60,
            child: IgnorePointer(
              child: Container(
                width: 300, height: 300,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x0A00B4FF), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          // Content
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: mobile ? 56 : 96,
              horizontal: mobile ? 24 : 64,
            ),
            child: Column(
              children: [
                // Badge
                _buildBadge(mobile)
                    .animate(target: _entered ? 1 : 0)
                    .fade(duration: 300.ms),
                const SizedBox(height: 32),
                // Headline
                _buildHeadline(mobile)
                    .animate(target: _entered ? 1 : 0)
                    .fade(duration: 400.ms, delay: 80.ms)
                    .slideY(begin: 0.04, end: 0, duration: 400.ms, delay: 80.ms, curve: Curves.easeOut),
                const SizedBox(height: 24),
                // Tagline
                Text(
                  'Emergency response intelligence — built in Botswana, built for Africa.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: GcmpColors.green,
                    fontSize: mobile ? 13 : 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate(target: _entered ? 1 : 0).fade(duration: 350.ms, delay: 160.ms),
                const SizedBox(height: 14),
                // Body copy
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    'A smart panic button + real-time monitoring dashboard that gives first responders a live picture of what they\'re walking into — before they arrive.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: GcmpColors.textSecondary,
                      fontSize: mobile ? 15 : 18,
                      height: 1.75,
                    ),
                  ),
                ).animate(target: _entered ? 1 : 0).fade(duration: 350.ms, delay: 200.ms),
                const SizedBox(height: 44),
                // CTAs
                _buildButtons(mobile)
                    .animate(target: _entered ? 1 : 0)
                    .fade(duration: 300.ms, delay: 240.ms)
                    .slideY(begin: 0.02, end: 0, duration: 300.ms, delay: 240.ms),
                const SizedBox(height: 60),
                // Stats row
                const _StatsRow()
                    .animate(target: _entered ? 1 : 0)
                    .fade(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.02, end: 0, duration: 400.ms, delay: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(bool mobile) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: GcmpColors.green.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: GcmpColors.green.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseDot(),
        const SizedBox(width: 8),
        Text(
          'NOW ACCEPTING PILOT PARTNERS IN BOTSWANA',
          style: GoogleFonts.inter(
            color: GcmpColors.green,
            fontSize: mobile ? 9 : 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    ),
  );

  Widget _buildHeadline(bool mobile) => Column(
    children: [
      Text(
        'We Cut Emergency\nWaiting Times',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: GcmpColors.textPrimary,
          fontSize: mobile ? 44 : 80,
          fontWeight: FontWeight.w900,
          letterSpacing: -3,
          height: 1.0,
        ),
      ),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: mobile ? 44 : 80,
            fontWeight: FontWeight.w900,
            letterSpacing: -3,
            height: 1.0,
          ),
          children: [
            const TextSpan(text: 'From '),
            const TextSpan(text: 'Hours ', style: TextStyle(color: GcmpColors.red)),
            const TextSpan(text: 'To ', style: TextStyle(color: GcmpColors.textPrimary)),
            TextSpan(
              text: 'Seconds',
              style: TextStyle(
                color: GcmpColors.green,
                shadows: [
                  Shadow(
                    color: GcmpColors.green.withValues(alpha: 0.4),
                    blurRadius: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildButtons(bool mobile) => mobile
      ? Column(children: [
          GreenButton(label: 'Apply for Free 60-Day Pilot', onTap: widget.onPilotTap, large: true),
          const SizedBox(height: 14),
          GhostButton(label: 'See How It Works', onTap: widget.onHowTap),
        ])
      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GreenButton(label: 'Apply for Free 60-Day Pilot', onTap: widget.onPilotTap, large: true),
          const SizedBox(width: 14),
          GhostButton(label: 'See How It Works', onTap: widget.onHowTap),
        ]);
}

class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _anim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _anim,
        builder: (context, _) => Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GcmpColors.green.withValues(alpha: _anim.value),
          ),
        ),
      );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _StatItem(value: '<30s', label: 'FIRST ALERT SENT', showDivider: true)),
            Expanded(child: _StatItem(value: '60', label: 'DAY FREE PILOT', showDivider: true, valueColor: GcmpColors.textPrimary)),
            Expanded(child: _StatItem(value: 'Live', label: 'SCENE CONTEXT', showDivider: false, valueColor: GcmpColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final bool showDivider;
  final Color? valueColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.showDivider,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.06)))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              color: valueColor ?? GcmpColors.green,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              shadows: valueColor == null
                  ? [Shadow(color: GcmpColors.green.withValues(alpha: 0.3), blurRadius: 16)]
                  : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: GcmpColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
