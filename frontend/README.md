# TravelTrack (Flutter)

Flutter frontend for TravelTrack — bottom-tab navigation (Home / Map), a native OpenStreetMap view via [flutter_map](https://pub.dev/packages/flutter_map), and Supabase auth/data via [supabase_flutter](https://pub.dev/packages/supabase_flutter).

## Getting started

```bash
cp .env.example .env   # fill in your Supabase credentials + API URL
flutter pub get
flutter run
```

## Structure

```
lib/
├── main.dart
└── src/
    ├── lib/            # Supabase client
    ├── navigation/      # go_router config + tab shell
    └── screens/         # Home, Map, TripDetail
```
