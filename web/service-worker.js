// Service Worker for Local Notifications
const CACHE_NAME = 'pti-mobile-app-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/icons/icon-192.png',
  '/icons/icon-512.png'
];

// Install event - cache assets
self.addEventListener('install', event => {
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
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});

// Handle push notifications
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
    ]
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

// Handle messages from the app
self.addEventListener('message', event => {
  console.log('Message received:', event.data);
  
  switch (event.data.type) {
    case 'SHOW_NOTIFICATION':
      self.registration.showNotification(
        event.data.title,
        {
          body: event.data.body,
          icon: event.data.icon || '/icons/icon-192.png',
          badge: '/icons/icon-192.png',
          vibrate: [100, 50, 100]
        }
      );
      break;
      
    case 'SCHEDULE_DAILY_REMINDER':
      // In a real implementation, you would schedule periodic notifications
      // For this demo, we'll just show a notification immediately
      self.registration.showNotification(
        event.data.title,
        {
          body: event.data.body,
          icon: '/icons/icon-192.png',
          badge: '/icons/icon-192.png',
          vibrate: [100, 50, 100]
        }
      );
      break;
      
    case 'CANCEL_NOTIFICATIONS':
      // Cancel any scheduled notifications
      // In a real implementation, you would clear any timeouts or intervals
      break;
  }
});