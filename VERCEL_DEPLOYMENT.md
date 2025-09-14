# PTI Mobile App - Vercel Deployment

This Flutter web application is configured for deployment on Vercel.

## Deployment Steps

### 1. Prerequisites
- Vercel account
- Git repository
- Flutter SDK (handled automatically by Vercel)

### 2. Deploy to Vercel

#### Option A: Using Vercel CLI
1. Install Vercel CLI: `npm install -g vercel`
2. Login: `vercel login`
3. Deploy: `vercel --prod`

#### Option B: Using Vercel Dashboard
1. Import your Git repository to Vercel
2. Vercel will automatically detect the configuration from `vercel.json`
3. Deploy with default settings

### 3. Environment Variables
No additional environment variables are required for basic deployment.

### 4. Build Process
The build process is configured in `vercel.json`:
- Install Flutter SDK automatically
- Run `flutter pub get`
- Build with `flutter build web --release`
- Serve from `build/web` directory

### 5. Features
- Progressive Web App (PWA) support
- Mobile-responsive design
- Offline capabilities
- Service Worker caching

### 6. Custom Domain
Configure your custom domain in the Vercel dashboard under Project Settings > Domains.

## File Structure
- `vercel.json` - Vercel configuration
- `package.json` - Node.js compatibility
- `.vercelignore` - Files to exclude from deployment
- `web/` - Web-specific assets
- `build/web/` - Generated production build (auto-created)

## Troubleshooting
- Ensure all dependencies in `pubspec.yaml` are compatible with web
- Check Vercel deployment logs for any build errors
- Verify that the `build/web` directory contains all necessary files

## Performance
- Tree-shaking enabled for icons (99%+ reduction)
- Optimized for web delivery
- CORS headers configured for security