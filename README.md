# TravelTrack

> "Donnez un score à votre curiosité." Turns exploring a city into a real-world game — users discover geolocated cultural/food/history quests, validate them with a photo + GPS check, and track their progress across the city.

Flutter frontend (MVVM) + Node.js/Express backend, backed by Supabase.

## Structure

```
traveltrack-webapp/
├── frontend/                    Flutter app (MVVM)
│   └── lib/src/
│       ├── models/               # Quest, FeedItem, ...
│       ├── viewmodels/           # AuthViewModel, ...
│       ├── views/                # Home, Map, Feed, QuestsList, Search, Profile, AddQuest, TripDetail
│       │   └── auth/              # Login, Register
│       ├── widgets/               # Shared widgets (QuestCard, ...)
│       ├── navigation/            # go_router config + tab shell
│       └── services/
│           ├── auth_service.dart
│           ├── supabase_client.dart
│           └── data/               # Mock data (pre-backend-integration)
└── backend/                     Node.js/Express — Supabase (service role) + Render deployment
    └── src/
        ├── routes/                # trips, ...
        ├── middleware/            # requireAuth
        └── lib/                    # Supabase client
```

## Getting started

### Prerequisites
- Node.js 18+
- Flutter SDK (stable channel) + Android Studio / Xcode (for device/emulator)
- A [Supabase](https://supabase.com) project

### Backend

```bash
cd backend
cp .env.example .env   # fill in your Supabase credentials
npm install
npm run dev
```

### Frontend

```bash
cd frontend
cp .env.example .env   # fill in your Supabase credentials + API URL
flutter pub get
flutter run   # pick an Android/iOS device or emulator
```

## Map

The map is rendered natively with [flutter_map](https://pub.dev/packages/flutter_map) (`latlong2` for coordinates) — no WebView involved.

## Environment variables

| Variable | Where | Description |
|---|---|---|
| `SUPABASE_URL` | backend + frontend | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | backend only | Service role key (never expose to client) |
| `SUPABASE_ANON_KEY` | frontend only | Public anon key |
| `API_BASE_URL` | frontend | Backend URL (`http://10.0.2.2:3000` for Android emulator) |
| `ALLOWED_ORIGIN` | backend | CORS allowed origin |
| `PORT` | backend | Backend listen port (defaults to `3000`) |

## Deploy (backend → Render)

Push the repo and connect `backend/` as a Render Web Service. Set env vars in the Render dashboard. The `render.yaml` in `backend/` documents the expected configuration.
