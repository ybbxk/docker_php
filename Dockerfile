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
    && docker-php-ext-enable xdebug redis \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_mode=\"req\"" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=\"dbgp\"" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=bdb" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_host=10.0.75.1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    # phpunit
    && curl https://phar.phpunit.de/phpunit-7.phar -o /usr/local/bin/phpunit \
    && chmod 755 /usr/local/bin/phpunit \
    && usermod -u 1000 www-data -d /home/www-data \
    # composer
    && php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && su - www-data 'composer config -g repo.packagist composer https://packagist.phpcomposer.com' \
    && echo "export PATH=$PATH:/home/www-data/.composer/vendor/bin/" >> /home/www-data/.bashrc \
    # code sniffer
    && su - www-data 'composer global require "squizlabs/php_codesniffer=*"' \
    # phpmd
    && http://static.phpmd.org/php/latest/phpmd.phar /usr/local/bin/phpmd \
    && chmod 755 /usr/local/bin/phpmd 

VOLUME ["/opt"]
VOLUME ["/workspace"]
