# TaskSense API Documentation

Base URL: `http://localhost:3000/api` (Development)
Production: `https://tasksense-api.onrender.com/api`

## Authentication

Currently, the API does not require authentication. Future versions will implement API key authentication.

## Response Format

All responses follow this structure:

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "errors": [ ... ]  // Optional, for validation errors
}
```

## Endpoints

### 1. Create Task

**POST** `/tasks`

Creates a new task with automatic classification.

#### Request Body
```json
{
  "title": "Schedule urgent meeting with team today",
  "description": "Discuss Q4 budget allocation",
  "assigned_to": "John Doe",
  "due_date": "2025-12-27T14:00:00Z",
  "status": "pending"
}
```

#### Parameters

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| title | string | Yes | Task title (max 255 chars) |
| description | string | No | Task description |
| assigned_to | string | No | Person assigned to task |
| due_date | string (ISO 8601) | No | Task due date |
| status | string | No | pending, in_progress, or completed (default: pending) |

#### Response (201 Created)
```json
{
  "success": true,
  "message": "Task created successfully",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Schedule urgent meeting with team today",
    "description": "Discuss Q4 budget allocation",
    "category": "scheduling",
    "priority": "high",
    "status": "pending",
    "assigned_to": "John Doe",
    "due_date": "2025-12-27T14:00:00.000Z",
    "extracted_entities": {
      "people": ["team", "John Doe"],
      "keywords": ["meeting", "budget"],
      "urgency_indicators": ["urgent", "today"],
      "time_indicators": []
    },
    "suggested_actions": [
      "Block calendar",
      "Send invite",
      "Prepare agenda",
      "Set reminder"
    ],
    "created_at": "2025-12-26T10:00:00.000Z",
    "updated_at": "2025-12-26T10:00:00.000Z"
  }
}
```

---

### 2. Get All Tasks

**GET** `/tasks`

Retrieves all tasks with optional filtering.

#### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| status | string | Filter by status (pending, in_progress, completed) |
| category | string | Filter by category (scheduling, finance, technical, safety, general) |
| priority | string | Filter by priority (high, medium, low) |
| assigned_to | string | Filter by assigned person |

#### Example Requests

```bash
# Get all tasks
GET /tasks

# Get pending tasks
GET /tasks?status=pending

# Get high priority finance tasks
GET /tasks?category=finance&priority=high

# Get tasks assigned to John Doe
GET /tasks?assigned_to=John%20Doe
```

#### Response (200 OK)
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Schedule urgent meeting with team today",
      "description": "Discuss Q4 budget allocation",
      "category": "scheduling",
      "priority": "high",
      "status": "pending",
      "assigned_to": "John Doe",
      "due_date": "2025-12-27T14:00:00.000Z",
      "extracted_entities": { ... },
      "suggested_actions": [ ... ],
      "created_at": "2025-12-26T10:00:00.000Z",
      "updated_at": "2025-12-26T10:00:00.000Z"
    },
    ...
  ]
}
```

---

### 3. Get Task by ID

**GET** `/tasks/{id}`

Retrieves a single task with its history.

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | UUID | Task ID |

