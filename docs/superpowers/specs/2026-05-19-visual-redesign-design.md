# Design: Full Visual Redesign — Intelligent Security Brand

**Date:** 2026-05-19
**Scope:** Full page visual overhaul — Evolved GCMP direction with scroll-reveal animations
**Goal:** Modernise the GCMP landing page to feel like a premium "Intelligent Security" product — keeping the green + dark brand DNA but adding depth, glow, motion, and a redesigned hero.

---

## Direction: Evolved GCMP

Keep existing brand identity (dark navy background, `#00FF94` green, Inter font) but elevate significantly:
- Radial glow backgrounds and layered depth
- Glassmorphism card treatment (backdrop blur, inset accent lines, glow borders)
- Scroll-reveal animations on every section using `flutter_animate` + `visibility_detector` (already in pubspec)
- Gradient section transitions replacing flat 1px dividers
- Redesigned hero with stats row and larger headline

---

## Section-by-Section Changes

### NavBar (`lib/navbar.dart`)
- Add `backdropFilter: blur(12px)` to nav container
- Tighten background opacity: `GcmpColors.bg.withValues(alpha: 0.85)` at all times (currently varies)
- Add glow border variant when scrolled: `rgba(0,255,148,0.12)` instead of flat border
- Pilot button: add `boxShadow` with `rgba(0,255,148,0.06)` outer glow

### HeroSection (`lib/hero.dart`)
- **Radial glow background:** Two positioned radial gradients behind content — large green glow centred top, smaller blue-tinted glow top-right
- **Headline:** Increase font size to ~80px desktop / 44px mobile, tighten `letterSpacing` to -3px, add `textShadow`-equivalent glow on the green "Seconds" word using a `Stack` + blur approach or `flutter_animate` shimmer
- **Stats row:** Replace `_ResponseTimeVisual` (Hours → Seconds comparison boxes) with a three-column stats strip: `<30s First Alert`, `60 Day Free Pilot`, `Live Scene Context` — styled with subtle border, dark background, green numbers with glow
- **CTA button:** Add `boxShadow` glow `rgba(0,255,148,0.25)` to `GreenButton`
- **Scroll-reveal:** Badge fades in → headline slides up → body fades → buttons fade → stats rise

### GcmpDivider (`lib/shared.dart`)
- Replace flat `color: Colors.white.withValues(alpha: 0.05)` with a gradient divider:
  - 1px height, `LinearGradient`: `transparent → rgba(0,255,148,0.15) → transparent`
  - 8px `Container` below with `LinearGradient` top-to-bottom fade: `rgba(0,255,148,0.03) → transparent`

### HowItWorksSection (`lib/how_and_features.dart`)
- **Step cards:** Add green top-bar accent on the first/active card (`LinearGradient` 2px bar)
- **Active step highlight:** First card gets full green border + glow; others progressively dimmer
- **Card background:** Subtle `backdrop-filter`-equivalent using layered `Container` with `GcmpColors.card` + gradient overlay
- **Scroll-reveal:** Section label slides left → heading fades up → step cards rise staggered (120ms apart)

### VideoSection (`lib/video_section.dart`)
- Add rounded container with `border: rgba(0,255,148,0.12)` and `boxShadow` depth around the video element
- **Scroll-reveal:** Container fades + scales from 0.97 → 1.0

### FeaturesSection (`lib/how_and_features.dart`)
- **Card depth:** Add inset top accent line (`LinearGradient` positioned at top of card), increase border opacity on hover to `rgba(0,255,148,0.3)`, add `boxShadow` with `rgba(0,0,0,0.4)` + inner glow
- Radial glow behind each card's icon box
- **Scroll-reveal:** Heading fades up → cards fade + rise staggered (150ms apart)

### WhoSection (`lib/who_and_pilot.dart`)
- **Who-cards:** Upgrade border to `rgba(0,255,148,0.1)` with glow `boxShadow`, emoji gets a small circular glow background
- **Scroll-reveal:** Grid items rise staggered (80ms apart)

