FROM php:8.1-fpm

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    imagemagick \
    mariadb-client \
    libmagickwand-dev --no-install-recommends

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mbstring

# Установить Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

# Установка зависимостей PHP
RUN composer install

# Настройка прав доступа
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Экспонирование порта
EXPOSE 9000

# Запуск PHP-FPM
CMD ["php-fpm"]