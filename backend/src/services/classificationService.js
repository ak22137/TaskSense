/**
 * Auto-Classification Service
 * Analyzes task content to determine category, priority, entities, and suggested actions
 */

class ClassificationService {
  constructor() {
    // Category keywords mapping
    this.categoryKeywords = {
      scheduling: ['meeting', 'schedule', 'call', 'appointment', 'deadline', 'calendar', 'event', 'conference'],
      finance: ['payment', 'invoice', 'bill', 'budget', 'cost', 'expense', 'financial', 'revenue', 'profit'],
      technical: ['bug', 'fix', 'error', 'install', 'repair', 'maintain', 'code', 'system', 'server', 'deploy'],
      safety: ['safety', 'hazard', 'inspection', 'compliance', 'ppe', 'accident', 'risk', 'emergency'],
    };

    // Priority keywords mapping
    this.priorityKeywords = {
      high: ['urgent', 'asap', 'immediately', 'today', 'critical', 'emergency', 'now', 'crucial'],
      medium: ['soon', 'this week', 'important', 'needed', 'upcoming'],
    };

    // Suggested actions by category
    this.suggestedActions = {
      scheduling: ['Block calendar', 'Send invite', 'Prepare agenda', 'Set reminder'],
      finance: ['Check budget', 'Get approval', 'Generate invoice', 'Update records'],
      technical: ['Diagnose issue', 'Check resources', 'Assign technician', 'Document fix'],
      safety: ['Conduct inspection', 'File report', 'Notify supervisor', 'Update checklist'],
      general: ['Review task', 'Assign owner', 'Set deadline', 'Add notes'],
    };
  }

  /**
   * Classify a task based on its title and description
   * @param {string} title - Task title
   * @param {string} description - Task description
   * @returns {Object} Classification results
   */
  classifyTask(title, description = '') {
    const text = `${title} ${description}`.toLowerCase();

    const category = this.detectCategory(text);
    const priority = this.detectPriority(text);
    const entities = this.extractEntities(text, title, description);
    const actions = this.getSuggestedActions(category);

    return {
      category,
      priority,
      extracted_entities: entities,
      suggested_actions: actions,
    };
  }

  /**
   * Detect category based on keywords
   * @param {string} text - Combined text to analyze
   * @returns {string} Detected category
   */
  detectCategory(text) {
    const scores = {};

    // Calculate score for each category
    for (const [category, keywords] of Object.entries(this.categoryKeywords)) {
      scores[category] = 0;
      for (const keyword of keywords) {
        if (text.includes(keyword)) {
          scores[category]++;
        }
      }
    }

    // Find category with highest score
    let maxScore = 0;
    let detectedCategory = 'general';

    for (const [category, score] of Object.entries(scores)) {
      if (score > maxScore) {
        maxScore = score;
        detectedCategory = category;
      }
    }

    return detectedCategory;
  }

  /**
   * Detect priority based on keywords
   * @param {string} text - Combined text to analyze
   * @returns {string} Detected priority
   */
  detectPriority(text) {
    // Check for high priority keywords
    for (const keyword of this.priorityKeywords.high) {
      if (text.includes(keyword)) {
        return 'high';
      }
    }

    // Check for medium priority keywords
    for (const keyword of this.priorityKeywords.medium) {
      if (text.includes(keyword)) {
        return 'medium';
      }
    }

    return 'low';
  }

  /**
   * Extract entities from text (people, keywords, urgency indicators)
   * @param {string} text - Lowercased text
   * @param {string} title - Original title
   * @param {string} description - Original description
   * @returns {Object} Extracted entities
   */
  extractEntities(text, title, description) {
    const entities = {
      people: [],
      keywords: [],
      urgency_indicators: [],
      time_indicators: [],
    };

    // Extract people mentions (after "with", "by", "assign to")
    const peoplePatterns = [
      /(?:with|by|assign to|contact|notify|tell)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)/g,
      /(?:team|group|department)/gi,
    ];

    const originalText = `${title} ${description}`;
    peoplePatterns.forEach((pattern) => {
      const matches = originalText.matchAll(pattern);
      for (const match of matches) {
        if (match[1] && !entities.people.includes(match[1])) {
          entities.people.push(match[1]);
        } else if (match[0] && !entities.people.includes(match[0])) {
          entities.people.push(match[0].trim());
        }
      }
    });

    // Extract keywords from all categories
    Object.values(this.categoryKeywords).flat().forEach((keyword) => {
      if (text.includes(keyword) && !entities.keywords.includes(keyword)) {
        entities.keywords.push(keyword);
      }
    });

    // Extract urgency indicators
    Object.values(this.priorityKeywords)
      .flat()
      .forEach((keyword) => {
        if (text.includes(keyword) && !entities.urgency_indicators.includes(keyword)) {
          entities.urgency_indicators.push(keyword);
        }
      });

    // Extract time indicators
    const timePatterns = [
      /today/gi,
      /tomorrow/gi,
      /this week/gi,
      /next week/gi,
      /this month/gi,
      /next month/gi,
      /\d{1,2}:\d{2}\s*(?:am|pm)?/gi, // Time patterns
      /\d{1,2}\/\d{1,2}\/\d{2,4}/gi, // Date patterns
    ];

    timePatterns.forEach((pattern) => {
      const matches = originalText.matchAll(pattern);
      for (const match of matches) {
        if (!entities.time_indicators.includes(match[0].toLowerCase())) {
          entities.time_indicators.push(match[0].toLowerCase());
        }
      }
    });

    return entities;
  }

  /**
   * Get suggested actions for a category
   * @param {string} category - Task category
   * @returns {Array} Suggested actions
   */
  getSuggestedActions(category) {
    return this.suggestedActions[category] || this.suggestedActions.general;
  }
}

module.exports = new ClassificationService();
