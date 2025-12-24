# Housepital AI - API Documentation

Welcome to the Housepital AI API Documentation. This folder contains complete documentation for the authentication and user management API.

## 📚 Documentation Structure

```
Docs/
├── README.md                          (This file)
├── index.md                           (Quick start guide)
├── API/
│   ├── overview.md                    (API overview & base configuration)
│   ├── authentication.md              (Auth endpoints: register, login, me)
│   ├── error-handling.md              (Error codes & responses)
│   └── data-models.md                 (User model & field specs)
├── Guides/
│   ├── getting-started.md             (Installation & setup)
│   ├── authentication-flow.md         (Auth implementation guide)
│   ├── security.md                    (Security best practices)
│   ├── testing.md                     (Testing guide)
│   └── troubleshooting.md             (Common issues & solutions)
├── Examples/
│   ├── curl-examples.md               (cURL request examples)
│   ├── javascript-examples.md         (JavaScript/Node.js examples)
│   ├── python-examples.md             (Python examples)
│   ├── react-examples.md              (React integration)
│   └── flutter-examples.md            (Flutter integration)
├── Reference/
│   ├── endpoints.md                   (All endpoints quick reference)
│   ├── http-status-codes.md           (HTTP status codes)
│   ├── response-formats.md            (Response format specifications)
│   └── rate-limiting.md               (Rate limiting guidelines)
├── Tools/
│   ├── postman-setup.md               (Postman collection setup)
│   ├── openapi-spec.yaml              (OpenAPI/Swagger specification)
│   └── collection.json                (Postman collection)
└── CHANGELOG.md                       (Version history)
```

## 🚀 Quick Start

### 1. **New to the API?**
   → Start with [Getting Started Guide](./Guides/getting-started.md)

### 2. **Want to Implement Authentication?**
   → Read [Authentication Flow Guide](./Guides/authentication-flow.md)

### 3. **Need API Endpoint Details?**
   → Check [Endpoints Reference](./Reference/endpoints.md)

### 4. **Looking for Code Examples?**
   → See [Examples](./Examples/) folder

### 5. **Having Issues?**
   → Check [Troubleshooting Guide](./Guides/troubleshooting.md)

## 📖 Main Sections

### API Documentation
- **[Overview](./API/overview.md)** - Base URL, content types, response formats
- **[Authentication](./API/authentication.md)** - Register, login, get user endpoints
- **[Error Handling](./API/error-handling.md)** - Error codes and responses
- **[Data Models](./API/data-models.md)** - User schema and field specifications

### Implementation Guides
- **[Getting Started](./Guides/getting-started.md)** - Installation and setup
- **[Authentication Flow](./Guides/authentication-flow.md)** - How to implement auth
- **[Security](./Guides/security.md)** - Password hashing, best practices
- **[Testing](./Guides/testing.md)** - How to test the API
- **[Troubleshooting](./Guides/troubleshooting.md)** - Common problems and solutions

### Code Examples
- **[cURL Examples](./Examples/curl-examples.md)** - Command line examples
- **[JavaScript](./Examples/javascript-examples.md)** - Node.js/Browser examples
- **[Python](./Examples/python-examples.md)** - Python examples
- **[React](./Examples/react-examples.md)** - React integration
- **[Flutter](./Examples/flutter-examples.md)** - Flutter mobile app

### Reference
- **[Endpoints](./Reference/endpoints.md)** - All endpoints quick table
- **[HTTP Status Codes](./Reference/http-status-codes.md)** - Status codes explained
- **[Response Formats](./Reference/response-formats.md)** - Standard response structures
- **[Rate Limiting](./Reference/rate-limiting.md)** - Rate limit guidelines

### Tools & Integrations
- **[Postman Setup](./Tools/postman-setup.md)** - Import Postman collection
- **[OpenAPI Spec](./Tools/openapi-spec.yaml)** - Swagger/OpenAPI specification
- **[Postman Collection](./Tools/collection.json)** - Ready-to-import Postman collection

## 🔑 Key Features

✅ **User Registration** - Create accounts with email, phone, password  
✅ **Secure Login** - Authenticate with bcrypt (cost factor 12)  
✅ **Password Security** - Strong hashing with salt storage  
✅ **Input Validation** - Comprehensive validation for all fields  
✅ **Error Handling** - Clear error messages and codes  
✅ **Professional API** - RESTful design with proper HTTP methods  

