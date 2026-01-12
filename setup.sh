#!/bin/bash

echo "========================================"
echo "Laravel Docker Starter - Setup Script"
echo "========================================"
echo ""

# Create .env if doesn't exist
if [ ! -f ".env" ]; then
    echo "[1/7] Creating .env file..."
    cp .env.example .env
else
    echo "[1/7] .env file already exists"
fi

# Build containers
echo "[2/7] Building containers..."
docker-compose build > /dev/null 2>&1

# Start containers
echo "[3/7] Starting containers..."
docker-compose up -d > /dev/null 2>&1

# Wait for containers
echo "[4/7] Waiting 30 seconds for containers to initialize..."
sleep 30

# Install composer dependencies
echo "[5/7] Installing dependencies (this takes 2-3 minutes)..."
docker-compose exec -T app composer install --no-interaction --quiet

# Generate application key
echo "[6/7] Generating application key..."
docker-compose exec -T app php artisan key:generate --force

# Run migrations
echo "[7/7] Running migrations..."
docker-compose exec -T app php artisan migrate --force > /dev/null 2>&1

echo ""
echo "========================================"
echo "Setup complete!"
echo "========================================"
echo ""
echo "Visit: http://localhost:8000"
echo ""
