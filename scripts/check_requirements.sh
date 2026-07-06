#!/usr/bin/env bash
# =============================================================================
# check_requirements.sh — Vérifie l'environnement de développement
# Usage   : bash scripts/check_requirements.sh
# =============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

OK="${GREEN}✓${NC}"
FAIL="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"

echo ""
echo "=== Vérification des prérequis ==="
echo ""

# Flutter
if command -v flutter &>/dev/null; then
    FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
    echo -e "$OK Flutter     : $FLUTTER_VERSION"
else
    echo -e "$FAIL Flutter     : Non installé"
fi

# Dart
if command -v dart &>/dev/null; then
    DART_VERSION=$(dart --version 2>&1)
    echo -e "$OK Dart        : $DART_VERSION"
else
    echo -e "$FAIL Dart        : Non installé"
fi

# Java
if command -v java &>/dev/null; then
    JAVA_VERSION=$(java --version 2>&1 | head -1)
    echo -e "$OK Java        : $JAVA_VERSION"
else
    echo -e "$WARN Java        : Non trouvé (requis pour Android)"
fi

# Xcode (macOS seulement)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v xcodebuild &>/dev/null; then
        XCODE_VERSION=$(xcodebuild -version 2>&1 | head -1)
        echo -e "$OK Xcode       : $XCODE_VERSION"
    else
        echo -e "$WARN Xcode       : Non installé (requis pour iOS)"
    fi
fi

# .env
if [ -f .env ]; then
    echo -e "$OK .env        : Présent"
else
    echo -e "$FAIL .env        : Absent (lancer : make set-env)"
fi

# google-services.json (Android)
if [ -f android/app/google-services.json ]; then
    echo -e "$OK google-services.json (Android)"
else
    echo -e "$WARN google-services.json : Absent (requis pour Firebase Android)"
fi

# GoogleService-Info.plist (iOS)
if [ -f ios/Runner/GoogleService-Info.plist ]; then
    echo -e "$OK GoogleService-Info.plist (iOS)"
else
    echo -e "$WARN GoogleService-Info.plist : Absent (requis pour Firebase iOS)"
fi

echo ""
