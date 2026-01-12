@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo 🚀 Laravel Docker Starter - Setup Script
echo ========================================
echo.

REM Check Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker is not running. Please start Docker Desktop and try again.
    echo.
    pause
    exit /b 1
)

REM Check if .env exists
if not exist ".env" (
    echo 📝 Creating .env file from .env.example...
    copy .env.example .env >nul
    if errorlevel 1 (
        echo ❌ Error: Could not create .env file
        pause
        exit /b 1
    )
    echo ✅ .env file created successfully
) else (
    echo ℹ️  .env file already exists, using existing configuration
)

echo.
echo 📦 Building Docker containers (this may take a few minutes on first run)...
docker-compose build
if errorlevel 1 (
    echo ❌ Error: Failed to build Docker containers
    echo Please check the error messages above
    pause
    exit /b 1
)

echo.
echo 🔧 Starting containers...
docker-compose up -d
if errorlevel 1 (
    echo.
    echo ❌ Error: Failed to start containers
    echo.
    echo Common issues:
    echo   - Port conflicts (MySQL on 3306, Redis on 6379, etc.)
    echo   - Check if ports 8000, 3307, 6380, 8025, 1025 are available
    echo.
    echo To fix port conflicts:
    echo   1. Stop services using these ports (e.g., local MySQL, Redis)
    echo   2. Or change ports in .env file:
    echo      APP_PORT=8001
    echo      DB_PORT=3308
    echo      REDIS_PORT=6381
    echo.
    docker-compose logs
    pause
    exit /b 1
)

echo.
echo ⏳ Waiting for containers to be ready...
timeout /t 5 /nobreak >nul

REM Check if app container is running
docker-compose ps | findstr "laravel_app" | findstr "Up" >nul
if errorlevel 1 (
    echo ❌ Error: App container is not running
    echo.
    echo Showing container logs:
    docker-compose logs app
    echo.
    pause
    exit /b 1
)

echo ✅ Containers are running

echo.
echo ⏳ Waiting for MySQL to be fully ready (this may take 10-30 seconds)...
set MAX_ATTEMPTS=30
set ATTEMPT=0

:WAIT_MYSQL
set /a ATTEMPT+=1
docker-compose exec -T mysql mysql -uroot -proot -e "SELECT 1" >nul 2>&1
if errorlevel 1 (
    if !ATTEMPT! GEQ !MAX_ATTEMPTS! (
        echo ❌ Error: MySQL did not start in time
        echo Showing MySQL logs:
        docker-compose logs mysql
        pause
        exit /b 1
    )
    timeout /t 1 /nobreak >nul
    goto WAIT_MYSQL
)

echo ✅ MySQL is ready

REM Check if Laravel is already installed
if not exist "composer.json" (
    echo.
    echo 📥 Installing Laravel (this will take a few minutes)...
    docker-compose exec -T app composer create-project laravel/laravel . --prefer-dist --no-interaction
    if errorlevel 1 (
        echo ❌ Error: Failed to install Laravel
        pause
        exit /b 1
    )

    echo.
    echo 📝 Configuring Laravel environment...
    docker cp .env laravel_app:/var/www/.env
    if errorlevel 1 (
        echo ⚠️  Warning: Could not copy .env file, Laravel will use defaults
    )

    echo.
    echo 🔑 Generating application key...
    docker-compose exec -T app php artisan key:generate --force
    if errorlevel 1 (
        echo ⚠️  Warning: Could not generate application key
    )

    echo.
    echo 🗄️  Running migrations...
    docker-compose exec -T app php artisan migrate --force
    if errorlevel 1 (
        echo ⚠️  Warning: Migrations failed, but continuing...
    )
) else (
    echo.
    echo ℹ️  Laravel already installed, checking dependencies...

    if not exist "vendor" (
        echo 📦 Installing Composer dependencies...
        docker-compose exec -T app composer install --no-interaction
        if errorlevel 1 (
            echo ❌ Error: Failed to install dependencies
            pause
            exit /b 1
        )
    ) else (
        echo ✅ Dependencies already installed
    )

    if not exist ".env" (
        echo 📝 Configuring Laravel environment...
        docker cp .env laravel_app:/var/www/.env
        docker-compose exec -T app php artisan key:generate --force
    )

    echo.
    echo 🗄️  Running migrations...
    docker-compose exec -T app php artisan migrate --force
    if errorlevel 1 (
        echo ⚠️  Warning: Migrations failed (this is normal for fresh install)
    )
)

echo.
echo 🔐 Setting permissions...
docker-compose exec -T app chmod -R 777 storage bootstrap/cache 2>nul
if errorlevel 1 (
    echo ⚠️  Warning: Could not set permissions (this is okay on Windows)
)

echo.
echo 🧹 Clearing caches...
docker-compose exec -T app php artisan config:clear 2>nul
docker-compose exec -T app php artisan cache:clear 2>nul
docker-compose exec -T app php artisan route:clear 2>nul
docker-compose exec -T app php artisan view:clear 2>nul

echo.
echo ========================================
echo ✅ Setup complete!
echo ========================================
echo.
echo 📍 Your application is running at: http://localhost:8000
echo 📧 Mailhog is running at: http://localhost:8025
echo 🗄️  MySQL is available at: localhost:3307
echo    Username: laravel_user
echo    Password: secret
echo    Database: laravel
echo.
echo 🎯 Useful commands:
echo   docker-compose up -d          # Start containers
echo   docker-compose down           # Stop containers
echo   docker-compose exec app bash  # Access app container
echo   docker-compose logs -f        # View logs
echo   docker-compose ps             # Check container status
echo.
echo 📚 Next steps:
echo   1. Visit http://localhost:8000 in your browser
echo   2. Check the logs with: docker-compose logs -f
echo   3. Read the README.md for more information
echo.

pause
