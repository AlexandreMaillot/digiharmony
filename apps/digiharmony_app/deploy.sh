#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
FLAVOR="${1:-production}"

flutter build apk --flavor "$FLAVOR" --target "lib/main_${FLAVOR}.dart" --release
echo "APK : build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
# Play Store : preferer l'App Bundle
# flutter build appbundle --flavor "$FLAVOR" --target "lib/main_${FLAVOR}.dart" --release

# Distribution test au choix :
# (A) Direct : APK / piste interne Play Console.
# (B) Firebase App Distribution (OPTIONNEL, diffusion testeurs uniquement,
#     AUCUN SDK Firebase dans l'app) :
# firebase appdistribution:distribute \
#   "build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk" \
#   --app "$FIREBASE_ANDROID_APP_ID" --groups "testeurs"
