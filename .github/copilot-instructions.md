# GitHub Copilot / AI Agent Instructions for MediscribeApp

Purpose: short, actionable guidance for AI coding agents working on this repo. Keep changes small and testable; prefer incremental edits and add or update tests that cover behavior changes.

## Project overview
- This is a Flutter application located in `mediscribe_app/` (mobile + desktop + web targets). The Flutter entrypoint is `mediscribe_app/lib/main.dart`.
- Platform folders: `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`. Most CI/build tasks should operate from the `mediscribe_app/` directory.

## Key files to inspect when making changes
- `mediscribe_app/pubspec.yaml` — dependencies, versioning, assets.
- `mediscribe_app/lib/main.dart` — app entrypoint and top-level widget hierarchy.
- `mediscribe_app/test/widget_test.dart` — example widget test; use this as a template for new widget tests.
- `mediscribe_app/android/` and `mediscribe_app/ios/` — native platform integration; be careful changing Gradle or Xcode project files as they may affect CI and local builds.

## Build & test workflows (commands)
Run these from `mediscribe_app/`:
- Install dependencies: `flutter pub get`
- Run app (device/emulator): `flutter run` (or `flutter run -d <device-id>`)
- Build app:
  - Android (debug): `flutter build apk`
  - iOS (archive): `flutter build ipa` (requires macOS & Xcode)
  - Web: `flutter build web`
  - Windows/Linux/macOS: `flutter build <windows|linux|macos>`
- Run tests: `flutter test`
- Format code: `dart format .`
- Analyze: `flutter analyze`

If a change touches native code (Gradle, CocoaPods, CMake), mention this in the PR and include platform-specific verification steps.

## Testing guidance
- Add tests under `mediscribe_app/test/` and follow patterns in `widget_test.dart`.
- Prefer small, focused tests that validate UI stateful behavior and logic.
- When adding behavior changes, include at least one test that would fail before the change.

## Code conventions & patterns observed
- Project uses default Flutter starter layout and idioms (Material, `StatefulWidget`/`StatelessWidget`).
- Naming conventions: camelCase for Dart identifiers; widget classes start with an uppercase.
- Keep UI logic in widgets; extract business logic to separate classes or providers if it grows.

## Integration points / external dependencies
- No third-party backend dependencies detected in the repo. If integrating external services (APIs, Firebase, OAuth), add configuration examples in `README.md` and update `.gitignore` for secrets.
- Android local properties like `local.properties` (SDK path) and iOS signing settings are environment-specific — do not commit credentials.

## PR guidance for AI agents
- Keep changes narrowly scoped; prefer multiple follow-up PRs over one large PR.
- Include a short description of the intent and why the change is needed.
- Run `flutter test`, `dart format`, and `flutter analyze` locally; include results in PR description if relevant.
- If touching platform code, list manual verification steps (which platforms were tested and how).

## Examples and concrete pointers
- To add a new widget, place it under `lib/`, create a unit/widget test in `test/`, and add an example usage in `lib/main.dart` or a relevant screen.
- For dependency updates, update `pubspec.yaml`, run `flutter pub get`, and run `flutter test` to ensure there are no regressions.

## Known gaps & notes for maintainers
- No CI workflows detected (no `.github/workflows/`); recommend adding a GitHub Actions workflow that runs `flutter test`, `flutter analyze`, and `dart format --set-exit-if-changed .` on PRs.
- There's currently no `assets/` or environment config; document any future external service config in `mediscribe_app/README.md`.

---

If this looks good I can squash this into a more compact `20–30` lines summary or expand sections with specific PR/CI examples. What do you want me to refine or add?  
(Examples I can add: a sample GitHub Actions workflow, a test template, or a checklist for releasing builds.)
