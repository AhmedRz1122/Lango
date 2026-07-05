# Lango

A Flutter translation app with offline on-device translation, Google Translate online mode, voice input, and translation history.

## Features

- **Splash onboarding** — Lexora-inspired design with Lango branding
- **Online translation** — Google Translate embedded via WebView (133+ languages)
- **Offline translation** — On-device (Play Store) or HY-MT via Genkit (development)
- **Voice input** — Speech-to-text (English)
- **Translation history** — Stored locally with sqflite
- **MVVM architecture** — Clean separation of Models, Views, and ViewModels

## Translation modes

| Mode | Production (Play Store) | Development |
|------|-------------------------|-------------|
| **Online** | Google Translate WebView | Same |
| **Offline** | On-device ML Kit (no server) | Genkit + HY-MT (`npm run dev` only) |

## Development setup

### Flutter app

```bash
flutter pub get
flutter run
```

### Offline translation (development only)

Only **one** command is needed — Genkit auto-starts the HY-MT Python service:

```bash
cd backend
npm install
npm run dev
```

Genkit runs on `http://localhost:3400` and loads HY-MT via a Python worker process (no port 3401).

> **Note:** Debug builds call Genkit on localhost. Release/Play Store builds use on-device ML Kit and **never** contact a dev server.

### Speech model

Download `vosk-model-small-en-us-0.15.zip` from https://alphacephei.com/vosk/models and place it in `assets/models/`.

## Google Play deployment

Build a release APK/AAB — offline translation works on-device with no backend:

```bash
flutter build appbundle --release
```

Language models download automatically on first use (requires internet once per language pair).

## Project structure

```
lango/
├── lib/               # Flutter app
├── backend/           # Genkit dev gateway (not bundled in Play Store release)
│   ├── src/index.ts   # hyMtTranslateFlow + auto-spawn HY-MT
│   └── hy_mt_service.py
└── assets/models/     # Speech recognition model
```

## License

Private project.
