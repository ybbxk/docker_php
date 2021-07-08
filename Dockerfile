FROM php:7.4-fpm
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
        libzip-dev \
        unzip \
        libxml2 \
        libxml2-dev \
        libxslt-dev \
        libsodium-dev \
	libgmp3-dev \
    && docker-php-ext-configure intl gd \
    && docker-php-ext-install -j$(nproc) intl \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-install bcmath
    # phalcon
#RUN git clone --depth=1 git://github.com/phalcon/cphalcon.git \
#    && cd cphalcon/build && ./install && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini \
#    && rm -rf /root/cphalcon
    # pecl
RUN pecl install xdebug-2.9.8 redis swoole \
    && docker-php-ext-install soap xsl sodium sockets gmp simplexml \
    #&& docker-php-ext-enable xdebug redis soap xsl sodium sockets gmp simplexml \
    && docker-php-ext-enable xdebug redis swoole \
    && echo "xdebug.remote_enable=on" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_mode=\"req\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=\"dbgp\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_output_dir=\"/usr/share/nginx/html/xdebug_profile\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.profiler_enable_trigger_value=\"XDEBUG_PROFILE\""  >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
    # phpunit
RUN curl -L https://phar.phpunit.de/phpunit-7.phar -o /usr/local/bin/phpunit \
    && chmod 755 /usr/local/bin/phpunit \
    && usermod -u 1000 -s /bin/bash -d /home/www-data www-data \
    && groupmod -g 1000 www-data \
    && mkdir /home/www-data \
    && chown www-data:www-data /home/www-data
    # composer
RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer \
    && su - www-data -c 'composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/' \
    && echo "export PATH=$PATH:/root/.composer/vendor/bin/" >> /root/.bashrc
    # code sniffer
RUN composer global require "squizlabs/php_codesniffer=*"
    # phpmd
#ADD phpmd.phar /usr/local/bin/phpmd
#RUN chmod 755 /usr/local/bin/phpmd 

VOLUME ["/opt"]
VOLUME ["/workspace"]
