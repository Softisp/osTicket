FROM php:8.1-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpng-dev libjpeg-dev libfreetype6-dev libicu-dev libc-client-dev libkrb5-dev libzip-dev libxml2-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install -j"$(nproc)" mysqli gd intl imap zip opcache \
    && pecl install apcu && docker-php-ext-enable apcu \
    && a2enmod rewrite remoteip headers \
    && rm -rf /var/lib/apt/lists/*

RUN { echo 'date.timezone=Africa/Kampala'; echo 'upload_max_filesize=20M'; echo 'post_max_size=24M'; \
      echo 'memory_limit=256M'; echo 'expose_php=Off'; } > /usr/local/etc/php/conf.d/osticket.ini

COPY . /var/www/html/
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Match the official release build (the packager hardens these two lines; git source has dev values).
RUN cd /var/www/html \
    && sed -i "s/ini_set('display_errors', 1);/ini_set('display_errors', '0');/; s/ini_set('display_startup_errors', 1);/ini_set('display_startup_errors', '0');/" bootstrap.php \
    && cp include/ost-sampleconfig.php include/ost-config.sample.php \
    && rm -rf .git .github charts docker Dockerfile \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && chown -R www-data:www-data /var/www/html

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
