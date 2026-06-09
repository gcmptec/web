# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app (defaults to connected device/browser)
flutter run -d chrome    # Run specifically in Chrome
flutter build web        # Build for web (output: build/web/)
flutter analyze          # Lint (uses flutter_lints via analysis_options.yaml)
flutter test             # Run tests
flutter test test/widget_test.dart  # Run a single test file
```

## Architecture

This is a Flutter multi-platform project targeting web, iOS, Android, Windows, Linux, and macOS.

**Entry point:** `lib/main.dart` — defines the `MaterialApp` widget tree. All Dart application code lives under `lib/`.

**Web shell:** `web/index.html` loads `flutter_bootstrap.js`, which bootstraps the compiled Dart-to-JS output. `web/manifest.json` configures PWA metadata.

**Lint config:** `analysis_options.yaml` extends `package:flutter_lints/flutter.yaml`. Run `flutter analyze` to check for issues before committing.

The project currently has a single screen (Hello World scaffold) in `lib/main.dart`.
