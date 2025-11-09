#!/bin/sh

set -e

echo "🚀 Lancement de l'entrypoint Laravel..."

# Définir le répertoire de marqueurs
MARKERS_DIR="/tmp/laravel-setup-markers"

# Option pour forcer la réexécution complète
if [ "$FORCE_SETUP" = "true" ]; then
  echo "🔄 Mode force activé : suppression des marqueurs existants..."
  rm -rf "$MARKERS_DIR"
fi

# Créer le répertoire de marqueurs s'il n'existe pas
mkdir -p "$MARKERS_DIR"

# ⏳ Attente de MySQL (seulement si DB_CONNECTION n'est pas sqlite)
if [ "$DB_CONNECTION" != "sqlite" ] && [ -n "$DB_HOST" ]; then
  echo "⏳ Attente de la base de données $DB_HOST..."
  until nc -z -v -w30 "$DB_HOST" "${DB_PORT:-3306}"; do
    echo "🔄 En attente de MySQL..."
    sleep 2
  done
  echo "✅ Base de données prête !"
else
  echo "✅ Utilisation de SQLite, pas besoin d'attendre."
fi

# 🔑 Génération de la clé Laravel si absente
if [ ! -f "$MARKERS_DIR/app_key_generated" ]; then
  if ! grep -q "^APP_KEY=base64" .env; then
    echo "🔑 Clé Laravel absente, génération..."
    php artisan key:generate
  else
    echo "✅ Clé Laravel déjà présente."
  fi
  touch "$MARKERS_DIR/app_key_generated"
else
  echo "✅ Clé Laravel déjà générée précédemment."
fi

# 🗃️ Exécuter les migrations SEULEMENT si pas encore fait
if [ ! -f "$MARKERS_DIR/migrations_done" ]; then
  echo "🧱 Exécution des migrations..."
  php artisan migrate --force
  touch "$MARKERS_DIR/migrations_done"
  echo "✅ Migrations terminées."
else
  echo "✅ Migrations déjà effectuées précédemment."
fi

# 🔗 Création du lien symbolique vers storage
if [ ! -f "$MARKERS_DIR/storage_link_created" ]; then
  if [ ! -L public/storage ]; then
    echo "🔗 Création du lien symbolique public/storage..."
    php artisan storage:link
  else
    echo "✅ Lien symbolique public/storage déjà présent."
  fi
  touch "$MARKERS_DIR/storage_link_created"
else
  echo "✅ Lien symbolique storage déjà créé précédemment."
fi

# 🧠 Cache config et routes (une seule fois)
if [ ! -f "$MARKERS_DIR/cache_optimized" ]; then
  echo "📦 Optimisation Laravel..."
  php artisan config:cache || echo "⚠️ Échec du cache de configuration"
  php artisan route:cache || echo "⚠️ Échec du cache des routes"
  php artisan view:cache || echo "⚠️ Échec du cache des vues"
  touch "$MARKERS_DIR/cache_optimized"
  echo "✅ Optimisation Laravel terminée."
else
  echo "✅ Optimisation Laravel déjà effectuée précédemment."
fi

# 🧹 Nettoyage du cache application (toujours exécuté pour s'assurer de la fraîcheur)
echo "🧹 Nettoyage du cache application..."
php artisan cache:clear || echo "⚠️ Échec du nettoyage du cache"

# 🚀 Lancer le serveur Laravel
echo "🌐 Démarrage du serveur Laravel..."
exec php artisan serve --host=0.0.0.0 --port=8000