FROM php:8.2

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git \
    zip unzip \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    sqlite3 \
    libsqlite3-dev \
    netcat-openbsd \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring bcmath zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurer Git
RUN git config --global --add safe.directory /var/www/html

# Définir le dossier de travail
WORKDIR /var/www/html

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

# Configurer Composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1
ENV COMPOSER_PROCESS_TIMEOUT=900

# Copier tous les fichiers de projet
COPY . .

# Installer les dépendances Composer sans dev
RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Configurer les permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache \
    && chmod -R 775 /tmp \
    && mkdir -p /tmp/laravel-setup-markers \
    && chown -R www-data:www-data /tmp/laravel-setup-markers \
    && chmod -R 775 /tmp/laravel-setup-markers

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Variables d'environnement par défaut
ENV LARAVEL_ENV=production

EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/ || exit 1

CMD ["/entrypoint.sh"]
