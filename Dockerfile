FROM php:7.2.19-fpm-alpine3.9

ENV PHALCON_VERSION=3.4.2
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

WORKDIR /var/www/html

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && apk add --no-cache \
    # nginx
    nginx \
    # compiler & tools
    make \
    g++ \
    autoconf \
    file \
    libtool \
    libpng \
    libpng-dev \
    re2c \
    pcre-dev \
    gnu-libiconv \
    # iconv & gd
    php7-iconv \
    php7-gd \
    php7-intl \
    php7-xsl \
    php7-redis \
    php7-dev \
    php7-pear \
    php7-mysqli \
    php7-pdo \
    php7-pdo_mysql \
    curl \
    libcurl \
    curl-dev \
    libxslt-dev \
    libmcrypt-dev \
    && \
    pecl install mcrypt-1.0.2 && \
    # docker ext
    docker-php-ext-install curl && \
    docker-php-ext-install calendar && \
    docker-php-ext-install xsl && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mysqli && \
    docker-php-ext-enable mcrypt && \
    # phalcon php
    set -xe && \
    curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
    tar xzf v${PHALCON_VERSION}.tar.gz && \
    # compile
    cd cphalcon-${PHALCON_VERSION}/build && ./install && \
    echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini && \
    cd ../.. && rm -rf v${PHALCON_VERSION}.tar.gz cphalcon-${PHALCON_VERSION} \
    && \
    # clean dev libs
    apk del \
    make \
    g++ \
    autoconf \
    file \
    libtool \
    re2c \
    libpng \
    libpng-dev \
    gnu-libiconv \
    pcre-dev \
    php7-dev \
    php7-pear \
&& rm -rf /var/cache/apk/* 

COPY ./src .

COPY ./config/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY ./config/nginx/mime.types /etc/nginx/conf/mime.types
COPY ./config/php-fpm/docker.conf /usr/local/etc/php-fpm.d/docker.conf
COPY ./config/php-fpm/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY ./entrypoint.sh entrypoint.sh

RUN chmod +x ./entrypoint.sh
RUN mkdir -p /run/nginx

ENTRYPOINT ["./entrypoint.sh"]