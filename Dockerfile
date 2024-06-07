# Используем базовый образ PHP 8.1 с FPM
FROM php:8.1-fpm

# Устанавливаем зависимости системы
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    imagemagick \
    mariadb-client \
    libmagickwand-dev \
    pkg-config \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем расширения PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd pdo pdo_mysql mbstring bcmath

# Устанавливаем Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Устанавливаем рабочую директорию
WORKDIR /var/www/html

# Копируем исходный код приложения
COPY . .

# Установка зависимостей PHP с разрешением запускать как суперпользователь
RUN COMPOSER_ALLOW_SUPERUSER=1 composer install

# Настройка прав доступа
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Экспонируем порт
EXPOSE 9000

# Стартовые команды
CMD ["php-fpm"]