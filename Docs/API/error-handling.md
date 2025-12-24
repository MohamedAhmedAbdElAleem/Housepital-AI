# Error Handling

## Standard Error Response Format

```json
{
  "success": false,
  "message": "Human-readable error message",
  "errors": [
    {
      "field": "fieldName",
      "message": "Specific field error message"
    }
  ]
}
```

---

## HTTP Status Codes

### 2xx Success Codes

| Code | Name | Meaning |
|------|------|---------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |

### 4xx Client Error Codes

| Code | Name | Meaning | When |
|------|------|---------|------|
| 400 | Bad Request | Invalid input or validation failed | Validation errors, duplicate users |
| 401 | Unauthorized | Invalid credentials or missing token | Wrong password, missing auth |
| 403 | Forbidden | Access denied | Insufficient permissions |
| 404 | Not Found | Resource not found | User/resource doesn't exist |
| 429 | Too Many Requests | Rate limit exceeded | Too many requests |

### 5xx Server Error Codes

| Code | Name | Meaning | When |
|------|------|---------|------|
| 500 | Internal Server Error | Unexpected error | Unhandled exception |
| 502 | Bad Gateway | Gateway error | Upstream service down |
| 503 | Service Unavailable | Service temporarily down | Maintenance or overload |

---

## Common Error Scenarios

### Validation Errors (400)

**Missing Required Field**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

**Invalid Email Format**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address"
    }
  ]
}
```

**Invalid Mobile Format**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "mobile",
      "message": "Mobile number must be 10-15 digits"
    }
  ]
}
```

**Name Too Short**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "name",
      "message": "Name must be at least 2 characters"
    }
  ]
}
```

**Password Too Short**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "password",
      "message": "Password must be at least 8 characters"
    }
  ]
}
```

**Weak Password**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "password",
      "message": "Password must contain uppercase, lowercase, number, and special character"
    }
  ]
}
```

**Passwords Don't Match**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "confirmPassword",
      "message": "Passwords do not match"
    }
  ]
}
```

### Multiple Validation Errors

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "name",
      "message": "Name must be at least 2 characters"
    },
    {
      "field": "email",
      "message": "Please provide a valid email address"
    },
    {
      "field": "password",
      "message": "Password must be at least 8 characters"
    }
  ]
}
```

### Duplicate User Errors (400)

**Duplicate Email**:
```json
{
  "success": false,
  "message": "A user with this email already exists"
}
```

**Duplicate Mobile**:
```json
{
  "success": false,
  "message": "A user with this mobile already exists"
}
```

### Authentication Errors (401)

**Invalid Credentials**:
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

**Missing Token**:
```json
{
  "success": false,
  "message": "No token provided"
}
```

**Invalid Token**:
```json
{
  "success": false,
  "message": "Invalid or expired token"
}
```

**Not Authenticated**:
```json
{
  "success": false,
  "message": "Not authenticated"
}
```

### Authorization Errors (403)

**Insufficient Permissions**:
```json
{
  "success": false,
  "message": "Access denied. Required role: admin"
}
```

**Email Not Verified**:
```json
{
  "success": false,
  "message": "Please verify your email first"
}
```

### Not Found Errors (404)

**User Not Found**:
```json
{
  "success": false,
  "message": "User not found"
}
```

### Rate Limiting Errors (429)

**Too Many Requests**:
```json
{
  "success": false,
  "message": "Too many login attempts. Please try again in 15 minutes"
}
```

### Server Errors (500)

**Database Error**:
```json
{
  "success": false,
  "message": "Error registering user"
}
```

**Unexpected Error**:
```json
{
  "success": false,
  "message": "An unexpected error occurred"
}
```

---

## Error Field Reference

### Validation Error Fields

| Field | Description | Example |
|-------|-------------|---------|
| name | User's full name | "John must be 2-50 characters" |
| email | User's email address | "Invalid email format" |
| mobile | User's phone number | "Must be 10-15 digits" |
| password | User's password | "Must contain uppercase letter" |
| confirmPassword | Password confirmation | "Passwords do not match" |

---

## Error Handling Best Practices

### Client-Side

1. **Check `success` field first**
   ```javascript
   if (response.success) {
     // Handle success
   } else {
     // Handle error
   }
   ```

2. **Display validation errors**
   ```javascript
   if (response.errors) {
     response.errors.forEach(error => {
       console.error(`${error.field}: ${error.message}`);
     });
   }
   ```

3. **Retry on server errors**
   ```javascript
   if (status === 500) {
     // Retry after delay
   }
   ```

4. **Handle timeouts**
   ```javascript
   try {
     const response = await Promise.race([
       fetch(url),
       new Promise((_, reject) => 
         setTimeout(() => reject('Timeout'), 30000)
       )
     ]);
   } catch (error) {
     console.error('Request timeout');
   }
   ```

### Server-Side

1. **Log all errors** (without sensitive data)
2. **Return appropriate status codes**
3. **Provide clear error messages** (without technical details)
4. **Include field-specific errors**
5. **Don't expose internal errors**

---

## Rate Limiting Response Headers

When rate limiting is implemented:

```
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1705318200
Retry-After: 900

{
  "success": false,
  "message": "Too many login attempts. Please try again in 15 minutes"
}
```

---

## Debugging Tips

### Enable Verbose Logging
```bash
DEBUG=housepital:* npm start
```

### Check Request Headers
```bash
curl -v http://localhost:3500/api/auth/register
```

### Monitor Network Traffic
Use browser DevTools → Network tab

### Test with Postman
Import collection and use debugging tools

---

## Common Error Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| Invalid email | Wrong format | Check @ symbol and domain |
| Weak password | Missing requirements | Add uppercase, lowercase, number, special char |
| Passwords don't match | Typo in confirm | Re-enter passwords carefully |
| Duplicate email | Email in use | Use different email or login |
| Too many requests | Rate limit hit | Wait 15 minutes before retry |
| Invalid credentials | Wrong password | Check password and try again |
| Server error | Unexpected issue | Retry, check logs, contact support |

---

## Error Codes by Endpoint

### POST /auth/register

| Code | Errors |
|------|--------|
| 201 | Success |
| 400 | Validation failed, duplicate email/mobile |
| 500 | Server error |

### POST /auth/login

| Code | Errors |
|------|--------|
| 200 | Success |
| 400 | Validation failed |
| 401 | Invalid credentials |
| 500 | Server error |

### GET /auth/me

| Code | Errors |
|------|--------|
| 200 | Success |
| 401 | Not authenticated |
| 500 | Server error |

---

## See Also

- [Authentication Endpoints](./authentication.md) - Endpoint details
- [API Overview](./overview.md) - General API information
- [Troubleshooting Guide](../Guides/troubleshooting.md) - Common issues

---

**Version**: 1.0.0  
**Last Updated**: November 13, 2025
