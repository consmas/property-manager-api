# PropertyManagerAPI - Phase 1 API

Base URL: `/api/v1`

## Authentication

### Login
- `POST /api/v1/auth/login`

```json
{
  "auth": {
    "email": "manager@propertymanager.local",
    "password": "Password123!"
  }
}
```

Response includes:
- `access_token` (JWT, 30 minutes)
- `refresh_token` (rotating, 30 days)

### Refresh Session
- `POST /api/v1/auth/refresh`

```json
{
  "auth": {
    "refresh_token": "<refresh_token>"
  }
}
```

### Logout
- `DELETE /api/v1/auth/logout`

```json
{
  "auth": {
    "refresh_token": "<refresh_token>"
  }
}
```

## Authenticated Endpoints

Add header:
- `Authorization: Bearer <access_token>`

### Properties (scoped)
- `GET /api/v1/properties`
- `GET /api/v1/properties/:id`

### Create Lease (auto rent schedule)
- `POST /api/v1/leases`

```json
{
  "lease": {
    "property_id": "<uuid>",
    "unit_id": "<uuid>",
    "tenant_id": "<uuid>",
    "start_date": "2026-03-01",
    "end_date": "2027-03-01",
    "plan_months": 12,
    "status": "active",
    "rent_cents": 185000,
    "security_deposit_cents": 185000
  }
}
```

`rent_cents` is monthly rent, but billing is generated as a single term invoice based on `plan_months`:
- 3 months: `rent_cents * 3`
- 6 months: `rent_cents * 6`
- 12 months: `rent_cents * 12`

### Create Payment (auto allocation to oldest unpaid invoices)
- `POST /api/v1/payments`

```json
{
  "payment": {
    "property_id": "<uuid>",
    "tenant_id": "<uuid>",
    "reference": "PMT-2026-0001",
    "payment_method": "bank_transfer",
    "amount_cents": 185000,
    "paid_at": "2026-02-26T14:00:00Z",
    "notes": "February rent"
  }
}
```

### Online Payments (Rent & Utilities)

#### Create Online Payment Intent
- `POST /api/v1/online_payments`

```json
{
  "online_payment": {
    "property_id": "<uuid>",
    "tenant_id": "<uuid>",
    "invoice_id": "<uuid>",
    "amount_cents": 120000,
    "purpose": "rent",
    "channel": "mobile_money",
    "provider": "hubtel"
  }
}
```

`purpose` supports: `rent`, `utilities`, `mixed`  
`channel` supports: `mobile_money`, `card`, `bank_transfer`  
`provider` supports: `hubtel`, `zeepay`

#### List / View Online Payments
- `GET /api/v1/online_payments`
- `GET /api/v1/online_payments/:id`

#### Confirm Online Payment (provider success callback flow)
- `POST /api/v1/online_payments/:id/confirm`

```json
{
  "online_payment": {
    "provider_reference": "PSK-TRX-123",
    "paid_at": "2026-02-27T12:00:00Z",
    "callback_payload": {
      "status": "success"
    }
  }
}
```

This creates a posted `Payment` record and allocates it to the target invoice first (if provided), then oldest unpaid invoices.

#### Mark Online Payment Failed
- `POST /api/v1/online_payments/:id/fail`

```json
{
  "online_payment": {
    "provider_reference": "PSK-TRX-123",
    "failure_reason": "Declined by issuer",
    "callback_payload": {
      "status": "failed"
    }
  }
}
```

#### Provider Webhooks (no bearer token)
- `POST /api/v1/payment_webhooks/hubtel`
- `POST /api/v1/payment_webhooks/zeepay`

Webhook handlers automatically:
- match by `reference`/`provider_reference`
- mark online payment `succeeded` or `failed`
- create and allocate ledger `Payment` when successful

### Create Maintenance Request
- `POST /api/v1/maintenance_requests`

```json
{
  "maintenance_request": {
    "property_id": "<uuid>",
    "unit_id": "<uuid>",
    "tenant_id": "<uuid>",
    "title": "Kitchen tap leaking",
    "description": "Tap keeps dripping",
    "priority": "medium",
    "status": "open",
    "requested_at": "2026-02-26T11:30:00Z"
  }
}
```

## Background Jobs
- `MonthlyWaterInvoiceJob.perform_later(property_id, billing_month)`
- Uses finalized water meter readings for the month and creates water invoices.

## JSON:API Response Shape

Success:

```json
{
  "data": {
    "id": "<uuid>",
    "type": "properties",
    "attributes": {}
  }
}
```

Errors:

```json
{
  "errors": [
    {
      "status": "422",
      "title": "Validation Error",
      "detail": "Rent cents can't be blank"
    }
  ]
}
```
