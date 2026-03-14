# Registration Validation Rules

## Backend Validation (Express Validator)

The registration endpoint `/api/auth/register` has the following validation rules:

### Required Fields

1. **name** (Required)
   - Must not be empty
   - Minimum length: 2 characters
   - Maximum length: 50 characters
   - Can only contain: letters, spaces, hyphens, and apostrophes
   - Example: `"John Doe"`, `"Mary O'Brien"`, `"Jean-Paul"`

2. **email** (Required)
   - Must not be empty
   - Must be a valid email format
   - Automatically normalized (lowercase)
   - Example: `"doctor@example.com"`

3. **password** (Required)
   - Must not be empty
   - Minimum length: 6 characters
   - Example: `"password123"`

### Optional Fields

4. **mobile** (Optional)
   - If provided, must match Egyptian mobile number format
   - Pattern: `01[0125][0-9]{8}` (11 digits starting with 010, 011, 012, or 015)
   - Example: `"01012345678"`
   - Can be empty string or omitted for staff registration

5. **confirmPassword** (Optional)
   - If provided, must match the password field
   - Used for client-side validation

6. **role** (Optional)
   - If provided, must be one of: `customer`, `doctor`, `nurse`, `admin`
   - Defaults to `customer` if not provided
   - Example: `"doctor"` or `"nurse"`

## Flutter Validation (Client-Side)

The registration form in Flutter has the following validation:

### Form Fields

1. **Full Name**
   - Required field
   - Error message: "Name is required"

2. **Email Address**
   - Required field
   - Must contain '@' symbol
   - Error message: "Invalid email"

3. **Password**
   - Required field
   - Minimum length: 6 characters
   - Has visibility toggle
   - Error message: "Password must be at least 6 characters"

4. **Confirm Password**
   - Required field
   - Must match password field
   - Has visibility toggle
   - Error message: "Passwords do not match"

5. **Role Selection**
   - Required (defaults to "doctor")
   - Options: Doctor or Nurse
   - Visual card selection interface

## API Request Example

### Successful Registration Request

```json
{
  "name": "Dr. John Smith",
  "email": "john.smith@hospital.com",
  "password": "securePass123",
  "role": "doctor",
  "mobile": ""
}
```

### Successful Response

```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": "507f1f77bcf86cd799439011",
    "name": "Dr. John Smith",
    "email": "john.smith@hospital.com",
    "role": "doctor",
    "isVerified": false
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Validation Error Response

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Please provide a valid email address"
    },
    {
      "field": "password",
      "message": "Password must be at least 6 characters"
    }
  ]
}
```

## Error Handling

### Backend Errors
- **400 Bad Request**: Validation errors
- **400 Bad Request**: User already exists (email or mobile)
- **500 Internal Server Error**: Server errors

### Flutter Error Handling
- Form validation prevents submission if fields are invalid
- API errors are displayed via SnackBar
- Loading state prevents multiple submissions
- Network errors are caught and displayed to user

## Security Features

1. **Password Hashing**: Passwords are hashed using bcrypt before storage
2. **Email Normalization**: Emails are converted to lowercase for case-insensitive comparison
3. **JWT Token**: Secure token generated upon successful registration
4. **Role Validation**: Only valid roles are accepted
5. **Duplicate Prevention**: Checks for existing email/mobile before registration
