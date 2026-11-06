#!/usr/bin/env bash
# Build Flutter web exécuté par Vercel (voir vercel.json).
# Vercel n'a pas Flutter : on le télécharge, on recrée le .env à partir des
# variables d'environnement du projet Vercel, puis on compile build/web.
set -euo pipefail

FLUTTER_VERSION="3.47.4"

: "${SUPABASE_URL:?Variable SUPABASE_URL manquante dans Vercel}"
: "${SUPABASE_ANON_KEY:?Variable SUPABASE_ANON_KEY manquante dans Vercel}"
: "${API_BASE_URL:?Variable API_BASE_URL manquante dans Vercel}"

if [ ! -x flutter/bin/flutter ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git
fi
export PATH="$PWD/flutter/bin:$PATH"

flutter --version
flutter config --enable-web --no-analytics
flutter pub get

# Le .env est déclaré comme asset dans pubspec.yaml mais n'est pas versionné.
printf 'SUPABASE_URL=%s\nSUPABASE_ANON_KEY=%s\nAPI_BASE_URL=%s\n' \
  "$SUPABASE_URL" "$SUPABASE_ANON_KEY" "${API_BASE_URL%/}" > .env

flutter build web --release
