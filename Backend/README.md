# Housepital Backend - CI/CD Pipeline

This document describes the CI/CD pipeline setup for the Housepital backend.

## Pipeline Overview

The GitHub Actions workflow runs on every push to `main` or when a Pull Request is created targeting `main`.

### Pipeline Stages

1. **✅ Trigger**: Push to main or Pull Request
2. **✅ Checkout & Cache**: Checks out code and caches npm dependencies
3. **✅ Install Dependencies**: Runs `npm ci` for clean install
4. **✅ Static Code Analysis (Linting)**: Runs ESLint with Airbnb style guide
5. **✅ Security Audit (SCA)**: Runs `npm audit` and optional Snyk scan
6. **✅ Unit Testing**: Runs unit tests with coverage reporting
7. **✅ Integration Testing**: Runs integration tests with coverage reporting

### Matrix Testing

The pipeline runs tests against multiple Node.js versions:
- Node.js 18.x
- Node.js 20.x

## Setup Instructions

### 1. Install Dependencies

Navigate to the Backend directory and run:

```bash
cd Backend
npm install
```

### 2. Required NPM Scripts

The `package.json` includes these scripts used by the CI/CD pipeline:

- `npm run lint` - Run ESLint
- `npm run test:unit` - Run unit tests
- `npm run test:integration` - Run integration tests
- `npm run build` - Build the application (optional)
- `npm audit` - Run security audit

### 3. Optional: Snyk Integration

To enable Snyk security scanning:

1. Sign up at [snyk.io](https://snyk.io)
2. Get your Snyk token
3. Add it to GitHub Secrets as `SNYK_TOKEN`

### 4. Directory Structure

```
Backend/
├── src/
│   ├── __tests__/
│   │   ├── unit/
│   │   │   └── *.unit.test.js
│   │   └── integration/
│   │       └── *.integration.test.js
│   └── index.js
├── .eslintrc.js
├── .eslintignore
├── jest.config.js
└── package.json
```

## Running Tests Locally

### Run all tests
```bash
npm test
```

### Run unit tests only
```bash
npm run test:unit
```

### Run integration tests only
```bash
npm run test:integration
```

### Run linter
```bash
npm run lint
```

### Fix linting issues
```bash
npm run lint:fix
```

### Run security audit
```bash
npm audit
```

## Coverage Reports

Test coverage reports are automatically uploaded to Codecov (optional). Coverage is also available locally in the `coverage/` directory after running tests.

## Workflow File Location

The GitHub Actions workflow is located at:
```
.github/workflows/backend-ci.yml
```

## Next Steps

1. Install dependencies: `npm install`
2. Write your tests in `src/__tests__/unit/` and `src/__tests__/integration/`
3. Push your code to trigger the pipeline
4. Check the Actions tab in GitHub to see the pipeline results
