ARG FRANKENPHP_VERSION=1
ARG PHP_VERSION=8.4

FROM php:${PHP_VERSION}-cli AS builder

RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

WORKDIR /app

ARG DRUPAL_VERSION=11
RUN \
	composer create-project "drupal-composer/drupal-project:${DRUPAL_VERSION}" . --no-interaction; \
	composer clear-cache

COPY docker/Drupal/phpunit.xml.dist phpunit.xml.dist

FROM dunglas/frankenphp:${FRANKENPHP_VERSION}-php${PHP_VERSION}

RUN apt-get update && \
	apt-get -y --no-install-recommends install \
		wget \
		gcc \
		make \
		libreadline-dev \
    	zlib1g-dev \
	&& \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN wget https://www.sqlite.org/2025/sqlite-autoconf-3480000.tar.gz \
    && tar xvfz sqlite-autoconf-3480000.tar.gz \
    && cd sqlite-autoconf-3480000 \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf sqlite-autoconf-3480000*

RUN install-php-extensions \
	mysqli \
	exif \
	imagick \
	zip \
	intl \
	gd \
	xdebug

RUN apt-get remove -y wget make gcc libreadline-dev zlib1g-dev \
	&& apt-get autoremove -y \
	&& ldconfig

RUN echo "xdebug.mode=coverage" > /usr/local/etc/php/conf.d/xdebug.ini

COPY Caddyfile /etc/caddy/Caddyfile

WORKDIR /app/public

RUN rm -rf ./*

COPY --from=builder /app .

ENV PATH="${PATH}:/app/public/vendor/bin"

# To install Drupal automatically.
COPY docker/Frankenphp/entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

ENTRYPOINT ["entrypoint"]
CMD ["--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]