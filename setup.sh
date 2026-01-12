#!/bin/bash

set -e  # Exit on error

echo "========================================"
echo "🚀 Laravel Docker Starter - Setup Script"
echo "========================================"
echo ""

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    echo ""
    exit 1
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    if [ $? -ne 0 ]; then
        echo "❌ Error: Could not create .env file"
        exit 1
    fi
    echo "✅ .env file created successfully"
else
    echo "ℹ️  .env file already exists, using existing configuration"
fi

echo ""
echo "📦 Building Docker containers (this may take a few minutes on first run)..."
if ! docker-compose build; then
    echo "❌ Error: Failed to build Docker containers"
    echo "Please check the error messages above"
    exit 1
fi

echo ""
echo "🔧 Starting containers..."
if ! docker-compose up -d; then
    echo ""
    echo "❌ Error: Failed to start containers"
    echo ""
    echo "Common issues:"
    echo "  - Port conflicts (MySQL on 3306, Redis on 6379, etc.)"
    echo "  - Check if ports 8000, 3307, 6380, 8025, 1025 are available"
    echo ""
    echo "To fix port conflicts:"
    echo "  1. Stop services using these ports (e.g., local MySQL, Redis)"
    echo "  2. Or change ports in .env file:"
    echo "     APP_PORT=8001"
    echo "     DB_PORT=3308"
    echo "     REDIS_PORT=6381"
    echo ""
    docker-compose logs
    exit 1
fi

echo ""
echo "⏳ Waiting for containers to be ready..."
sleep 5

# Check if app container is running
if ! docker-compose ps | grep "laravel_app" | grep -q "Up"; then
    echo "❌ Error: App container is not running"
    echo ""
    echo "Showing container logs:"
    docker-compose logs app
    echo ""
    exit 1
fi

echo "✅ Containers are running"

echo ""
echo "⏳ Waiting for MySQL to be fully ready (this may take 10-30 seconds)..."
MAX_ATTEMPTS=30
ATTEMPT=0

while ! docker-compose exec -T mysql mysql -uroot -proot -e "SELECT 1" > /dev/null 2>&1; do
    ATTEMPT=$((ATTEMPT + 1))
    if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
        echo "❌ Error: MySQL did not start in time"
        echo "Showing MySQL logs:"
        docker-compose logs mysql
        exit 1
    fi
    sleep 1
done

echo "✅ MySQL is ready"

# Check if Laravel is already installed
if [ ! -f "composer.json" ]; then
    echo ""
    echo "📥 Installing Laravel (this will take a few minutes)..."
    if ! docker-compose exec -T app composer create-project laravel/laravel . --prefer-dist --no-interaction; then
        echo "❌ Error: Failed to install Laravel"
        exit 1
    fi

    echo ""
    echo "📝 Configuring Laravel environment..."
    if ! docker cp .env laravel_app:/var/www/.env; then
        echo "⚠️  Warning: Could not copy .env file, Laravel will use defaults"
    fi

    echo ""
    echo "🔑 Generating application key..."
    if ! docker-compose exec -T app php artisan key:generate --force; then
        echo "⚠️  Warning: Could not generate application key"
    fi

    echo ""
    echo "🗄️  Running migrations..."
    if ! docker-compose exec -T app php artisan migrate --force; then
        echo "⚠️  Warning: Migrations failed, but continuing..."
    fi
else
    echo ""
    echo "ℹ️  Laravel already installed, checking dependencies..."

    if [ ! -d "vendor" ]; then
        echo "📦 Installing Composer dependencies..."
        if ! docker-compose exec -T app composer install --no-interaction; then
            echo "❌ Error: Failed to install dependencies"
            exit 1
        fi
    else
        echo "✅ Dependencies already installed"
    fi

    if [ ! -f ".env" ]; then
        echo "📝 Configuring Laravel environment..."
        docker cp .env laravel_app:/var/www/.env
        docker-compose exec -T app php artisan key:generate --force
    fi

    echo ""
    echo "🗄️  Running migrations..."
    if ! docker-compose exec -T app php artisan migrate --force; then
        echo "⚠️  Warning: Migrations failed (this is normal for fresh install)"
    fi
fi

echo ""
echo "🔐 Setting permissions..."
if ! docker-compose exec -T app chmod -R 777 storage bootstrap/cache 2>/dev/null; then
    echo "⚠️  Warning: Could not set permissions (continuing anyway)"
fi

echo ""
echo "🧹 Clearing caches..."
docker-compose exec -T app php artisan config:clear 2>/dev/null || true
docker-compose exec -T app php artisan cache:clear 2>/dev/null || true
docker-compose exec -T app php artisan route:clear 2>/dev/null || true
docker-compose exec -T app php artisan view:clear 2>/dev/null || true

echo ""
echo "========================================"
echo "✅ Setup complete!"
echo "========================================"
echo ""
echo "📍 Your application is running at: http://localhost:8000"
echo "📧 Mailhog is running at: http://localhost:8025"
echo "🗄️  MySQL is available at: localhost:3307"
echo "   Username: laravel_user"
echo "   Password: secret"
echo "   Database: laravel"
echo ""
echo "🎯 Useful commands:"
echo "  docker-compose up -d          # Start containers"
echo "  docker-compose down           # Stop containers"
echo "  docker-compose exec app bash  # Access app container"
echo "  docker-compose logs -f        # View logs"
echo "  docker-compose ps             # Check container status"
echo ""
echo "📚 Next steps:"
echo "  1. Visit http://localhost:8000 in your browser"
echo "  2. Check the logs with: docker-compose logs -f"
echo "  3. Read the README.md for more information"
echo ""
