# TaskSense - Quick Start Guide

Get TaskSense up and running in minutes!

## 🚀 Quick Setup

### Prerequisites Checklist
- [ ] Node.js 18+ installed
- [ ] PostgreSQL/Supabase account
- [ ] Git installed
- [ ] Flutter SDK (for mobile app)

---

## Backend Setup (5 minutes)

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Setup Supabase Database

1. Go to [https://supabase.com](https://supabase.com)
2. Create a new project
3. Go to **SQL Editor**
4. Copy and paste contents from `database/schema.sql`
5. Click **Run**

### 3. Configure Environment

Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Edit `.env` with your Supabase credentials:
```env
PORT=3000
NODE_ENV=development

# Get these from Supabase Settings → API
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=your-anon-key-here

ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5000
```

### 4. Start the Server
```bash
# Development mode (with auto-reload)
npm run dev

# Or production mode
npm start
```

✅ Backend is now running at `http://localhost:3000`

### 5. Test the API
```bash
# Health check
curl http://localhost:3000/health

# Get tasks
curl http://localhost:3000/api/tasks
```

---

## Flutter App Setup (5 minutes)

### 1. Install Dependencies
```bash
cd flutter_app
flutter pub get
```

### 2. Configure API Endpoint

Edit `lib/config/api_config.dart`:

For Android Emulator:
```dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

For iOS Simulator:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

For Real Device (use your computer's IP):
```dart
static const String baseUrl = 'http://192.168.1.XXX:3000/api';
```

### 3. Run the App
```bash
# Connect your device or start an emulator first
flutter devices

# Run the app
flutter run
```

✅ Flutter app is now running!

---

## Testing (2 minutes)

### Backend Tests
```bash
cd backend
npm test
```

### Test Auto-Classification

Create a test task:
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Schedule urgent meeting with team today",
    "description": "Discuss budget allocation"
  }'
```

The API should automatically:
- Detect category: `scheduling`
- Assign priority: `high`
- Extract entities
- Suggest actions

---

## Deployment (10 minutes)

### Deploy to Render.com

1. **Push to GitHub**
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/SmartTaskFlow.git
git push -u origin main
```

2. **Deploy on Render**
   - Go to [https://render.com](https://render.com)
   - Click **New** → **Blueprint**
   - Connect your GitHub repository
   - Render detects `render.yaml` automatically
   - Add environment variables:
     - `SUPABASE_URL`
     - `SUPABASE_KEY`
   - Click **Apply**

3. **Update Flutter App**

Edit `lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://your-app.onrender.com/api';
```

---

## Troubleshooting

### Backend Won't Start
- Check if `.env` file exists
- Verify Supabase credentials
- Make sure port 3000 is not in use

### Flutter Connection Error
- Verify API endpoint in `api_config.dart`
- Check if backend is running
- For Android emulator, use `10.0.2.2` instead of `localhost`

### Database Errors
- Ensure `schema.sql` was run successfully
- Check Supabase project status
- Verify credentials in `.env`

---

## Next Steps

✅ **Backend is running**: http://localhost:3000  
✅ **Flutter app is running** on your device  
✅ **Tests are passing**

Now you can:
1. Create tasks via the Flutter app
2. Test auto-classification with different keywords
3. Filter and search tasks
4. Deploy to Render.com
5. Share with users!

---

## Quick Commands Reference

### Backend
```bash
cd backend
npm install          # Install dependencies
npm run dev          # Start development server
npm start            # Start production server
npm test             # Run tests
```

### Flutter
```bash
cd flutter_app
flutter pub get      # Install dependencies
flutter run          # Run app
flutter test         # Run tests
flutter build apk    # Build Android APK
```

---

## Getting Help

- Check [README.md](README.md) for detailed documentation
- See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API reference
- Review [DEPLOYMENT.md](DEPLOYMENT.md) for deployment guide

---

**Built with ❤️ for Navicon Internship**
