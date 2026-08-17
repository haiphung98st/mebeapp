// Template file — copy this to app_secrets.dart and fill in real values.
// app_secrets.dart is gitignored and must NEVER be committed.
//
// Setup: cp lib/core/config/app_secrets.template.dart lib/core/config/app_secrets.dart
// Then replace each placeholder with the actual credential.

class AppSecrets {
  AppSecrets._();

  // ── Firebase ─────────────────────────────────────────────────────────────
  // Lấy từ: Firebase Console → Project settings → Your apps

  static const firebaseAndroidApiKey = 'REPLACE_WITH_FIREBASE_ANDROID_API_KEY';
  static const firebaseAndroidAppId = 'REPLACE_WITH_FIREBASE_ANDROID_APP_ID';
  static const firebaseAndroidMessagingSenderId =
      'REPLACE_WITH_FIREBASE_MESSAGING_SENDER_ID';

  static const firebaseIosApiKey = 'REPLACE_WITH_FIREBASE_IOS_API_KEY';
  static const firebaseIosAppId = 'REPLACE_WITH_FIREBASE_IOS_APP_ID';
  static const firebaseIosMessagingSenderId =
      'REPLACE_WITH_FIREBASE_MESSAGING_SENDER_ID';

  static const firebaseWebApiKey = 'REPLACE_WITH_FIREBASE_WEB_API_KEY';
  static const firebaseWebAppId = 'REPLACE_WITH_FIREBASE_WEB_APP_ID';
  static const firebaseWebMessagingSenderId =
      'REPLACE_WITH_FIREBASE_MESSAGING_SENDER_ID';

  static const firebaseProjectId = 'mebe-tracker';
  static const firebaseStorageBucket = 'mebe-tracker.appspot.com';
  static const firebaseIosBundleId = 'com.mebe.mebeTracker';
}
