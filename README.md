# MediscribeApp

Mediscribe is an AI-powered Flutter application that converts images of handwritten or printed medical prescriptions into readable, structured text. It uses on-device OCR (Google ML Kit) to extract text from images and the Google Generative Language (Gemini) API to extract medicine names, dosages, and instructions.

---

## 🚀 Key features
- Upload prescription images from Camera or Gallery (with optional compression)
- On-device OCR using `google_mlkit_text_recognition` (`OcrService`)
- Structured extraction using Google Gemini (`GeminiService`) with a focused prompt
- Medicine highlighting heuristic (`MedicineHighlighter` / UI highlighting)
- Export results to PDF (`PdfService`) and share via system share sheet

---

## 📁 Repository layout (important places)
- `mediscribe_app/` — main Flutter app
  - `lib/main.dart` — app initialization (loads `assets/.env`)
  - `lib/screens/` — UI screens (`login_screen`, `home_screen`, `upload_screen`, `processing_screen`, `result_screen`)
  - `lib/services/` — `ocr_service.dart`, `gemini_text_services.dart`, `pdf_service.dart`
  - `lib/utils/` — `medicine_highlighter.dart`
  - `test/` — widget/unit tests (see `widget_test.dart`)
- `.github/copilot-instructions.md` — guidance for AI coding agents

---

## ▶️ Quick start (developer)
Prerequisites: Flutter SDK, Android SDK (and Xcode for iOS builds on macOS).

From the project root run:

```bash
cd mediscribe_app
flutter pub get
flutter run            # runs on connected device or emulator
flutter test           # run unit/widget tests
flutter analyze        # static analysis
dart format .          # code formatting
```

Builds:
- Android: `flutter build apk`
- iOS: `flutter build ipa` (macOS only)
- Web: `flutter build web`
- Desktop: `flutter build <windows|linux|macos>`

---

## 🔐 Environment & secrets
- The app uses `flutter_dotenv` and expects `GEMINI_API_KEY` to be available in `assets/.env` (loaded in `lib/main.dart`).
- **Important:** `assets/.env` must NOT contain real API keys in a public repository. If keys are currently committed, rotate them immediately and replace `assets/.env` content with placeholders.
- Recommended: Add `assets/.env` to `.gitignore` and commit `assets/.env.example` containing:

```env
GEMINI_API_KEY=YOUR_API_KEY_HERE
```

In CI, inject the secret into the environment and write `assets/.env` at workflow time before building.

---

## 🧪 Testing & CI
- Tests live in `mediscribe_app/test/`. Use `flutter test` to run them.
- No CI workflows are present; recommended GH Actions steps:
  - Run `flutter pub get`
  - Run `flutter analyze`
  - Run `flutter test`
  - Check formatting via `dart format --set-exit-if-changed .`

---

## 📝 Notes for contributors
- OCR is on-device and supports Latin script; image quality impacts accuracy (handwriting may be poorly recognized).
- Gemini is used only for extracting and formatting medicine details — the app falls back to raw OCR text if Gemini fails.
- Medicine highlighting is currently a simple keyword heuristic — consider improving via a dedicated NER or stronger prompt parsing.

---

If you'd like, I can:
- Add an `assets/.env.example` and remove sensitive keys from `assets/.env` for you
- Add a GitHub Actions workflow that injects `GEMINI_API_KEY` from repo secrets and runs tests
- Add a sample test mocking `GeminiService` and verifying fallback behavior

Tell me which change you want next and I’ll implement it.