## 📊 API Endpoints at a Glance

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login user |
| GET | `/api/auth/me` | Get current user |

## 🔐 Security Highlights

- **Password Hashing**: bcrypt with cost factor 12 (OWASP standard)
- **Salt Generation**: Automatic per password
- **Algorithm Metadata**: Stored for future upgrades
- **No Plaintext**: Passwords never logged or exposed
- **Validation**: All inputs validated server-side

## 📱 Supported Platforms

- **Backend**: Node.js + Express
- **Database**: MongoDB
- **Frontend**: React, Vue, Angular, Flutter
- **Desktop**: Electron, Tauri

## 🛠️ Tools Included

- Postman collection for easy testing
- OpenAPI/Swagger specification
- cURL examples for quick testing
- Code examples in multiple languages

## 📞 Support

- 📖 Documentation: This folder
- 🐛 Issues: GitHub Issues
- 📧 Email: support@housepital.com
- 💬 Discord: [Link to community]

## 📝 Table of Contents by Use Case

### I want to...

| Goal | Document |
|------|----------|
| Get started quickly | [Getting Started](./Guides/getting-started.md) |
| Understand the API | [API Overview](./API/overview.md) |
| Register users | [Authentication](./API/authentication.md) |
| Login users | [Authentication](./API/authentication.md) |
| See code examples | [Examples folder](./Examples/) |
| Test the API | [Testing Guide](./Guides/testing.md) |
| Use Postman | [Postman Setup](./Tools/postman-setup.md) |
| Fix errors | [Troubleshooting](./Guides/troubleshooting.md) |
| Understand security | [Security Guide](./Guides/security.md) |
| Check endpoints | [Endpoints Reference](./Reference/endpoints.md) |

## 🎓 Documentation Levels

### 👶 Beginner
- [Getting Started](./Guides/getting-started.md)
- [API Overview](./API/overview.md)
- [cURL Examples](./Examples/curl-examples.md)

### 👨‍💻 Intermediate
- [Authentication Flow](./Guides/authentication-flow.md)
- [Security Guide](./Guides/security.md)
- [Language-specific Examples](./Examples/)

### 🏆 Advanced
- [Data Models](./API/data-models.md)
- [Error Handling](./API/error-handling.md)
- [OpenAPI Spec](./Tools/openapi-spec.yaml)

## 📈 API Versions

- **v1.0.0** (Current) - Authentication API
- **v1.1.0** (Planned) - JWT tokens, email verification
- **v1.2.0** (Planned) - Password reset, 2FA
- **v2.0.0** (Future) - Additional features

## ✨ What's in Each Section

### 📌 API Section
Complete API specifications including:
- Endpoint definitions
- Request/response formats
- Field validations
- Error scenarios

### 📌 Guides Section
Implementation guides including:
- Step-by-step setup
- Code patterns
- Best practices
- Testing strategies

### 📌 Examples Section
Ready-to-use code examples for:
- cURL (bash)
- JavaScript/Node.js
- Python
- React
- Flutter

### 📌 Reference Section
Quick lookup resources for:
- All endpoints
- HTTP status codes
- Response formats
- Rate limits

### 📌 Tools Section
Integration tools including:
- Postman collection
- OpenAPI specification
- Setup guides

## 🔄 Workflow

```
1. Read Getting Started → Installation
2. Read API Overview → Understand base URL, formats
3. Read Authentication → Learn endpoints
4. Check Examples → Find your language
5. Use Postman/cURL → Test API
6. Build Integration → Use in your app
7. Reference as needed → Troubleshoot if issues
```

## 📞 Getting Help

1. **Check Documentation** - Most answers are here
2. **Search Examples** - Code examples cover common cases
3. **Review Troubleshooting** - Common issues are documented
4. **Check GitHub Issues** - See if others had same problem
5. **Contact Support** - Email support@housepital.com

## 🎉 You're All Set!

The documentation is organized, comprehensive, and easy to navigate. Start with the [Getting Started Guide](./Guides/getting-started.md) and proceed from there.

**Happy coding!** 🚀

---

**Last Updated**: November 13, 2025  
**API Version**: 1.0.0  
**Status**: ✅ Production Ready
