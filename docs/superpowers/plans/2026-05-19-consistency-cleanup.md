# Consistency Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate repeated magic values and layout patterns across all landing page sections without any visual change to the user.

**Architecture:** Four token fixes (breakpoint constant, red color alias, withOpacity deprecation, scroll helper deduplication) followed by a shared `SectionContainer` widget adopted across five section files.

**Tech Stack:** Flutter/Dart, `lib/theme.dart` for constants, `lib/shared.dart` for shared widgets/helpers.

---

## File Map

| File | Change |
|---|---|
| `lib/theme.dart` | Add `kMobile = 768.0` constant to `GcmpColors` |
| `lib/shared.dart` | Add `ScrollHelper`, `SectionContainer`; fix `withOpacity` (11 sites) |
| `lib/main.dart` | Use `ScrollHelper.to`, `GcmpColors.kMobile` |
| `lib/navbar.dart` | Use `ScrollHelper.to`, `GcmpColors.kMobile`; fix `withOpacity` (8 sites) |
| `lib/hero.dart` | Use `GcmpColors.red`, `GcmpColors.kMobile`; fix `withOpacity` (5 sites) |
| `lib/how_and_features.dart` | Use `GcmpColors.kMobile`, `SectionContainer`; fix `withOpacity` (6 sites) |
| `lib/who_and_pilot.dart` | Use `GcmpColors.red`, `GcmpColors.kMobile`, `SectionContainer`; fix `withOpacity` (18 sites) |
| `lib/b2b_section.dart` | Use `GcmpColors.kMobile`, `SectionContainer`; fix `withOpacity` (8 sites) |
| `lib/faq_section.dart` | Use `SectionContainer`; fix `withOpacity` (1 site) |
| `lib/video_section.dart` | Fix `withOpacity` (1 site) |
| `lib/footer.dart` | Fix `withOpacity` (2 sites) |
| `test/widget_test.dart` | Create — tests for `ScrollHelper` and `SectionContainer` |

---

## Task 1: Add `kMobile` breakpoint constant

**Files:**
- Modify: `lib/theme.dart`
- Modify: `lib/hero.dart`
- Modify: `lib/navbar.dart`
- Modify: `lib/how_and_features.dart`
- Modify: `lib/who_and_pilot.dart`
- Modify: `lib/b2b_section.dart`
- Modify: `lib/faq_section.dart`

- [ ] **Step 1: Add the constant to `GcmpColors` in `lib/theme.dart`**

  In `lib/theme.dart`, add one line inside `GcmpColors`:

  ```dart
  class GcmpColors {
    static const bg = Color(0xFF0E0E1C);
    static const surface = Color(0xFF13131F);
    static const card = Color(0xFF16162A);
    static const border = Color(0xFF1F1F35);
    static const green = Color(0xFF00FF94);
    static const greenDim = Color(0xFF00CC76);
    static const greenFaint = Color(0xFF003D24);
    static const red = Color(0xFFEF4444);
    static const textPrimary = Color(0xFFE8F0FF);
    static const textSecondary = Color(0xFF7D92B8);
    static const textMuted = Color(0xFF4A5E7A);
    static const kMobile = 768.0;   // ← add this line
  }
  ```

- [ ] **Step 2: Replace all hardcoded `768` breakpoint references**

  Run this PowerShell command from the project root:

  ```powershell
  Get-ChildItem lib -Filter *.dart -Recurse | ForEach-Object {
      $content = Get-Content $_.FullName -Raw
      $updated = $content -replace '\.width < 768\b', '.width < GcmpColors.kMobile'
      if ($content -ne $updated) {
          Set-Content $_.FullName $updated -Encoding utf8
          Write-Host "Updated: $($_.Name)"
      }
  }
  ```

  Expected output:
  ```
  Updated: hero.dart
  Updated: navbar.dart
  Updated: how_and_features.dart
  Updated: who_and_pilot.dart
  Updated: b2b_section.dart
  Updated: faq_section.dart
  ```

