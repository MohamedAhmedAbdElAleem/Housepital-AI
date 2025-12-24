# OTP (One-Time Password) Endpoints

Base Path: `/api/otp`

OTP endpoints handle verification codes for email and SMS authentication flows.

---

## 1. Request OTP

Send a one-time password to user's email or phone number.

### Request

**Method**: `POST`  
**Endpoint**: `/api/otp/request`  
**Authentication**: Not required  
**Content-Type**: `application/json`

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "contact": "user@example.com",
  "contactType": "email",
  "purpose": "email_verification"
}
```

### Field Validation

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| contact | string | Yes | Valid email or phone number |
| contactType | string | Yes | `email` or `phone` |
| purpose | string | Yes | `email_verification`, `phone_verification`, `password_reset`, `login` |

### Response

**Success** (HTTP 200):
```json
{
  "success": true,
  "message": "OTP sent successfully",
  "data": {
    "contact": "user@example.com",
    "contactType": "email",
    "otpId": "otp_12345abc",
    "expiresIn": 600,
    "attempt": 1,
    "maxAttempts": 5
  }
}
```

**Error** (HTTP 400):
```json
{
  "success": false,
  "message": "Invalid contact information",
  "errors": [
    {
      "field": "contact",
      "message": "Please provide a valid email or phone number"
    }
  ]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| otpId | string | Unique identifier for this OTP request |
| expiresIn | number | OTP expiration time in seconds (default: 600 = 10 minutes) |
| attempt | number | Current attempt number |
| maxAttempts | number | Maximum allowed verification attempts |

### Error Responses

| Status | Error | Reason |
|--------|-------|--------|
| 400 | Invalid contact | Email/phone format invalid |
| 400 | Rate limited | Too many OTP requests (max 3 per hour) |
| 409 | Conflict | User already verified / User not found |
| 500 | Server error | Failed to send OTP |

### Example cURL

```bash
# Request OTP for email verification
curl -X POST http://localhost:3500/api/otp/request \
  -H "Content-Type: application/json" \
  -d '{
    "contact": "user@example.com",
    "contactType": "email",
    "purpose": "email_verification"
  }'

# Request OTP for phone verification
curl -X POST http://localhost:3500/api/otp/request \
  -H "Content-Type: application/json" \
  -d '{
    "contact": "+1234567890",
    "contactType": "phone",
    "purpose": "phone_verification"
  }'

# Request OTP for password reset
curl -X POST http://localhost:3500/api/otp/request \
  -H "Content-Type: application/json" \
  -d '{
    "contact": "user@example.com",
    "contactType": "email",
    "purpose": "password_reset"
  }'
```

---

## 2. Verify OTP

Verify the one-time password sent to user's email or phone.

### Request

**Method**: `POST`  
**Endpoint**: `/api/otp/verify`  
**Authentication**: Not required  
**Content-Type**: `application/json`

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "otpId": "otp_12345abc",
  "code": "123456",
  "contact": "user@example.com"
}
```

### Field Validation

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| otpId | string | Yes | Valid OTP ID from request |
| code | string | Yes | 6 digits, numeric only |
| contact | string | Yes | Email or phone (must match request) |

### Response

**Success** (HTTP 200):
```json
{
  "success": true,
  "message": "OTP verified successfully",
  "data": {
    "verified": true,
    "verificationToken": "token_abc123xyz",
    "expiresIn": 3600,
    "tokenType": "Bearer"
  }
}
```

**Error** (HTTP 400):
```json
{
  "success": false,
  "message": "Invalid or expired OTP",
  "errors": [
    {
      "field": "code",
      "message": "OTP code is incorrect or expired. Please request a new one."
    }
  ]
}
```

**Error** (HTTP 429):
```json
{
  "success": false,
  "message": "Too many verification attempts",
  "data": {
    "attempt": 5,
    "maxAttempts": 5,
    "retryAfter": 900
  }
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| verified | boolean | Whether OTP was successfully verified |
| verificationToken | string | Token for next step (register/reset password) |
| expiresIn | number | Verification token expiration in seconds |
| tokenType | string | Token type (always "Bearer") |

### Error Responses

| Status | Error | Reason |
|--------|-------|--------|
| 400 | Invalid OTP | Code is incorrect |
| 400 | OTP expired | Code expired after 10 minutes |
| 400 | OTP not found | OTP ID doesn't exist |
| 429 | Too many attempts | Max verification attempts exceeded |
| 500 | Server error | Verification failed |

### Example cURL

```bash
# Verify OTP code
curl -X POST http://localhost:3500/api/otp/verify \
  -H "Content-Type: application/json" \
  -d '{
    "otpId": "otp_12345abc",
    "code": "123456",
    "contact": "user@example.com"
  }'

# With output parsing
curl -X POST http://localhost:3500/api/otp/verify \
  -H "Content-Type: application/json" \
  -d '{
    "otpId": "otp_12345abc",
    "code": "123456",
    "contact": "user@example.com"
  }' | jq '.data.verificationToken'
```

---

## 3. Resend OTP

Resend the OTP code if user didn't receive it or it expired.

### Request

**Method**: `POST`  
**Endpoint**: `/api/otp/resend`  
**Authentication**: Not required  
**Content-Type**: `application/json`

**Headers**:
```
Content-Type: application/json
```

**Body**:
```json
{
  "otpId": "otp_12345abc",
  "contact": "user@example.com"
}
```

### Field Validation

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| otpId | string | Yes | Valid OTP ID from initial request |
| contact | string | Yes | Email or phone (must match original) |

### Response

**Success** (HTTP 200):
```json
{
  "success": true,
  "message": "OTP resent successfully",
  "data": {
    "contact": "user@example.com",
    "otpId": "otp_12345abc",
    "expiresIn": 600,
    "resendCount": 2,
    "maxResends": 3
  }
}
```

**Error** (HTTP 400):
```json
{
  "success": false,
  "message": "Cannot resend OTP",
  "errors": [
    {
      "field": "otpId",
      "message": "Maximum resend attempts exceeded. Please request a new OTP."
    }
  ]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| resendCount | number | Number of times OTP has been resent |
| maxResends | number | Maximum resend attempts allowed |

### Error Responses

| Status | Error | Reason |
|--------|-------|--------|
| 400 | OTP not found | OTP ID doesn't exist |
| 400 | Max resends | Maximum resend attempts exceeded |
| 400 | OTP verified | OTP already verified |
| 429 | Rate limited | Too many resend requests |
| 500 | Server error | Failed to resend OTP |

### Example cURL

```bash
# Resend OTP code
curl -X POST http://localhost:3500/api/otp/resend \
  -H "Content-Type: application/json" \
  -d '{
    "otpId": "otp_12345abc",
    "contact": "user@example.com"
  }'
