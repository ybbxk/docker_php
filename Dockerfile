FROM php:7.4-fpm-alpine3.13
ADD php.ini    /usr/local/etc/php/php.ini
#ADD php-fpm.conf    /usr/local/etc/php-fpm.conf

WORKDIR /usr/share/nginx/html/

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories

RUN apk update --update && apk add --no-cache \
        ${PHPIZE_DEPS} \
        libmcrypt-dev \
	shadow \
        libjpeg-turbo-dev \
        libpng-dev \
        git \
        libzip-dev \
        unzip \
        libxml2 \
        libxml2-dev \
        libxslt-dev \
        libsodium-dev \
        freetype-dev \
        pcre-dev \
        gmp-dev \
        icu-dev \
        oniguruma \
        oniguruma-dev 
RUN docker-php-ext-configure intl \
    &&docker-php-ext-install -j$(nproc) intl \
    #&& docker-php-ext-configure gd \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath
    #psr
#RUN git clone https://github.com/jbboehr/php-psr.git \
#    && cd php-psr \
#    && /usr/local/bin/phpize \
#    && ./configure --with-php-config=/usr/local/bin/php-config \
#    && make \
#    && make install \
#    && cd ..;rm -rf php-psr \
#    && echo "extension=psr.so" >> /usr/local/etc/php/conf.d/psr.ini 
#RUN kill -USR2 1
#    # phalcon
#RUN git clone --depth=1 git://github.com/phalcon/cphalcon.git \
#    && cd cphalcon/build && ./install && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \
#    && rm -rf /root/cphalcon
    # pecl
RUN pecl install xdebug-2.9.8 redis swoole \
    && docker-php-ext-install soap xsl sodium sockets gmp simplexml \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_mode=\"req\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=\"dbgp\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    # phpunit
RUN curl -L https://phar.phpunit.de/phpunit-7.phar -o /usr/local/bin/phpunit \
    && chmod 755 /usr/local/bin/phpunit \
    && usermod -u 1000 -s /bin/sh -d /home/www-data www-data \
    && groupmod -g 1000 www-data \
    && mkdir -p /home/www-data \
    && chown www-data:www-data /home/www-data
    # composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && su - www-data -c 'composer config -g repo.packagist composer https://packagist.laravel-china.org' \
    && echo "export PATH=$PATH:/root/.composer/vendor/bin/" >> /root/.bashrc
    # code sniffer
RUN composer global require "squizlabs/php_codesniffer=*"
    # phpmd
ADD phpmd.phar /usr/local/bin/phpmd
RUN chmod 755 /usr/local/bin/phpmd 

RUN apk del shadow \
    ${PHPIZE_DEPS}

VOLUME ["/opt"]
VOLUME ["/workspace"]
