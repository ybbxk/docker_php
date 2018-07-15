FROM php:7.2-fpm
ADD php.ini    /usr/local/etc/php/php.ini

ADD php-fpm.conf    /usr/local/etc/php-fpm.conf

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
    && docker-php-ext-install bcmath 

WORKDIR /root/
RUN git clone --depth=1 git://github.com/phalcon/cphalcon.git
RUN cd cphalcon/build && ./install && echo "extension=phalcon.so" > /usr/local/etc/php/conf.d/phalcon.ini


RUN pecl install xdebug redis swoole
RUN docker-php-ext-enable xdebug redis 

RUN echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_mode=\"req\"" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=\"dbgp\"" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=bdb" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_host=10.0.75.1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/conf.d/xdebug.ini

# RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
#     && php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
#     && php composer-setup.php \
#     && php -r "unlink('composer-setup.php');"

ADD https://phar.phpunit.de/phpunit-7.phar /usr/local/bin/phpunit
RUN chmod 755 /usr/local/bin/phpunit
WORKDIR /workspace
RUN usermod -u 1000 www-data

RUN php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=/usr/bin/ --filename=composer

RUN composer global require "squizlabs/php_codesniffer=*"

ADD http://static.phpmd.org/php/latest/phpmd.phar /usr/local/bin/phpmd
RUN chmod 755 /usr/local/bin/phpmd

RUN  echo "export PATH=$PATH:/root/.composer/vendor/bin/" >> /root/.bashrc

VOLUME ["/opt"]
VOLUME ["/workspace"]
