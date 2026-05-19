import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';

class B2bSection extends StatelessWidget {
  final VoidCallback onPartnerTap;
  const B2bSection({super.key, required this.onPartnerTap});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      decoration: BoxDecoration(
        color: GcmpColors.surface,
        border: Border.symmetric(
          horizontal: BorderSide(color: GcmpColors.green.withValues(alpha: 0.08)),
        ),
      ),
      child: SectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RevealWrapper(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('For Security Companies'),
                  const SizedBox(height: 14),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: mobile ? 28 : 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.15,
                        color: GcmpColors.textPrimary,
                      ),
                      children: const [
                        TextSpan(text: 'You bring the clients.\n'),
                        TextSpan(
                          text: 'We bring the intelligence layer.',
                          style: TextStyle(color: GcmpColors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Security companies license GCMP at BWP 15–25 per end-user per month and bundle it into their existing packages at BWP 50–80. No new sales motion. No friction for your clients.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 52),
            if (mobile)
              Column(children: [
                RevealWrapper(
                  delay: const Duration(milliseconds: 120),
                  child: _B2bCard(
                    icon: Icons.attach_money_rounded, label: 'LICENSE COST',
                    heading: 'BWP 15–25\nper user / mo',
                    body: 'Wholesale pricing for registered security companies. Scales cleanly with your client base – no per-seat minimums.',
                  ),
                ),
                const SizedBox(height: 16),
                RevealWrapper(
                  delay: const Duration(milliseconds: 240),
                  child: _B2bCard(
                    icon: Icons.trending_up_rounded, label: 'YOUR BUNDLE PRICE',
                    heading: 'BWP 50–80\nper user / mo',
                    body: 'Add GCMP to your existing service package. The margin sits between BWP 25–55 per user – and it\'s yours to keep.',
                    highlight: true,
                  ),
                ),
                const SizedBox(height: 16),
                RevealWrapper(
                  delay: const Duration(milliseconds: 360),
                  child: _B2bCard(
                    icon: Icons.handshake_outlined, label: 'SALES MOTION',
                    heading: 'Zero new\nmotion needed',
                    body: 'Your clients are already bought in. GCMP layers onto your existing contracts. No new pitch. No new procurement cycle.',
                  ),
                ),
              ])
            else
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: RevealWrapper(
                    delay: const Duration(milliseconds: 120),
                    child: _B2bCard(
                      icon: Icons.attach_money_rounded, label: 'LICENSE COST',
                      heading: 'BWP 15–25\nper user / mo',
                      body: 'Wholesale pricing for registered security companies. Scales cleanly with your client base – no per-seat minimums.',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RevealWrapper(
                    delay: const Duration(milliseconds: 240),
                    child: _B2bCard(
                      icon: Icons.trending_up_rounded, label: 'YOUR BUNDLE PRICE',
                      heading: 'BWP 50–80\nper user / mo',
                      body: 'Add GCMP to your existing service package. The margin sits between BWP 25–55 per user – and it\'s yours to keep.',
                      highlight: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RevealWrapper(
                    delay: const Duration(milliseconds: 360),
                    child: _B2bCard(
                      icon: Icons.handshake_outlined, label: 'SALES MOTION',
                      heading: 'Zero new\nmotion needed',
                      body: 'Your clients are already bought in. GCMP layers onto your existing contracts. No new pitch. No new procurement cycle.',
                    ),
                  ),
                ),
              ]),
            const SizedBox(height: 44),
            RevealWrapper(
              delay: const Duration(milliseconds: 480),
              child: _B2bBottomRow(onPartnerTap: onPartnerTap, mobile: mobile),
            ),
          ],
        ),
      ),
    );
  }
}

class _B2bCard extends StatelessWidget {
  final IconData icon;
  final String label, heading, body;
  final bool highlight;

  const _B2bCard({
    required this.icon, required this.label,
    required this.heading, required this.body,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: highlight ? GcmpColors.green.withValues(alpha: 0.05) : GcmpColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlight
                  ? GcmpColors.green.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.06),
            ),
            boxShadow: highlight
                ? [BoxShadow(color: GcmpColors.green.withValues(alpha: 0.12), blurRadius: 32)]
                : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: GcmpColors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: GcmpColors.green.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: GcmpColors.green, size: 18),
              ),
              const SizedBox(width: 12),
              Text(label, style: GoogleFonts.inter(
                  color: GcmpColors.green,
                  fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ]),
            const SizedBox(height: 20),
            Text(heading, style: GoogleFonts.inter(
                color: GcmpColors.textPrimary,
                fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.2)),
            const SizedBox(height: 12),
            Text(body, style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
        if (highlight)
          Positioned(
            top: 0, left: 24, right: 24,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    GcmpColors.green.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _B2bBottomRow extends StatelessWidget {
  final VoidCallback onPartnerTap;
  final bool mobile;
  const _B2bBottomRow({required this.onPartnerTap, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: mobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.check_circle_outline, color: GcmpColors.green, size: 18),
                const SizedBox(width: 12),
                Expanded(child: Text(
                  'White-label ready Â· API-first architecture Â· Dedicated partner support Â· Botswana-hosted infrastructure',
                  style: GoogleFonts.inter(color: GcmpColors.textSecondary, fontSize: 13, height: 1.5),
                )),
              ]),
              const SizedBox(height: 16),
              _PartnerCta(onTap: onPartnerTap),
            ])
          : Row(children: [
              const Icon(Icons.check_circle_outline, color: GcmpColors.green, size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(
                'White-label ready Â· API-first architecture Â· Dedicated partner support Â· Botswana-hosted infrastructure',
                style: GoogleFonts.inter(color: GcmpColors.textSecondary, fontSize: 13, height: 1.5),
              )),
              const SizedBox(width: 24),
              _PartnerCta(onTap: onPartnerTap),
            ]),
    );
  }
}

class _PartnerCta extends StatefulWidget {
  final VoidCallback onTap;
  const _PartnerCta({required this.onTap});

  @override
  State<_PartnerCta> createState() => _PartnerCtaState();
}

class _PartnerCtaState extends State<_PartnerCta> {
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _hover
                ? GcmpColors.green.withValues(alpha: 0.15)
                : GcmpColors.green.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GcmpColors.green.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: GcmpColors.green.withValues(alpha: 0.08), blurRadius: 16),
            ],
          ),
          child: Text('Become a Partner â†’',
              style: GoogleFonts.inter(color: GcmpColors.green,
                  fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}


