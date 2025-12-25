// Manual mock for uuid to avoid ESM issues
module.exports = {
    v4: jest.fn(() => 'mocked-uuid-v4'),
    v1: jest.fn(() => 'mocked-uuid-v1'),
    v3: jest.fn(() => 'mocked-uuid-v3'),
    v5: jest.fn(() => 'mocked-uuid-v5'),
    validate: jest.fn(() => true),
    version: jest.fn(() => 4),
};
