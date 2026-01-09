# Quick Start Guide

Guía ultra-rápida para usar este template en nuevos proyectos.

---

## Para Tu Próximo Proyecto Laravel

### 1. Clonar el template
```bash
git clone https://github.com/secrojas/laravel-docker-starter.git mi-nuevo-proyecto
cd mi-nuevo-proyecto
```

### 2. Ejecutar setup
```bash
# Windows
setup.bat

# Linux/Mac
chmod +x setup.sh
./setup.sh
```

### 3. Listo!
- App: http://localhost:8000
- Mailhog: http://localhost:8025

---

## Si Ya Publicaste la Imagen en Docker Hub

En `docker-compose.yml`, cambia:

```yaml
# ANTES (build local)
build:
  context: .
  dockerfile: Dockerfile
image: secrojas/laravel-docker:latest

# DESPUÉS (usa imagen de Docker Hub)
image: secrojas/laravel-docker:latest
```

Ventaja: **No necesitas construir**, descarga directo de Docker Hub (más rápido).

---

## Publicar en Docker Hub (Solo Primera Vez)

```bash
# 1. Login
docker login

# 2. Build
docker build -t secrojas/laravel-docker:latest .
docker build -t secrojas/laravel-docker:1.0.0 .

# 3. Push
docker push secrojas/laravel-docker:latest
docker push secrojas/laravel-docker:1.0.0
```

Luego ya puedes usar `image: secrojas/laravel-docker:latest` en otros proyectos.

**Ver guía completa:** `DOCKER_HUB_GUIDE.md`

---

## Cambiar Puertos (Múltiples Proyectos)

Si ya tienes otro proyecto en 8000:

**.env:**
```env
APP_PORT=8001
DB_PORT=3308
REDIS_PORT=6381
MAILHOG_UI_PORT=8026
```

```bash
docker-compose down
docker-compose up -d
```

---

## Comandos Esenciales

```bash
# Levantar
docker-compose up -d

# Bajar
docker-compose down

# Ver logs
docker-compose logs -f

# Entrar al contenedor
docker-compose exec app bash

# Artisan
docker-compose exec app php artisan migrate
docker-compose exec app php artisan make:model Product -m

# Tests
docker-compose exec app php artisan test

# MySQL
docker-compose exec mysql mysql -u laravel_user -psecret laravel
```

---

## Estructura Después del Setup

```
mi-proyecto/
├── app/              # Laravel app
├── database/         # Migrations, seeds
├── routes/           # API, web routes
├── tests/            # Tests
├── docker/           # Docker configs
├── docker-compose.yml
├── .env
└── ...
```

---

## Tips

✅ **Cambiar nombre de proyecto:** Edita `APP_NAME` en `.env`

✅ **Conectar desde Tinker:**
```bash
docker-compose exec app php artisan tinker
App\Models\User::all();
```

✅ **Ver estructura de BD:**
```bash
docker-compose exec mysql mysql -u laravel_user -psecret laravel -e "SHOW TABLES;"
```

✅ **Limpiar todo y empezar de cero:**
```bash
docker-compose down -v
docker-compose up -d
./setup.sh
```

---

¡Eso es todo! Ahora tienes Laravel corriendo en Docker en minutos. 🚀
