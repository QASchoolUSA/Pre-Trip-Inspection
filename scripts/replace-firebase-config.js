// Script to replace Firebase configuration placeholders with environment variables
// This script should be run during the build process

const fs = require('fs');
const path = require('path');

// Path to the Firebase config file
const configPath = path.join(__dirname, '../web/firebase-config.js');

// Read the config file
let configContent = fs.readFileSync(configPath, 'utf8');

// Replace placeholders with environment variables if they exist
configContent = configContent.replace(
  'YOUR_API_KEY_PLACEHOLDER',
  process.env.VITE_FIREBASE_API_KEY || 'YOUR_API_KEY_PLACEHOLDER'
);

configContent = configContent.replace(
  'YOUR_PROJECT_ID',
  process.env.VITE_FIREBASE_PROJECT_ID || 'YOUR_PROJECT_ID'
);

configContent = configContent.replace(
  'YOUR_MESSAGING_SENDER_ID',
  process.env.VITE_FIREBASE_MESSAGING_SENDER_ID || 'YOUR_MESSAGING_SENDER_ID'
);

configContent = configContent.replace(
  'YOUR_APP_ID',
  process.env.VITE_FIREBASE_APP_ID || 'YOUR_APP_ID'
);

configContent = configContent.replace(
  'YOUR_MEASUREMENT_ID',
  process.env.VITE_FIREBASE_MEASUREMENT_ID || 'YOUR_MEASUREMENT_ID'
);

// Write the updated config file
fs.writeFileSync(configPath, configContent);

console.log('Firebase configuration updated with environment variables');