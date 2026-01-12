@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Laravel Docker Starter - Setup Script
echo ========================================
echo.

REM Create .env if doesn't exist
if not exist ".env" (
    echo [1/6] Creating .env file...
    copy .env.example .env >nul
) else (
    echo [1/6] .env file already exists
)

REM Build containers
echo [2/6] Building containers...
docker-compose build >nul 2>&1

REM Start containers
echo [3/6] Starting containers...
docker-compose up -d >nul 2>&1

REM Wait for containers
echo [4/6] Waiting 30 seconds for containers to initialize...
timeout /t 30 /nobreak >nul

REM Install composer dependencies
echo [5/7] Installing dependencies (this takes 2-3 minutes)...
docker-compose exec -T app composer install --no-interaction --quiet

REM Generate application key
echo [6/7] Generating application key...
docker-compose exec -T app php artisan key:generate --force

REM Run migrations
echo [7/7] Running migrations...
docker-compose exec -T app php artisan migrate --force >nul 2>&1

echo.
echo ========================================
echo Setup complete!
echo ========================================
echo.
echo Visit: http://localhost:8000
echo.
pause
