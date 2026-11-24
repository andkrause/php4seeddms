FROM php:8.6.0-apache-trixie

# Update and install necessary packages
RUN apt-get update \
    && apt-get install libpq-dev libmagickwand-dev imagemagick id3 poppler-utils catdoc xpdf html2text docx2txt zlib1g-dev libpng-dev libzip-dev libxslt-dev -y \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j"$(nproc)" gd mysqli pdo pdo_mysql pdo_pgsql zip xsl intl \
    && rm -rf /var/lib/apt/lists/*

# Imagick 3.8.1 uses XtOffsetOf, which was removed in PHP 8.6.
RUN curl -fsSL https://pecl.php.net/get/imagick-3.8.1.tgz -o /tmp/imagick.tgz \
    && mkdir /tmp/imagick \
    && tar -xzf /tmp/imagick.tgz -C /tmp/imagick --strip-components=1 \
    && sed -i 's/XtOffsetOf/offsetof/g' /tmp/imagick/php_imagick_defs.h /tmp/imagick/imagick.c \
    && cd /tmp/imagick \
    && phpize \
    && ./configure \
    && make -j"$(nproc)" \
    && make install \
    && docker-php-ext-enable imagick \
    && cd / \
    && rm -rf /tmp/imagick /tmp/imagick.tgz

# PHP 8.6 no longer bundles PEAR.
RUN curl -fsSL https://pear.php.net/go-pear.phar -o /tmp/go-pear.phar \
    && php /tmp/go-pear.phar </dev/null \
    && rm /tmp/go-pear.phar \
    && echo 'include_path=".:/usr/local/share/pear"' > "$PHP_INI_DIR/conf.d/pear.ini" \
    && pear channel-update pear.php.net \
    && pear install Log \
    && pear install Mail \
    && pear install Net_SMTP \
    && pear install HTTP_WebDAV_Server-1.0.0RC8 \
    # Replace removed curly-brace string offsets in the legacy WebDAV package. \
    && sed -i -E 's/\$(http_stat|uuid|hex|string|child)\{([^}]+)\}/$\1[\2]/g' /usr/local/share/pear/HTTP/WebDAV/Server.php \
    && sed -i 's/\$stat{0}/$stat[0]/g' /usr/local/share/pear/HTTP/WebDAV/Server/Filesystem.php \
    && find /usr/local/share/pear/HTTP/WebDAV -name '*.php' -exec sh -c 'for file do php -l "$file" || exit 1; done' sh '{}' +



