# Getting Started Guide

Welcome! This guide will help you get up and running with the Housepital AI API.

---

## Prerequisites

Before you start, make sure you have:

- **Node.js** (v14 or higher)
- **npm** (v6 or higher)
- **MongoDB** account (Atlas or local)
- **Code Editor** (VS Code recommended)
- **Postman** or **cURL** (for testing)

### Verify Installation

```bash
node --version    # Should be v14+
npm --version     # Should be v6+
```

---

## Step 1: Installation

### Clone or Download Project

```bash
cd Backend
```

### Install Dependencies

```bash
npm install
```

This installs:
- `express` - Web framework
- `mongoose` - MongoDB ODM
- `bcrypt` - Password hashing
- `express-validator` - Input validation
- `dotenv` - Environment variables
- `cookie-parser` - Cookie handling

### Verify Installation

```bash
npm list
```

---

## Step 2: Environment Setup

### Configure .env File

Create or update `Backend/.env`:

```
NODE_ENV=development
DATABASE_URI=mongodb+srv://housepital:6xNQ02sD9EPIgKIV@database.kj5vfon.mongodb.net/?appName=Database
PORT=3500
```

### Update for Your Environment

| Variable | Description | Example |
|----------|-------------|---------|
| NODE_ENV | Environment mode | `development` or `production` |
| DATABASE_URI | MongoDB connection string | `mongodb+srv://...` |
| PORT | Server port | `3500` |

---

## Step 3: Start the Server

### Development Mode (with auto-reload)

```bash
npm run dev
```

### Production Mode

```bash
npm start
```

### Expected Output

```
Connected to MongoDB
Server running on port 3500
```

---

## Step 4: Test the API

### Using cURL

**Register a user**:
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

**Login**:
```bash
curl -X POST http://localhost:3500/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePass123!"
  }'
```

### Using Postman

1. Open Postman
2. Import collection: `Housepital_API.postman_collection.json`
3. Set `base_url` variable to `http://localhost:3500/api`
4. Try the register endpoint

---

## Step 5: Explore the API

### Key Endpoints

```
POST   /api/auth/register    Register new user
POST   /api/auth/login       Login user
GET    /api/auth/me          Get current user
```

### First Request

**Register**:
- Method: POST
- URL: `http://localhost:3500/api/auth/register`
- Body:
  ```json
  {
    "name": "Your Name",
    "email": "your@email.com",
    "mobile": "1234567890",
    "password": "SecurePass123!",
    "confirmPassword": "SecurePass123!"
  }
  ```

### Expected Response

```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "_id": "...",
    "name": "Your Name",
    "email": "your@email.com",
    "mobile": "1234567890",
    "isVerified": false,
    "role": "customer",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

---

## Common Issues

### Issue: MongoDB Connection Error

**Error**: `MongooseError: Cannot connect to MongoDB`

**Solution**:
1. Check `.env` DATABASE_URI is correct
2. Ensure MongoDB Atlas IP is whitelisted
3. Verify internet connection
4. Check MongoDB cluster is running

### Issue: Port Already in Use

**Error**: `EADDRINUSE: address already in use :::3500`

**Solution**:
```bash
# Kill process on port 3500
npx lsof -ti:3500 | xargs kill -9

# Or change PORT in .env
PORT=3501
```

### Issue: bcrypt Module Not Found

**Error**: `Cannot find module 'bcrypt'`

**Solution**:
```bash
npm install
npm install bcrypt
```

---

## What's Next?

1. **Read Documentation** → [API Overview](../API/overview.md)
2. **See Examples** → [Code Examples](../Examples/)
3. **Learn Security** → [Security Guide](./security.md)
4. **Test API** → [Testing Guide](./testing.md)
5. **Integrate in Your App** → [Authentication Flow](./authentication-flow.md)

---

## Project Structure

```
Backend/
├── src/
│   ├── models/User.js              User schema
│   ├── controllers/authController.js    Auth logic
│   ├── routes/authRoutes.js        Auth routes
│   ├── middleware/
│   │   ├── validation.js           Input validation
│   │   ├── errorHandler.js
│   │   └── logger.js
│   ├── config/dbConn.js            Database connection
│   └── server.js                   Express app
├── package.json
├── .env
└── Docs/                           This documentation
```

---

## Development Tips

### Enable Debug Logging

```bash
DEBUG=* npm run dev
```

### Test Specific Endpoint

```bash
curl -v http://localhost:3500/api/auth/register
```

### Monitor MongoDB

Use MongoDB Compass or Atlas UI

### Check Logs

```bash
tail -f logs/authLog.log
tail -f logs/authErrLog.log
```

---

## Database Setup

### MongoDB Atlas

1. Go to [mongodb.com/cloud/atlas](https://mongodb.com/cloud/atlas)
2. Create free account
3. Create new cluster
4. Whitelist your IP
5. Get connection string
6. Add to `.env` as DATABASE_URI

### Local MongoDB

1. Install MongoDB locally
2. Start MongoDB server
3. Use connection string: `mongodb://localhost:27017/housepital`

---

## API Base URL

| Environment | URL |
|-------------|-----|
| Development | http://localhost:3500/api |
| Production | https://api.housepital.com/api |

---

## Authentication Status

| Feature | Status |
|---------|--------|
| Register | ✅ Working |
| Login | ✅ Working |
| Password Hashing | ✅ Bcrypt (cost 12) |
| Input Validation | ✅ Active |
| Error Handling | ✅ Implemented |
| JWT Tokens | 🔄 Planned (v1.1.0) |
| Email Verification | 🔄 Planned (v1.1.0) |

---

## Next Steps

Choose what you want to do:

- **I want to understand the API** → [API Overview](../API/overview.md)
- **I want to see code examples** → [Examples](../Examples/curl-examples.md)
- **I want to test the API** → [Testing Guide](./testing.md)
- **I want to implement in my app** → [Authentication Flow](./authentication-flow.md)
- **I need to understand security** → [Security Guide](./security.md)

---

## Getting Help

- 📖 Read the documentation
- 🔍 Check [Troubleshooting](./troubleshooting.md)
- 📧 Contact support@housepital.com
- 🐛 Report issues on GitHub

---

**Version**: 1.0.0  
**Last Updated**: November 13, 2025  
**Status**: Ready to use ✅
