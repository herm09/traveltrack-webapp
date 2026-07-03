# TravelTrack (Flutter)

Flutter frontend for TravelTrack — bottom-tab navigation (Home / Map), a Leaflet/OpenStreetMap view via [webview_flutter](https://pub.dev/packages/webview_flutter), and Supabase auth/data via [supabase_flutter](https://pub.dev/packages/supabase_flutter).

## Getting started

```bash
cp .env.example .env   # fill in your Supabase credentials + API URL
flutter pub get
flutter run
```

## Structure

```
lib/
└── src/
    ├── services/     # Supabase client
    ├── navigation/   # go_router config + tab shell
    ├── models/
    ├── viewmodels/
    └── views/        # Home, Map, TripDetail
```
