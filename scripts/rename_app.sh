#!/usr/bin/env bash
# =============================================================================
# rename_app.sh — Renomme l'application (applicationId, bundleId, appName)
# Usage   : bash scripts/rename_app.sh (ou make rename)
# =============================================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "=== Renommage de l'application Flutter ==="
echo ""

# Application ID (reverse domain notation)
read -rp "Application ID (ex: com.monentreprise.monapp) : " APP_ID
if [[ -z "$APP_ID" ]]; then
    echo "Application ID requis."
    exit 1
fi

# Nom de l'application
read -rp "Nom de l'application (ex: Mon App) : " APP_NAME
if [[ -z "$APP_NAME" ]]; then
    echo "Nom requis."
    exit 1
fi

OLD_ID="com.yourcompany.yourapp"
OLD_NAME="Flutter Template App"
OLD_PACKAGE_PATH="com/yourcompany/yourapp"
NEW_PACKAGE_PATH=$(echo "$APP_ID" | tr '.' '/')

echo ""
echo -e "${YELLOW}Remplacement de '${OLD_ID}' par '${APP_ID}'...${NC}"

# pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|$OLD_ID|$APP_ID|g" pubspec.yaml
    sed -i '' "s|$OLD_NAME|$APP_NAME|g" pubspec.yaml
else
    sed -i "s|$OLD_ID|$APP_ID|g" pubspec.yaml
    sed -i "s|$OLD_NAME|$APP_NAME|g" pubspec.yaml
fi

# Android — build.gradle.kts
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|$OLD_ID|$APP_ID|g" android/app/build.gradle.kts
else
    sed -i "s|$OLD_ID|$APP_ID|g" android/app/build.gradle.kts
fi

# Android — AndroidManifest.xml
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|$OLD_NAME|$APP_NAME|g" android/app/src/main/AndroidManifest.xml
else
    sed -i "s|$OLD_NAME|$APP_NAME|g" android/app/src/main/AndroidManifest.xml
fi

# Android — MainActivity package
OLD_MAIN_KT="android/app/src/main/kotlin/${OLD_PACKAGE_PATH}/MainActivity.kt"
NEW_KT_DIR="android/app/src/main/kotlin/${NEW_PACKAGE_PATH}"
mkdir -p "$NEW_KT_DIR"
cat > "${NEW_KT_DIR}/MainActivity.kt" << EOF
package ${APP_ID}

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
EOF
# Supprimer l'ancien si différent
if [[ "$OLD_PACKAGE_PATH" != "$NEW_PACKAGE_PATH" ]]; then
    rm -f "$OLD_MAIN_KT"
fi

# iOS — Info.plist
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|$OLD_NAME|$APP_NAME|g" ios/Runner/Info.plist
else
    sed -i "s|$OLD_NAME|$APP_NAME|g" ios/Runner/Info.plist
fi

echo ""
echo -e "${GREEN}✓ Renommage terminé !${NC}"
echo ""
echo "Fichiers modifiés :"
echo "  • pubspec.yaml"
echo "  • android/app/build.gradle.kts"
echo "  • android/app/src/main/AndroidManifest.xml"
echo "  • android/app/src/main/kotlin/${NEW_PACKAGE_PATH}/MainActivity.kt"
echo "  • ios/Runner/Info.plist"
echo ""
echo "Prochaines étapes :"
echo "  • iOS: Ouvrir Xcode > Runner > General > Bundle Identifier → ${APP_ID}"
echo "  • Relancer : make clean-full"
