# TaskSense Testing & Validation Guide

This guide helps you validate that TaskSense is working correctly.

## 🧪 Backend Testing

### 1. Unit Tests

Run all tests:
```bash
cd backend
npm test
```

Expected output:
```
PASS  tests/classification.test.js
  ✓ Category detection tests (8 tests)
  ✓ Priority detection tests (4 tests)
  ✓ Entity extraction tests (3 tests)

PASS  tests/api.test.js
  ✓ API endpoint tests (7 tests)
  ✓ Validation tests (4 tests)

PASS  tests/validation.test.js
  ✓ Input validation tests (6 tests)

Test Suites: 3 passed, 3 total
Tests:       21 passed, 21 total
```

### 2. Manual API Testing

#### Test 1: Health Check
```bash
curl http://localhost:3000/health
```
✅ Expected: `{"success": true, "message": "TaskSense API is running"}`

#### Test 2: Create Task (Auto-Classification)
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Schedule urgent meeting with team today",
    "description": "Discuss budget allocation"
  }'
```

✅ Expected Response:
- `category`: "scheduling"
- `priority`: "high"
- `extracted_entities`: Contains "team", "meeting"
- `suggested_actions`: Contains calendar-related actions

#### Test 3: Get All Tasks
```bash
curl http://localhost:3000/api/tasks
```
✅ Expected: Array of tasks

#### Test 4: Filter by Status
```bash
curl "http://localhost:3000/api/tasks?status=pending"
```
✅ Expected: Only pending tasks

#### Test 5: Get Task Statistics
```bash
curl http://localhost:3000/api/tasks/stats
```
✅ Expected: Object with byStatus, byCategory, byPriority

#### Test 6: Update Task
```bash
curl -X PATCH http://localhost:3000/api/tasks/{task_id} \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'
```
✅ Expected: Task updated successfully

#### Test 7: Delete Task
```bash
curl -X DELETE http://localhost:3000/api/tasks/{task_id}
```
✅ Expected: Task deleted successfully

---

## 📱 Flutter App Testing

### 1. Manual Testing Checklist

#### Dashboard Screen
- [ ] App launches successfully
- [ ] Summary cards display correct counts
- [ ] Tasks list loads
- [ ] Pull-to-refresh works
- [ ] Search filters tasks correctly
- [ ] Filter dialog opens
- [ ] Empty state shows when no tasks
- [ ] Loading indicator appears during fetch

#### Task Creation
- [ ] FAB button opens create form
- [ ] Title field is required
- [ ] Description is optional
- [ ] Date picker works
- [ ] Time picker works
- [ ] Task creates successfully
- [ ] Returns to dashboard after creation
- [ ] New task appears in list
- [ ] Success message shows

#### Task Editing
- [ ] Tapping task opens edit form
- [ ] Form pre-fills with task data
- [ ] Can update title
- [ ] Can change status
- [ ] Can enable manual override
- [ ] Manual override shows category/priority fields
- [ ] Update saves successfully
- [ ] Changes reflect in dashboard

#### Task Deletion
- [ ] Delete button shows in edit mode
- [ ] Confirmation dialog appears
- [ ] Cancel works
- [ ] Delete removes task
- [ ] Returns to dashboard
- [ ] Task removed from list

#### Filtering
- [ ] Status filter works
- [ ] Category filter works
- [ ] Priority filter works
- [ ] Multiple filters combine correctly
- [ ] Clear filters resets view

#### Search
- [ ] Search finds tasks by title
- [ ] Search finds tasks by description
- [ ] Search is case-insensitive
- [ ] Clear button works
- [ ] Search + filters work together

---

## 🎯 Classification Testing

Test various task titles to validate auto-classification:

### Scheduling Tasks (Expected: scheduling category)
```bash
# Test 1: Meeting
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Schedule team meeting for project discussion"}'

# Test 2: Appointment
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Book appointment with client next week"}'

# Test 3: Deadline
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Submit project by deadline tomorrow"}'
```
✅ All should have `category: "scheduling"`

### Finance Tasks (Expected: finance category)
```bash
# Test 1: Invoice
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Process invoice payment for vendor"}'

# Test 2: Budget
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Review quarterly budget allocation"}'

# Test 3: Expense
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Submit expense report for travel"}'
```
✅ All should have `category: "finance"`

### Technical Tasks (Expected: technical category)
```bash
# Test 1: Bug
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Fix critical bug in authentication system"}'

# Test 2: Deployment
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Deploy new feature to production server"}'

# Test 3: Maintenance
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Perform system maintenance and updates"}'
```
✅ All should have `category: "technical"`

### Safety Tasks (Expected: safety category)
```bash
# Test 1: Inspection
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Conduct safety inspection of workplace"}'

