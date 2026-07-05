#!/usr/bin/env bash
# =============================================================================
# setup.sh — Installation complète depuis zéro
# Usage   : bash scripts/setup.sh (ou make setup)
# Prérequis: Flutter installé et dans le PATH
# =============================================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_step() { echo -e "\n${GREEN}➜${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error() { echo -e "${RED}✗ $1${NC}"; }

echo ""
echo "=========================================="
echo "  Flutter Template App — Setup"
echo "=========================================="

# 1. Vérification Flutter
log_step "Vérification de l'environnement Flutter..."
if ! command -v flutter &> /dev/null; then
    log_error "Flutter n'est pas installé ou pas dans le PATH."
    echo "  Installation : https://docs.flutter.dev/get-started/install"
    exit 1
fi
flutter --version

# 2. Variables d'environnement
log_step "Configuration des variables d'environnement..."
bash scripts/gen_env.sh

# 3. Dépendances
log_step "Installation des dépendances (flutter pub get)..."
flutter pub get

# 4. Génération de code
log_step "Génération du code (build_runner)..."
dart run build_runner build --delete-conflicting-outputs

# 5. Hook pre-commit
log_step "Installation du hook pre-commit..."
git config core.hooksPath .git-hooks
chmod +x .git-hooks/pre-commit
echo -e "${GREEN}✓${NC} Hook pre-commit installé."

# 6. Analyse
log_step "Analyse du code..."
flutter analyze --no-pub || log_warn "Des avertissements ont été détectés. Vérifiez flutter analyze."

# Résumé
echo ""
echo "==========================================="
echo -e "${GREEN}✓ Setup terminé !${NC}"
echo "==========================================="
echo ""
echo "Prochaines étapes :"
echo "  1. Remplir les TODO: [TEMPLATE] dans les fichiers"
echo "  2. Configurer Firebase : flutter configure --project YOUR_PROJECT"
echo "  3. Renommer l'app : make rename"
echo "  4. Lancer l'app : make run-dev"
echo ""
