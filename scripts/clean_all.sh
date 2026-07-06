#!/usr/bin/env bash
# =============================================================================
# clean_all.sh — Nettoyage complet (flutter clean + artefacts)
# Usage   : bash scripts/clean_all.sh
# =============================================================================
set -e

echo "➜ flutter clean..."
flutter clean

echo "➜ Suppression de build/ et .dart_tool/..."
rm -rf build/ .dart_tool/

if [[ "$OSTYPE" == "darwin"* ]] && [ -d ios/Pods ]; then
    echo "➜ Suppression des Pods iOS..."
    rm -rf ios/Pods ios/.symlinks
fi

echo "✓ Nettoyage terminé. Relancer : make install && make codegen"