### B2bSection (`lib/b2b_section.dart`)
- **Highlighted card:** Increase glow: `boxShadow: 0 0 32px rgba(0,255,148,0.12)`; add top accent line
- **Bottom CTA row:** Add border glow on Partner button
- **Scroll-reveal:** Cards staggered 120ms, bottom row fades in last

### FaqSection (`lib/faq_section.dart`)
- **Item dividers:** Replace flat `Colors.white.withValues(alpha: 0.05)` with gradient fade
- **Scroll-reveal:** Items fade in staggered 60ms apart

### PilotSection (`lib/who_and_pilot.dart`)
- **Form card:** Add inset top accent line (green gradient), focused field gets green glow ring (`boxShadow: 0 0 0 3px rgba(0,255,148,0.08)`), button glow
- **Background section:** Keep green tint bg, add subtle radial glow behind the form card
- **Scroll-reveal:** Left copy slides right, form card slides left, both fade in

### FooterSection (`lib/footer.dart`)
- Add top gradient divider (same as GcmpDivider upgrade)
- Subtle background shift: `GcmpColors.surface` with a touch more depth

---

## Scroll-Reveal Animation System

**Implementation:** `visibility_detector` + `flutter_animate` — both already in `pubspec.yaml`.

**Pattern for each section:**
```dart
VisibilityDetector(
  key: Key('section-id'),
  onVisibilityChanged: (info) {
    if (info.visibleFraction > 0.1 && !_visible) {
      setState(() => _visible = true);
    }
  },
  child: AnimatedOpacity(/* or flutter_animate */),
)
```

**Animation specs:**
| Element | Effect | Duration | Delay |
|---|---|---|---|
| Section label | Slide in from left + fade | 300ms | 0ms |
| Heading | Fade + slide up 16px | 400ms | 80ms |
| Body text | Fade | 350ms | 160ms |
| Buttons | Fade + slide up 8px | 300ms | 240ms |
| Cards (grid) | Fade + rise 20px | 400ms | 120ms × index |
| Stats row | Fade + rise | 400ms | 300ms |

**One-time only:** Each section tracks a `_visible` bool in state. Once `true`, never resets. Animations play once per page load.

**Shared widget:** Extract `RevealWrapper` to `lib/shared.dart` — wraps any child with the standard fade+rise behaviour, accepting `delay` parameter.

---

## New / Modified Shared Widgets (`lib/shared.dart`)

| Widget | Change |
|---|---|
| `GcmpDivider` | Gradient version (green fade + 8px glow strip) |
| `GreenButton` | Add `boxShadow` glow |
| `FeatureIconBox` | Add outer glow `boxShadow` |
| `RevealWrapper` | **New** — scroll-triggered fade+rise animation |

---

## Theme Changes (`lib/theme.dart`)

No color changes. `GcmpColors` stays identical. No new dependencies required.

---

---

## Bug Fix: Pilot Form Submit Shows No Success State

**File:** `lib/who_and_pilot.dart` — `_submitForm()`

**Symptom:** Clicking submit writes data to Firestore correctly but the success state never appears. The form just freezes.

**Root cause:** `FirebaseAnalytics.instance.logEvent()` throws on Flutter web (same Pigeon/null issue as fixed in commit `46e8a06`). The exception is caught by the outer `catch` block, which sets `_error = true` and never sets `_submitted = true`.

**Fix:** Set `_submitted = true` immediately after the Firestore write succeeds, before the analytics call. Fire analytics without `await` so it cannot block or break the UX:

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
    setState(() { _submitted = true; _loading = false; });         // ← move here
    FirebaseAnalytics.instance.logEvent(name: 'pilot_form_success'); // ← fire and forget
  } catch (_) {
    FirebaseAnalytics.instance.logEvent(name: 'pilot_form_error');   // ← fire and forget
    setState(() { _loading = false; _error = true; });
  }
}
```

---

## Out of Scope
- Content or copy changes
- New sections
- Mobile layout restructuring (mobile responsiveness carries over from existing code)
- Any backend / Firebase changes
