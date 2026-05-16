import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onPilotTap;
  final VoidCallback onHowTap;

  const HeroSection({super.key, required this.onPilotTap, required this.onHowTap});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: mobile ? 56 : 96,
        horizontal: mobile ? 24 : 64,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: GcmpColors.green.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GcmpColors.green.withOpacity(0.2)),
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
          ),
          const SizedBox(height: 32),
          Text(
            'We Cut Emergency\nWaiting Times',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: GcmpColors.textPrimary,
              fontSize: mobile ? 40 : 62,
              fontWeight: FontWeight.w900,
              letterSpacing: mobile ? -1.5 : -2.5,
              height: 1.05,
            ),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: mobile ? 40 : 62,
                fontWeight: FontWeight.w900,
                letterSpacing: mobile ? -1.5 : -2.5,
                height: 1.05,
              ),
              children: const [
                TextSpan(text: 'From '),
                TextSpan(text: 'Hours ', style: TextStyle(color: Color(0xFFEF4444))),
                TextSpan(text: 'To ', style: TextStyle(color: GcmpColors.textPrimary)),
                TextSpan(text: 'Seconds', style: TextStyle(color: GcmpColors.green)),
              ],
            ),
          ),
          const SizedBox(height: 24),
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
          ),
          const SizedBox(height: 14),
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
          ),
          const SizedBox(height: 44),
          mobile
              ? Column(children: [
                  GreenButton(label: 'Apply for Free 60-Day Pilot', onTap: onPilotTap, large: true),
                  const SizedBox(height: 14),
                  GhostButton(label: 'See How It Works', onTap: onHowTap),
                ])
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GreenButton(label: 'Apply for Free 60-Day Pilot', onTap: onPilotTap, large: true),
                  const SizedBox(width: 14),
                  GhostButton(label: 'See How It Works', onTap: onHowTap),
                ]),
          const SizedBox(height: 60),
          _ResponseTimeVisual(mobile: mobile),
        ],
      ),
    );
  }
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
        builder: (_, __) => Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GcmpColors.green.withOpacity(_anim.value),
          ),
        ),
      );
}

class _ResponseTimeVisual extends StatelessWidget {
  final bool mobile;
  const _ResponseTimeVisual({required this.mobile});

  @override
  Widget build(BuildContext context) {
    final without = _TimeBox(time: 'Hours', label: 'WITHOUT GCMP',
        sub: 'Blind response, no context', color: const Color(0xFFEF4444), mobile: mobile);
    final arrow = Padding(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 0 : 24, vertical: mobile ? 12 : 0),
      child: Text(mobile ? '↓' : '→',
          style: GoogleFonts.inter(color: GcmpColors.textMuted, fontSize: 24)),
    );
    final with_ = _TimeBox(time: 'Seconds', label: 'WITH GCMP',
        sub: 'Live scene context, instant alert', color: GcmpColors.green, mobile: mobile);

    return mobile
        ? Column(children: [without, arrow, with_])
        : Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [without, arrow, with_]);
  }
}

class _TimeBox extends StatelessWidget {
  final String time, label, sub;
  final Color color;
  final bool mobile;

  const _TimeBox({required this.time, required this.label, required this.sub,
      required this.color, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mobile ? double.infinity : 220,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Text(time, style: GoogleFonts.inter(color: color, fontSize: 38,
            fontWeight: FontWeight.w900, letterSpacing: -2.0)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(color: color, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 1.0)),
        const SizedBox(height: 3),
        Text(sub, textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: GcmpColors.textMuted, fontSize: 12)),
      ]),
    );
  }
}
