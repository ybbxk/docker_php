FROM php:7.2-fpm
ADD php.ini    /usr/local/etc/php/php.ini

ADD php-fpm.conf    /usr/local/etc/php-fpm.conf

WORKDIR /root/
RUN apt-get update && apt-get install -y \
        libmcrypt-dev \
        libicu-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpcre3-dev\
        git \
        unzip \
        libxml2 \
        libxml2-dev \
        libxslt-dev \
        libsodium-dev \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath \
    # phalcon
    && git clone --depth=1 git://github.com/phalcon/cphalcon.git \
    && cd cphalcon/build && ./install && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \
    # pecl
    && pecl install xdebug redis swoole \
    && docker-php-ext-install soap xsl sodium sockets gmp simplexml \
    && docker-php-ext-enable xdebug redis soap xsl sodium sockets gmp simplexml \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_mode=\"req\"" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=\"dbgp\"" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=bdb" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_host=10.0.75.1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    # phpunit
    && curl -L https://phar.phpunit.de/phpunit-7.phar -o /usr/local/bin/phpunit \
    && chmod 755 /usr/local/bin/phpunit \
    && usermod -u 1000 -s /bin/bash -d /home/www-data www-data \
    && groupmod -g 1000 www-data \
    && mkdir /home/www-data \
    && chown www-data:www-data /home/www-data \
    # composer
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && su - www-data -c 'composer config -g repo.packagist composer https://packagist.laravel-china.org' \
    && echo "export PATH=$PATH:/root/.composer/vendor/bin/" >> /root/.bashrc \
    # code sniffer
    && composer global require "squizlabs/php_codesniffer=*" \
    # phpmd
    && curl -L http://static.phpmd.org/php/latest/phpmd.phar -o /usr/local/bin/phpmd \
    && chmod 755 /usr/local/bin/phpmd 

VOLUME ["/opt"]
VOLUME ["/workspace"]
