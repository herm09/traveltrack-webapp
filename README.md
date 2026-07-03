# TravelTrack

Travel tracking app — Flutter frontend + Node.js/Express backend.

## Structure

```
traveltrack-webapp/
├── frontend/   Flutter — go_router + Leaflet (WebView) + Supabase
│   └── lib/src/
│       ├── services/     # Supabase client
│       ├── navigation/   # go_router config + tab shell
│       ├── models/
│       ├── viewmodels/
│       └── views/        # Home, Map, TripDetail
└── backend/    Node.js/Express — Supabase (service role) + Render deployment
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

## Environment variables

| Variable | Where | Description |
|---|---|---|
| `SUPABASE_URL` | backend + frontend | Supabase project URL |
| `SUPABASE_SERVICE_ROLE_KEY` | backend only | Service role key (never expose to client) |
| `SUPABASE_ANON_KEY` | frontend only | Public anon key |
| `API_BASE_URL` | frontend | Backend URL (`http://10.0.2.2:3000` for Android emulator) |
| `ALLOWED_ORIGIN` | backend | CORS allowed origin |

## Deploy (backend → Render)

Push the repo and connect `backend/` as a Render Web Service. Set env vars in the Render dashboard. The `render.yaml` in `backend/` documents the expected configuration.
