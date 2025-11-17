FROM php:8.3-fpm

# 引数の設定
ARG ENVIRONMENT=local
ARG INSTALL_XDEBUG=false

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo

# システムパッケージの更新と必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libxpm-dev \
    zip \
    unzip \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libmemcached-dev \
    zlib1g-dev \
    libonig-dev \
    supervisor \
    cron \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        opcache \
        soap \
        sockets \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Redis拡張のインストール
RUN pecl install redis \
    && docker-php-ext-enable redis

# Xdebugのインストール（開発環境用）
RUN if [ ${INSTALL_XDEBUG} = true ]; then \
    pecl install xdebug-3.3.1 \
    && docker-php-ext-enable xdebug; \
fi

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.js 20.x LTSとnpmのインストール
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# 作業ディレクトリの設定
WORKDIR /var/www/html

# 実行ユーザーの設定
RUN groupadd -g 1000 www && \
    useradd -u 1000 -ms /bin/bash -g www www

# Composerのグローバルパッケージインストール（Laravel Installerのみ）
USER www
RUN composer global require laravel/installer

# PATHの設定
ENV PATH="/home/www/.composer/vendor/bin:${PATH}"

# rootに戻る
USER root

# Note: PHPStan、PHP-CS-Fixer、PHPCSはプロジェクトのcomposer.jsonのdev依存関係として
# インストールされます。グローバルインストールは避け、プロジェクトごとの
# バージョン管理を推奨します。

# パーミッションの設定
RUN chown -R www:www /var/www/html

# Supervisorの設定ディレクトリ作成
RUN mkdir -p /var/log/supervisor

# php-fpmの設定最適化
RUN echo "pm = dynamic" >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
    echo "pm.max_children = 50" >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
    echo "pm.start_servers = 5" >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
    echo "pm.min_spare_servers = 5" >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
    echo "pm.max_spare_servers = 35" >> /usr/local/etc/php-fpm.d/zz-docker.conf

USER www

EXPOSE 9000

CMD ["php-fpm"]
