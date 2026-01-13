const admin = require('firebase-admin');
const path = require('path');
require('dotenv').config();

// Allow overriding service account path via env var, otherwise try common filenames
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT || path.join(__dirname, '..', 'nexora-8c5e6-firebase-adminsdk-fbsvc-234efbd232.json');

try {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (e) {
  // If the file isn't available, initialize without credentials (will fail verification calls).
  console.warn('firebaseAdmin: service account not found or invalid path', serviceAccountPath);
}

module.exports = admin;