- [ ] **Step 3: Verify**

  ```
  flutter analyze
  ```

  Expected: no new errors or warnings.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/theme.dart lib/hero.dart lib/navbar.dart lib/how_and_features.dart lib/who_and_pilot.dart lib/b2b_section.dart lib/faq_section.dart
  git commit -m "refactor: extract kMobile breakpoint constant"
  ```

---

## Task 2: Replace hardcoded red with `GcmpColors.red`

**Files:**
- Modify: `lib/hero.dart`
- Modify: `lib/who_and_pilot.dart`

- [ ] **Step 1: Bulk replace in both files**

  Run this PowerShell command from the project root. It handles both `const Color(0xFFEF4444)` and bare `Color(0xFFEF4444)` (the icon constructor uses the latter):

  ```powershell
  'lib/hero.dart', 'lib/who_and_pilot.dart' | ForEach-Object {
      $content = Get-Content $_ -Raw
      $updated = $content -replace 'const Color\(0xFFEF4444\)', 'GcmpColors.red'
      $updated = $updated -replace '\bColor\(0xFFEF4444\)', 'GcmpColors.red'
      if ($content -ne $updated) {
          Set-Content $_ $updated -Encoding utf8
          Write-Host "Updated: $_"
      }
  }
  ```

  Expected output:
  ```
  Updated: lib/hero.dart
  Updated: lib/who_and_pilot.dart
  ```

  This replaces 2 occurrences in `hero.dart` and 7 in `who_and_pilot.dart` (badge background/border/text, error container background/border, error icon, error text).

- [ ] **Step 3: Verify**

  ```
  flutter analyze
  ```

  Expected: no errors.

- [ ] **Step 4: Commit**

  ```bash
  git add lib/hero.dart lib/who_and_pilot.dart
  git commit -m "refactor: replace hardcoded red with GcmpColors.red"
  ```

---

## Task 3: Replace deprecated `withOpacity` → `withValues(alpha:)`

**Files:** All 9 files in `lib/` (60 occurrences total)

- [ ] **Step 1: Bulk replace across all lib files**

  Run this PowerShell command from the project root:

  ```powershell
  Get-ChildItem lib -Filter *.dart -Recurse | ForEach-Object {
      $content = Get-Content $_.FullName -Raw
      $updated = $content -replace '\.withOpacity\(', '.withValues(alpha: '
      if ($content -ne $updated) {
          Set-Content $_.FullName $updated -Encoding utf8
          Write-Host "Updated: $($_.Name)"
      }
  }
  ```

  Expected output (9 files):
  ```
  Updated: how_and_features.dart
  Updated: who_and_pilot.dart
  Updated: faq_section.dart
  Updated: hero.dart
  Updated: video_section.dart
  Updated: footer.dart
  Updated: navbar.dart
  Updated: shared.dart
  Updated: b2b_section.dart
  ```

- [ ] **Step 2: Verify**

  ```
  flutter analyze
  ```

  Expected: no errors. `withValues` is available since Flutter 3.27 — this project's SDK constraint (`^3.11.1`) covers it.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/
  git commit -m "refactor: replace deprecated withOpacity with withValues(alpha:)"
  ```

---

## Task 4: Extract `ScrollHelper` to `shared.dart`

**Files:**
- Modify: `lib/shared.dart`
- Modify: `lib/main.dart`
- Modify: `lib/navbar.dart`
- Create: `test/widget_test.dart`

- [ ] **Step 1: Write the failing test**

  Create `test/widget_test.dart`:

  ```dart
  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:gcmp_web/shared.dart';

  void main() {
    group('ScrollHelper', () {
      test('to() with unmounted key does not throw', () {
        final key = GlobalKey();
        // key has no context (never mounted) — should be a silent no-op
        expect(() => ScrollHelper.to(key), returnsNormally);
      });
    });

    group('SectionContainer', () {
      testWidgets('applies 80px vertical and 24px horizontal padding on narrow screen',
          (tester) async {
        tester.view.physicalSize = const Size(375, 812);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SectionContainer(child: Text('test')),
            ),
          ),
        );

        final padding = tester.widget<Padding>(find.byType(Padding).first);
        final insets = padding.padding as EdgeInsets;
        expect(insets.top, 80.0);
        expect(insets.bottom, 80.0);
        expect(insets.left, 24.0);
        expect(insets.right, 24.0);
      });
    });
  }
  ```

