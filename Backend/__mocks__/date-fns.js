// Manual mock for date-fns to avoid ESM issues
module.exports = {
    format: jest.fn((date, formatStr) => {
        // Simple mock implementation
        const d = new Date(date);
        return formatStr
            .replace('yyyyMMdd', d.toISOString().split('T')[0].replace(/-/g, ''))
            .replace('HH:mm:ss', d.toTimeString().split(' ')[0]);
    }),
    parse: jest.fn((dateStr) => new Date(dateStr)),
    isValid: jest.fn(() => true),
    addDays: jest.fn((date, days) => new Date(date.getTime() + days * 86400000)),
};
