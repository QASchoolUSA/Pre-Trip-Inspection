// Firebase Messaging Service Worker
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyCFcsZigl7WKabZtLY162XeYcNXf6STu7c",
  authDomain: "pretripinspection-71ea7.firebaseapp.com",
  projectId: "pretripinspection-71ea7",
  storageBucket: "pretripinspection-71ea7.firebasestorage.app",
  messagingSenderId: "66778285150",
  appId: "1:66778285150:web:55d334513f65347b8260cf",
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Retrieve Firebase Messaging object
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message: ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: payload.notification.icon || '/icons/icon-192.png',
    badge: '/icons/icon-192.png'
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});