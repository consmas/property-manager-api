# PropertyManagerAPI

Production-oriented Rails API for multi-property management.

## Stack
- Rails 8 (API mode)
- PostgreSQL
- JWT auth + refresh tokens
- Sidekiq jobs
- UUID primary keys
- Money values in integer cents

## Phase 1 Included
- Users + roles (`owner`, `admin`, `property_manager`, `caretaker`, `accountant`, `tenant`)
- Property-level scoping via memberships
- Core domain models (property, unit, tenant, lease, invoices, payments, maintenance, metering)
- Lease rent schedule generation for 3/6/12 month plans
- Payment allocation to oldest unpaid invoices
- Paid-through-date updates on lease payment progress
- Monthly water billing service + background job
- Audit logs for financial actions
- JSON:API-style success/error envelopes
- Versioned API under `/api/v1`

## Environment Variables
- `JWT_SECRET_KEY` (recommended in production)
- `REDIS_URL` (default `redis://localhost:6379/0`)
- `CORS_ALLOWED_ORIGINS` (comma-separated, default `*`)
- `ONLINE_PAYMENTS_MOCK` (`true` for local/dev stubs, `false` for real provider calls)
- `HUBTEL_INITIATE_URL`, `HUBTEL_CLIENT_ID`, `HUBTEL_CLIENT_SECRET`, `HUBTEL_CALLBACK_URL`
- `ZEEPAY_INITIATE_URL`, `ZEEPAY_API_KEY`, `ZEEPAY_CALLBACK_URL`

## Setup (Postgres in Docker, Rails local)
```bash
cp .env.docker.example .env
docker compose up -d db
bundle install
bin/rails db:create db:migrate db:seed
```

## Run (Rails local)
```bash
bin/rails server
```

Optional (if using background jobs and local Redis is running):
```bash
bundle exec sidekiq
```

## Docs
- API guide: `docs/API.md`
- Postman collection: `docs/postman_collection.json`

## Seed Login
- `owner@propertymanager.local` / `Password123!`
- `manager@propertymanager.local` / `Password123!`
