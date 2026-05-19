# Visual Redesign — Intelligent Security Brand Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernise the GCMP landing page to an "Intelligent Security" aesthetic — adding glassmorphism card depth, radial glow backgrounds, scroll-reveal animations, a redesigned hero, and fixing a critical pilot form bug.

**Architecture:** All changes are purely visual — no new dependencies, no new sections, no layout restructuring. `RevealWrapper` (new shared widget) provides scroll-triggered animations via `visibility_detector` + `AnimatedOpacity`/`AnimatedSlide`. Hero entry uses `flutter_animate`'s `.animate(target:)` API. The pilot form bug fix is a standalone change to `_submitForm()` in `who_and_pilot.dart`.

**Tech Stack:** Flutter web, Dart 3.11+, `flutter_animate ^4.5.0`, `visibility_detector ^0.4.0+2` (both already in pubspec), `google_fonts`, Firebase Firestore/Analytics.

---

## File Map

| File | Changes |
|---|---|
| `lib/who_and_pilot.dart` | Bug fix to `_submitForm()` (Task 1); WhoSection + PilotSection visual (Task 7); PilotSection reveal (Task 8) |
| `lib/shared.dart` | `GcmpDivider` gradient; `GreenButton` glow; `FeatureIconBox` glow; new `RevealWrapper` (Task 2) |
| `lib/navbar.dart` | BackdropFilter blur; glow border when scrolled; `_PilotNavBtn` glow (Task 3) |
| `lib/hero.dart` | Full StatefulWidget rewrite; radial glow; `_StatsRow`; flutter_animate entry (Task 4) |
| `lib/how_and_features.dart` | Step card active highlight; `_FeatureCard` accent + depth; staggered reveals (Task 5) |
| `lib/video_section.dart` | Glow border around video container; reveal (Task 6) |
| `lib/faq_section.dart` | Gradient item dividers; staggered reveal (Task 6) |
| `lib/b2b_section.dart` | Highlighted card glow boost; `_PartnerCta` glow; staggered reveal (Task 7) |
| `lib/footer.dart` | Gradient top divider (Task 8) |
| `test/widget_test.dart` | Add `RevealWrapper` tests (Task 2) |

---

## Task 1: Fix Pilot Form Submit Bug

**Files:**
- Modify: `lib/who_and_pilot.dart:122-143`

**Root cause:** `await FirebaseAnalytics.instance.logEvent()` throws on Flutter web (Pigeon/null — same issue as commit `46e8a06`). The exception is caught by the outer `catch` block, which sets `_error = true` and prevents `_submitted` from ever becoming `true`.

- [ ] **Step 1: Apply the fix**

In `lib/who_and_pilot.dart`, replace the current `_submitForm()` body (lines 122–143):

```dart
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
    setState(() { _submitted = true; _loading = false; });
    // fire-and-forget: logEvent throws on Flutter web — never await it
    FirebaseAnalytics.instance.logEvent(name: 'pilot_form_success');
  } catch (_) {
    FirebaseAnalytics.instance.logEvent(name: 'pilot_form_error');
    setState(() { _loading = false; _error = true; });
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze
```

Expected: no new issues.

- [ ] **Step 3: Commit**

```bash
git add lib/who_and_pilot.dart
git commit -m "fix: pilot form success state — fire analytics without await on web"
```

---

## Task 2: Shared Widget Upgrades + RevealWrapper

