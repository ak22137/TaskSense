# TaskSense - Smart Task Management Application

A task management application that automatically classifies and organizes tasks based on content analysis using intelligent keyword detection and entity extraction.

## 📋 Overview

TaskSense automatically:
- **Detects Categories**: Scheduling, Finance, Technical, Safety, or General
- **Assigns Priority**: High, Medium, or Low based on urgency keywords
- **Extracts Entities**: Dates, person names, locations, and action verbs
- **Suggests Actions**: Context-aware recommendations based on task category

**Example**: 
> User creates: "Schedule urgent meeting with team today about budget allocation"

System automatically:
- Category: `Scheduling` (keywords: meeting, schedule)
- Priority: `High` (keywords: urgent, today)
- Entities: `team`, `budget`
- Actions: `Block calendar`, `Send invite`, `Prepare agenda`

## 🛠️ Tech Stack

### Backend
- **Runtime**: Node.js v18+
- **Framework**: Express.js
- **Database**: PostgreSQL (Supabase)
- **Testing**: Jest
- **Deployment**: Render.com

### Frontend
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Design**: Material Design 3

## 🏗️ Architecture

```
SmartTaskFlow/
├── backend/                 # Node.js API
│   ├── src/
│   │   ├── config/         # Database & environment config
│   │   ├── controllers/    # Request handlers
│   │   ├── models/         # Data models
│   │   ├── routes/         # API routes
│   │   ├── services/       # Business logic
│   │   ├── middleware/     # Express middleware
│   │   └── utils/          # Helper functions
│   ├── tests/              # Unit tests
│   ├── package.json
│   └── server.js
├── flutter_app/            # Flutter mobile app
│   ├── lib/
│   │   ├── models/         # Data models
│   │   ├── providers/      # State management
│   │   ├── screens/        # UI screens
│   │   ├── services/       # API services
│   │   └── widgets/        # Reusable components
│   └── pubspec.yaml
├── database/               # Database schemas
│   └── schema.sql
└── README.md
```

## 💾 Database Schema

### `tasks` Table
```sql
id              uuid PRIMARY KEY
title           text NOT NULL
description     text
category        text        -- scheduling, finance, technical, safety, general
priority        text        -- high, medium, low
status          text        -- pending, in_progress, completed
assigned_to     text
due_date        timestamp
extracted_entities  jsonb   -- dates, people, locations, actions
suggested_actions   jsonb   -- category-based action suggestions
created_at      timestamp
updated_at      timestamp
```

### `task_history` Table
```sql
id              uuid PRIMARY KEY
task_id         uuid REFERENCES tasks(id)
action          text        -- created, updated, status_changed, completed
old_value       jsonb
new_value       jsonb
changed_by      text
changed_at      timestamp
```

## 🚀 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/tasks` | Create a new task (with auto-classification) |
| GET | `/api/tasks` | List all tasks (filters: status, category, priority) |
| GET | `/api/tasks/{id}` | Get task details with history |
| PATCH | `/api/tasks/{id}` | Update task |
| DELETE | `/api/tasks/{id}` | Delete task |

### Example Request: Create Task
```bash
POST /api/tasks
Content-Type: application/json

{
  "title": "Schedule urgent meeting with team today about budget allocation",
  "description": "Discuss Q4 budget and resource allocation with the engineering team",
  "assigned_to": "John Doe",
  "due_date": "2025-12-27T14:00:00Z"
}
```

### Example Response
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Schedule urgent meeting with team today about budget allocation",
  "description": "Discuss Q4 budget and resource allocation with the engineering team",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "assigned_to": "John Doe",
  "due_date": "2025-12-27T14:00:00Z",
  "extracted_entities": {
    "people": ["team", "John Doe"],
    "keywords": ["meeting", "budget", "allocation"],
    "urgency_indicators": ["urgent", "today"]
  },
  "suggested_actions": [
    "Block calendar",
    "Send invite",
    "Prepare agenda",
    "Set reminder"
  ],
  "created_at": "2025-12-26T10:00:00Z",
  "updated_at": "2025-12-26T10:00:00Z"
}
```

## 🧠 Auto-Classification Logic

### Category Detection
- **scheduling**: meeting, schedule, call, appointment, deadline
- **finance**: payment, invoice, bill, budget, cost, expense
- **technical**: bug, fix, error, install, repair, maintain
- **safety**: safety, hazard, inspection, compliance, PPE
- **general**: default (no matches)

### Priority Assignment
- **high**: urgent, asap, immediately, today, critical, emergency
- **medium**: soon, this week, important
- **low**: default (no matches)

### Entity Extraction
- Dates/times mentioned in text
- Person names (after "with", "by", "assign to")
- Location references
- Action verbs

### Suggested Actions by Category
```javascript
{
  "scheduling": ["Block calendar", "Send invite", "Prepare agenda", "Set reminder"],
  "finance": ["Check budget", "Get approval", "Generate invoice", "Update records"],
  "technical": ["Diagnose issue", "Check resources", "Assign technician", "Document fix"],
  "safety": ["Conduct inspection", "File report", "Notify supervisor", "Update checklist"],
  "general": ["Review task", "Assign owner", "Set deadline", "Add notes"]
}
```

## 🔧 Setup Instructions

### Backend Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd SmartTaskFlow/backend
```

