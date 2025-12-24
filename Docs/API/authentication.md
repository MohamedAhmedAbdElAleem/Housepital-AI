# Authentication Endpoints

Base Path: `/api/auth`

---

## 1. Register User

Create a new user account with email, phone, and password.

### Request

**Method**: `POST`  
**Endpoint**: `/api/auth/register`  
**Authentication**: Not required  
**Content-Type**: `application/json`

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "mobile": "1234567890",
  "password": "SecurePass123!",
  "confirmPassword": "SecurePass123!"
}
```

### Field Validation

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| name | string | Yes | 2-50 chars, letters/spaces/hyphens/apostrophes |
| email | string | Yes | Valid email format, unique |
| mobile | string | Yes | 10-15 digits, unique |
| password | string | Yes | 8+ chars, uppercase+lowercase+digit+special |
| confirmPassword | string | Yes | Must match password |

### Response

**Success** (HTTP 201):
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

**Error - Validation Failed** (HTTP 400):
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

**Error - Duplicate Email** (HTTP 400):
```json
{
  "success": false,
  "message": "A user with this email already exists"
}
```

**Error - Duplicate Mobile** (HTTP 400):
```json
{
  "success": false,
  "message": "A user with this mobile already exists"
}
```

**Error - Server Error** (HTTP 500):
```json
{
  "success": false,
  "message": "Error registering user"
}
```

### Examples

**cURL**:
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

**JavaScript**:
```javascript
const response = await fetch('http://localhost:3500/api/auth/register', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
    mobile: '1234567890',
    password: 'SecurePass123!',
    confirmPassword: 'SecurePass123!'
  })
});
const data = await response.json();
```

---

## 2. Login User

Authenticate user with email and password.

### Request

**Method**: `POST`  
**Endpoint**: `/api/auth/login`  
**Authentication**: Not required  
**Content-Type**: `application/json`

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}
```

### Field Validation

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| email | string | Yes | Valid email format |
| password | string | Yes | Non-empty string |

### Response

**Success** (HTTP 200):
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
    "role": "customer",
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  },
  "token": null
}
```

**Error - Invalid Credentials** (HTTP 401):
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

**Error - Validation Failed** (HTTP 400):
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

**Error - Server Error** (HTTP 500):
```json
{
  "success": false,
  "message": "Error logging in"
}
```

### Examples

**cURL**:
```bash
curl -X POST http://localhost:3500/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!"
  }'
```

**JavaScript**:
```javascript
const response = await fetch('http://localhost:3500/api/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'john@example.com',
    password: 'SecurePass123!'
  })
});
const data = await response.json();
if (data.success) {
  console.log('Login successful:', data.user);
}
```

---

## 3. Get Current User

Retrieve authenticated user's profile.

### Request

**Method**: `GET`  
**Endpoint**: `/api/auth/me`  
**Authentication**: Required (Bearer token)  
**Content-Type**: `application/json`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <token>
```

**Body**: None

### Response

**Success** (HTTP 200):
```json
{
  "success": true,
  "user": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "John Doe",
    "email": "john@example.com",
    "mobile": "1234567890",
    "isVerified": false,
    "role": "customer",
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**Error - Not Authenticated** (HTTP 401):
```json
{
  "success": false,
  "message": "Not authenticated"
}
```

**Error - Server Error** (HTTP 500):
```json
{
  "success": false,
  "message": "Error getting user"
}
```

### Examples

**cURL**:
```bash
curl -X GET http://localhost:3500/api/auth/me \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_token_here"
```

**JavaScript**:
```javascript
const response = await fetch('http://localhost:3500/api/auth/me', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your_token_here'
  }
});
const data = await response.json();
console.log(data.user);
```

---

## Response User Object

All user responses include:

```json
{
  "_id": "507f1f77bcf86cd799439011",
  "name": "John Doe",
  "email": "john@example.com",
  "mobile": "1234567890",
  "isVerified": false,
  "role": "customer",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

**Note**: `password_hash`, `salt`, and hashing algorithm are never included in responses.

---

## Password Requirements

All passwords must contain:
- ✅ Minimum 8 characters
- ✅ At least 1 uppercase letter (A-Z)
- ✅ At least 1 lowercase letter (a-z)
- ✅ At least 1 digit (0-9)
- ✅ At least 1 special character (@$!%*?&)

**Valid Passwords**:
- `SecurePass123!`
- `MyApp@2024`
- `Test#Pass99`

**Invalid Passwords**:
- `password` - No uppercase, digits, special chars
- `Pass123` - No special character
- `P@ss1` - Less than 8 characters

---

## Status Codes

| Code | Endpoint | Meaning |
|------|----------|---------|
| 200 | POST /login, GET /me | Success |
| 201 | POST /register | Created |
| 400 | All | Validation error or duplicate |
| 401 | GET /me | Not authenticated |
| 401 | POST /login | Invalid credentials |
| 500 | All | Server error |

---

## See Also

- [OTP Endpoints](./otp.md) - Email/SMS verification codes
- [Error Handling](./error-handling.md) - Detailed error codes
- [Data Models](./data-models.md) - User schema
- [Security Guide](../Guides/security.md) - Password hashing details

---

**Version**: 1.0.0  
**Last Updated**: November 13, 2025