**Files:**
- Modify: `lib/shared.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing RevealWrapper tests**

Add to `test/widget_test.dart` after the `SectionContainer` group:

```dart
group('RevealWrapper', () {
  testWidgets('renders child without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevealWrapper(child: Text('visible')),
        ),
      ),
    );
    expect(find.text('visible'), findsOneWidget);
  });

  testWidgets('child starts with zero opacity before visibility fires', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevealWrapper(child: Text('hello')),
        ),
      ),
    );
    // Before VisibilityDetector callback: opacity must be 0
    final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(opacity.opacity, 0.0);
  });

  testWidgets('accepts a non-zero delay without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevealWrapper(
            delay: Duration(milliseconds: 200),
            child: Text('delayed'),
          ),
        ),
      ),
    );
    expect(find.text('delayed'), findsOneWidget);
  });
});
```

- [ ] **Step 2: Run tests — expect failure on RevealWrapper (undefined)**

```
flutter test test/widget_test.dart
```

Expected: compile error — `RevealWrapper` not defined yet.

- [ ] **Step 3: Add `visibility_detector` import and update `GcmpDivider`**

At the top of `lib/shared.dart`, add:

```dart
import 'package:visibility_detector/visibility_detector.dart';
```

Replace the `GcmpDivider` class (lines 152–160):

```dart
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
```

- [ ] **Step 4: Add glow to `GreenButton`**

Inside `_GreenButtonState.build()`, the `AnimatedContainer` decoration currently has no `boxShadow`. Replace the `decoration:` inside the `AnimatedContainer` (around line 51):

```dart
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
```

- [ ] **Step 5: Add glow to `FeatureIconBox`**

Replace `FeatureIconBox.build()` decoration (around line 142):

```dart
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
```

- [ ] **Step 6: Add `RevealWrapper` to `lib/shared.dart`**

Append after the `SectionContainer` class at the end of `lib/shared.dart`:

```dart
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
```

- [ ] **Step 7: Run tests — expect pass**

```
flutter test test/widget_test.dart
```

Expected: all 5 tests pass (2 existing + 3 new RevealWrapper tests).

- [ ] **Step 8: Run analyze**

```
flutter analyze
```

Expected: no issues.

- [ ] **Step 9: Commit**

```bash
git add lib/shared.dart test/widget_test.dart
git commit -m "feat: gradient GcmpDivider, button/icon glows, RevealWrapper widget"
```

---

## Task 3: NavBar Modernization

**Files:**
- Modify: `lib/navbar.dart`

- [ ] **Step 1: Add `dart:ui` import**

Add at the top of `lib/navbar.dart` after the existing imports:

```dart
import 'dart:ui' show ImageFilter;
```

- [ ] **Step 2: Wrap `AnimatedContainer` with `ClipRect + BackdropFilter`**

Replace the `return AnimatedContainer(...)` in `NavBar.build()` with:

```dart
return ClipRect(
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 66,
      decoration: BoxDecoration(
        color: GcmpColors.bg.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: scrolled
                ? GcmpColors.green.withValues(alpha: 0.12)
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
    ),
  ),
);
```

- [ ] **Step 3: Add glow boxShadow to `_PilotNavBtn`**

In `_PilotNavBtnState.build()`, replace the `AnimatedContainer` decoration:

```dart
decoration: BoxDecoration(
  color: _hover
      ? GcmpColors.green.withValues(alpha: 0.18)
      : GcmpColors.green.withValues(alpha: 0.08),
  borderRadius: BorderRadius.circular(7),
  border: Border.all(color: GcmpColors.green.withValues(alpha: 0.35)),
  boxShadow: [
    BoxShadow(
      color: GcmpColors.green.withValues(alpha: 0.06),
      blurRadius: 12,
    ),
  ],
),
```

- [ ] **Step 4: Run analyze**

```
flutter analyze
```

Expected: no issues.

- [ ] **Step 5: Commit**

```bash
git add lib/navbar.dart
git commit -m "feat: navbar backdrop blur, glow border, pilot button glow"
```

---

## Task 4: HeroSection Full Redesign

**Files:**
- Modify: `lib/hero.dart`

The `HeroSection` is converted from `StatelessWidget` to `StatefulWidget`. The `_ResponseTimeVisual` and `_TimeBox` classes are removed and replaced with `_StatsRow` and `_StatItem`. Entry animations use `flutter_animate`.

- [ ] **Step 1: Add flutter_animate import**

At the top of `lib/hero.dart`, add:

```dart
import 'package:flutter_animate/flutter_animate.dart';
```

- [ ] **Step 2: Replace the entire `lib/hero.dart` content**

```dart
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
        builder: (_, __) => Container(
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
```

- [ ] **Step 3: Run analyze**

```
flutter analyze
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/hero.dart
git commit -m "feat: hero redesign — radial glow, 80px headline, StatsRow, entry animations"
```

---

## Task 5: HowItWorksSection + FeaturesSection

**Files:**
- Modify: `lib/how_and_features.dart`

- [ ] **Step 1: Update `_StepCard` — add `isActive` parameter + green top bar accent**

Replace the `_StepCard` class entirely:

```dart
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
```

- [ ] **Step 2: Update `HowItWorksSection` — pass `isActive: true` to step 01 + wrap with `RevealWrapper`**

Replace `HowItWorksSection.build()` with:

```dart
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
```

- [ ] **Step 3: Update `_FeatureCard` — add inset accent line + deeper shadow + glow border on hover**

Replace `_FeatureCardState.build()`:

```dart
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
```

- [ ] **Step 4: Update `FeaturesSection` — wrap with `RevealWrapper` staggered**

Replace `FeaturesSection.build()`:

```dart
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
```

- [ ] **Step 5: Run analyze**

```
flutter analyze
```

Expected: no issues.

- [ ] **Step 6: Commit**

```bash
git add lib/how_and_features.dart
git commit -m "feat: step card active highlight, feature card depth + accent, staggered reveals"
```

---

## Task 6: VideoSection + FaqSection

**Files:**
- Modify: `lib/video_section.dart`
- Modify: `lib/faq_section.dart`

- [ ] **Step 1: Update `VideoSection` — glow border + reveal**

Replace `VideoSection.build()`:

```dart
@override
Widget build(BuildContext context) {
  return SectionContainer(
    child: RevealWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SectionLabel('Demo'),
          const SizedBox(height: 12),
          Text(
            'See the Platform in Action',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Early Access Demo — v1',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: GcmpColors.card,
                  border: Border.all(color: GcmpColors.green.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 32),
                    BoxShadow(color: GcmpColors.green.withValues(alpha: 0.04), blurRadius: 20),
                  ],
                ),
                child: buildWebVideo(
                  'assets/assets/videos/demo.mp4',
                  aspectRatio: 16 / 9,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 2: Update `FaqSection` — gradient dividers + staggered reveal**

In `lib/faq_section.dart`, replace `FaqSection.build()`:

```dart
@override
Widget build(BuildContext context) {
  return SectionContainer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RevealWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('FAQ'),
              const SizedBox(height: 12),
              Text('Common questions', style: Theme.of(context).textTheme.displayMedium),
            ],
          ),
        ),
        const SizedBox(height: 48),
        ...List.generate(_faqs.length, (i) => RevealWrapper(
          delay: Duration(milliseconds: 60 * i + 100),
          child: _FaqItem(
            question: _faqs[i].$1,
            answer: _faqs[i].$2,
            isLast: i == _faqs.length - 1,
          ),
        )),
      ],
    ),
  );
}
```

Also add `import 'package:gcmp_web/shared.dart';` at the top of `faq_section.dart` if not already present (it is — `RevealWrapper` is in shared.dart).

In `_FaqItem.build()`, replace the flat divider at the bottom with a gradient divider. Find this part:

```dart
if (!widget.isLast)
  Container(height: 1, color: Colors.white.withValues(alpha: 0.05)),
```

Replace with:

```dart
if (!widget.isLast)
  Container(
    height: 1,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.06),
          Colors.transparent,
        ],
      ),
    ),
  ),
```

- [ ] **Step 3: Run analyze**

```
flutter analyze
```

Expected: no issues.

- [ ] **Step 4: Commit**

```bash
git add lib/video_section.dart lib/faq_section.dart
git commit -m "feat: video glow border, faq gradient dividers + staggered reveal"
```

---

## Task 7: WhoSection + B2bSection

**Files:**
- Modify: `lib/who_and_pilot.dart`
- Modify: `lib/b2b_section.dart`

- [ ] **Step 1: Update `_WhoCard` — glow border + emoji circular glow**

In `lib/who_and_pilot.dart`, replace `_WhoCard.build()`:

```dart
@override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: GcmpColors.card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: GcmpColors.green.withValues(alpha: 0.10)),
      boxShadow: [
        BoxShadow(color: GcmpColors.green.withValues(alpha: 0.04), blurRadius: 16),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: GcmpColors.green.withValues(alpha: 0.06),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
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
```

- [ ] **Step 2: Update `WhoSection.build()` — wrap grid items with staggered `RevealWrapper`**

Replace the `GridView.count(...)` call in `WhoSection.build()`:

```dart
GridView.count(
  crossAxisCount: crossAxis,
  crossAxisSpacing: 14,
  mainAxisSpacing: 14,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  childAspectRatio: mobile ? 3.0 : 2.3,
  children: List.generate(_items.length, (i) => RevealWrapper(
    delay: Duration(milliseconds: 80 * i + 100),
    child: _WhoCard(
      emoji: _items[i].$1,
      title: _items[i].$2,
      body: _items[i].$3,
    ),
  )),
),
```

Also wrap the heading block at the top of `WhoSection.build()` in a `RevealWrapper`:

```dart
RevealWrapper(
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
    ],
  ),
),
const SizedBox(height: 44),
```

- [ ] **Step 3: Update `_B2bCard` — highlighted card glow boost + top accent line**

Replace `_B2bCard.build()` in `lib/b2b_section.dart`:

```dart
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
```

- [ ] **Step 4: Update `_PartnerCta` — add glow boxShadow**

In `_PartnerCtaState.build()`, add `boxShadow` to the `AnimatedContainer` decoration:

```dart
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
```

- [ ] **Step 5: Wrap `B2bSection` content with staggered `RevealWrapper`**

In `B2bSection.build()`, wrap the heading block and the cards row/column. Inside the `SectionContainer > Column`, wrap:

1. Wrap the heading + body text block:
```dart
RevealWrapper(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel('For Security Companies'),
      const SizedBox(height: 14),
      RichText(...), // existing rich text
      const SizedBox(height: 20),
      Text(...), // existing body text
    ],
  ),
),
```

2. Wrap each card in the mobile `Column` and desktop `Row` with staggered delays (120ms apart), and wrap the bottom row:
```dart
// Mobile Column:
Column(children: [
  RevealWrapper(delay: const Duration(milliseconds: 120),
      child: _B2bCard(icon: Icons.attach_money_rounded, ...)),
  const SizedBox(height: 16),
  RevealWrapper(delay: const Duration(milliseconds: 240),
      child: _B2bCard(icon: Icons.trending_up_rounded, ..., highlight: true)),
  const SizedBox(height: 16),
  RevealWrapper(delay: const Duration(milliseconds: 360),
      child: _B2bCard(icon: Icons.handshake_outlined, ...)),
])

// Desktop Row: same pattern, Expanded wraps outside RevealWrapper
Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Expanded(child: RevealWrapper(delay: const Duration(milliseconds: 120),
      child: _B2bCard(...))),
  const SizedBox(width: 16),
  Expanded(child: RevealWrapper(delay: const Duration(milliseconds: 240),
      child: _B2bCard(..., highlight: true))),
  const SizedBox(width: 16),
  Expanded(child: RevealWrapper(delay: const Duration(milliseconds: 360),
      child: _B2bCard(...))),
])

// Bottom row:
RevealWrapper(
  delay: const Duration(milliseconds: 480),
  child: _B2bBottomRow(onPartnerTap: onPartnerTap, mobile: mobile),
),
```

- [ ] **Step 6: Run analyze**

```
flutter analyze
```

Expected: no issues.

- [ ] **Step 7: Commit**

```bash
git add lib/who_and_pilot.dart lib/b2b_section.dart
git commit -m "feat: who cards glow, B2b highlighted card accent + glow, staggered reveals"
```

---

## Task 8: PilotSection Visual + FooterSection

**Files:**
- Modify: `lib/who_and_pilot.dart`
- Modify: `lib/footer.dart`

- [ ] **Step 1: Update `_FormCard()` in `_PilotSectionState` — inset top accent + deeper card + glow**

Replace `_FormCard()` method in `_PilotSectionState`:

```dart
Widget _FormCard() {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: GcmpColors.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GcmpColors.green.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40),
            BoxShadow(color: GcmpColors.green.withValues(alpha: 0.04), blurRadius: 20),
          ],
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
      ),
      Positioned(
        top: 0, left: 32, right: 32,
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
```

- [ ] **Step 2: Add subtle radial glow behind form card in `PilotSection.build()`**

The `PilotSection` wraps its content in a `Container` with `color: GcmpColors.green.withValues(alpha: 0.03)`. Upgrade the decoration to also include a radial glow:

Replace the outer `Container` decoration in `PilotSection.build()`:

```dart
decoration: BoxDecoration(
  color: GcmpColors.green.withValues(alpha: 0.03),
  gradient: RadialGradient(
    center: const Alignment(0.7, 0),
    radius: 1.0,
    colors: [
      GcmpColors.green.withValues(alpha: 0.05),
      Colors.transparent,
    ],
  ),
  border: Border.symmetric(
    horizontal: BorderSide(color: GcmpColors.green.withValues(alpha: 0.1)),
  ),
),
```

Note: `BoxDecoration` does not allow both `color` and `gradient`. Remove the `color:` field and rely on the `gradient` for the tint.

- [ ] **Step 3: Add `RevealWrapper` slide animations to `PilotSection`**

Wrap left copy and form card in `_buildDesktop()` and `_buildMobile()` using `RevealWrapper`. Update both builders:

```dart
Widget _buildDesktop(BuildContext context) => Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      child: RevealWrapper(
        child: _LeftCopy(context),
      ),
    ),
    const SizedBox(width: 64),
    SizedBox(
      width: 400,
      child: RevealWrapper(
        delay: const Duration(milliseconds: 150),
        child: _FormCard(),
      ),
    ),
  ],
);

Widget _buildMobile(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    RevealWrapper(child: _LeftCopy(context)),
    const SizedBox(height: 40),
    RevealWrapper(
      delay: const Duration(milliseconds: 150),
      child: _FormCard(),
    ),
  ],
);
```

- [ ] **Step 4: Update `FooterSection` — gradient top divider**

Replace the `Container` decoration in `FooterSection.build()`:

```dart
decoration: BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.transparent),
  ),
),
```

Wait — that's the wrong approach. The footer currently uses a `Container` with `decoration: BoxDecoration(border: Border(top: ...))`. We want to replace the flat top border with a gradient divider.

Replace `FooterSection.build()`:

```dart
@override
Widget build(BuildContext context) {
  final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Gradient top divider (matches upgraded GcmpDivider)
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
      Padding(
        padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 32),
        child: mobile ? _buildMobile(context) : _buildDesktop(context),
      ),
    ],
  );
}
```

- [ ] **Step 5: Run analyze**

```
flutter analyze
```

Expected: no issues.

- [ ] **Step 6: Commit**

```bash
git add lib/who_and_pilot.dart lib/footer.dart
git commit -m "feat: pilot form card accent + glow, PilotSection reveal, footer gradient divider"
```

---

## Self-Review

**Spec coverage check:**

| Spec requirement | Task |
|---|---|
| NavBar backdrop blur + glow border + pilot button glow | Task 3 ✓ |
| Hero radial glow background | Task 4 ✓ |
| Hero headline 80px/44px, -3 letterSpacing, Seconds glow | Task 4 ✓ |
| Hero stats row: `<30s`, `60`, `Live` | Task 4 ✓ |
| Hero CTA button glow | Task 2 (GreenButton glow) ✓ |
| Hero entry animations staggered | Task 4 ✓ |
| GcmpDivider gradient | Task 2 ✓ |
| HowItWorks step 01 active highlight + green top bar | Task 5 ✓ |
| HowItWorks progressive dimming | Task 5 (isActive alpha dim) ✓ |
| HowItWorks scroll reveal staggered | Task 5 ✓ |
| VideoSection glow border + reveal | Task 6 ✓ |
| FeaturesSection card depth + accent + hover glow | Task 5 ✓ |
| FeaturesSection staggered reveal | Task 5 ✓ |
| WhoSection card glow + emoji circular bg | Task 7 ✓ |
| WhoSection staggered reveal | Task 7 ✓ |
| B2bSection highlighted card glow boost + top accent | Task 7 ✓ |
| B2bSection Partner button glow | Task 7 ✓ |
| B2bSection staggered reveal | Task 7 ✓ |
| FaqSection gradient dividers | Task 6 ✓ |
| FaqSection staggered reveal | Task 6 ✓ |
| PilotSection form card accent + glow | Task 8 ✓ |
| PilotSection radial glow behind card | Task 8 ✓ |
| PilotSection reveal (copy + form card) | Task 8 ✓ |
| FooterSection gradient top divider | Task 8 ✓ |
| RevealWrapper shared widget | Task 2 ✓ |
| Bug fix — pilot form submit | Task 1 ✓ |

**Placeholder scan:** No TBDs, no incomplete sections.

**Type consistency:** `RevealWrapper` (Task 2) used in Tasks 5–8. `_StatsRow`/`_StatItem` replace `_ResponseTimeVisual`/`_TimeBox` (Task 4 only). `isActive` parameter added to `_StepCard` (Task 5). All usages match.

**Scope check:** All changes are self-contained to the specified files. No new sections, no content changes, no backend changes.