```

---

## 4. Validate OTP Token

Validate a verification token received from OTP verification.

### Request

**Method**: `POST`  
**Endpoint**: `/api/otp/validate-token`  
**Authentication**: Not required  
**Content-Type**: `application/json`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer <verification_token>
```

**Body**:
```json
{
  "token": "token_abc123xyz"
}
```

### Field Validation

| Field | Type | Required | Validation Rules |
|-------|------|----------|------------------|
| token | string | Yes | Valid verification token from OTP verify |

### Response

**Success** (HTTP 200):
```json
{
  "success": true,
  "message": "Token is valid",
  "data": {
    "valid": true,
    "contact": "user@example.com",
    "purpose": "email_verification",
    "expiresAt": "2025-11-13T12:30:00Z"
  }
}
```

**Error** (HTTP 401):
```json
{
  "success": false,
  "message": "Token is invalid or expired",
  "errors": [
    {
      "field": "token",
      "message": "Please verify your OTP again"
    }
  ]
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| valid | boolean | Whether token is valid |
| contact | string | Email/phone verified with this token |
| purpose | string | Why OTP was requested |
| expiresAt | string | Token expiration timestamp (ISO 8601) |

### Error Responses

| Status | Error | Reason |
|--------|-------|--------|
| 401 | Invalid token | Token doesn't exist or invalid format |
| 401 | Expired token | Token expired |
| 400 | No token provided | Token field is empty |
| 500 | Server error | Validation failed |

### Example cURL

```bash
# Validate OTP token
curl -X POST http://localhost:3500/api/otp/validate-token \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token_abc123xyz" \
  -d '{
    "token": "token_abc123xyz"
  }'
