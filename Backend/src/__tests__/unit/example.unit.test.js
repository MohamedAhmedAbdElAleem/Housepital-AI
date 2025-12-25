/**
 * Simple example unit test
 * This is a basic test that will always pass
 */

describe('Example Unit Tests', () => {
    test('should pass - basic assertion', () => {
        expect(true).toBe(true);
    });

    test('should pass - math operation', () => {
        expect(1 + 1).toBe(2);
    });

    test('should pass - string comparison', () => {
        expect('hello').toBe('hello');
    });
});
