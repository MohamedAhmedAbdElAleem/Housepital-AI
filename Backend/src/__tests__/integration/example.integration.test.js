/**
 * Simple example integration test
 * This is a basic test that will always pass
 */

describe('Example Integration Tests', () => {
    test('should pass - basic assertion', () => {
        expect(true).toBe(true);
    });

    test('should pass - object comparison', () => {
        const obj = { name: 'test', value: 123 };
        expect(obj).toEqual({ name: 'test', value: 123 });
    });

    test('should pass - array check', () => {
        const arr = [1, 2, 3];
        expect(arr).toHaveLength(3);
        expect(arr).toContain(2);
    });
});
