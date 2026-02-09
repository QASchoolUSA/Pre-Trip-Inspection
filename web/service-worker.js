// Service Worker for Local Notifications with iOS PWA support
const CACHE_NAME = 'pti-mobile-app-v2';  // Increment version to bust cache
const urlsToCache = [
  '/',
  '/index.html',
  '/icons/icon-192.png',
  '/icons/icon-512.png'
];

// Development mode flag - set to true to disable caching during development
const DEVELOPMENT_MODE = false;  // Set to false for production

// Install event - cache assets
self.addEventListener('install', event => {
  // Skip waiting to activate new service worker immediately
  self.skipWaiting();

  if (DEVELOPMENT_MODE) {
    console.log('Development mode: Skipping cache installation');
    return;
  }

  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Opened cache');
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch event - serve cached content when offline
self.addEventListener('fetch', event => {
  if (DEVELOPMENT_MODE) {
    // In development mode, always fetch from network
    event.respondWith(
      fetch(event.request)
        .catch(() => {
          // Only fallback to cache for essential resources if network fails
          if (event.request.url.includes('/icons/') ||
            event.request.url.endsWith('/') ||
            event.request.url.includes('index.html')) {
            return caches.match(event.request);
          }
          throw new Error('Network unavailable and no cache fallback');
        })
    );
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});

// Handle push notifications with iOS-specific options
self.addEventListener('push', event => {
  console.log('Push event received:', event);

  let notificationData;
  if (event.data) {
    notificationData = event.data.json();
  } else {
    notificationData = {
      title: 'PTI Reminder',
      body: 'Time to perform your daily Pre-Trip Inspection',
      icon: '/icons/icon-192.png'
    };
  }

  const options = {
    body: notificationData.body,
    icon: notificationData.icon || '/icons/icon-192.png',
    badge: '/icons/icon-192.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 'pti-notification'
    },
    actions: [
      {
        action: 'perform-inspection',
        title: 'Perform PTI'
      },
      {
        action: 'dismiss',
        title: 'Dismiss'
      }
    ],
    // iOS-specific options
    requireInteraction: notificationData.requireInteraction || false,
    // On iOS, notifications should be more persistent
    renotify: true,
    tag: 'pti-notification'
  };

  event.waitUntil(
    self.registration.showNotification(notificationData.title, options)
  );
});

// Handle notification clicks
self.addEventListener('notificationclick', event => {
  console.log('Notification click received:', event);

  event.notification.close();

  // Handle action buttons
  if (event.action === 'perform-inspection') {
    event.waitUntil(
      clients.openWindow('/')
    );
  } else {
    // Default action - open the app
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

// Store scheduled notifications in IndexedDB
function storeScheduledNotification(notification) {
  if (self.indexedDB) {
    const request = indexedDB.open('PTINotifications', 1);

    request.onupgradeneeded = function (event) {
      const db = event.target.result;
      if (!db.objectStoreNames.contains('scheduled')) {
        db.createObjectStore('scheduled', { keyPath: 'id' });
      }
    };

    request.onsuccess = function (event) {
      const db = event.target.result;
      const transaction = db.transaction(['scheduled'], 'readwrite');
      const store = transaction.objectStore('scheduled');
      store.put(notification);
    };
  }
}

// Get scheduled notifications from IndexedDB
function getScheduledNotifications() {
  return new Promise((resolve, reject) => {
    if (self.indexedDB) {
      const request = indexedDB.open('PTINotifications', 1);

      request.onsuccess = function (event) {
        const db = event.target.result;
        const transaction = db.transaction(['scheduled'], 'readonly');
        const store = transaction.objectStore('scheduled');
        const getAllRequest = store.getAll();

        getAllRequest.onsuccess = function (event) {
          resolve(event.target.result || []);
        };

        getAllRequest.onerror = function () {
          resolve([]);
        };
      };

      request.onerror = function () {
        resolve([]);
      };
    } else {
      resolve([]);
    }
  });
}

// Handle messages from the app
self.addEventListener('message', event => {
  console.log('Message received:', event.data);

  // Common notification options with iOS support
  const baseOptions = {
    icon: event.data.icon || '/icons/icon-192.png',
    badge: '/icons/icon-192.png',
    vibrate: [100, 50, 100],
    // iOS-specific options
    requireInteraction: event.data.requireInteraction || false,
    renotify: true,
    tag: 'pti-notification'
  };

  switch (event.data.type) {
    case 'SHOW_NOTIFICATION':
      self.registration.showNotification(
        event.data.title,
        {
          body: event.data.body,
          ...baseOptions
        }
      );
      break;

    case 'SCHEDULE_DAILY_REMINDER':
      // Store the scheduled notification
      const scheduledNotification = {
        id: 'daily-reminder',
        title: event.data.title,
        body: event.data.body,
        hour: event.data.hour,
        minute: event.data.minute,
        requireInteraction: event.data.requireInteraction || false,
        createdAt: Date.now()
      };

      storeScheduledNotification(scheduledNotification);

      // For this demo, we'll just show a notification immediately
      // In a real implementation, you would set up periodic notifications
      self.registration.showNotification(
        event.data.title,
        {
          body: event.data.body,
          ...baseOptions
        }
      );

      // Set up periodic notifications using background sync if available
      if ('periodicSync' in self.registration) {
        self.registration.periodicSync.register('pti-daily-reminder', {
          minInterval: 24 * 60 * 60 * 1000, // 24 hours
        }).catch(err => {
          console.log('Periodic sync registration failed:', err);
        });
      }
      break;

    case 'CANCEL_NOTIFICATIONS':
      // Cancel any scheduled notifications
      // In a real implementation, you would clear any timeouts or intervals
      break;
  }
});

// Handle periodic background sync for daily reminders
self.addEventListener('periodicsync', event => {
  if (event.tag === 'pti-daily-reminder') {
    event.waitUntil(handleDailyReminder());
  }
});

// Handle daily reminder logic
async function handleDailyReminder() {
  try {
    // Get scheduled notifications
    const scheduledNotifications = await getScheduledNotifications();
    const dailyReminder = scheduledNotifications.find(n => n.id === 'daily-reminder');

    if (dailyReminder) {
      // Show the notification
      await self.registration.showNotification(dailyReminder.title, {
        body: dailyReminder.body,
        icon: '/icons/icon-192.png',
        badge: '/icons/icon-192.png',
        vibrate: [100, 50, 100],
        requireInteraction: dailyReminder.requireInteraction || false,
        renotify: true,
        tag: 'pti-notification'
      });
    }
  } catch (error) {
    console.error('Error handling daily reminder:', error);
  }
}