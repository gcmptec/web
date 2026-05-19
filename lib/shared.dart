import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/theme.dart';
import 'package:visibility_detector/visibility_detector.dart';

// â”€â”€â”€ Section Label (e.g. "HOW IT WORKS") â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.inter(
      color: GcmpColors.green,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.5,
    ),
  );
}

// â”€â”€â”€ Green accent button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GreenButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool large;

  const GreenButton({super.key, required this.label, required this.onTap, this.large = false});

  @override
  State<GreenButton> createState() => _GreenButtonState();
}

class _GreenButtonState extends State<GreenButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: widget.large ? 32 : 24,
            vertical: widget.large ? 16 : 12,
          ),
          decoration: BoxDecoration(
            color: _hover ? GcmpColors.greenDim : GcmpColors.green,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: GcmpColors.green.withValues(alpha: 0.25),
                blurRadius: 16,
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: const Color(0xFF0A0A18),
              fontSize: widget.large ? 15 : 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Ghost button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const GhostButton({super.key, required this.label, required this.onTap});

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          decoration: BoxDecoration(
            color: _hover ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: Colors.white.withValues(alpha: _hover ? 0.25 : 0.12),
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: GcmpColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Green check circle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GreenCheck extends StatelessWidget {
  const GreenCheck({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: GcmpColors.green.withValues(alpha: 0.12),
      border: Border.all(color: GcmpColors.green.withValues(alpha: 0.3)),
    ),
    child: const Icon(Icons.check, color: GcmpColors.green, size: 12),
  );
}

// â”€â”€â”€ Feature icon box â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class FeatureIconBox extends StatelessWidget {
  final IconData icon;
  const FeatureIconBox(this.icon, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: GcmpColors.green.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: GcmpColors.green.withValues(alpha: 0.2)),
      boxShadow: [
        BoxShadow(
          color: GcmpColors.green.withValues(alpha: 0.10),
          blurRadius: 12,
        ),
      ],
    ),
    child: Icon(icon, color: GcmpColors.green, size: 20),
  );
}

// â”€â”€â”€ Horizontal rule â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GcmpDivider extends StatelessWidget {
  const GcmpDivider({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              GcmpColors.green.withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
      Container(
        height: 8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GcmpColors.green.withValues(alpha: 0.03), Colors.transparent],
          ),
        ),
      ),
    ],
  );
}

// â”€â”€â”€ Green tag / chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GreenTag extends StatelessWidget {
  final String label;
  const GreenTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: GcmpColors.green.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: GcmpColors.green.withValues(alpha: 0.2)),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        color: GcmpColors.greenDim,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// â”€â”€â”€ Status badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: color.withValues(alpha: 0.25)),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// â”€â”€â”€ GCMP Logo widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class GcmpLogo extends StatelessWidget {
  final double size;
  const GcmpLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/logo_200x200.png',
          width: size,
          height: size,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GCMP',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
              ),
            ),
            Text(
              'SECURITY',
              style: GoogleFonts.inter(
                color: GcmpColors.green,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Scroll helper ────────────────────────────────────────────────
class ScrollHelper {
  static void to(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }
}

// ─── Standard section padding container ───────────────────────────
class SectionContainer extends StatelessWidget {
  final Widget child;

  const SectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: mobile ? 24 : 64,
      ),
      child: child,
    );
  }
}

// ─── Scroll-reveal animation wrapper ──────────────────────────────
class RevealWrapper extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const RevealWrapper({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<RevealWrapper> createState() => _RevealWrapperState();
}

class _RevealWrapperState extends State<RevealWrapper> {
  bool _visible = false;
  late final Key _detectorKey;

  @override
  void initState() {
    super.initState();
    _detectorKey = UniqueKey();
  }

  void _onVisibility(VisibilityInfo info) {
    if (info.visibleFraction > 0.1 && !_visible) {
      if (widget.delay == Duration.zero) {
        setState(() => _visible = true);
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) setState(() => _visible = true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _detectorKey,
      onVisibilityChanged: _onVisibility,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _visible ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 400),
          offset: _visible ? Offset.zero : const Offset(0, 0.05),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
