#  MediscribeApp

**Mediscribe** is an AI-powered Flutter application that converts images of handwritten or printed medical prescriptions into readable, structured medical text.

The app uses on-device OCR (Google ML Kit) to extract raw text from prescription images and the Google Generative Language (Gemini) API to intelligently extract medicine names, dosages, and instructions.

---

## Key Features

-  Upload prescription images from Camera or Gallery
-  Optional image compression for faster processing
-  On-device OCR using `google_mlkit_text_recognition`
-  AI-powered structuring via Google Gemini API
-  Medicine highlighting heuristic in the result UI
-  Export extracted data as PDF
-  Share results using the system share sheet

---

##  Repository Structure

```
mediscribe_app/
│
├── lib/
│   ├── main.dart                 # App entry point (loads .env)
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── upload_screen.dart
│   │   ├── processing_screen.dart
│   │   └── result_screen.dart
│   │
│   ├── services/
│   │   ├── ocr_service.dart       # ML Kit OCR logic
│   │   ├── gemini_text_services.dart
│   │   └── pdf_service.dart
│   │
│   ├── utils/
│   │   └── medicine_highlighter.dart
│   │
│   └── widgets/
│       └── primary_button.dart
│
├── test/
│   └── widget_test.dart
│
├── assets/
│   └── .env.example
│
└── .github/
    └── copilot-instructions.md
```

---

##  Application Flow

1. App Launch
2. Home / Welcome Screen
3. Prescription Upload (Camera or Gallery)
4. OCR Processing (on-device using ML Kit)
5. AI Structuring (Gemini API extracts structured medical data)
6. Result Screen (Clean output, medicine highlighting)
7. Export / Share (PDF or system share)

---

##  AI / ML Pipeline

Prescription Image
        ↓
Google ML Kit OCR (On-device)
        ↓
Raw OCR Text
        ↓
Gemini API (Text Understanding)
        ↓
Structured Medical Data
        ↓
UI Table + PDF + Share

---

##  OCR (Google ML Kit)

- Runs completely on-device
- No internet required
- Fast and privacy-friendly
- Extracts raw text only

##  Gemini API (Text Only)

- Used only for text understanding (no image processing via Gemini)
- Extracts:
  - Medicine names
  - Dosage
  - Frequency
  - Instructions
- Safe fallback to raw OCR if Gemini fails

---

##  Tech Stack

**Frontend:** Flutter, Dart, Material Design

**OCR:** Google ML Kit — Text Recognition (on-device)

**AI / LLM:** Google Gemini API (text-only usage)

**Utilities:** image_picker, flutter_image_compress, flutter_dotenv, pdf, path_provider, share_plus

**Backend:** None (client-only, demo-friendly)

---

##  Quick Start (Developers)

**Prerequisites**

- Flutter SDK
- Android SDK
- Physical device or emulator

**Run Locally**

```bash
cd mediscribe_app
flutter pub get
flutter run
```

**Testing & Analysis**

```bash
flutter test
flutter analyze
dart format .
```

---

##  Build Commands

- Android APK: `flutter build apk`
- Android Release APK: `flutter build apk --release`
- iOS (macOS only): `flutter build ipa`
- Web: `flutter build web`

---

##  Environment Variables & Secrets

The app uses `flutter_dotenv`.

**Required Variable**

`GEMINI_API_KEY=YOUR_API_KEY_HERE`

**Setup**

- Create `assets/.env`
- Add your Gemini API key
- Ensure `.env` is NOT committed

**Recommended**

- Add `assets/.env` to `.gitignore`
- Commit `assets/.env.example` instead

---

##  Testing Notes

- Tests are located in `test/`
- `widget_test.dart` verifies UI integrity
- Gemini calls should be mocked in future tests
- OCR accuracy depends on image clarity

---

##  Notes for Contributors

- OCR works best with clear, well-lit images
- Handwritten prescriptions may vary in accuracy
- Gemini is restricted to medical text formatting only
- No diagnosis or medical advice is provided
- Medicine highlighting uses a simple heuristic (can be improved)

---

##  Disclaimer

Mediscribe is not a medical diagnostic tool. It assists in digitizing prescriptions and does not replace professional medical advice.

---

##  Contributions & Next Steps

If you’d like, we can next:

-  Add GitHub Actions CI
-  Add mocked Gemini tests
-  Add README screenshots
-  Add architecture diagram
-  Create hackathon demo script

---
