# Laravel Docker Starter - Setup Script (PowerShell)
# Encoding: UTF-8

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Laravel Docker Starter - Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Docker is running
Write-Host "[CHECK] Verifying Docker is running..." -ForegroundColor Yellow
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker is not running"
    }
    Write-Host "[OK] Docker is running" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker is not running. Please start Docker Desktop and try again." -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if .env exists
Write-Host ""
if (-not (Test-Path ".env")) {
    Write-Host "[SETUP] Creating .env file from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Could not create .env file" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "[OK] .env file created successfully" -ForegroundColor Green
} else {
    Write-Host "[INFO] .env file already exists, using existing configuration" -ForegroundColor Blue
}

# Build Docker containers
Write-Host ""
Write-Host "[BUILD] Building Docker containers (this may take a few minutes on first run)..." -ForegroundColor Yellow
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to build Docker containers" -ForegroundColor Red
    Write-Host "Please check the error messages above" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] Containers built successfully" -ForegroundColor Green

# Start containers
Write-Host ""
Write-Host "[START] Starting containers..." -ForegroundColor Yellow
docker-compose up -d 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[ERROR] Failed to start containers" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  - Port conflicts (MySQL on 3306, Redis on 6379, etc.)" -ForegroundColor Yellow
    Write-Host "  - Check if ports 8000, 3307, 6380, 8025, 1025 are available" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To fix port conflicts:" -ForegroundColor Yellow
    Write-Host "  1. Stop services using these ports (e.g., local MySQL, Redis)" -ForegroundColor Yellow
    Write-Host "     net stop MySQL80" -ForegroundColor Yellow
    Write-Host "  2. Or change ports in .env file:" -ForegroundColor Yellow
    Write-Host "     APP_PORT=8001" -ForegroundColor Yellow
    Write-Host "     DB_PORT=3308" -ForegroundColor Yellow
    Write-Host "     REDIS_PORT=6381" -ForegroundColor Yellow
    Write-Host ""
    docker-compose logs
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] Containers started successfully" -ForegroundColor Green

# Wait for containers to be ready
Write-Host ""
Write-Host "[WAIT] Waiting for containers to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Check if app container is running
$appStatus = docker-compose ps | Select-String "laravel_app" | Select-String "Up"
if (-not $appStatus) {
    Write-Host "[ERROR] App container is not running" -ForegroundColor Red
    Write-Host ""
    Write-Host "Showing container logs:" -ForegroundColor Yellow
    docker-compose logs app
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] App container is running" -ForegroundColor Green

# Wait for MySQL to be ready
Write-Host ""
Write-Host "[WAIT] Waiting for MySQL to be fully ready (this may take 10-30 seconds)..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$mysqlReady = $false

while (-not $mysqlReady -and $attempt -lt $maxAttempts) {
    $attempt++
    try {
        docker-compose exec -T mysql mysql -uroot -proot -e "SELECT 1" 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $mysqlReady = $true
        }
    } catch {
        Start-Sleep -Seconds 1
    }

    if (-not $mysqlReady) {
        Start-Sleep -Seconds 1
    }
}

if (-not $mysqlReady) {
    Write-Host "[ERROR] MySQL did not start in time" -ForegroundColor Red
    Write-Host "Showing MySQL logs:" -ForegroundColor Yellow
    docker-compose logs mysql
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "[OK] MySQL is ready" -ForegroundColor Green

# Check if Laravel is already installed
Write-Host ""
if (-not (Test-Path "composer.json")) {
    Write-Host "[INSTALL] Installing Laravel (this will take a few minutes)..." -ForegroundColor Yellow
    docker-compose exec -T app composer create-project laravel/laravel . --prefer-dist --no-interaction
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to install Laravel" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Host "[OK] Laravel installed successfully" -ForegroundColor Green

    Write-Host ""
    Write-Host "[CONFIG] Configuring Laravel environment..." -ForegroundColor Yellow
    docker cp .env laravel_app:/var/www/.env
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Could not copy .env file, Laravel will use defaults" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "[KEY] Generating application key..." -ForegroundColor Yellow
    docker-compose exec -T app php artisan key:generate --force
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Could not generate application key" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "[MIGRATE] Running migrations..." -ForegroundColor Yellow
    docker-compose exec -T app php artisan migrate --force
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Migrations failed, but continuing..." -ForegroundColor Yellow
    }
} else {
    Write-Host "[INFO] Laravel already installed, checking dependencies..." -ForegroundColor Blue

    if (-not (Test-Path "vendor")) {
        Write-Host "[INSTALL] Installing Composer dependencies..." -ForegroundColor Yellow
        docker-compose exec -T app composer install --no-interaction
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[ERROR] Failed to install dependencies" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host "[OK] Dependencies installed successfully" -ForegroundColor Green
    } else {
        Write-Host "[OK] Dependencies already installed" -ForegroundColor Green
    }

    if (-not (Test-Path ".env")) {
        Write-Host "[CONFIG] Configuring Laravel environment..." -ForegroundColor Yellow
        docker cp .env laravel_app:/var/www/.env
        docker-compose exec -T app php artisan key:generate --force
    }

    Write-Host ""
    Write-Host "[MIGRATE] Running migrations..." -ForegroundColor Yellow
    docker-compose exec -T app php artisan migrate --force
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Migrations failed (this is normal for fresh install)" -ForegroundColor Yellow
    }
}

# Set permissions
Write-Host ""
Write-Host "[PERMISSIONS] Setting permissions..." -ForegroundColor Yellow
docker-compose exec -T app chmod -R 777 storage bootstrap/cache 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[INFO] Could not set permissions (this is okay on Windows)" -ForegroundColor Blue
}

# Clear caches
Write-Host ""
Write-Host "[CACHE] Clearing caches..." -ForegroundColor Yellow
docker-compose exec -T app php artisan config:clear 2>$null
docker-compose exec -T app php artisan cache:clear 2>$null
docker-compose exec -T app php artisan route:clear 2>$null
docker-compose exec -T app php artisan view:clear 2>$null

# Success message
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your application is running at: http://localhost:8000" -ForegroundColor Cyan
Write-Host "Mailhog is running at: http://localhost:8025" -ForegroundColor Cyan
Write-Host "MySQL is available at: localhost:3307" -ForegroundColor Cyan
Write-Host "   Username: laravel_user" -ForegroundColor Gray
Write-Host "   Password: secret" -ForegroundColor Gray
Write-Host "   Database: laravel" -ForegroundColor Gray
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  docker-compose up -d          # Start containers" -ForegroundColor Gray
Write-Host "  docker-compose down           # Stop containers" -ForegroundColor Gray
Write-Host "  docker-compose exec app bash  # Access app container" -ForegroundColor Gray
Write-Host "  docker-compose logs -f        # View logs" -ForegroundColor Gray
Write-Host "  docker-compose ps             # Check container status" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Visit http://localhost:8000 in your browser" -ForegroundColor Gray
Write-Host "  2. Check the logs with: docker-compose logs -f" -ForegroundColor Gray
Write-Host "  3. Read the README.md for more information" -ForegroundColor Gray
Write-Host ""

Read-Host "Press Enter to exit"
