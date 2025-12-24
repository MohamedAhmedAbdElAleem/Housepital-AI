# API Overview

## Base Configuration

### Base URL
```
Development: http://localhost:3500/api
Production: https://api.housepital.com/api
```

### API Version
- Current Version: **1.0.0**
- Release Date: January 15, 2024

### Content Types

**Request**:
```
Content-Type: application/json
```

**Response**:
```
Content-Type: application/json; charset=utf-8
```

## Standard Response Format

All API responses follow a consistent JSON structure.

### Success Response
```json
{
  "success": true,
  "message": "Operation description",
  "data": { /* response data */ } or [ /* array data */ ],
  "token": null | "jwt_token_here"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [
    {
      "field": "fieldName",
      "message": "Specific error message"
    }
  ]
}
```

## HTTP Methods

| Method | Purpose | Idempotent | Safe |
|--------|---------|-----------|------|
| GET | Retrieve data | Yes | Yes |
| POST | Create resource | No | No |
| PUT | Update resource | Yes | No |
| PATCH | Partial update | No | No |
| DELETE | Delete resource | Yes | No |

## Request/Response Cycle

```
Client Request
    ↓
Express Middleware
    ↓
Route Handler
    ↓
Validation
    ↓
Business Logic
    ↓
Database Operation
    ↓
Response Formatting
    ↓
Client Response
```

## Authentication

### Current Implementation (v1.0.0)
- Status: **Not required** for register/login
- Method: None

### Future Implementation (v1.1.0)
- Status: **Required** for protected endpoints
- Method: JWT Bearer tokens
- Header: `Authorization: Bearer <token>`

## Request Headers

### Required Headers
```
Content-Type: application/json
```

### Optional Headers
```
Authorization: Bearer <token>          (for protected endpoints)
X-Request-ID: <unique-id>             (for tracking)
User-Agent: <client-info>             (client information)
```

## Response Headers

```
Content-Type: application/json; charset=utf-8
Date: Mon, 15 Jan 2024 10:30:00 GMT
Server: Express
Connection: keep-alive
X-Response-Time: 145ms
```

## Rate Limiting (Recommended)

### Default Limits
| Endpoint | Limit | Window |
|----------|-------|--------|
| POST /register | 3 | per hour per IP |
| POST /login | 5 | per 15 minutes per IP |
| GET /me | 10 | per minute per user |

### Rate Limit Headers (Future)
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1705318200
```

## CORS Configuration

### Allowed Origins (Configurable)
```
http://localhost:3000
http://localhost:3001
https://housepital.com
https://app.housepital.com
```

### Allowed Methods
```
GET, POST, PUT, DELETE, PATCH, OPTIONS
```

### Allowed Headers
```
Content-Type
Authorization
X-Request-ID
```

## Pagination (Future)

When implemented, use query parameters:

```
GET /api/users?page=1&limit=20
```

### Parameters
| Parameter | Type | Default | Max |
|-----------|------|---------|-----|
| page | number | 1 | N/A |
| limit | number | 20 | 100 |

### Response Format
```json
{
  "success": true,
  "data": [ /* items */ ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 500,
    "pages": 25
  }
}
```

## Filtering (Future)

Query parameters for filtering:

```
GET /api/users?role=customer&isVerified=true
```

## Sorting (Future)

Sort by any field:

```
GET /api/users?sort=createdAt              // ascending
GET /api/users?sort=-createdAt             // descending
```

## Timeout Configuration

### Request Timeout
- **Duration**: 30 seconds
- **Error**: 408 Request Timeout

### Connection Timeout
- **Duration**: 10 seconds
- **Error**: Connection refused

## Request Size Limits

| Limit | Size |
|-------|------|
| Maximum Request Size | 1 MB |
| Maximum Response Size | 5 MB |
| Maximum Payload | 512 KB |

## Response Time Targets

| Endpoint | Target | Acceptable | Max |
|----------|--------|-----------|-----|
| POST /register | < 500ms | < 1s | 2s |
| POST /login | < 300ms | < 1s | 2s |
| GET /me | < 100ms | < 500ms | 1s |

## Status Codes Summary

| Code | Category | Meaning |
|------|----------|---------|
| 200 | Success | Request succeeded |
| 201 | Success | Resource created |
| 400 | Client Error | Bad request |
| 401 | Client Error | Unauthorized |
| 403 | Client Error | Forbidden |
| 404 | Client Error | Not found |
| 429 | Client Error | Too many requests |
| 500 | Server Error | Internal error |
| 502 | Server Error | Bad gateway |
| 503 | Server Error | Service unavailable |

## Versioning Strategy

### URL Versioning
```
/api/v1/auth/register
/api/v2/auth/register
```

### Header Versioning
```
Accept: application/vnd.housepital.v1+json
```

## Error Handling

### Validation Errors (400)
- Multiple field errors possible
- Each field has specific message

### Authentication Errors (401)
- Invalid credentials
- Missing or invalid token

### Authorization Errors (403)
- User lacks required permission
- User role insufficient

### Server Errors (500)
- Unexpected exception
- Database unavailable
- Third-party service failure

## Data Formats

### Dates
```
ISO 8601 Format: 2024-01-15T10:30:00.000Z
```

### Monetary Values
```
As numbers with 2 decimal places: 99.99
```

### Booleans
```
true or false (lowercase)
```

### Null Values
```
null (not omitted, explicitly null)
```

## HTTP Headers Best Practices

### Security Headers (Recommended)
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

### CORS Headers
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Allow-Credentials: true
```

## Request Examples

### Simple GET Request
```
GET /api/auth/me HTTP/1.1
Host: localhost:3500
Content-Type: application/json
Authorization: Bearer token_here
```

### POST with JSON Body
```
POST /api/auth/register HTTP/1.1
Host: localhost:3500
Content-Type: application/json
Content-Length: 142

{
  "name": "John Doe",
  "email": "john@example.com",
  "mobile": "1234567890",
  "password": "SecurePass123!",
  "confirmPassword": "SecurePass123!"
}
```

## Performance Considerations

1. **Minimize Requests** - Combine data when possible
2. **Cache Responses** - Cache user data 5-10 minutes
3. **Compress Data** - Enable gzip compression
4. **Optimize Queries** - Use database indexes
5. **Monitor Performance** - Track response times

## API Lifecycle

```
Development → Testing → Staging → Production → Monitoring → Maintenance
```

## Support

For API questions:
- 📖 See [Authentication Guide](./authentication.md)
- 🔍 Check [Error Handling](./error-handling.md)
- 📊 Review [Data Models](./data-models.md)

---

**Version**: 1.0.0  
**Last Updated**: November 13, 2025
