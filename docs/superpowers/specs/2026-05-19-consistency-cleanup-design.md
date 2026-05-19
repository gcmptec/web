# Design: Visual Consistency Cleanup

**Date:** 2026-05-19
**Scope:** Token cleanup (A) + SectionContainer widget (B)
**Goal:** Eliminate repeated magic values and layout patterns across all landing page sections without any visual change to the user.

---

## Option A — Token Cleanup

### 1. Mobile breakpoint constant
- Add `static const kMobile = 768.0` to `GcmpColors` in `lib/theme.dart`
- Replace all hardcoded `< 768` comparisons across: `hero.dart`, `navbar.dart`, `who_and_pilot.dart`, `how_and_features.dart`, `b2b_section.dart`, `faq_section.dart`

### 2. Hardcoded red color
- `const Color(0xFFEF4444)` appears in `hero.dart` (response time box) and `who_and_pilot.dart` (pilot badge, error state)
- Replace all instances with `GcmpColors.red` (already defined in theme, currently unused)

### 3. Deprecated `withOpacity` → `withValues(alpha:)`
- `withOpacity` is deprecated in Flutter 3.x
- ~30 call sites across all lib files
- Mechanical replacement, no visual change

### 4. Deduplicate `_scrollTo`
- Identical private method exists in both `lib/main.dart` and `lib/navbar.dart`
- Move to a static helper in `lib/shared.dart`:
  ```dart
  class ScrollHelper {
    static void to(GlobalKey key) {
      final ctx = key.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx,
            duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    }
  }
  ```
- Update both call sites to use `ScrollHelper.to(key)`

---

## Option B — SectionContainer Widget

### New widget in `lib/shared.dart`
```dart
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
```

### Adoption sites
| File | Section | Notes |
|---|---|---|
| `who_and_pilot.dart` | `WhoSection` | Replace outer `Container` padding |
| `how_and_features.dart` | `HowItWorksSection`, `FeaturesSection` | Replace outer padding |
| `b2b_section.dart` | `B2bSection` | Replace outer padding |
| `faq_section.dart` | `FaqSection` | Replace outer padding |
| `who_and_pilot.dart` | `PilotSection` | Keep outer `Container` for background color; wrap inner `Column` content only |

### Exclusions
- `HeroSection` — uses asymmetric vertical padding (56 mobile / 96 desktop), stays as-is
- `NavBar` — fixed height bar, not a content section
- `FooterSection` — has its own distinct layout

---

## Out of scope
- Any visual redesign
- Animation changes
- New features or sections
- Theme-first text style refactor (Option C — deferred)
