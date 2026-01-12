# Laravel Docker Starter

> **Production-ready Docker development environment for Laravel applications**

![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat&logo=laravel)
![PHP](https://img.shields.io/badge/PHP-8.2-777BB4?style=flat&logo=php)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)
![Docker Pulls](https://img.shields.io/docker/pulls/secrojas/laravel-docker?style=flat&logo=docker)

Complete Docker Compose setup for Laravel with Nginx, MySQL 8.0, Redis, and Mailhog. Perfect starting point for any Laravel project with zero configuration required.

---

## 📋 Prerequisites

Before starting, make sure you have:

- **Docker Desktop** installed and running
  - Windows: [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
  - Mac: [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
  - Linux: [Docker Engine](https://docs.docker.com/engine/install/)
- **Git** (optional, for cloning the repository)
- **Available ports**: 8000, 3307, 6380, 8025, 1025
  - ⚠️ **Important**: If you have local MySQL (port 3306), Redis, or other services running, they won't conflict as this setup uses different ports by default
  - If ports 8000, 3307, 6380, 8025, or 1025 are in use, you can change them in the `.env` file

### Port Conflicts

If you encounter port conflict errors, you have two options:

**Option 1: Stop conflicting services (recommended for clean setup)**
```bash
# Windows - Stop MySQL service (if you have local MySQL)
net stop MySQL80

# Linux/Mac - Stop MySQL
sudo systemctl stop mysql
# or
sudo service mysql stop
```

**Option 2: Change ports in `.env` file**
```env
APP_PORT=8001        # Change from 8000
DB_PORT=3308         # Change from 3307
REDIS_PORT=6381      # Change from 6380
MAILHOG_UI_PORT=8026 # Change from 8025
```

---

## 📦 What's Included

### Tech Stack

- **PHP 8.2-FPM** with all Laravel required extensions (pdo_mysql, mbstring, exif, pcntl, bcmath, gd, zip, redis)
- **Nginx Alpine** - High-performance web server optimized for Laravel
- **MySQL 8.0** - Relational database with persistent volumes
- **Redis Alpine** - In-memory data store for cache, sessions, and queues
- **Mailhog** - Email testing interface (catches all outgoing emails)
- **Composer 2.x** - Latest version included in PHP container
- **Laravel 12.x** - Latest stable version (installed during setup)

### Key Features

- ✅ **Zero Configuration** - Clone and run with a single script
- ✅ **Pre-built Image Available** - Pull from Docker Hub for instant setup
- ✅ **Hot Reload** - Code changes reflect immediately without rebuilding
- ✅ **Persistent Data** - MySQL data survives container restarts
- ✅ **Email Testing** - Mailhog captures all emails in development
- ✅ **Configurable Ports** - Run multiple projects simultaneously
- ✅ **Production Ready** - Same environment from dev to prod
- ✅ **Easy Debugging** - Access logs via docker-compose commands

---

## 🚀 Quick Start

### Option 1: Clone Repository (Recommended)

**Linux/Mac:**
```bash
# 1. Clone repository
git clone https://github.com/secrojas/laravel-docker-starter.git my-project
cd my-project

# 2. Make setup script executable and run it
chmod +x setup.sh
./setup.sh

# 3. Wait for completion and visit http://localhost:8000
```

**Windows (PowerShell or CMD):**
```powershell
# 1. Clone repository
git clone https://github.com/secrojas/laravel-docker-starter.git my-project
cd my-project

# 2. Run setup script with .\ prefix
.\setup.bat

# 3. Wait for completion and visit http://localhost:8000
```

**Note for Windows users:**
- You **must** use `.\setup.bat` (with `.\` prefix) to run the script
- Make sure Docker Desktop is running before executing the script
- If you see encoding issues, the script will still work correctly

### Option 2: Using Pre-built Docker Image (Fastest)

Pull the image directly from Docker Hub and get started in seconds:

**Linux/Mac:**
```bash
# Create and enter project directory
mkdir my-laravel-app && cd my-laravel-app

# Download configuration files
curl -O https://raw.githubusercontent.com/secrojas/laravel-docker-starter/main/docker-compose.yml
curl -O https://raw.githubusercontent.com/secrojas/laravel-docker-starter/main/.env.example
curl -O https://raw.githubusercontent.com/secrojas/laravel-docker-starter/main/setup.sh
cp .env.example .env

# Run setup
chmod +x setup.sh && ./setup.sh
```

**Windows (PowerShell):**
```powershell
# Create and enter project directory
mkdir my-laravel-app
cd my-laravel-app

# Download configuration files
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/secrojas/laravel-docker-starter/main/docker-compose.yml" -OutFile "docker-compose.yml"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/secrojas/laravel-docker-starter/main/.env.example" -OutFile ".env.example"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/secrojas/laravel-docker-starter/main/setup.bat" -OutFile "setup.bat"
Copy-Item .env.example .env

# Run setup
.\setup.bat
```

### Option 3: Manual Setup

If you prefer manual control over each step:

```bash
# 1. Clone or create project
git clone https://github.com/secrojas/laravel-docker-starter.git my-project
cd my-project

# 2. Copy environment file
cp .env.example .env  # Windows: copy .env.example .env

# 3. Build and start containers
docker-compose build
docker-compose up -d

# 4. Wait for MySQL to be ready (30 seconds recommended)
# Linux/Mac:
until docker-compose exec -T mysql mysql -uroot -proot -e "SELECT 1" > /dev/null 2>&1; do sleep 1; done
# Windows: wait 30 seconds manually or check logs with: docker-compose logs mysql

# 5. Install Composer dependencies (Laravel is already in the project)
docker-compose exec -T app composer install --no-interaction

# 6. Generate application key
docker-compose exec -T app php artisan key:generate --force

# 7. Run migrations
docker-compose exec -T app php artisan migrate --force

# 8. Set permissions (Linux/Mac only, not needed on Windows)
docker-compose exec -T app chmod -R 777 storage bootstrap/cache
```

### What Happens During Setup?

The setup script will:
1. ✅ Check if Docker is running
2. ✅ Create `.env` file from `.env.example`
3. ✅ Build Docker containers (first run takes 3-5 minutes)
4. ✅ Start all services (MySQL, Redis, Nginx, PHP-FPM, Mailhog)
5. ✅ Wait for MySQL to be fully ready
6. ✅ Install Laravel and Composer dependencies
7. ✅ Generate application key
8. ✅ Run database migrations
9. ✅ Set proper permissions

### After Setup

Your application will be running at:
- **Laravel App:** http://localhost:8000
- **Mailhog UI:** http://localhost:8025 (email testing)
- **MySQL:** localhost:3307 (use DBeaver, MySQL Workbench, etc.)

---

## 🐳 Using Docker Hub Image

The pre-built image is available at: **[secrojas/laravel-docker](https://hub.docker.com/r/secrojas/laravel-docker)**

### Pull Image Directly

```bash
docker pull secrojas/laravel-docker:latest
```

### Use in docker-compose.yml

Instead of building locally, reference the pre-built image:

```yaml
services:
  app:
    image: secrojas/laravel-docker:latest  # Use pre-built image
    container_name: laravel_app
    restart: unless-stopped
    working_dir: /var/www
    volumes:
      - ./:/var/www
    networks:
      - laravel_network
```

### Available Tags

- `secrojas/laravel-docker:latest` - Latest stable version
- `secrojas/laravel-docker:1.0.0` - Specific version

---

## 🌐 Services & Ports

| Service | Internal Port | External Port | Description |
|---------|--------------|---------------|-------------|
| **Nginx** | 80 | 8000 | Web server (Laravel frontend) |
| **MySQL** | 3306 | 3307 | Database server |
| **Redis** | 6379 | 6380 | Cache/Sessions/Queues |
| **Mailhog SMTP** | 1025 | 1025 | Email capture (SMTP) |
| **Mailhog UI** | 8025 | 8025 | Email testing interface |
| **PHP-FPM** | 9000 | - | PHP FastCGI processor |

**All ports are configurable via `.env` file.**

---

## 📝 Common Commands

### Container Management

```bash
# Start all containers
docker-compose up -d

# Stop all containers
docker-compose down

# Restart containers
docker-compose restart

# View logs (all services)
docker-compose logs -f

# View logs (specific service)
docker-compose logs -f app
docker-compose logs -f nginx
docker-compose logs -f mysql

# Check container status
docker-compose ps
```

### Laravel Artisan Commands

```bash
# Access container shell
docker-compose exec app bash

# Run migrations
docker-compose exec app php artisan migrate

# Create model with migration and controller
docker-compose exec app php artisan make:model Product -mcr

# Create controller
docker-compose exec app php artisan make:controller ProductController

# Run tests
docker-compose exec app php artisan test

# Clear caches
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear

# Laravel Tinker (REPL)
docker-compose exec app php artisan tinker

# Queue worker
docker-compose exec app php artisan queue:work

# Run database seeder
docker-compose exec app php artisan db:seed
```

### Composer Commands

```bash
# Install dependencies
docker-compose exec app composer install

# Add new package
docker-compose exec app composer require vendor/package

# Update dependencies
docker-compose exec app composer update

# Dump autoload
docker-compose exec app composer dump-autoload
```

### Database Commands

```bash
# Access MySQL CLI
docker-compose exec mysql mysql -u laravel_user -psecret laravel

# Export database
docker-compose exec mysql mysqldump -u laravel_user -psecret laravel > backup.sql

# Import database
docker-compose exec -T mysql mysql -u laravel_user -psecret laravel < backup.sql

# Fresh migration with seeders
docker-compose exec app php artisan migrate:fresh --seed
```

### Makefile Shortcuts

If you have `make` installed, you can use these shortcuts:

```bash
make up          # Start containers
make down        # Stop containers
make shell       # Access app container
make logs        # View all logs
make test        # Run tests
make migrate     # Run migrations
make fresh       # Fresh migration with seeds
make cache-clear # Clear all caches
```

---

## ⚙️ Configuration

### Change Ports (Run Multiple Projects)

Edit `.env` file to change ports:

```env
# Docker Configuration
APP_PORT=8001        # Change from 8000
DB_PORT=3308         # Change from 3307
REDIS_PORT=6381      # Change from 6380
MAILHOG_UI_PORT=8026 # Change from 8025
```

Then restart containers:

```bash
docker-compose down
docker-compose up -d
```

### Database Access

#### From Laravel Application

Already configured in `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306          # Internal port
DB_DATABASE=laravel
DB_USERNAME=laravel_user
DB_PASSWORD=secret
```

#### From Database GUI (DBeaver, MySQL Workbench, etc.)

Use these credentials:

- **Host:** `localhost`
- **Port:** `3307` (external port, configurable)
- **Database:** `laravel`
- **Username:** `laravel_user`
- **Password:** `secret`

**Root access:**
- **Username:** `root`
- **Password:** `root`

### Redis Configuration

Laravel is pre-configured to use Redis for cache, sessions, and queues:

```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379  # Internal port
```

### Email Configuration (Mailhog)

Laravel is pre-configured to send emails to Mailhog:

```env
MAIL_MAILER=smtp
MAIL_HOST=mailhog
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

Access Mailhog UI at: http://localhost:8025

---

## 📁 Project Structure

```
laravel-docker-starter/
├── docker/
│   ├── nginx/
│   │   └── conf.d/
│   │       └── app.conf         # Nginx virtual host configuration
│   └── php/
│       └── local.ini             # PHP configuration (upload limits, etc.)
├── docker-compose.yml            # Services orchestration
├── Dockerfile                    # Custom PHP 8.2-FPM image
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore rules
├── setup.sh                      # Linux/Mac automated setup
├── setup.bat                     # Windows automated setup
├── Makefile                      # Command shortcuts
├── README.md                     # This file
├── QUICK_START.md                # Ultra-quick reference guide
└── DOCKER_HUB_GUIDE.md           # Guide for publishing updates
```

**After running setup, Laravel files will be in the root directory.**

---

## 🔧 Customization

### Add PHP Extensions

Edit `Dockerfile` and rebuild:

```dockerfile
RUN docker-php-ext-install extension_name
```

Then rebuild:

```bash
docker-compose build --no-cache
docker-compose up -d
```

### Add More Services

Edit `docker-compose.yml` to add services like:
- PostgreSQL
- MongoDB
- Elasticsearch
- RabbitMQ
- Soketi (WebSockets)

Example - Add PostgreSQL:

```yaml
postgres:
  image: postgres:15-alpine
  container_name: laravel_postgres
  environment:
    POSTGRES_DB: laravel
    POSTGRES_USER: laravel_user
    POSTGRES_PASSWORD: secret
  ports:
    - "${POSTGRES_PORT:-5432}:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data
  networks:
    - laravel_network

volumes:
  postgres_data:
    driver: local
```

### Modify Nginx Configuration

Edit `docker/nginx/conf.d/app.conf` to customize web server settings:

```nginx
server {
    listen 80;
    index index.php index.html;
    root /var/www/public;

    # Add custom configuration here
    client_max_body_size 100M;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

---

## 🐛 Troubleshooting

### Port Already in Use (Most Common Issue)

**Error message:**
```
Error response from daemon: ports are not available: exposing port TCP 0.0.0.0:3306
bind: Solo se permite un uso de cada dirección de socket
```

**This happens when:** Your local MySQL, Redis, or other services are using the same ports.

**Solution 1: Stop conflicting services (recommended)**
```bash
# Windows - Stop MySQL
net stop MySQL80
# or check running services
netstat -ano | findstr :3306
netstat -ano | findstr :6379

# Linux/Mac - Stop MySQL
sudo systemctl stop mysql
# or
sudo service mysql stop

# Check what's using a port
lsof -i :3306
lsof -i :6379
```

**Solution 2: Change ports in `.env` file**
```env
APP_PORT=8001        # Instead of 8000
DB_PORT=3308         # Instead of 3307
REDIS_PORT=6381      # Instead of 6380
MAILHOG_UI_PORT=8026 # Instead of 8025
MAILHOG_SMTP_PORT=1026 # Instead of 1025
```

After changing ports:
```bash
docker-compose down
docker-compose up -d
```

### Setup Script Command Not Found (Windows)

**Error:** `'setup.bat' is not recognized as an internal or external command`

**Solution:** On Windows, you must use `.\setup.bat` (with `.\` prefix)
```powershell
# Correct:
.\setup.bat

# Wrong:
setup.bat
```

### Service "app" is Not Running

**Error message:**
```
service "app" is not running
```

**This happens when:** The app container failed to start, usually due to port conflicts or build errors.

**Solution:**
1. Check which containers are running:
```bash
docker-compose ps
```

2. Check logs for errors:
```bash
docker-compose logs app
docker-compose logs mysql
docker-compose logs nginx
```

3. If port conflict, see "Port Already in Use" section above

4. If build error, rebuild:
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Vendor/autoload.php Not Found

**Error message:**
```
Warning: require(/var/www/public/../vendor/autoload.php): Failed to open stream: No such file or directory
Fatal error: Failed opening required '/var/www/public/../vendor/autoload.php'
```

**This happens when:** Composer dependencies were not installed properly.

**Solution:**
1. Check if container is running:
```bash
docker-compose ps
```

2. Install dependencies manually:
```bash
docker-compose exec -T app composer install --no-interaction
```

3. If that fails, enter the container and check:
```bash
docker-compose exec app bash
ls -la /var/www/
composer install
```

4. Make sure the setup script completed successfully. If it failed midway, run it again:
```bash
.\setup.bat  # Windows
./setup.sh   # Linux/Mac
```

### Docker Compose Version Warning

**Warning message:**
```
level=warning msg="docker-compose.yml: the attribute `version` is obsolete"
```

**This is safe to ignore.** The warning appears because Docker Compose V2 no longer requires the `version` attribute. The latest version of this project has this fixed, but if you see it, it won't affect functionality.

**To fix:** Update the project files:
```bash
git pull origin main
# or download the latest docker-compose.yml
```

### Permission Denied Errors

**Linux/Mac:**
```bash
docker-compose exec app chmod -R 777 storage bootstrap/cache
```

**Windows:** Permission errors are usually not an issue on Windows with Docker Desktop.

### Container Won't Start

Check logs for specific errors:

```bash
docker-compose logs -f
```

Rebuild from scratch:

```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

### MySQL Connection Refused

**Error:** `SQLSTATE[HY000] [2002] Connection refused`

**This happens when:** MySQL is still starting up (takes 10-30 seconds on first run).

**Solution:**
1. Wait for MySQL to be ready:
```bash
# Check MySQL logs
docker-compose logs mysql | grep "ready for connections"

# Or wait until you see "ready for connections" twice (MySQL 8.0 restarts once)
```

2. The setup script now waits automatically, but if running manual commands, wait 30 seconds:
```bash
# Linux/Mac
until docker-compose exec -T mysql mysql -uroot -proot -e "SELECT 1" > /dev/null 2>&1; do sleep 1; done

# Windows
timeout /t 30 /nobreak
```

### Laravel Shows 500 Error

1. Check `.env` file exists and has `APP_KEY` set:
```bash
docker-compose exec app php artisan key:generate --force
```

2. Check storage permissions (Linux/Mac):
```bash
docker-compose exec app chmod -R 777 storage bootstrap/cache
```

3. Check logs:
```bash
docker-compose logs -f app
docker-compose exec app tail -f storage/logs/laravel.log
```

4. Clear caches:
```bash
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan route:clear
docker-compose exec app php artisan view:clear
```

### Setup Script Hangs or Fails

1. Make sure Docker Desktop is running
2. Check if you have enough disk space (Docker needs at least 10GB)
3. Check your internet connection (downloads images and Composer packages)
4. Try running setup again - it's safe to run multiple times
5. Check logs for specific errors:
```bash
docker-compose logs
```

### Clear Everything and Start Over

If nothing works, start completely fresh:

```bash
# WARNING: This deletes all data!

# Stop and remove containers, volumes, and networks
docker-compose down -v

# Remove local files (be careful with this!)
# Windows (PowerShell)
Remove-Item -Recurse -Force vendor, node_modules, .env -ErrorAction SilentlyContinue

# Linux/Mac
rm -rf vendor node_modules .env

# Rebuild everything
docker-compose build --no-cache
docker-compose up -d

# Run setup again
.\setup.bat  # Windows
./setup.sh   # Linux/Mac
```

### Getting Help

If you still have issues:

1. Check container status:
```bash
docker-compose ps
```

2. Check all logs:
```bash
docker-compose logs
```

3. Create an issue on GitHub with:
   - Your operating system
   - Docker version (`docker --version`)
   - Docker Compose version (`docker-compose --version`)
   - Error messages from logs
   - Output of `docker-compose ps`

---

## 📚 Documentation

- **[Quick Start Guide](QUICK_START.md)** - Ultra-concise reference for experienced users
- **[Docker Hub Publishing Guide](DOCKER_HUB_GUIDE.md)** - How to publish updates to Docker Hub
- **[Laravel Documentation](https://laravel.com/docs)** - Official Laravel docs
- **[Docker Documentation](https://docs.docker.com)** - Docker reference
- **[Docker Compose Documentation](https://docs.docker.com/compose)** - Compose reference

---

## 🔗 Links

- **GitHub Repository:** https://github.com/secrojas/laravel-docker-starter
- **Docker Hub Image:** https://hub.docker.com/r/secrojas/laravel-docker
- **Issues & Support:** https://github.com/secrojas/laravel-docker-starter/issues

---

## 🚀 Production Deployment

**This setup is optimized for development.** For production:

1. Create separate `docker-compose.prod.yml`
2. Remove Mailhog service
3. Use environment variables for all secrets
4. Enable HTTPS/SSL with Let's Encrypt
5. Optimize PHP-FPM worker configuration
6. Use managed database service (AWS RDS, Google Cloud SQL)
7. Implement Redis clustering for scalability
8. Add monitoring and logging (Prometheus, ELK Stack)
9. Set up CI/CD pipeline (GitHub Actions, GitLab CI)

---

## 📄 License

This project is open-source software licensed under the [MIT License](LICENSE).

---

## 👤 Author

**secrojas**

- GitHub: [@secrojas](https://github.com/secrojas)
- Docker Hub: [secrojas/laravel-docker](https://hub.docker.com/r/secrojas/laravel-docker)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## ⭐ Show Your Support

If this project helped you, please give it a **star** on GitHub!

---

## 📝 Changelog

### v1.0.0 (2026-01-09)
- Initial release
- PHP 8.2-FPM with Laravel extensions
- Nginx Alpine configuration
- MySQL 8.0 with persistent storage
- Redis Alpine for caching
- Mailhog for email testing
- Automated setup scripts
- Complete documentation

---

**Built with ❤️ for the Laravel community**
