# Caching Configuration Documentation

## Overview
This document describes the caching mechanisms implemented in the PTI Mobile App and how to configure them for different environments.

## Caching Mechanisms

### 1. Service Worker Caching (Web)
**Location**: `web/service-worker.js`

The service worker implements browser-level caching for PWA functionality:
- Caches essential assets (icons, index.html, root path)
- Provides offline fallback for critical resources
- Handles push notifications

**Development Configuration**:
```javascript
const DEVELOPMENT_MODE = true; // Set to true to disable caching
```

When `DEVELOPMENT_MODE` is enabled:
- Cache installation is skipped during service worker install
- All requests bypass cache and fetch from network
- Only essential resources (icons, index.html) have cache fallback on network failure

**Production Configuration**:
```javascript
const DEVELOPMENT_MODE = false; // Set to false to enable caching
```

### 2. HTTP Cache Headers (API Requests)
**Location**: `lib/core/services/api_service.dart`

The API service adds cache control headers to HTTP requests:

**Development Configuration**:
```dart
// Disable caching during development
if (kDebugMode) {
  options.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
  options.headers['Pragma'] = 'no-cache';
  options.headers['Expires'] = '0';
}
```

These headers ensure:
- `Cache-Control: no-cache, no-store, must-revalidate` - Prevents any caching
- `Pragma: no-cache` - HTTP/1.0 compatibility
- `Expires: 0` - Forces immediate expiration

### 3. Local Storage Caching
**Location**: `lib/data/datasources/database_service.dart`

Uses Hive for local data persistence:
- Inspections data
- Vehicle information
- User data
- Application settings

This caching is always active and provides offline functionality.

## Configuration for Different Environments

### Development Environment
1. **Service Worker**: Set `DEVELOPMENT_MODE = true` in `web/service-worker.js`
2. **API Requests**: Cache headers are automatically added when `kDebugMode` is true
3. **Local Storage**: Remains active for offline functionality

### Production Environment
1. **Service Worker**: Set `DEVELOPMENT_MODE = false` in `web/service-worker.js`
2. **API Requests**: No cache headers added, allowing normal HTTP caching
3. **Local Storage**: Remains active for offline functionality

## Best Practices

### During Development
- Keep `DEVELOPMENT_MODE = true` to ensure fresh content
- Monitor network requests to verify cache bypass
- Test offline functionality with essential resources

### Before Production Deployment
- Set `DEVELOPMENT_MODE = false` to enable caching
- Test PWA functionality with caching enabled
- Verify offline capabilities work as expected

### Cache Management
- Update `CACHE_NAME` version when deploying significant changes
- Clear browser cache during development if needed
- Monitor cache size and performance impact

## Troubleshooting

### Common Issues
1. **Stale Content**: Ensure `DEVELOPMENT_MODE = true` during development
2. **Offline Issues**: Check if essential resources are properly cached
3. **Performance**: Monitor cache hit rates and adjust cache strategy

### Cache Clearing
- **Browser**: Use developer tools to clear cache
- **Service Worker**: Update `CACHE_NAME` to force cache refresh
- **Local Storage**: Use database service methods to clear Hive boxes

## Future Enhancements
- Implement cache versioning strategy
- Add cache size monitoring
- Consider implementing selective cache invalidation
- Add cache performance metrics