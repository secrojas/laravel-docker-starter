# Docker Hub Publishing Guide

Guía completa para publicar tu imagen Laravel Docker en Docker Hub como `secrojas/laravel-docker`.

---

## Requisitos Previos

1. **Cuenta en Docker Hub:**
   - Crear cuenta en https://hub.docker.com
   - Username: `secrojas`

2. **Docker instalado localmente:**
   ```bash
   docker --version
   ```

---

## Paso 1: Login en Docker Hub

```bash
docker login
```

Ingresa tus credenciales:
- **Username:** `secrojas`
- **Password:** [tu password de Docker Hub]

Deberías ver:
```
Login Succeeded
```

---

## Paso 2: Build de la Imagen

### Opción A: Build Simple

```bash
cd laravel-docker-starter
docker build -t secrojas/laravel-docker:latest .
```

### Opción B: Build Multi-tag (Recomendado)

```bash
# Tag latest
docker build -t secrojas/laravel-docker:latest .

# Tag con versión específica
docker build -t secrojas/laravel-docker:1.0.0 .

# Tag con versión de PHP
docker build -t secrojas/laravel-docker:php8.2 .
```

### Verificar la imagen creada

```bash
docker images | grep secrojas
```

Deberías ver algo como:
```
secrojas/laravel-docker   latest    abc123def456   2 minutes ago   500MB
secrojas/laravel-docker   1.0.0     abc123def456   2 minutes ago   500MB
```

---

## Paso 3: Push a Docker Hub

### Push tag latest

```bash
docker push secrojas/laravel-docker:latest
```

### Push versiones específicas

```bash
docker push secrojas/laravel-docker:1.0.0
docker push secrojas/laravel-docker:php8.2
```

**Esto puede tardar varios minutos** dependiendo del tamaño de la imagen (~500MB).

Verás algo como:
```
The push refers to repository [docker.io/secrojas/laravel-docker]
abc123: Pushed
def456: Pushed
...
latest: digest: sha256:abc... size: 1234
```

---

## Paso 4: Verificar en Docker Hub

1. Ve a https://hub.docker.com
2. Login con tu cuenta
3. Deberías ver tu repositorio: `secrojas/laravel-docker`
4. Verás los tags: `latest`, `1.0.0`, `php8.2`

---

## Paso 5: Actualizar README en Docker Hub

1. Ve a tu repositorio en Docker Hub
2. Click en la pestaña "Description"
3. Copia el contenido del `README.md` principal
4. Pégalo y guarda

---

## Usar la Imagen Publicada

### Opción 1: Docker Pull Directo

```bash
docker pull secrojas/laravel-docker:latest
```

### Opción 2: En docker-compose.yml

Reemplaza:
```yaml
build:
  context: .
  dockerfile: Dockerfile
image: secrojas/laravel-docker:latest
```

Con:
```yaml
image: secrojas/laravel-docker:latest
```

Esto descargará la imagen de Docker Hub en lugar de construirla localmente.

---

## Actualizar la Imagen (Nuevas Versiones)

Cuando hagas cambios al Dockerfile:

```bash
# 1. Build con nuevo tag de versión
docker build -t secrojas/laravel-docker:latest .
docker build -t secrojas/laravel-docker:1.1.0 .

# 2. Push ambos tags
docker push secrojas/laravel-docker:latest
docker push secrojas/laravel-docker:1.1.0
```

### Versionado Semántico

