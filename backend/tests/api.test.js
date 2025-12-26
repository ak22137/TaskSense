/**
 * Task API Integration Tests
 * Tests for API endpoints
 */

const request = require('supertest');
const app = require('../server');

// Note: These tests require a running database connection
// For actual testing, mock the Supabase client or use a test database

describe('Task API Endpoints', () => {
  describe('GET /health', () => {
    test('should return health status', async () => {
      const response = await request(app).get('/health');
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('TaskSense API is running');
    });
  });

  describe('GET /', () => {
    test('should return welcome message', async () => {
      const response = await request(app).get('/');
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Welcome to TaskSense API');
      expect(response.body.endpoints).toBeDefined();
    });
  });

  describe('POST /api/tasks', () => {
    test('should reject task without title', async () => {
      const response = await request(app)
        .post('/api/tasks')
        .send({
          description: 'Test description',
        });
      
      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    test('should reject task with invalid status', async () => {
      const response = await request(app)
        .post('/api/tasks')
        .send({
          title: 'Test task',
          status: 'invalid_status',
        });
      
      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    test('should validate required title field', async () => {
      const response = await request(app)
        .post('/api/tasks')
        .send({
          description: 'Description without title',
        });
      
      expect(response.status).toBe(400);
      expect(response.body.errors).toBeDefined();
    });
  });

  describe('PATCH /api/tasks/:id', () => {
    test('should reject invalid status update', async () => {
      const response = await request(app)
        .patch('/api/tasks/550e8400-e29b-41d4-a716-446655440000')
        .send({
          status: 'invalid_status',
        });
      
      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    test('should reject invalid category', async () => {
      const response = await request(app)
        .patch('/api/tasks/550e8400-e29b-41d4-a716-446655440000')
        .send({
          category: 'invalid_category',
        });
      
      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });

    test('should reject invalid priority', async () => {
      const response = await request(app)
        .patch('/api/tasks/550e8400-e29b-41d4-a716-446655440000')
        .send({
          priority: 'invalid_priority',
        });
      
      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });

  describe('404 Handler', () => {
    test('should return 404 for undefined routes', async () => {
      const response = await request(app).get('/api/undefined-route');
      
      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toContain('not found');
    });
  });
});
