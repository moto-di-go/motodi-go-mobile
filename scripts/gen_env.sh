#!/usr/bin/env bash
# =============================================================================
# gen_env.sh — Génère .env depuis .env.example si absent
# Usage   : bash scripts/gen_env.sh (ou make set-env)
# =============================================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -f .env ]; then
    echo -e "${YELLOW}⚠ .env existe déjà. Non écrasé.${NC}"
else
    cp .env.example .env
    echo -e "${GREEN}✓ .env créé depuis .env.example${NC}"
fi

echo ""
echo "Variables à renseigner dans .env :"
grep -E '^[A-Z_]+=.*#' .env | awk -F'=' '{print "  • " $1}' || true
echo ""
echo -e "${YELLOW}N'oubliez pas de remplir les valeurs avant de lancer l'app.${NC}"