#### Response (200 OK)
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Schedule urgent meeting with team today",
    "description": "Discuss Q4 budget allocation",
    "category": "scheduling",
    "priority": "high",
    "status": "in_progress",
    "assigned_to": "John Doe",
    "due_date": "2025-12-27T14:00:00.000Z",
    "extracted_entities": { ... },
    "suggested_actions": [ ... ],
    "created_at": "2025-12-26T10:00:00.000Z",
    "updated_at": "2025-12-26T11:00:00.000Z",
    "history": [
      {
        "id": "660f9511-f3ac-52e5-b827-557766551111",
        "task_id": "550e8400-e29b-41d4-a716-446655440000",
        "action": "status_changed",
        "old_value": { "status": "pending" },
        "new_value": { "status": "in_progress" },
        "changed_by": "John Doe",
        "changed_at": "2025-12-26T11:00:00.000Z"
      },
      {
        "id": "770f9511-f3ac-52e5-b827-557766552222",
        "task_id": "550e8400-e29b-41d4-a716-446655440000",
        "action": "created",
        "new_value": { ... },
        "changed_by": "John Doe",
        "changed_at": "2025-12-26T10:00:00.000Z"
      }
    ]
  }
}
```

#### Error Response (404 Not Found)
```json
{
  "success": false,
  "message": "Task not found"
}
```

---

### 4. Update Task

**PATCH** `/tasks/{id}`

Updates a task. Auto-reclassifies if title/description changes (unless manually overridden).

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | UUID | Task ID |

#### Request Body
```json
{
  "title": "Updated title",
  "description": "Updated description",
  "status": "in_progress",
  "category": "finance",
  "priority": "high",
  "assigned_to": "Jane Smith",
  "due_date": "2025-12-28T14:00:00Z",
  "manualOverride": true
}
```

#### Parameters

| Field | Type | Description |
|-------|------|-------------|
| title | string | Task title (max 255 chars) |
| description | string | Task description |
| status | string | pending, in_progress, or completed |
| category | string | Manual category override |
| priority | string | Manual priority override |
| assigned_to | string | Person assigned to task |
| due_date | string (ISO 8601) | Task due date |
| manualOverride | boolean | If true, prevents auto-reclassification |

**Note**: All fields are optional. Only provided fields will be updated.

#### Response (200 OK)
```json
{
  "success": true,
  "message": "Task updated successfully",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Updated title",
    ...
  }
}
```

---

### 5. Delete Task

**DELETE** `/tasks/{id}`

Deletes a task and its history.

#### URL Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| id | UUID | Task ID |

#### Response (200 OK)
```json
{
  "success": true,
  "message": "Task deleted successfully"
}
```

---

### 6. Get Task Statistics

**GET** `/tasks/stats`

Retrieves task statistics aggregated by status, category, and priority.

#### Response (200 OK)
```json
{
  "success": true,
  "data": {
    "byStatus": {
      "pending": 5,
      "in_progress": 3,
      "completed": 12
    },
    "byCategory": {
      "scheduling": 4,
      "finance": 6,
      "technical": 5,
      "safety": 3,
      "general": 2
    },
    "byPriority": {
      "high": 8,
      "medium": 7,
      "low": 5
    },
    "total": 20
  }
}
```

---

## Auto-Classification

The system automatically classifies tasks based on keywords in the title and description.

### Category Detection

| Category | Keywords |
|----------|----------|
| **scheduling** | meeting, schedule, call, appointment, deadline, calendar, event, conference |
| **finance** | payment, invoice, bill, budget, cost, expense, financial, revenue, profit |
| **technical** | bug, fix, error, install, repair, maintain, code, system, server, deploy |
| **safety** | safety, hazard, inspection, compliance, ppe, accident, risk, emergency |
| **general** | Default (no matches) |

### Priority Detection

| Priority | Keywords |
|----------|----------|
| **high** | urgent, asap, immediately, today, critical, emergency, now, crucial |
| **medium** | soon, this week, important, needed, upcoming |
| **low** | Default (no matches) |

### Entity Extraction

The system extracts:
- **People**: Names mentioned after "with", "by", "assign to", "contact", "notify"
- **Keywords**: Relevant task-related keywords
- **Urgency Indicators**: Keywords indicating urgency
- **Time Indicators**: Dates and times mentioned in text

### Suggested Actions

Based on the detected category, the system suggests relevant actions:

| Category | Suggested Actions |
|----------|-------------------|
| **scheduling** | Block calendar, Send invite, Prepare agenda, Set reminder |
| **finance** | Check budget, Get approval, Generate invoice, Update records |
| **technical** | Diagnose issue, Check resources, Assign technician, Document fix |
| **safety** | Conduct inspection, File report, Notify supervisor, Update checklist |
| **general** | Review task, Assign owner, Set deadline, Add notes |

---

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request (validation error) |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## Rate Limiting

Currently not implemented. Future versions will include rate limiting.

---

## Examples with cURL

### Create a Task
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Fix critical bug in payment system",
    "description": "Users unable to process transactions",
    "assigned_to": "Jane Smith",
    "due_date": "2025-12-26T18:00:00Z"
  }'
```

### Get All Pending Tasks
```bash
curl -X GET "http://localhost:3000/api/tasks?status=pending"
```

### Update Task Status
```bash
curl -X PATCH http://localhost:3000/api/tasks/550e8400-e29b-41d4-a716-446655440000 \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'
```

### Delete a Task
```bash
curl -X DELETE http://localhost:3000/api/tasks/550e8400-e29b-41d4-a716-446655440000
```

### Get Statistics
```bash
curl -X GET http://localhost:3000/api/tasks/stats
```

---

## Testing with Postman

Import this collection URL: (To be added)

---

## Support

For issues or questions, please open an issue on GitHub.
