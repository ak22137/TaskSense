# TaskSense Backend Deployment Guide

## Prerequisites

1. **GitHub Account**: Code must be in a GitHub repository
2. **Supabase Account**: Database setup at https://supabase.com
3. **Render Account**: Deployment platform at https://render.com

## Step 1: Setup Supabase Database

1. Go to [Supabase](https://supabase.com) and create a new project
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `database/schema.sql`
4. Click **Run** to create tables and indexes
5. Go to **Settings** → **API** and note:
   - Project URL (SUPABASE_URL)
   - Anon/Public Key (SUPABASE_KEY)

## Step 2: Deploy to Render

### Option A: Using Blueprint (Recommended)

1. Push your code to GitHub
2. Go to [Render Dashboard](https://dashboard.render.com)
3. Click **New** → **Blueprint**
4. Connect your GitHub repository
5. Render will detect `render.yaml` automatically
6. Add environment variables:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_KEY`: Your Supabase anon key
7. Click **Apply** to deploy

### Option B: Manual Setup

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **New** → **Web Service**
3. Connect your GitHub repository
4. Configure:
   - **Name**: tasksense-api
   - **Region**: Oregon (US West)
   - **Branch**: main
   - **Root Directory**: Leave empty
   - **Environment**: Node
   - **Build Command**: `cd backend && npm install`
   - **Start Command**: `cd backend && npm start`
5. Add Environment Variables:
   ```
   NODE_ENV=production
   PORT=3000
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_KEY=your-anon-key-here
   ALLOWED_ORIGINS=*
   ```
6. Click **Create Web Service**

## Step 3: Verify Deployment

Once deployed, your API will be available at:
```
https://tasksense-api.onrender.com
```

Test endpoints:
```bash
# Health check
curl https://tasksense-api.onrender.com/health

# Root endpoint
curl https://tasksense-api.onrender.com/

# Get tasks
curl https://tasksense-api.onrender.com/api/tasks
```

## Step 4: Update Flutter App

Update the API endpoint in your Flutter app:

Edit `flutter_app/lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'https://tasksense-api.onrender.com/api';
}
```

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| NODE_ENV | Environment mode | production |
| PORT | Server port (Render sets this) | 3000 |
| SUPABASE_URL | Supabase project URL | https://xyz.supabase.co |
| SUPABASE_KEY | Supabase anon key | eyJhbGci... |
| ALLOWED_ORIGINS | CORS allowed origins | * |

## Monitoring

### Render Dashboard
- View logs: **Logs** tab in your service
- Monitor health: Check health check status
- View metrics: CPU, memory, and request stats

### Health Check
The `/health` endpoint provides server status:
```json
{
  "success": true,
  "message": "TaskSense API is running",
  "timestamp": "2025-12-26T10:00:00.000Z",
  "environment": "production"
}
```

## Troubleshooting

### Build Failures
- Check build logs in Render dashboard
- Verify `package.json` is in `backend/` directory
- Ensure all dependencies are in `dependencies` not `devDependencies`

### Runtime Errors
- Check application logs in Render
- Verify environment variables are set correctly
- Test Supabase connection from local environment first

### Database Connection Issues
- Verify SUPABASE_URL and SUPABASE_KEY
- Check Supabase project status
- Ensure database tables are created

## Free Tier Limitations

Render's free tier includes:
- 750 hours/month compute time
- Services spin down after 15 minutes of inactivity
- First request after spin-down may take 30-60 seconds

To prevent spin-down, upgrade to paid tier or use an uptime monitor.

## Continuous Deployment

Render automatically deploys when you push to your main branch:
1. Make changes locally
2. Commit and push to GitHub
3. Render automatically builds and deploys
4. Monitor deployment in Render dashboard

## Custom Domain (Optional)

To use a custom domain:
1. Go to your service settings in Render
2. Click **Custom Domain**
3. Follow instructions to add DNS records
4. SSL certificate is automatically provisioned

## Scaling

To handle more traffic:
1. Upgrade to paid tier in Render
2. Increase instance size
3. Enable auto-scaling
4. Consider adding a Redis cache layer

---

**Need Help?**
- [Render Documentation](https://render.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- Check GitHub Issues in the repository
