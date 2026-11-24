FROM ghcr.io/php/pie:1.6.0-bin AS pie
FROM composer:2.9 AS composer

FROM php:8.6.0-apache-trixie

# Imagick 3.8.1 does not build on PHP 8.6. The fix is merged upstream but not
# yet released (https://github.com/Imagick/imagick/issues/804), so build from a
# pinned commit. Replace with a release version (e.g. 3.9.0) once available.
ARG IMAGICK_VERSION=dev-master#55ed2e9fda264395636a2e27e51f31673f5566ab

# Update and install necessary packages
RUN apt-get update \
    && apt-get install libpq-dev libmagickwand-dev imagemagick id3 poppler-utils catdoc xpdf html2text docx2txt zlib1g-dev libpng-dev libzip-dev libxslt-dev -y \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j"$(nproc)" gd mysqli pdo pdo_mysql pdo_pgsql zip xsl intl \
    && rm -rf /var/lib/apt/lists/*

# Third-party extensions are installed with PIE, which is only needed at build time.
RUN --mount=type=bind,from=pie,source=/pie,target=/usr/local/bin/pie \
    pie install --no-interaction imagick/imagick:${IMAGICK_VERSION}

# PHP libraries are managed with Composer (see composer.json / composer.lock).
# The generated autoloader also sets the include_path for the PEAR-style
# libraries (Log, Mail, Net_SMTP) and is loaded for every request.
WORKDIR /opt/seeddms-deps
COPY composer.json composer.lock ./
RUN --mount=type=bind,from=composer,source=/usr/bin/composer,target=/usr/local/bin/composer \
    composer install --no-dev --no-interaction --no-scripts --no-plugins --optimize-autoloader \
    && echo 'auto_prepend_file=/opt/seeddms-deps/vendor/autoload.php' > "$PHP_INI_DIR/conf.d/seeddms-deps.ini"

WORKDIR /var/www/html
