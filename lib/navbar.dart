import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';

class NavBar extends StatelessWidget {
  final ScrollController scrollController;
  final GlobalKey howKey, featuresKey, whoKey, b2bKey, pilotKey;
  final bool scrolled;

  const NavBar({
    super.key,
    required this.scrollController,
    required this.howKey,
    required this.featuresKey,
    required this.whoKey,
    required this.b2bKey,
    required this.pilotKey,
    required this.scrolled,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 66,
      decoration: BoxDecoration(
        color: scrolled
            ? GcmpColors.bg.withValues(alpha: 0.98)
            : GcmpColors.bg.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: scrolled
                ? GcmpColors.green.withValues(alpha: 0.15)
                : GcmpColors.green.withValues(alpha: 0.08),
          ),
        ),
        boxShadow: scrolled
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16)]
            : [],
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64),
      child: Row(
        children: [
          Image.asset('assets/logo_200x200.png', height: 40),
          const Spacer(),
          if (!mobile) ...[
            _NavLink('How It Works', () => ScrollHelper.to(howKey)),
            const SizedBox(width: 28),
            _NavLink('Platform', () => ScrollHelper.to(featuresKey)),
            const SizedBox(width: 28),
            _NavLink('Who It\'s For', () => ScrollHelper.to(whoKey)),
            const SizedBox(width: 28),
            _NavLink('For Partners', () => ScrollHelper.to(b2bKey)),
            const SizedBox(width: 28),
          ],
          _PilotNavBtn(onTap: () => ScrollHelper.to(pilotKey)),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink(this.label, this.onTap);

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              color: _hover ? GcmpColors.textPrimary : GcmpColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}

class _PilotNavBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _PilotNavBtn({required this.onTap});

  @override
  State<_PilotNavBtn> createState() => _PilotNavBtnState();
}

class _PilotNavBtnState extends State<_PilotNavBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: _hover
                  ? GcmpColors.green.withValues(alpha: 0.18)
                  : GcmpColors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: GcmpColors.green.withValues(alpha: 0.35)),
            ),
            child: Text(
              'Free 60-Day Pilot â†’',
              style: GoogleFonts.inter(
                color: GcmpColors.green,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
}


