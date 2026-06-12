# TravelTrack

Travel tracking app — React Native frontend + Node.js/Express backend.

## Structure

```
traveltrack-webapp/
├── frontend/   React Native (CLI) — React Navigation + Leaflet + Supabase
└── backend/    Node.js/Express — Supabase (service role) + Render deployment
```

## Getting started

### Prerequisites
- Node.js 18+
- Android Studio / Xcode (for device/emulator)
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
npm install
npx react-native run-android   # or run-ios
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
