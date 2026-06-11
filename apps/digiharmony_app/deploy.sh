#!/usr/bin/env bash
#
# Build release + diffusion testeurs via Firebase App Distribution.
#   ./deploy.sh [flavor]            (defaut: production)
#   DISTRIBUTE=0 ./deploy.sh        (build seul, sans diffusion)
#
# App Distribution ne diffuse qu'un binaire a des testeurs : AUCUN SDK Firebase
# n'est embarque dans l'app (pas de firebase_core, pas de google-services.json),
# la politique « zero collecte » reste intacte. L'app Firebase Android n'est
# qu'un identifiant de diffusion cote console.
#
# Le package de l'app Firebase (com.creappi.digiharmony) correspond a
# l'applicationId du flavor PRODUCTION. Pour diffuser staging (.stg) ou
# development (.dev), enregistrer une app Firebase dediee et surcharger
# FIREBASE_ANDROID_APP_ID.
set -euo pipefail
cd "$(dirname "$0")"

FLAVOR="${1:-production}"
DISTRIBUTE="${DISTRIBUTE:-1}"
# App ID Android Firebase (projet dev-digiharmony, package com.creappi.digiharmony).
FIREBASE_ANDROID_APP_ID="${FIREBASE_ANDROID_APP_ID:-1:614105312744:android:897629d5752390e47e485d}"
GROUPS="${GROUPS:-testeurs}"

flutter build apk --flavor "$FLAVOR" --target "lib/main_${FLAVOR}.dart" --release
APK="build/app/outputs/flutter-apk/app-${FLAVOR}-release.apk"
echo "APK : $APK"
# Play Store : preferer l'App Bundle
# flutter build appbundle --flavor "$FLAVOR" --target "lib/main_${FLAVOR}.dart" --release

if [[ "$DISTRIBUTE" == "1" ]]; then
  firebase appdistribution:distribute "$APK" \
    --app "$FIREBASE_ANDROID_APP_ID" \
    --groups "$GROUPS" \
    --release-notes "Build $FLAVOR"
  echo "APK $FLAVOR diffuse au groupe : $GROUPS"
else
  echo "Diffusion ignoree (DISTRIBUTE=0)."
fi
