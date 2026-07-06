# Lango

A beautiful Flutter translation app with offline and online modes, voice-to-text support, and AI-powered insights via Genkit.

## Features

- **Splash onboarding** — Lexora-inspired design with Lango branding
- **Online translation** — Seamless cloud translation (no provider branding in UI)
- **Offline translation** — Tencent HY-MT1.5 model via Genkit backend
- **Voice input** — Offline speech recognition with Vosk
- **AI assistant** — Genkit-powered translation explanations and cultural insights
- **MVVM architecture** — Clean separation of Models, Views, and ViewModels

## Project Structure

```
lango/
├── lib/
│   ├── core/          # Theme, constants, utilities
│   ├── models/        # Data models
│   ├── services/      # Translation, speech, Genkit AI services
│   ├── viewmodels/    # MVVM ViewModels
│   └── views/         # Screens and widgets
├── backend/           # Genkit Node.js AI backend
│   ├── src/index.ts   # Genkit flows
│   └── hy_mt_service.py  # HY-MT1.5 Python service
└── assets/
    └── models/        # Vosk speech models
```

## Prerequisites

- Flutter 3.11+ (installed)
- Node.js 20+
- Python 3.10+ (for HY-MT1.5 offline service, optional)
- Google AI API key (for Genkit AI features)

## Setup

### 1. Flutter App

```bash
cd D:\Yards\Lango
flutter pub get
```

### 2. Vosk Speech Model

Download `vosk-model-small-en-us-0.15.zip` from https://alphacephei.com/vosk/models
and place it in `assets/models/`.

For Windows, install Vosk native binaries:

```bash
dart run vosk_flutter_service install -t windows
```

### 3. Genkit Backend

```bash
cd backend
npm install
cp .env.example .env
# Edit .env and set GOOGLE_GENAI_API_KEY
npm run dev
```

The Genkit server runs on `http://localhost:3400`.

### 4. HY-MT1.5 Offline Service (Optional)

```bash
cd backend
pip install -r requirements.txt
python hy_mt_service.py
```

Runs on `http://localhost:3401`. Without this, offline mode uses Genkit AI fallback.

### 5. Run the App

```bash
flutter run
```

## Translation Modes

| Mode | Engine | When Used |
|------|--------|-----------|
| Online | Cloud translation API | Internet available |
| Offline | Tencent HY-MT1.5 | No internet or forced offline |
| Auto | Switches automatically | Default |

## Architecture (MVVM)

- **Models**: `Language`, `TranslationRecord`, `TranslationMode`
- **ViewModels**: `AppViewModel`, `TranslateViewModel` (via Provider)
- **Views**: Screens and reusable widgets
- **Services**: `OnlineTranslationService`, `OfflineTranslationService`, `VoskSpeechService`, `GenkitAiService`

## Genkit Flows

| Flow | Purpose |
|------|---------|
| `hyMtTranslateFlow` | Offline HY-MT1.5 translation |
| `explainTranslationFlow` | AI translation explanations |
| `contextualTranslateFlow` | Context-aware translation |
| `suggestPhrasesFlow` | Topic-based phrase suggestions |

## License

Private project.
