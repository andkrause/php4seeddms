FROM php:8.6.0-apache-trixie

# Update and install necessary packages
RUN apt-get update \
    && apt-get install libpq-dev libmagickwand-dev imagemagick id3 poppler-utils catdoc xpdf html2text docx2txt zlib1g-dev libpng-dev libzip-dev libxslt-dev -y \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j"$(nproc)" gd mysqli pdo pdo_mysql pdo_pgsql zip xsl intl \
    && rm -rf /var/lib/apt/lists/*

# Install Imagick with PIE. Version 3.8.1 uses XtOffsetOf, removed in PHP 8.6.
RUN --mount=type=bind,from=ghcr.io/php/pie:bin,source=/pie,target=/usr/local/bin/pie \
    curl -fsSL https://github.com/Imagick/imagick/archive/70087bab33eab913e99ac77d64d04d1a2fd0b7b0.tar.gz -o /tmp/imagick.tgz \
    && mkdir /tmp/imagick \
    && tar -xzf /tmp/imagick.tgz -C /tmp/imagick --strip-components=1 \
    && sed -i 's/XtOffsetOf/offsetof/g' /tmp/imagick/php_imagick_defs.h /tmp/imagick/imagick.c \
    && pie repository:add path /tmp/imagick \
    && pie install --no-interaction --skip-enable-extension imagick/imagick:@dev \
    && docker-php-ext-enable imagick \
    && pie repository:remove /tmp/imagick \
    && rm -rf /tmp/imagick /tmp/imagick.tgz

# Composer installs the PHP libraries; PIE remains a build-time tool only.
COPY composer.json composer.lock /opt/seeddms-deps/
RUN --mount=type=bind,from=composer:2,source=/usr/bin/composer,target=/usr/local/bin/composer \
    cd /opt/seeddms-deps \
    && composer install --no-dev --no-interaction --prefer-dist --no-scripts --no-plugins \
    && echo 'include_path=".:/opt/seeddms-deps/vendor/pear/log:/opt/seeddms-deps/vendor/pear/mail:/opt/seeddms-deps/vendor/pear/net_smtp:/opt/seeddms-deps/vendor/pear/net_socket:/opt/seeddms-deps/vendor/pear/pear-core-minimal/src:/opt/seeddms-deps/vendor/pear/console_getopt:/opt/seeddms-deps/vendor/pear/pear_exception"' > "$PHP_INI_DIR/conf.d/seeddms-deps.ini"
