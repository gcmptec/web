import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gcmp_web/shared.dart';
import 'package:gcmp_web/theme.dart';

const _faqs = [
  (
    'How does the panic button work?',
    'Staff trigger an alert via the GCMP mobile app or a physical device. The system instantly notifies your designated first responders with the exact location and a live contextual snapshot â€” so they know what they\'re walking into before they arrive.',
  ),
  (
    'Does it work without internet?',
    'The mobile panic button requires a data connection to send alerts. We recommend ensuring reliable mobile coverage at your premises. For high-risk environments, GSM-backed physical device options are available.',
  ),
  (
    'Who receives the alerts?',
    'You decide during setup. Alerts can go to your contracted security company\'s dispatch, an internal security manager, or both. All responders receive simultaneous push notifications and a live dashboard update.',
  ),
  (
    'Where is our data stored?',
    'All incident data is stored on Firebase infrastructure in a compliant region. Alert logs, location records, and response history stay within the platform and are never sold or shared with third parties.',
  ),
  (
    'How long does setup take?',
    'We handle everything. From your application being accepted to your first live alert is typically under a week. We provide hands-on onboarding support for all Gaborone-area pilot partners.',
  ),
  (
    'What happens after the 60-day pilot?',
    'You decide with full incident data in hand. No automatic charges, no lock-in. If the platform is working for your team we move to a monthly plan. If not, we part ways â€” no strings attached.',
  ),
];

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('FAQ'),
          const SizedBox(height: 12),
          Text('Common questions', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 48),
          ...List.generate(_faqs.length, (i) => _FaqItem(
            question: _faqs[i].$1,
            answer: _faqs[i].$2,
            isLast: i == _faqs.length - 1,
          )),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isLast;

  const _FaqItem({required this.question, required this.answer, required this.isLast});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: GoogleFonts.inter(
                      color: GcmpColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: GcmpColors.green, size: 22),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 40),
            child: Text(
              widget.answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          crossFadeState: _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (!widget.isLast)
          Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
      ],
    );
  }
}