```

---

## OTP Flow Examples

### Email Verification Flow

```
1. User provides email
   POST /api/otp/request
   {
     "contact": "user@example.com",
     "contactType": "email",
     "purpose": "email_verification"
   }
   
   Response: otpId = "otp_xyz123"

2. User receives email with 6-digit code

3. User submits code
   POST /api/otp/verify
   {
     "otpId": "otp_xyz123",
     "code": "123456",
     "contact": "user@example.com"
   }
   
   Response: verificationToken = "token_abc123xyz"

4. Use token for registration
   POST /api/auth/register
   {
     "name": "John Doe",
     "email": "user@example.com",
     "mobile": "1234567890",
     "password": "SecurePass123!",
     "confirmPassword": "SecurePass123!",
     "verificationToken": "token_abc123xyz"
   }
```

### Password Reset Flow

```
1. User requests password reset
   POST /api/otp/request
   {
     "contact": "user@example.com",
     "contactType": "email",
     "purpose": "password_reset"
   }
   
   Response: otpId = "otp_reset123"

2. User receives reset code via email

3. User submits code
   POST /api/otp/verify
   {
     "otpId": "otp_reset123",
     "code": "654321",
     "contact": "user@example.com"
   }
   
   Response: verificationToken = "token_reset123"

4. Reset password with token
   POST /api/auth/reset-password
   {
     "newPassword": "NewPass456!",
     "confirmPassword": "NewPass456!",
     "verificationToken": "token_reset123"
   }
```

### Phone Verification Flow

```
1. User provides phone number
   POST /api/otp/request
   {
     "contact": "+1234567890",
     "contactType": "phone",
     "purpose": "phone_verification"
   }
   
   Response: otpId = "otp_phone123"

2. User receives SMS with 6-digit code

3. User submits code
   POST /api/otp/verify
   {
     "otpId": "otp_phone123",
     "code": "789012",
     "contact": "+1234567890"
   }
   
   Response: verificationToken = "token_phone123"

4. Use token to update profile
   PATCH /api/users/profile
   {
     "phone": "+1234567890",
     "verificationToken": "token_phone123"
   }
```

---

## Rate Limiting

OTP endpoints have built-in rate limiting to prevent abuse:

| Endpoint | Limit | Window |
|----------|-------|--------|
| Request OTP | 3 per hour | 1 hour |
| Verify OTP | 5 attempts | Per OTP |
| Resend OTP | 3 times | Per request |
| Validate Token | 10 per minute | 1 minute |

**Rate Limit Headers**:
```
X-RateLimit-Limit: 3
X-RateLimit-Remaining: 2
X-RateLimit-Reset: 1699865400
```

**Rate Limit Error** (HTTP 429):
```json
{
  "success": false,
  "message": "Too many requests",
  "data": {
    "retryAfter": 900
  }
}
```

---

## Security Considerations

### OTP Best Practices

✅ **DO:**
- Use 6-digit OTP codes
- Set 10-minute expiration
- Limit verification attempts to 5
- Use secure channels (HTTPS/TLS)
- Hash OTPs in database
- Log OTP events (without code)
- Rate limit heavily

❌ **DON'T:**
- Send OTP via unsecured channels
- Log plaintext OTP codes
- Reuse OTP codes
- Set expiration > 15 minutes
- Allow unlimited verification attempts
- Send OTP in email subject line

### Token Security

- Verification tokens expire after 1 hour
- Tokens are single-use (invalidated after use)
- Tokens are cryptographically secure
- Tokens cannot be reused

---

## Related Documentation

- See `Guides/authentication-flow.md` for OTP integration patterns
- See `Examples/curl-examples.md` for complete examples
- See `API/error-handling.md` for error scenarios
- See `API/authentication.md` for registration/login endpoints

---

**Version**: 1.0.0  
**Last Updated**: November 13, 2025  
**Status**: Production Ready