- [ ] **Step 2: Run test — expect failures**

  ```
  flutter test test/widget_test.dart
  ```

  Expected: both tests fail — `ScrollHelper` and `SectionContainer` don't exist yet.

- [ ] **Step 3: Add `ScrollHelper` to `lib/shared.dart`**

  Append to the bottom of `lib/shared.dart`:

  ```dart
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
  ```

- [ ] **Step 4: Run the ScrollHelper test — expect it to pass**

  ```
  flutter test test/widget_test.dart --name "to\(\) with unmounted"
  ```

  Expected: PASS.

- [ ] **Step 5: Remove `_scrollTo` from `lib/main.dart` and use `ScrollHelper.to`**

  Delete lines 68–74 in `lib/main.dart` (the `_scrollTo` method):
  ```dart
  // DELETE this method:
  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }
  ```

  Replace the three call sites in `lib/main.dart`:
  ```dart
  // Before
  onPilotTap: () {
    FirebaseAnalytics.instance.logEvent(name: 'hero_pilot_cta_tap');
    _scrollTo(_pilotKey);
  },
  onHowTap: () => _scrollTo(_howKey),
  // ...
  B2bSection(onPartnerTap: () {
    FirebaseAnalytics.instance.logEvent(name: 'partner_cta_tap');
    _scrollTo(_pilotKey);
  }),

  // After
  onPilotTap: () {
    FirebaseAnalytics.instance.logEvent(name: 'hero_pilot_cta_tap');
    ScrollHelper.to(_pilotKey);
  },
  onHowTap: () => ScrollHelper.to(_howKey),
  // ...
  B2bSection(onPartnerTap: () {
    FirebaseAnalytics.instance.logEvent(name: 'partner_cta_tap');
    ScrollHelper.to(_pilotKey);
  }),
  ```

- [ ] **Step 6: Remove `_scrollTo` from `lib/navbar.dart` and use `ScrollHelper.to`**

  Delete lines 21–27 in `lib/navbar.dart` (the `_scrollTo` method):
  ```dart
  // DELETE this method:
  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }
  ```

  Replace all five call sites in `NavBar.build`:
  ```dart
  // Before
  _NavLink('How It Works', () => _scrollTo(howKey)),
  _NavLink('Platform', () => _scrollTo(featuresKey)),
  _NavLink('Who It\'s For', () => _scrollTo(whoKey)),
  _NavLink('For Partners', () => _scrollTo(b2bKey)),
  _PilotNavBtn(onTap: () => _scrollTo(pilotKey)),

  // After
  _NavLink('How It Works', () => ScrollHelper.to(howKey)),
  _NavLink('Platform', () => ScrollHelper.to(featuresKey)),
  _NavLink('Who It\'s For', () => ScrollHelper.to(whoKey)),
  _NavLink('For Partners', () => ScrollHelper.to(b2bKey)),
  _PilotNavBtn(onTap: () => ScrollHelper.to(pilotKey)),
  ```

- [ ] **Step 7: Verify**

  ```
  flutter analyze
  ```

  Expected: no errors.

- [ ] **Step 8: Commit**

  ```bash
  git add lib/shared.dart lib/main.dart lib/navbar.dart test/widget_test.dart
  git commit -m "refactor: extract ScrollHelper, remove duplicated _scrollTo"
  ```

---

## Task 5: Add `SectionContainer` widget

**Files:**
- Modify: `lib/shared.dart`

- [ ] **Step 1: Add `SectionContainer` to `lib/shared.dart`**

  Append after `ScrollHelper` at the bottom of `lib/shared.dart`:

  ```dart
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
  ```

- [ ] **Step 2: Run all tests — expect both to pass**

  ```
  flutter test test/widget_test.dart
  ```

  Expected: both tests PASS.

