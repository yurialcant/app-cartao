# API Documentation Template

**Service**: [Service Name]  
**Version**: 1.0  
**Author**: [Team]  
**Last Updated**: YYYY-MM-DD  

---

## Overview

[Brief description of the API]

---

## Authentication

- **Type**: Bearer Token (JWT)
- **Header**: `Authorization: Bearer <token>`
- **Token Source**: Keycloak

---

## Base URL

```
https://api.example.com/v1/[service-name]
```

---

## Common Headers

```
Authorization: Bearer <token>
X-Tenant-ID: <tenant-uuid>
X-Correlation-ID: <correlation-uuid>
Idempotency-Key: <idempotency-key>
Content-Type: application/json
```

---

## Endpoints

### [Operation Name]

**Endpoint**: `[METHOD] /[path]`

**Description**: [What this does]

**Request**:
```json
{
  "field1": "type",
  "field2": 123
}
```

**Response** (200 OK):
```json
{
  "status": "SUCCESS",
  "data": {
    "id": "uuid",
    "created_at": "2026-01-16T00:00:00Z"
  },
  "correlation_id": "uuid"
}
```

**Error** (422 Unprocessable Entity):
```json
{
  "type": "https://api.example.com/errors/business-rule-violation",
  "title": "Business Rule Violation",
  "status": 422,
  "detail": "Description of what went wrong",
  "correlation_id": "uuid"
}
```

**Status Codes**:
- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success, no content
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Not authenticated
- `403 Forbidden` - Not authorized
- `404 Not Found` - Resource not found
- `409 Conflict` - Idempotency conflict or version mismatch
- `422 Unprocessable Entity` - Business rule violation
- `500 Internal Server Error` - Server error

---

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| INVALID_TENANT | 400 | Tenant not found or invalid |
| UNAUTHORIZED | 401 | Authentication failed |
| FORBIDDEN | 403 | Authorization failed |
| NOT_FOUND | 404 | Resource not found |
| CONFLICT_IDEMPOTENCY | 409 | Duplicate idempotency key |
| CONFLICT_VERSION | 409 | Version mismatch |
| INVALID_REQUEST | 400 | Invalid request |
| BUSINESS_RULE_VIOLATION | 422 | Business rule violated |
| INTERNAL_SERVER_ERROR | 500 | Server error |

---

## OpenAPI / Swagger

[Link to OpenAPI spec]

---

## Examples

### Example 1: [Scenario]

Request:
```bash
curl -X POST https://api.example.com/v1/service/resource \
  -H "Authorization: Bearer <token>" \
  -H "X-Tenant-ID: <tenant-id>" \
  -H "Content-Type: application/json" \
  -d '{...}'
```

Response:
```json
{...}
```

---

## Pagination

**Parameters**:
- `limit`: Number of records (default: 20, max: 100)
- `cursor` or `offset`: Pagination token or offset
- `sort`: Sort order (e.g., `-created_at` for descending)

**Response**:
```json
{
  "data": [...],
  "pagination": {
    "cursor": "...",
    "has_more": true,
    "next_cursor": "..."
  }
}
```

---

## Rate Limiting

**Headers**:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1705416600
```

**Limits**:
- Public: 100 req/min
- Authenticated: 10,000 req/hour
- Internal: Unlimited

---

## Changelog

### v1.0 (2026-01-16)
- Initial release
