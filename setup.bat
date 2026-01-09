@echo off
echo 🚀 Laravel Docker Starter - Setup Script
echo ========================================
echo.

REM Check if .env exists
if not exist ".env" (
    echo 📝 Creating .env file from .env.example...
    copy .env.example .env
) else (
    echo ℹ️  .env file already exists, skipping...
)

echo.
echo 📦 Building Docker containers...
docker-compose build

echo.
echo 🔧 Starting containers...
docker-compose up -d

echo.
echo ⏳ Waiting for MySQL to be ready...
timeout /t 10 /nobreak

REM Check if Laravel is already installed
if not exist "composer.json" (
    echo.
    echo 📥 Installing Laravel...
    docker-compose exec app composer create-project laravel/laravel . --prefer-dist

    echo.
    echo 📝 Copying Docker .env configuration...
    REM Copy our .env from host to container (overwrites Laravel's .env.example)
    docker cp .env laravel_app:/var/www/.env

    echo.
    echo 🔑 Generating application key...
    docker-compose exec app php artisan key:generate

    echo.
    echo 🗄️  Running migrations...
    docker-compose exec app php artisan migrate --force
) else (
    echo.
    echo ℹ️  Laravel already installed, installing dependencies...
    docker-compose exec app composer install

    if not exist ".env" (
        echo 📝 Copying Docker .env configuration...
        docker cp .env laravel_app:/var/www/.env
        docker-compose exec app php artisan key:generate
    )

    echo.
    echo 🗄️  Running migrations...
    docker-compose exec app php artisan migrate
)

echo.
echo 🧹 Clearing caches...
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

echo.
echo 🔐 Setting permissions...
docker-compose exec app chmod -R 777 storage bootstrap/cache

echo.
echo ✅ Setup complete!
echo.
echo 📍 Your application is running at: http://localhost:8000
echo 📧 Mailhog is running at: http://localhost:8025
echo 🗄️  MySQL is available at: localhost:3307
echo.
echo 🎯 Useful commands:
echo   docker-compose up -d          # Start containers
echo   docker-compose down           # Stop containers
echo   docker-compose exec app bash  # Access app container
echo   docker-compose logs -f        # View logs
echo.

pause
