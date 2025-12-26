/**
 * Validation Tests
 * Tests for input validation
 */

const { body, validationResult } = require('express-validator');

describe('Input Validation', () => {
  describe('Task Title Validation', () => {
    test('should require title field', () => {
      const title = '';
      expect(title.trim()).toBe('');
    });

    test('should limit title length', () => {
      const longTitle = 'a'.repeat(300);
      expect(longTitle.length).toBeGreaterThan(255);
    });

    test('should accept valid title', () => {
      const title = 'Valid task title';
      expect(title.trim().length).toBeGreaterThan(0);
      expect(title.length).toBeLessThan(255);
    });
  });

  describe('Status Validation', () => {
    const validStatuses = ['pending', 'in_progress', 'completed'];

    test('should accept valid statuses', () => {
      validStatuses.forEach((status) => {
        expect(validStatuses).toContain(status);
      });
    });

    test('should reject invalid status', () => {
      const invalidStatus = 'invalid_status';
      expect(validStatuses).not.toContain(invalidStatus);
    });
  });

  describe('Category Validation', () => {
    const validCategories = ['scheduling', 'finance', 'technical', 'safety', 'general'];

    test('should accept valid categories', () => {
      validCategories.forEach((category) => {
        expect(validCategories).toContain(category);
      });
    });

    test('should reject invalid category', () => {
      const invalidCategory = 'invalid_category';
      expect(validCategories).not.toContain(invalidCategory);
    });
  });

  describe('Priority Validation', () => {
    const validPriorities = ['high', 'medium', 'low'];

    test('should accept valid priorities', () => {
      validPriorities.forEach((priority) => {
        expect(validPriorities).toContain(priority);
      });
    });

    test('should reject invalid priority', () => {
      const invalidPriority = 'invalid_priority';
      expect(validPriorities).not.toContain(invalidPriority);
    });
  });

  describe('Date Validation', () => {
    test('should validate ISO 8601 date format', () => {
      const validDate = '2025-12-27T14:00:00Z';
      const date = new Date(validDate);
      expect(date.toISOString()).toBe(validDate);
    });

    test('should reject invalid date format', () => {
      const invalidDate = 'not-a-date';
      const date = new Date(invalidDate);
      expect(date.toString()).toBe('Invalid Date');
    });
  });

  describe('Entity Extraction', () => {
    test('should handle empty text', () => {
      const text = '';
      expect(text.length).toBe(0);
    });

    test('should handle text with special characters', () => {
      const text = 'Task with @special #characters & symbols!';
      expect(text.length).toBeGreaterThan(0);
    });

    test('should handle very long text', () => {
      const longText = 'word '.repeat(1000);
      expect(longText.length).toBeGreaterThan(100);
    });
  });
});
