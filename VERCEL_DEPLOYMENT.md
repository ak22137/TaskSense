# Vercel Deployment Guide for TaskSense

## 🚀 Deploy to Vercel

### Prerequisites
- GitHub account
- Vercel account (sign up at https://vercel.com)
- Supabase database already set up

### Step 1: Push to GitHub

```bash
git add .
git commit -m "feat: Add Vercel deployment configuration"
git push
```

### Step 2: Deploy on Vercel

1. **Go to**: https://vercel.com/new
2. **Import your repository**: `ak22137/TaskSense`
3. **Configure Project**:
   - **Framework Preset**: Other
   - **Root Directory**: `./` (leave as is)
   - **Build Command**: Leave empty or `cd backend && npm install`
   - **Output Directory**: Leave empty
   - **Install Command**: `cd backend && npm install`

4. **Add Environment Variables**:
   Click "Environment Variables" and add:
   ```
   NODE_ENV=production
   SUPABASE_URL=https://qplgljpfyiodrkcumztw.supabase.co
   SUPABASE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFwbGdsanBmeWlvZHJrY3VtenR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY3NjAwNDMsImV4cCI6MjA4MjMzNjA0M30.mwblbv3M1Db_YIyY9JcrpWLG4vZqLLA4qZxaPfC3AQo
   ALLOWED_ORIGINS=*
   PORT=3000
   ```

5. **Click**: "Deploy"

### Step 3: Get Your API URL

After deployment (2-3 minutes), your API will be at:
```
https://your-project-name.vercel.app
```

### Step 4: Test Your API

```bash
# Test health endpoint
curl https://your-project-name.vercel.app/health

# Test tasks endpoint
curl https://your-project-name.vercel.app/api/tasks
```

### Step 5: Update Flutter App

Edit `flutter_app/lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://your-project-name.vercel.app/api';
```

## 📝 Important Notes

### Vercel Serverless Limitations
- **Cold starts**: First request may take 2-3 seconds
- **Timeout**: 10 seconds per request (free tier)
- **No persistent connections**: Each request is isolated

### Environment Variables
All environment variables are set in Vercel dashboard:
- Go to: Project Settings → Environment Variables
- Add/edit as needed
- Redeploy to apply changes

### Custom Domain (Optional)
1. Go to Project Settings → Domains
2. Add your custom domain
3. Follow DNS configuration instructions

## 🔄 Continuous Deployment

Vercel automatically deploys when you push to GitHub:
```bash
git add .
git commit -m "Update: your changes"
git push
```

Vercel will:
1. Detect the push
2. Build automatically
3. Deploy new version
4. Update your URL

## 🐛 Troubleshooting

### Deployment Failed
- Check build logs in Vercel dashboard
- Verify environment variables are set
- Ensure `vercel.json` is in root directory

### API Returns 404
- Check `vercel.json` routes configuration
- Verify `backend/server.js` exports app correctly

### Database Connection Errors
- Verify Supabase credentials in environment variables
- Check Supabase project is active
- Ensure tables are created

## 📊 Monitoring

View logs and analytics:
1. Go to Vercel Dashboard
2. Select your project
3. Click "Deployments" to see logs
4. Click "Analytics" for performance metrics

## 💰 Pricing

**Free Tier Includes**:
- 100 GB bandwidth/month
- Unlimited deployments
- Automatic SSL
- Global CDN

For production, consider upgrading to Pro for:
- Longer execution time
- More bandwidth
- Team collaboration

---

**Your API is now live on Vercel! 🎉**
