#!/usr/bin/env bash
# =============================================================================
# build_release.sh — Build release Android et/ou iOS avec obfuscation
# Usage   : bash scripts/build_release.sh [android|ios|all]
# =============================================================================
set -e

TARGET=${1:-all}

build_android() {
    echo "➜ Build Android App Bundle (release)..."
    flutter build appbundle --release \
        --obfuscate \
        --split-debug-info=build/symbols/android \
        --dart-define=APP_ENV=production
    echo "✓ AAB disponible : build/app/outputs/bundle/release/app-release.aab"
}

build_ios() {
    echo "➜ Build iOS (release)..."
    flutter build ios --release \
        --obfuscate \
        --split-debug-info=build/symbols/ios \
        --dart-define=APP_ENV=production
    echo "✓ Archive disponible dans Xcode Organizer"
}

case "$TARGET" in
    android) build_android ;;
    ios) build_ios ;;
    all) build_android && build_ios ;;
    *)
        echo "Usage: bash scripts/build_release.sh [android|ios|all]"
        exit 1
        ;;
esac
