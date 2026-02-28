# PropertyManagerAPI Production Runbook

This runbook deploys `property-manager-api` with strict isolation from existing apps.

## 1) Directory Layout

```text
/opt/property-manager-api/
  Dockerfile
  docker-compose.production.yml
  .env.production
  deploy/nginx/propertyapi.consmas.com.conf
  docs/ops/property-manager-api-production-runbook.md
  backups/
```

## 2) One-Time Setup

```bash
cd /opt
git clone https://github.com/consmas/property-manager-api.git
cd /opt/property-manager-api
cp .env.production.example .env.production
chmod 600 .env.production
mkdir -p /opt/property-manager-api/backups
```

Fill `.env.production` securely (never commit).

## 3) Build and First Deploy

```bash
cd /opt/property-manager-api

docker compose -p property-manager -f docker-compose.production.yml build
docker compose -p property-manager -f docker-compose.production.yml up -d

docker compose -p property-manager -f docker-compose.production.yml run --rm api bin/rails db:migrate
# Run seed only if idempotent and approved:
# docker compose -p property-manager -f docker-compose.production.yml run --rm api bin/rails db:seed
```

## 4) Reverse Proxy + TLS (Nginx)

```bash
sudo cp deploy/nginx/propertyapi.consmas.com.conf /etc/nginx/sites-available/propertyapi.consmas.com
sudo ln -s /etc/nginx/sites-available/propertyapi.consmas.com /etc/nginx/sites-enabled/propertyapi.consmas.com
sudo nginx -t
sudo systemctl reload nginx

# Certbot example
sudo certbot --nginx -d propertyapi.consmas.com
```

## 5) Health Checks

```bash
docker compose -p property-manager -f docker-compose.production.yml ps
docker compose -p property-manager -f docker-compose.production.yml logs --tail=200 api
docker compose -p property-manager -f docker-compose.production.yml logs --tail=200 sidekiq
curl -fsS http://127.0.0.1:3011/up
curl -fsS https://propertyapi.consmas.com/up
```

Expected:
- `api`, `sidekiq`, `db`, `redis` are `Up` and healthy.
- `/up` returns HTTP 200.

## 6) Zero-Impact Verification for Existing App

Run BEFORE and AFTER deploying this stack:

```bash
# Existing app checks (replace with actual domain/port)
curl -fsS https://<existing-app-domain>/up
# Add existing app smoke tests here
```

Also compare:
- existing app error rate
- existing DB latency/CPU
- existing Sidekiq queue latency

## 7) Backup Procedure

### Postgres backup

```bash
mkdir -p /opt/property-manager-api/backups

docker compose -p property-manager -f docker-compose.production.yml exec -T db \
  pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" \
  > /opt/property-manager-api/backups/property_manager_$(date +%F_%H%M%S).sql
```

### Redis persistence
Redis AOF is enabled in this stack (`--appendonly yes`).

## 8) Update / Release Workflow

```bash
cd /opt/property-manager-api
git fetch origin
git pull --no-rebase origin main

docker compose -p property-manager -f docker-compose.production.yml build
docker compose -p property-manager -f docker-compose.production.yml up -d
docker compose -p property-manager -f docker-compose.production.yml run --rm api bin/rails db:migrate

curl -fsS https://propertyapi.consmas.com/up
```

## 9) Rollback Procedure

1. Identify previous known-good commit/tag.
2. Checkout previous revision.
3. Rebuild and restart stack.
4. If needed, run backward migration plan (`db:rollback` or prepared migration rollback).
5. Re-check health endpoint and key APIs.
6. Record incident details.

Commands:

```bash
cd /opt/property-manager-api
git log --oneline -n 10
git checkout <previous-good-commit>

docker compose -p property-manager -f docker-compose.production.yml build
docker compose -p property-manager -f docker-compose.production.yml up -d

# Optional rollback migration when explicitly validated:
# docker compose -p property-manager -f docker-compose.production.yml run --rm api bin/rails db:rollback STEP=1

curl -fsS https://propertyapi.consmas.com/up
```

## 10) Security Checklist

- `.env.production` permissions are `600`.
- DB/Redis are not exposed to public internet.
- Firewall allows only 80/443 (+ SSH from trusted IPs).
- Secrets are externalized and rotated before go-live.
- Logs are reviewed for accidental secret leakage.
