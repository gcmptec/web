import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 32),
      child: mobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  Widget _buildDesktop(BuildContext context) => Row(
    children: [
      const GcmpLogo(size: 28),
      const SizedBox(width: 16),
      Text(
        'Â© 2026 GCMP Security (Pty) Ltd Â· Gaborone, Botswana',
        style: GoogleFonts.inter(color: GcmpColors.textMuted, fontSize: 13),
      ),
      const Spacer(),
      _FooterLink('LinkedIn', url: 'https://www.linkedin.com/in/didintle-motshubi-41944716a/'),
      const SizedBox(width: 24),
      _FooterLink('Contact', url: 'mailto:tsotlhedidintle@gmail.com'),
      const SizedBox(width: 24),
      _saasTag(),
    ],
  );

  Widget _buildMobile(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const GcmpLogo(size: 28),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FooterLink('LinkedIn', url: 'https://www.linkedin.com/in/didintle-motshubi-41944716a/'),
          const SizedBox(width: 24),
          _FooterLink('Contact', url: 'mailto:tsotlhedidintle@gmail.com'),
          const SizedBox(width: 24),
          _saasTag(),
        ],
      ),
      const SizedBox(height: 14),
      Text(
        'Â© 2026 GCMP Security (Pty) Ltd Â· Gaborone, Botswana',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(color: GcmpColors.textMuted, fontSize: 12),
      ),
    ],
  );

  Widget _saasTag() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: GcmpColors.green.withValues(alpha: 0.25)),
    ),
    child: Text(
      'SaaS Platform',
      style: GoogleFonts.inter(color: GcmpColors.green, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

class _FooterLink extends StatefulWidget {
  final String label;
  final String url;
  const _FooterLink(this.label, {required this.url});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication),
    child: MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: Text(
        widget.label,
        style: GoogleFonts.inter(
          color: _hover ? GcmpColors.textSecondary : GcmpColors.textMuted,
          fontSize: 13,
        ),
      ),
    ),
  );
}