Usa [Semantic Versioning](https://semver.org/):

- **1.0.0** → Primera release
- **1.0.1** → Bug fix
- **1.1.0** → Nueva feature (backward compatible)
- **2.0.0** → Breaking changes

Ejemplos:
```bash
# Patch (bug fix)
docker build -t secrojas/laravel-docker:1.0.1 .
docker push secrojas/laravel-docker:1.0.1

# Minor (nueva feature)
docker build -t secrojas/laravel-docker:1.1.0 .
docker push secrojas/laravel-docker:1.1.0

# Major (breaking change)
docker build -t secrojas/laravel-docker:2.0.0 .
docker push secrojas/laravel-docker:2.0.0
```

---

## Configurar Repositorio en Docker Hub

### 1. Descripción Corta
```
Production-ready Docker environment for Laravel with Nginx, MySQL, Redis, and Mailhog
```

### 2. Descripción Completa
Usa el contenido del `README.md` principal.

### 3. Tags Recomendados

| Tag | Descripción |
|-----|-------------|
| `latest` | Última versión estable |
| `1.0.0` | Versión específica |
| `php8.2` | PHP version tag |
| `dev` | Versión de desarrollo |

### 4. Hacer Público el Repositorio
Por defecto es público, pero verifica en Settings.

---

## Script de Build y Push Automatizado

Crea `publish.sh`:

```bash
#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./publish.sh <version>"
    echo "Example: ./publish.sh 1.0.0"
    exit 1
fi

echo "Building secrojas/laravel-docker:$VERSION and :latest"

# Build
docker build -t secrojas/laravel-docker:latest .
docker build -t secrojas/laravel-docker:$VERSION .

# Push
echo "Pushing to Docker Hub..."
docker push secrojas/laravel-docker:latest
docker push secrojas/laravel-docker:$VERSION

echo "✅ Published secrojas/laravel-docker:$VERSION and :latest"
```

Uso:
```bash
chmod +x publish.sh
./publish.sh 1.0.0
```

Windows (`publish.bat`):
```batch
@echo off
set VERSION=%1

if "%VERSION%"=="" (
    echo Usage: publish.bat version
    echo Example: publish.bat 1.0.0
    exit /b
)

echo Building secrojas/laravel-docker:%VERSION% and :latest

docker build -t secrojas/laravel-docker:latest .
docker build -t secrojas/laravel-docker:%VERSION% .

echo Pushing to Docker Hub...
docker push secrojas/laravel-docker:latest
docker push secrojas/laravel-docker:%VERSION%

echo ✅ Published secrojas/laravel-docker:%VERSION% and :latest
```

---

## Optimizar Tamaño de la Imagen

### 1. Multi-Stage Build

```dockerfile
# Build stage
FROM composer:latest AS build
WORKDIR /app
# ... build steps ...

# Final stage
FROM php:8.2-fpm
COPY --from=build /app /var/www
# ... resto de config ...
```

### 2. .dockerignore

Crea `.dockerignore`:
```
.git
.env
node_modules
vendor
storage/logs/*
storage/framework/cache/*
tests
.phpunit.result.cache
```

### 3. Limpiar cache APT

```dockerfile
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
```

---

## GitHub Actions (CI/CD Automatizado)

Crea `.github/workflows/docker-publish.yml`:

```yaml
name: Docker Build and Push

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            secrojas/laravel-docker:latest
            secrojas/laravel-docker:${{ github.ref_name }}
```

**Configurar secrets en GitHub:**
1. Settings → Secrets → New repository secret
2. `DOCKERHUB_USERNAME`: `secrojas`
3. `DOCKERHUB_TOKEN`: (crear en Docker Hub → Account Settings → Security)

**Publicar nueva versión:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions automáticamente construirá y publicará la imagen.

---

## Comandos de Referencia Rápida

```bash
# Login
docker login

# Build
docker build -t secrojas/laravel-docker:latest .

# Tag adicional
docker tag secrojas/laravel-docker:latest secrojas/laravel-docker:1.0.0

# Push
docker push secrojas/laravel-docker:latest
docker push secrojas/laravel-docker:1.0.0

# Pull (para usar)
docker pull secrojas/laravel-docker:latest

# Ver imágenes locales
docker images | grep secrojas

# Eliminar imagen local
docker rmi secrojas/laravel-docker:latest

# Ver info de imagen
docker inspect secrojas/laravel-docker:latest
```

---

## Troubleshooting

### Error: "denied: requested access to the resource is denied"

**Solución:** Verificar que estás logueado:
```bash
docker logout
docker login
```

### Error: "no basic auth credentials"

**Solución:** Login nuevamente con credenciales correctas.

### Push muy lento

**Solución:**
- Verifica tu conexión a internet
- La primera vez tarda más (sube todas las capas)
- Siguientes pushes son incrementales (más rápidos)

### Imagen muy grande (> 1GB)

**Solución:**
- Usar Alpine images cuando sea posible
- Implementar multi-stage builds
- Limpiar caches en Dockerfile
- Usar .dockerignore

---

## URLs Útiles

- **Tu repositorio:** https://hub.docker.com/r/secrojas/laravel-docker
- **Docker Hub:** https://hub.docker.com
- **Documentación:** https://docs.docker.com/docker-hub/

---

## Resumen del Flujo Completo

```bash
# 1. Desarrollo local
cd laravel-docker-starter
# ... hacer cambios al Dockerfile ...

# 2. Test local
docker-compose build
docker-compose up -d
# ... verificar que funciona ...

# 3. Build para producción
docker build -t secrojas/laravel-docker:latest .
docker build -t secrojas/laravel-docker:1.0.0 .

# 4. Login a Docker Hub
docker login

# 5. Push
docker push secrojas/laravel-docker:latest
docker push secrojas/laravel-docker:1.0.0

# 6. Usar en otros proyectos
cd mi-nuevo-proyecto
# En docker-compose.yml usar:
# image: secrojas/laravel-docker:latest
docker-compose up -d
```

---

**¡Listo!** Tu imagen está publicada y disponible para todo el mundo (o solo para ti si la haces privada).
