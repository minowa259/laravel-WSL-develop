FROM php:8.3-fpm

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libpq-dev \
    && docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.jsとnpmのインストール
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 作業ディレクトリの設定
WORKDIR /var/www/html

# 実行ユーザーの設定
RUN groupadd -g 1000 www && \
    useradd -u 1000 -ms /bin/bash -g www www

# パーミッションの設定
RUN chown -R www:www /var/www/html

USER www

EXPOSE 9000

CMD ["php-fpm"]
