.PHONY: help setup install codegen codegen-watch run-dev run-staging run-prod \
        analyze format test test-watch coverage coverage-open lint check rename set-env \
        build-apk-dev build-apk-prod build-aab-prod build-ios-dev build-ios-prod \
        clean clean-full deploy-android deploy-ios

# Affiche l'aide
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# === SETUP ===
setup: ## Installation complète depuis zéro (deps + codegen + hooks git)
	@echo "\n\033[1m=== Configuration initiale du template ===\033[0m"
	@bash scripts/setup.sh

install: ## flutter pub get
	flutter pub get

codegen: ## Génération de code (build_runner one-shot)
	dart run build_runner build --delete-conflicting-outputs

codegen-watch: ## Génération de code en mode watch
	dart run build_runner watch --delete-conflicting-outputs

# === LANCEMENT ===
run-dev: ## Lancer l'app en mode développement
	flutter run --dart-define=APP_ENV=development

run-staging: ## Lancer l'app en mode staging
	flutter run --dart-define=APP_ENV=staging

run-prod: ## Lancer l'app en mode production
	flutter run --dart-define=APP_ENV=production --release

# === QUALITÉ ===
analyze: ## Analyse statique du code Dart
	flutter analyze

format: ## Formater tout le code Dart
	dart format . --line-length 100

format-check: ## Vérifier le formatage sans modifier
	dart format . --line-length 100 --set-exit-if-changed

test: ## Lancer tous les tests avec couverture
	flutter test --coverage

test-watch: ## Lancer les tests en mode watch
	flutter test --watch

coverage: ## Tests + rapport HTML de couverture (nécessite lcov : brew/apt install lcov)
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html --quiet
	@echo "\n\033[32m✓ Rapport disponible dans coverage/html/index.html\033[0m"

coverage-open: coverage ## Tests + rapport HTML + ouverture dans le navigateur
	@open coverage/html/index.html 2>/dev/null || xdg-open coverage/html/index.html 2>/dev/null || \
	  echo "Ouvrir manuellement : coverage/html/index.html"

lint: analyze format-check ## Analyse + vérification formatage

check: lint test ## Pipeline CI local complet (lint + tests)
	@echo "\n\033[32m✓ Toutes les vérifications sont passées !\033[0m"

# === CONFIGURATION ===
rename: ## Renommer l'app (applicationId, bundleId, appName) de façon interactive
	@bash scripts/rename_app.sh

set-env: ## Copier .env.example → .env et lister les variables à remplir
	@bash scripts/gen_env.sh

# === BUILD ===
build-apk-dev: ## APK debug pour développement
	flutter build apk --debug --dart-define=APP_ENV=development

build-apk-prod: ## APK release production (obfusqué + split debug info)
	flutter build apk --release \
		--obfuscate \
		--split-debug-info=build/symbols/android \
		--dart-define=APP_ENV=production

build-aab-prod: ## Android App Bundle release (Google Play Store)
	flutter build appbundle --release \
		--obfuscate \
		--split-debug-info=build/symbols/android \
		--dart-define=APP_ENV=production

build-ios-dev: ## Archive iOS développement
	flutter build ios --debug --dart-define=APP_ENV=development

build-ios-prod: ## Archive iOS production (App Store)
	flutter build ios --release \
		--obfuscate \
		--split-debug-info=build/symbols/ios \
		--dart-define=APP_ENV=production

# === NETTOYAGE ===
clean: ## flutter clean + suppression du dossier build/
	flutter clean
	rm -rf build/

clean-full: clean install codegen ## Reset complet (clean + pub get + codegen)
	@echo "\n\033[32m✓ Nettoyage complet terminé !\033[0m"

# === DÉPLOIEMENT ===
deploy-android: build-apk-prod ## Firebase App Distribution — Android
	@echo "TODO: [TEMPLATE] Configurer Firebase App Distribution"
	# firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
	#   --app YOUR_ANDROID_APP_ID \
	#   --groups testers

deploy-ios: build-ios-prod ## Firebase App Distribution — iOS
	@echo "TODO: [TEMPLATE] Configurer Firebase App Distribution"
	# firebase appdistribution:distribute build/ios/ipa/Runner.ipa \
	#   --app YOUR_IOS_APP_ID \
	#   --groups testers