2. **Install dependencies**
```bash
npm install
```

3. **Configure environment variables**
Create a `.env` file in the `backend` directory:
```env
PORT=3000
DATABASE_URL=postgresql://user:password@host:5432/tasksense
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
NODE_ENV=development
```

4. **Setup database**
```bash
# Run the schema.sql file in your Supabase/PostgreSQL database
psql $DATABASE_URL -f ../database/schema.sql
```

5. **Run the server**
```bash
# Development
npm run dev

# Production
npm start
```

6. **Run tests**
```bash
npm test
```

### Flutter App Setup

1. **Navigate to Flutter directory**
```bash
cd flutter_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**
Edit `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://your-backend.onrender.com/api';
}
```

4. **Run the app**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

## 📱 Flutter App Features

### Task Dashboard
- **Summary Cards**: Task counts by status (Pending, In Progress, Completed)
- **Task List**: 
  - Title with category chip and priority badge
  - Due date and assigned person
  - Status indicator
  - Pull-to-refresh
- **Search & Filters**: By category, priority, and status
- **Create/Edit Form**:
  - Title and description (required)
  - Due date picker
  - Assign to field
  - Auto-classification preview
  - Manual override option

### UI/UX Features
- Material Design 3
- Loading skeletons
- Offline indicator
- Proper validation & error handling
- Responsive design

## 🚢 Deployment

### Backend (Render.com)

1. **Connect GitHub repository** to Render
2. **Configure build settings**:
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && npm start`
3. **Add environment variables** in Render dashboard
4. **Deploy**

### Database (Supabase)

1. Create a new project on [Supabase](https://supabase.com)
2. Go to SQL Editor
3. Run the `database/schema.sql` file
4. Copy the connection string and API keys to your `.env` file

## 🧪 Testing

Unit tests cover:
- Task creation with auto-classification
- Category detection logic
- Priority assignment logic
- Entity extraction
- API endpoint validation
- Database operations

Run tests:
```bash
cd backend
npm test
```

## 📸 Screenshots

*(Screenshots will be added after Flutter app implementation)*

## 🎯 Architecture Decisions

### Why Node.js + Express?
- Fast development and deployment
- Rich ecosystem for middleware
- Excellent async handling for I/O operations
- Easy integration with PostgreSQL

### Why Supabase?
- PostgreSQL-based (ACID compliance)
- Real-time subscriptions support
- Easy authentication
- Free tier for development
- RESTful API out of the box

### Why Riverpod?
- Better than Provider with compile-time safety
- No BuildContext dependency
- Easy testing
- Family and auto-dispose features

### Classification Approach
- Keyword-based matching (simple, fast, reliable)
- Regex for entity extraction
- JSON storage for flexibility
- Easily extensible for ML models later

## 🚀 Future Improvements

- [ ] Dark mode support
- [ ] Task search with highlighting
- [ ] Export to CSV
- [ ] Real-time updates with Supabase subscriptions
- [ ] Rate limiting
- [ ] API key authentication
- [ ] Swagger/OpenAPI documentation
- [ ] Machine learning-based classification
- [ ] Task dependencies and subtasks
- [ ] File attachments
- [ ] Notifications and reminders

## 👥 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License

## 🔗 Links

- **Live Backend**: [https://tasksense-api.onrender.com](https://tasksense-api.onrender.com)
- **Documentation**: [API Docs](https://tasksense-api.onrender.com/api-docs)
- **Repository**: [GitHub](https://github.com/username/SmartTaskFlow)

## 📞 Contact

For questions or support, please open an issue in the GitHub repository.

---

**Built with ❤️ for Navicon Internship Assessment**
