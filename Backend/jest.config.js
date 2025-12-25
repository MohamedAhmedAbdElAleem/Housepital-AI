module.exports = {
    testEnvironment: 'node',
    coverageDirectory: 'coverage',
    collectCoverageFrom: [
        'src/**/*.{js,jsx}',
        '!src/**/*.test.{js,jsx}',
        '!src/**/*.spec.{js,jsx}',
    ],
    testMatch: [
        '**/__tests__/**/*.[jt]s?(x)',
        '**/?(*.)+(spec|test).[tj]s?(x)',
    ],
    // Coverage thresholds removed for simple example tests
    coverageReporters: ['text', 'lcov', 'html'],
    reporters: [
        'default',
        ['jest-junit', {
            outputDirectory: './coverage',
            outputName: 'junit.xml',
        }],
    ],
    moduleNameMapper: {
        '^uuid$': '<rootDir>/__mocks__/uuid.js',
        '^date-fns$': '<rootDir>/__mocks__/date-fns.js',
    },
};
