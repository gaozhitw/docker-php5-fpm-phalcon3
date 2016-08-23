FROM php:5-fpm

RUN \
    apt-get update && \
    apt-get install -y php5-dev libpcre3-dev gcc make git libvpx-dev libjpeg62-turbo-dev libpng12-dev libfreetype6-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/list/*

RUN \
    cd ${HOME} && \
    git clone git://github.com/phalcon/cphalcon.git && \
    cd cphalcon/build && \
    ./install

RUN docker-php-ext-enable phalcon.so

RUN \
    docker-php-ext-configure pdo_mysql && \
    docker-php-ext-configure mbstring && \
    docker-php-ext-configure sockets && \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-vpx-dir=/usr/include --with-freetype-dir=/usr/include && \
    docker-php-ext-configure opcache && \
    docker-php-ext-configure exif && \
    docker-php-ext-install pdo_mysql mbstring sockets gd opcache exif

RUN \
    pecl install redis-2.2.8 && \
    docker-php-ext-enable redis.so && \
    pecl install mongo-1.6.14 && \
    docker-php-ext-enable mongo.so && \
    pecl clear-cache

RUN \
    apt-get update && \
    apt-get install -y libmcrypt-dev && \
    docker-php-ext-configure mcrypt && \
    docker-php-ext-install mcrypt && \
    apt-get clean && \
    rm -rf ${HOME}/cphalcon && \
    rm -rf /var/lib/apt/list/*

RUN \
    mkdir -p ${HOME}/php-default-conf && \
    cp -R /usr/local/etc/* ${HOME}/php-default-conf

ADD ["./docker-entrypoint.sh", "/root/"]

VOLUME ["/var/www", "/usr/local/etc"]

ENTRYPOINT ["sh", "-c", "${HOME}/docker-entrypoint.sh"]
