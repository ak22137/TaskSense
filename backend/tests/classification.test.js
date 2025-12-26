/**
 * Classification Service Tests
 * Tests for auto-classification logic
 */

const classificationService = require('../src/services/classificationService');

describe('ClassificationService', () => {
  describe('detectCategory', () => {
    test('should detect scheduling category', () => {
      const text = 'schedule a meeting with team tomorrow';
      const category = classificationService.detectCategory(text);
      expect(category).toBe('scheduling');
    });

    test('should detect finance category', () => {
      const text = 'process invoice payment for Q4 budget';
      const category = classificationService.detectCategory(text);
      expect(category).toBe('finance');
    });

    test('should detect technical category', () => {
      const text = 'fix critical bug in payment system';
      const category = classificationService.detectCategory(text);
      expect(category).toBe('technical');
    });

    test('should detect safety category', () => {
      const text = 'conduct safety inspection and file compliance report';
      const category = classificationService.detectCategory(text);
      expect(category).toBe('safety');
    });

    test('should default to general category', () => {
      const text = 'review documentation and update files';
      const category = classificationService.detectCategory(text);
      expect(category).toBe('general');
    });
  });

  describe('detectPriority', () => {
    test('should detect high priority with urgent keyword', () => {
      const text = 'urgent meeting required today';
      const priority = classificationService.detectPriority(text);
      expect(priority).toBe('high');
    });

    test('should detect high priority with asap keyword', () => {
      const text = 'need this fixed asap';
      const priority = classificationService.detectPriority(text);
      expect(priority).toBe('high');
    });

    test('should detect medium priority', () => {
      const text = 'important task this week';
      const priority = classificationService.detectPriority(text);
      expect(priority).toBe('medium');
    });

    test('should default to low priority', () => {
      const text = 'regular task to complete';
      const priority = classificationService.detectPriority(text);
      expect(priority).toBe('low');
    });
  });

  describe('extractEntities', () => {
    test('should extract people mentions', () => {
      const title = 'Schedule meeting with John Doe';
      const description = 'Contact Sarah Wilson about project';
      const text = `${title} ${description}`.toLowerCase();
      
      const entities = classificationService.extractEntities(text, title, description);
      
      expect(entities.people.length).toBeGreaterThan(0);
    });

    test('should extract keywords', () => {
      const title = 'Fix bug in payment system';
      const description = 'Critical error affecting invoices';
      const text = `${title} ${description}`.toLowerCase();
      
      const entities = classificationService.extractEntities(text, title, description);
      
      expect(entities.keywords).toContain('bug');
      expect(entities.keywords).toContain('payment');
    });

    test('should extract urgency indicators', () => {
      const title = 'Urgent task needs immediate attention';
      const description = 'Critical issue today';
      const text = `${title} ${description}`.toLowerCase();
      
      const entities = classificationService.extractEntities(text, title, description);
      
      expect(entities.urgency_indicators).toContain('urgent');
      expect(entities.urgency_indicators).toContain('today');
    });
  });

  describe('classifyTask', () => {
    test('should classify complete task correctly', () => {
      const title = 'Schedule urgent meeting with team today';
      const description = 'Discuss budget allocation for Q4';
      
      const result = classificationService.classifyTask(title, description);
      
      expect(result.category).toBe('scheduling');
      expect(result.priority).toBe('high');
      expect(result.extracted_entities).toBeDefined();
      expect(result.suggested_actions).toBeDefined();
      expect(result.suggested_actions.length).toBeGreaterThan(0);
    });

    test('should provide suggested actions based on category', () => {
      const title = 'Process invoice payment';
      const description = 'Finance task';
      
      const result = classificationService.classifyTask(title, description);
      
      expect(result.category).toBe('finance');
      expect(result.suggested_actions).toContain('Check budget');
      expect(result.suggested_actions).toContain('Get approval');
    });
  });

  describe('getSuggestedActions', () => {
    test('should return scheduling actions', () => {
      const actions = classificationService.getSuggestedActions('scheduling');
      expect(actions).toContain('Block calendar');
      expect(actions).toContain('Send invite');
    });

    test('should return finance actions', () => {
      const actions = classificationService.getSuggestedActions('finance');
      expect(actions).toContain('Check budget');
      expect(actions).toContain('Generate invoice');
    });

    test('should return technical actions', () => {
      const actions = classificationService.getSuggestedActions('technical');
      expect(actions).toContain('Diagnose issue');
      expect(actions).toContain('Assign technician');
    });

    test('should return general actions for unknown category', () => {
      const actions = classificationService.getSuggestedActions('unknown');
      expect(actions).toContain('Review task');
      expect(actions).toContain('Assign owner');
    });
  });
});
