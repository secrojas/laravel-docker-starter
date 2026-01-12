# Laravel Docker Starter - Setup Script (PowerShell)
$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Laravel Docker Starter - Setup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create .env if doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "[1/6] Creating .env file..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
} else {
    Write-Host "[1/6] .env file already exists" -ForegroundColor Blue
}

# Build containers
Write-Host "[2/6] Building containers..." -ForegroundColor Yellow
docker-compose build 2>&1 | Out-Null

# Start containers
Write-Host "[3/6] Starting containers..." -ForegroundColor Yellow
docker-compose up -d 2>&1 | Out-Null

# Wait for containers
Write-Host "[4/6] Waiting 30 seconds for containers to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Install composer dependencies
Write-Host "[5/6] Installing dependencies (this takes 2-3 minutes)..." -ForegroundColor Yellow
docker-compose exec -T app composer install --no-interaction --quiet

# Run migrations
Write-Host "[6/6] Running migrations..." -ForegroundColor Yellow
docker-compose exec -T app php artisan migrate --force 2>&1 | Out-Null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Visit: http://localhost:8000" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
