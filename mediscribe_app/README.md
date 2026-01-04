# Mediscribe — Prescription OCR & AI Assistant

Mediscribe is an AI-powered Flutter app that converts images of medical prescriptions into readable, structured text, highlights medicine names and dosages, and lets you export or share a PDF report.

This README documents the app's architecture, key workflows (OCR, Gemini integration), developer commands, and guidance for safely managing API keys.

---

## App overview
- Location: `mediscribe_app/`
- Entry point: `lib/main.dart` (loads environment variables then shows `LoginScreen`)
- Purpose: Upload a prescription image (camera or gallery) → OCR the image (ML Kit) → post-process/extract structured data using Google Gemini (Generative Language API) → show highlighted medicines and enable export/share.

### Primary flow (high-level)
1. User logs in (UI-only demo login) and taps **Upload Prescription**.
2. `UploadScreen` lets the user pick or capture an image (image compression attempted for smaller uploads).
3. `ProcessingScreen` runs a 2-step pipeline:
   - OCR (ML Kit Text Recognition) via `OcrService.extractText(File)`
   - Send OCR text to Gemini via `GeminiService.understandPrescription(String)` for structured extraction (medicine names, dose, frequency).
4. `ResultScreen` displays the resulting text. A simple keyword-based highlighter (`MedicineHighlighter` / `_highlightMedicines`) colors likely medicine tokens.
5. Users can export a PDF (`PdfService.generatePrescriptionPdf`) or share the extracted text.

---

## Key files & components
- `lib/main.dart` — app init (loads `assets/.env` using `flutter_dotenv`) and routing
- `lib/screens/` — screens: `login_screen.dart`, `home_screen.dart`, `upload_screen.dart`, `processing_screen.dart`, `result_screen.dart`
- `lib/services/ocr_service.dart` — ML Kit TextRecognizer wrapper (Latin script)
- `lib/services/gemini_text_services.dart` — calls Google Generative Language endpoint with a short prompt to extract medicines and details
- `lib/services/pdf_service.dart` — creates a simple PDF from extracted text
- `lib/utils/medicine_highlighter.dart` & highlighting logic in `result_screen.dart` — keyword heuristics to mark medicine-related tokens
- `assets/.env` — environment variables (GEMINI_API_KEY is loaded here by `flutter_dotenv`)

---

## How OCR works (implementation details)
- The app uses `google_mlkit_text_recognition` (ML Kit) through `OcrService.extractText`.
- Implementation: create an `InputImage` from the selected `File`, then run `TextRecognizer(script: TextRecognitionScript.latin).processImage(...)` and return `result.text`.
- Notes: The OCR step is purely on-device and supports Latin script; image quality strongly affects OCR accuracy (lighting, blur, and handwriting legibility).

## How Gemini (Generative Language) is used
- After OCR, the raw text is sent to `GeminiService.understandPrescription`, which:
  - Reads `GEMINI_API_KEY` from environment variables via `flutter_dotenv`.
  - Posts to Google Generative Language API (model `gemini-3-pro-preview`) with a prompt asking the model to extract medicine names and dosage/frequency, returning a minimally formatted response.
- Prompt behavior: the prompt instructs Gemini to return ONLY lists of medicines and a details section (no explanations). This makes downstream UI parsing simpler but relies on Gemini following instructions.
- Error handling: if Gemini is unavailable or the API key is missing/invalid, the app falls back to showing raw OCR text.

---

## Running the app (developer commands)
Prerequisites:
- Flutter SDK (same major version as the project; check `pubspec.yaml` for constraints)
- Platform SDKs for your target(s): Android SDK, Xcode (macOS for iOS), CMake for desktop targets.

Typical commands (run from `mediscribe_app/`):
- Install deps: `flutter pub get`
- Run on device/emulator: `flutter run` or `flutter run -d <device-id>`
- Run tests: `flutter test`
- Static analysis: `flutter analyze`
- Format: `dart format .`
- Build artifacts:
  - Android APK: `flutter build apk`
  - iOS archive: `flutter build ipa` (macOS)
  - Web: `flutter build web`
  - Desktop: `flutter build <windows|linux|macos>`

---

## Config & secrets (important)
- Environment variables are loaded from `assets/.env` by `flutter_dotenv` at app startup.
- The repo currently contains `assets/.env` with a `GEMINI_API_KEY` value — **this is sensitive**. For production or public repos:
  - **Remove** API keys from source control (rotate the key immediately if it's public).
  - Add `assets/.env` to `.gitignore` or keep an example file `assets/.env.example` with placeholders only:
    ```
    GEMINI_API_KEY=YOUR_API_KEY_HERE
    ```
  - In CI, store `GEMINI_API_KEY` as a secret and inject it into `assets/.env` during the workflow.

---

## Testing guidance
- Unit or widget tests belong in `test/`; `test/widget_test.dart` contains a starter example.
- To test OCR locally, use clear sample images of prescriptions (good lighting and contrast). Handwriting recognition can be unreliable — include expected failure cases in tests.
- For Gemini-related behavior, mock HTTP responses from the `GeminiService` endpoint to assert parsing and fallback behavior.

---

## Extensibility & notes for contributors
- Medicine highlighting is currently keyword-based (see `medicine_highlighter.dart` and the inline heuristic in `result_screen.dart`). Replace or extend this with a more robust NER (named entity recognition) model or use a stricter Gemini prompt and parse its structured output.
- Consider adding a small internal model or rule-based post-processor to normalize medicine names and dosages.
- Add CI (GitHub Actions) that runs `flutter test`, `flutter analyze`, and `dart format --set-exit-if-changed .` on PRs.

---

If you'd like, I can also:
- Add a `docs/` folder with an architecture diagram and example API responses
- Add a `assets/.env.example` file and a GitHub Actions workflow that injects the GEMINI_API_KEY-secret at build time
- Add unit tests that mock `GeminiService` and assert fallback behaviors

Please tell me which of these you'd like me to add next.