# Test 2: Compliance
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Review compliance checklist for regulations"}'

# Test 3: Hazard
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Report hazard in construction area"}'
```
✅ All should have `category: "safety"`

### Priority Detection

#### High Priority
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "URGENT: Fix critical production issue immediately"}'
```
✅ Should have `priority: "high"`

#### Medium Priority
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Important task to complete this week"}'
```
✅ Should have `priority: "medium"`

#### Low Priority
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Review documentation when available"}'
```
✅ Should have `priority: "low"`

---

## 🔍 Entity Extraction Testing

Test entity extraction:

```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Schedule urgent meeting with John Doe today",
    "description": "Contact Sarah Wilson by 3:00 PM to discuss Q4 budget"
  }'
```

✅ Expected `extracted_entities`:
```json
{
  "people": ["John Doe", "Sarah Wilson"],
  "keywords": ["meeting", "budget"],
  "urgency_indicators": ["urgent", "today"],
  "time_indicators": ["today", "3:00 pm"]
}
```

---

## 🎭 Edge Cases Testing

### 1. Empty Title (Should Fail)
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": ""}'
```
✅ Expected: 400 error with validation message

### 2. Very Long Title (Should Fail)
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "'$(python3 -c 'print("a"*300)')'"}'
```
✅ Expected: 400 error

### 3. Invalid Status (Should Fail)
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "status": "invalid_status"}'
```
✅ Expected: 400 error

### 4. Invalid Date Format (Should Fail)
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test", "due_date": "not-a-date"}'
```
✅ Expected: 400 error

### 5. Task with No Keywords (Should Default to General)
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Random task without specific keywords"}'
```
✅ Expected: `category: "general"`, `priority: "low"`

---

## 🔄 Integration Testing

### Test Full Workflow

1. **Create Task**
```bash
TASK_ID=$(curl -s -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test workflow task"}' | jq -r '.data.id')
```

2. **Get Task**
```bash
curl http://localhost:3000/api/tasks/$TASK_ID
```

3. **Update Task**
```bash
curl -X PATCH http://localhost:3000/api/tasks/$TASK_ID \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

4. **Verify History**
```bash
curl http://localhost:3000/api/tasks/$TASK_ID | jq '.data.history'
```

5. **Delete Task**
```bash
curl -X DELETE http://localhost:3000/api/tasks/$TASK_ID
```

6. **Verify Deletion**
```bash
curl http://localhost:3000/api/tasks/$TASK_ID
```
✅ Expected: 404 error

---

## 📊 Performance Testing

### Load Testing (Optional)

Using Apache Bench:
```bash
# 100 requests, 10 concurrent
ab -n 100 -c 10 -H "Content-Type: application/json" \
  -p post_data.json \
  http://localhost:3000/api/tasks
```

✅ Expected: <100ms average response time

---

## ✅ Validation Checklist

### Backend
- [ ] Server starts without errors
- [ ] All 21 unit tests pass
- [ ] Health endpoint returns 200
- [ ] Can create tasks
- [ ] Can retrieve tasks
- [ ] Can update tasks
- [ ] Can delete tasks
- [ ] Auto-classification works
- [ ] Filters work correctly
- [ ] Validation catches errors
- [ ] Database triggers work
- [ ] Task history is logged

### Flutter App
- [ ] App builds without errors
- [ ] Dashboard loads
- [ ] Can create tasks
- [ ] Can edit tasks
- [ ] Can delete tasks
- [ ] Search works
- [ ] Filters work
- [ ] Pull-to-refresh works
- [ ] Forms validate
- [ ] Error messages display
- [ ] Loading states show
- [ ] Empty states show

### Classification
- [ ] Scheduling tasks detected
- [ ] Finance tasks detected
- [ ] Technical tasks detected
- [ ] Safety tasks detected
- [ ] High priority detected
- [ ] Medium priority detected
- [ ] Low priority detected
- [ ] Entities extracted
- [ ] Actions suggested

### Deployment
- [ ] Backend deploys to Render
- [ ] Environment variables set
- [ ] Database accessible
- [ ] Health check passes
- [ ] Flutter app connects to API

---

## 🐛 Known Issues & Workarounds

None at this time. Report issues on GitHub.

---

## 📝 Test Reports

Document your test results:

```
Test Date: _______________
Tester: __________________

Backend Tests: PASS / FAIL
Flutter Tests: PASS / FAIL
Classification: PASS / FAIL
Integration: PASS / FAIL

Notes:
_________________________
_________________________
```

---

**Happy Testing! 🎉**
