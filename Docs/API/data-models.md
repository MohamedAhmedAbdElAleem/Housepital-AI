# Data Models

## User Model

The User model represents a user account in the Housepital system.

### User Schema

```javascript
{
  _id: ObjectId,
  name: String,
  email: String,
  mobile: String,
  password_hash: String,
  salt: String,
  hashingAlgorithm: String,
  costFactor: Number,
  isVerified: Boolean,
  role: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Field Details

#### _id
- **Type**: ObjectId
- **Generated**: Automatically by MongoDB
- **Immutable**: Yes
- **Example**: `"507f1f77bcf86cd799439011"`
- **Description**: Unique identifier for the user

#### name
- **Type**: String
- **Required**: Yes
- **Min Length**: 2 characters
- **Max Length**: 50 characters
- **Allowed Characters**: Letters, spaces, hyphens, apostrophes
- **Pattern**: `/^[a-zA-Z\s'-]+$/`
- **Example**: `"John Doe"`, `"Mary-Jane"`, `"O'Brien"`
- **Searchable**: Yes
- **Sensitive**: No

#### email
- **Type**: String
- **Required**: Yes
- **Format**: Valid email address
- **Unique**: Yes (database index)
- **Stored As**: Lowercase
- **Pattern**: `/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/`
- **Example**: `"john@example.com"`
- **Searchable**: Yes
- **Sensitive**: No

#### mobile
- **Type**: String
- **Required**: Yes
- **Format**: 10-15 digits (numbers only)
- **Unique**: Yes (database index)
- **Pattern**: `/^[0-9]{10,15}$/`
- **Example**: `"1234567890"`
- **Searchable**: Yes
- **Sensitive**: No

#### password_hash
- **Type**: String
- **Required**: Yes
- **Algorithm**: bcrypt
- **Cost Factor**: 12 (2^12 = 4096 iterations)
- **Format**: `$2b$12$[22-char-salt][31-char-hash]`
- **Example**: `"$2b$12$R9h7cIPz0gi.URNNZ3Lgh.i75CqEqySd7u8pf9E2TsGvfZXWsXVDe"`
- **Searchable**: No
- **Sensitive**: Yes
- **Returned in API**: No
- **Description**: Bcrypt hash of the user's password

#### salt
- **Type**: String
- **Required**: No
- **Generated**: Automatically by bcrypt
- **Format**: Bcrypt salt
- **Example**: `"$2b$12$R9h7cIPz0gi.URNNZ3Lgh"`
- **Searchable**: No
- **Sensitive**: Yes
- **Returned in API**: No
- **Description**: Bcrypt salt for reference and auditing

#### hashingAlgorithm
- **Type**: String
- **Required**: No
- **Default**: `"bcrypt"`
- **Allowed Values**: `"bcrypt"`, `"argon2"` (future)
- **Searchable**: No
- **Sensitive**: No
- **Returned in API**: No
- **Description**: Password hashing algorithm used

#### costFactor
- **Type**: Number
- **Required**: No
- **Default**: `12`
- **Min**: `10`
- **Max**: `15`
- **Searchable**: No
- **Sensitive**: No
- **Returned in API**: No
- **Description**: Bcrypt cost factor (work factor)

#### isVerified
- **Type**: Boolean
- **Required**: No
- **Default**: `false`
- **Allowed Values**: `true`, `false`
- **Indexed**: Yes (for filtering)
- **Searchable**: Yes
- **Sensitive**: No
- **Returned in API**: Yes
- **Description**: Email verification status

#### role
- **Type**: String
- **Required**: No
- **Default**: `"customer"`
- **Allowed Values**: `"customer"`, `"doctor"`, `"admin"`
- **Indexed**: Yes (for filtering)
- **Searchable**: Yes
- **Sensitive**: No
- **Returned in API**: Yes
- **Example**: `"customer"`
- **Description**: User's role in the system

#### createdAt
- **Type**: Date (ISO 8601)
- **Auto-generated**: Yes
- **Immutable**: Yes (after creation)
- **Indexed**: Yes (for sorting)
- **Searchable**: Yes
- **Sensitive**: No
- **Returned in API**: Yes
- **Example**: `"2024-01-15T10:30:00.000Z"`
- **Timezone**: UTC
- **Description**: Account creation timestamp

#### updatedAt
- **Type**: Date (ISO 8601)
- **Auto-generated**: Yes
- **Auto-updated**: Yes (on any change)
- **Indexed**: Yes (for sorting)
- **Searchable**: Yes
- **Sensitive**: No
- **Returned in API**: Yes
- **Example**: `"2024-01-15T10:30:00.000Z"`
- **Timezone**: UTC
- **Description**: Last account update timestamp

---

## API Response User Object

When returned in API responses, the User object excludes sensitive fields:

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

### Fields Excluded from API Responses
- ❌ `password_hash`
- ❌ `salt`
- ❌ `hashingAlgorithm`
- ❌ `costFactor`

**Reason**: Prevent exposure of sensitive authentication data

---

## Database Indexes

### Unique Indexes
```javascript
db.users.createIndex({ email: 1 }, { unique: true })
db.users.createIndex({ mobile: 1 }, { unique: true })
```

### Regular Indexes
```javascript
db.users.createIndex({ role: 1 })
db.users.createIndex({ isVerified: 1 })
db.users.createIndex({ createdAt: -1 })
db.users.createIndex({ updatedAt: -1 })
```

---

## Field Validation Rules

### name
```
- Required: Yes
- Type: String
- Min: 2 characters
- Max: 50 characters
- Pattern: Letters, spaces, hyphens, apostrophes only
- Error if: Too short, too long, invalid characters
```

### email
```
- Required: Yes
- Type: String
- Format: Valid email
- Unique: Yes
- Stored: Lowercase (normalized)
- Error if: Invalid format, already exists
```

### mobile
```
- Required: Yes
- Type: String
- Format: 10-15 digits
- Unique: Yes
- Error if: Too short, too long, contains letters
```

### password_hash
```
- Required: Yes
- Type: String
- Algorithm: bcrypt
- Cost Factor: 12
- Never stored: Plaintext
- Error if: Hash generation fails
```

### isVerified
```
- Required: No
- Type: Boolean
- Default: false
- Values: true or false
- Error if: Invalid type
```

### role
```
- Required: No
- Type: String
- Default: "customer"
- Allowed Values: "customer", "doctor", "admin"
- Error if: Unknown role
```

---

## Database Queries

### Find by Email
```javascript
db.users.findOne({ email: "john@example.com" })
```

### Find by ID
```javascript
db.users.findOne({ _id: ObjectId("507f1f77bcf86cd799439011") })
```

### Find by Role
```javascript
db.users.find({ role: "doctor" })
```

### Find Verified Users
```javascript
db.users.find({ isVerified: true })
```

### Find with Timestamps
```javascript
db.users.find({
  createdAt: { $gte: new Date("2024-01-01") }
})
```

### Count Users
```javascript
db.users.countDocuments()
db.users.countDocuments({ role: "customer" })
```

---

## Database Constraints

### Unique Constraints
- Email must be unique across all users
- Mobile must be unique across all users
- Prevents duplicate registrations

### Required Fields
- name (2-50 chars)
- email (valid format)
- mobile (10-15 digits)
- password_hash (bcrypt hash)

### Default Values
- isVerified: `false`
- role: `"customer"`
- createdAt: Current timestamp
- updatedAt: Current timestamp

---

## Data Types

### String Fields
- name, email, mobile, password_hash, salt, hashingAlgorithm, role

### Number Fields
- costFactor

### Boolean Fields
- isVerified

### Date Fields
- createdAt, updatedAt

### ObjectId Fields
- _id

---

## Field Statistics

### Email
- Min Length: 5 characters (e@a.co)
- Max Length: 100+ characters (as per RFC 5321)
- Normalized: Lowercase

### Mobile
- Min: 1000000000 (10 digits)
- Max: 999999999999999 (15 digits)
- Format: Digits only

### Password Hash
- Min Length: 60 characters (bcrypt fixed)
- Algorithm: bcrypt v2b
- Cost Factor: 12

---

## Example User Documents

### New Registration
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "name": "John Doe",
  "email": "john@example.com",
  "mobile": "1234567890",
  "password_hash": "$2b$12$R9h7cIPz0gi.URNNZ3Lgh.i75CqEqySd7u8pf9E2TsGvfZXWsXVDe",
  "salt": "$2b$12$R9h7cIPz0gi.URNNZ3Lgh",
  "hashingAlgorithm": "bcrypt",
  "costFactor": 12,
  "isVerified": false,
  "role": "customer",
  "createdAt": ISODate("2024-01-15T10:30:00.000Z"),
  "updatedAt": ISODate("2024-01-15T10:30:00.000Z")
}
```

### Verified Doctor
```json
{
  "_id": ObjectId("507f1f77bcf86cd799439012"),
  "name": "Dr. Jane Smith",
  "email": "jane.smith@example.com",
  "mobile": "9876543210",
  "password_hash": "$2b$12$...",
  "salt": "$2b$12$...",
  "hashingAlgorithm": "bcrypt",
  "costFactor": 12,
  "isVerified": true,
  "role": "doctor",
  "createdAt": ISODate("2024-01-10T08:00:00.000Z"),
  "updatedAt": ISODate("2024-01-15T14:30:00.000Z")
}
```

---

## Related Resources

- [Authentication Endpoints](./authentication.md)
- [Error Handling](./error-handling.md)
- [Security Guide](../Guides/security.md)

---

**Version**: 1.0.0  
**Last Updated**: November 13, 2025
