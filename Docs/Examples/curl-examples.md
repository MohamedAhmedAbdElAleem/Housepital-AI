# cURL Examples

Command-line examples for testing the API using cURL.

---

## Setup

Ensure the API is running:
```bash
cd Backend
npm run dev
```

---

## Basic Examples

### 1. Register User

```bash
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }'
```

**Response**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "isVerified": false,
    "role": "customer",
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  },
  "token": null
}
```

---

### 2. Login

```bash
curl -X POST http://localhost:3500/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!"
  }'
```

**Response**:
```json
{
  "success": true,
  "message": "User logged in successfully",
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "isVerified": false,
    "role": "customer"
  },
  "token": null
}
```

---

### 3. Get Current User

```bash
curl -X GET http://localhost:3500/api/auth/me \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_token_here"
```

---

## Error Examples

### Invalid Email

```bash
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "invalid-email",
    "mobile": "1234567890",
    "password": "TestPass123!",
    "confirmPassword": "TestPass123!"
  }'
```

**Response**:
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

---

### Weak Password

```bash
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "mobile": "1234567890",
    "password": "weak",
    "confirmPassword": "weak"
  }'
```

**Response**:
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

---

### Invalid Mobile

```bash
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "mobile": "123",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }'
```

---

### Duplicate Email

Register the same email twice:

```bash
# First registration - succeeds
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice",
    "email": "alice@example.com",
    "mobile": "1111111111",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }'

# Second registration with same email - fails
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice 2",
    "email": "alice@example.com",
    "mobile": "2222222222",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }'
```

**Response**:
```json
{
  "success": false,
  "message": "A user with this email already exists"
}
```

---

### Wrong Password

```bash
curl -X POST http://localhost:3500/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "WrongPassword123!"
  }'
```

**Response**:
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

---

## Advanced Examples

### Save Response to Variable

```bash
RESPONSE=$(curl -s -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }')

echo "$RESPONSE"
```

---

### Extract User ID from Response

```bash
USER_ID=$(curl -s -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }' | grep -o '"_id":"[^"]*"' | cut -d'"' -f4)

echo "User ID: $USER_ID"
```

---

### Extract Token from Response

```bash
TOKEN=$(curl -s -X POST http://localhost:3500/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!"
  }' | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "Token: $TOKEN"
```

---

### Use Token for Authenticated Request

```bash
TOKEN="your_token_here"

curl -X GET http://localhost:3500/api/auth/me \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Pretty Print JSON Response

```bash
curl -s -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }' | jq .
```

---

### Show Request and Response Headers

```bash
curl -v -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }'
```

---

### Measure Response Time

```bash
curl -w "\nTime: %{time_total}s\n" -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }'
```

---

### Test Multiple Requests

```bash
# Register 3 users
for i in {1..3}; do
  EMAIL="user$i@example.com"
  MOBILE="123456789$i"
  
  curl -X POST http://localhost:3500/api/auth/register \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"User $i\",
      \"email\": \"$EMAIL\",
      \"mobile\": \"$MOBILE\",
      \"password\": \"SecurePass123!\",
      \"confirmPassword\": \"SecurePass123!\"
    }"
  
  echo "\n---\n"
done
```

---

### Test with Different Content Types

**Should work**:
```bash
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"John","email":"john@example.com","mobile":"1234567890","password":"SecurePass123!","confirmPassword":"SecurePass123!"}'
```

---

### Timeout Handling

```bash
curl --max-time 10 -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }'
```

---

## Scripting Examples

### Bash Script - Register and Login

```bash
#!/bin/bash

API_URL="http://localhost:3500/api"

# Register
echo "Registering user..."
REGISTER_RESPONSE=$(curl -s -X POST $API_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }')

echo "Register Response: $REGISTER_RESPONSE"

# Login
echo "Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST $API_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!"
  }')

echo "Login Response: $LOGIN_RESPONSE"
```

---

## Tips & Tricks

### Escape Quotes in JSON

Use single quotes for outer, double quotes for inner:
```bash
curl -X POST ... -d '{"key": "value with \"quotes\""}'
```

### Send File as Body

```bash
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d @request.json
```

### Output to File

```bash
curl -X POST http://localhost:3500/api/auth/register \
  -H "Content-Type: application/json" \
  -d '...' > response.json
```

### Use Environment Variables

```bash
EMAIL="test@example.com"
PASSWORD="SecurePass123!"

curl -X POST http://localhost:3500/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"$EMAIL\", \"password\": \"$PASSWORD\"}"
```

---

## Common Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `-X` | HTTP method | `curl -X POST` |
| `-H` | Add header | `curl -H "Content-Type: application/json"` |
| `-d` | Data/body | `curl -d '{"key":"value"}'` |
| `-s` | Silent mode | `curl -s` |
| `-v` | Verbose | `curl -v` |
| `-i` | Include headers | `curl -i` |
| `-w` | Write stats | `curl -w "\n%{http_code}\n"` |
| `--max-time` | Timeout | `curl --max-time 10` |

---

## Testing Checklist

- [ ] Register new user
- [ ] Login with correct password
- [ ] Login with wrong password
- [ ] Register with invalid email
- [ ] Register with weak password
- [ ] Register duplicate email
- [ ] Register invalid mobile
- [ ] Get current user (with token)

---

See also:
- [JavaScript Examples](./javascript-examples.md)
- [Python Examples](./python-examples.md)
- [Testing Guide](../Guides/testing.md)

---

**Version**: 1.0.0  
**Last Updated**: November 13, 2025