- [ ] **Step 3: Commit**

  ```bash
  git add lib/shared.dart test/widget_test.dart
  git commit -m "feat: add SectionContainer shared widget"
  ```

---

## Task 6: Adopt `SectionContainer` in all sections

**Files:**
- Modify: `lib/how_and_features.dart`
- Modify: `lib/faq_section.dart`
- Modify: `lib/who_and_pilot.dart`
- Modify: `lib/b2b_section.dart`

### `HowItWorksSection` in `lib/how_and_features.dart`

- [ ] **Step 1: Replace outer `Container` with `SectionContainer`**

  `HowItWorksSection.build` currently returns a `Container` with padding. Replace:

  ```dart
  // Before
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ ... ],
      ),
    );
  }

  // After
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ ... ],
      ),
    );
  }
  ```

  `mobile` stays — it's still needed for the Column vs Row card layout inside.

### `FeaturesSection` in `lib/how_and_features.dart`

- [ ] **Step 2: Replace outer `Container` with `SectionContainer`**

  Same pattern as above. `FeaturesSection.build`:

  ```dart
  // Before
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: Column( ... ),
    );
  }

  // After
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return SectionContainer(
      child: Column( ... ),
    );
  }
  ```

### `FaqSection` in `lib/faq_section.dart`

- [ ] **Step 3: Replace outer `Container` with `SectionContainer` and remove `mobile`**

  `FaqSection` uses `mobile` only for padding — after this change `mobile` is unused and can be removed:

  ```dart
  // Before
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ ... ],
      ),
    );
  }

  // After
  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ ... ],
      ),
    );
  }
  ```

### `WhoSection` in `lib/who_and_pilot.dart`

- [ ] **Step 4: Replace outer `Container` with `SectionContainer`**

  ```dart
  // Before
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < GcmpColors.kMobile;
    final crossAxis = mobile ? 1 : (width < 1024 ? 2 : 3);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: Column( ... ),
    );
  }

  // After
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < GcmpColors.kMobile;
    final crossAxis = mobile ? 1 : (width < 1024 ? 2 : 3);
    return SectionContainer(
      child: Column( ... ),
    );
  }
  ```

### `PilotSection` in `lib/who_and_pilot.dart`

- [ ] **Step 5: Keep outer `Container` for decoration; use `SectionContainer` for inner padding**

  `PilotSection` has a background color and border on its outer container. Keep the outer `Container` for decoration only (remove its `padding`), and wrap the inner content with `SectionContainer`:

  ```dart
  // Before
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      decoration: BoxDecoration(
        color: GcmpColors.green.withValues(alpha: 0.03),
        border: Border.symmetric(
          horizontal: BorderSide(color: GcmpColors.green.withValues(alpha: 0.1)),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: mobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  // After
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < GcmpColors.kMobile;
    return Container(
      decoration: BoxDecoration(
        color: GcmpColors.green.withValues(alpha: 0.03),
        border: Border.symmetric(
          horizontal: BorderSide(color: GcmpColors.green.withValues(alpha: 0.1)),
        ),
      ),
      child: SectionContainer(
        child: mobile ? _buildMobile(context) : _buildDesktop(context),
      ),
    );
  }
  ```

### `B2bSection` in `lib/b2b_section.dart`

- [ ] **Step 6: Keep outer `Container` for decoration; use `SectionContainer` for inner padding**

  Same pattern as `PilotSection` — `B2bSection` has a `surface` background color and border:

  ```dart
  // Before
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
      padding: EdgeInsets.symmetric(vertical: 80, horizontal: mobile ? 24 : 64),
      child: Column( ... ),
    );
  }

  // After
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
        child: Column( ... ),
      ),
    );
  }
  ```

- [ ] **Step 7: Verify all changes**

  ```
  flutter analyze
  flutter test test/widget_test.dart
  ```

  Expected: analyze clean, both tests pass.

- [ ] **Step 8: Commit**

  ```bash
  git add lib/how_and_features.dart lib/faq_section.dart lib/who_and_pilot.dart lib/b2b_section.dart
  git commit -m "refactor: adopt SectionContainer across all landing page sections"
  ```
