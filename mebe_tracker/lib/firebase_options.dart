import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'core/config/app_secrets.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const web = FirebaseOptions(
    apiKey: AppSecrets.firebaseWebApiKey,
    appId: AppSecrets.firebaseWebAppId,
    messagingSenderId: AppSecrets.firebaseWebMessagingSenderId,
    projectId: AppSecrets.firebaseProjectId,
    authDomain: AppSecrets.firebaseWebAuthDomain,
    storageBucket: AppSecrets.firebaseStorageBucket,
    measurementId: AppSecrets.firebaseWebMeasurementId,
  );

  static const android = FirebaseOptions(
    apiKey: AppSecrets.firebaseAndroidApiKey,
    appId: AppSecrets.firebaseAndroidAppId,
    messagingSenderId: AppSecrets.firebaseAndroidMessagingSenderId,
    projectId: AppSecrets.firebaseProjectId,
    storageBucket: AppSecrets.firebaseStorageBucket,
  );

  static const ios = FirebaseOptions(
    apiKey: AppSecrets.firebaseIosApiKey,
    appId: AppSecrets.firebaseIosAppId,
    messagingSenderId: AppSecrets.firebaseIosMessagingSenderId,
    projectId: AppSecrets.firebaseProjectId,
    storageBucket: AppSecrets.firebaseStorageBucket,
    iosClientId: AppSecrets.firebaseIosClientId,
    iosBundleId: AppSecrets.firebaseIosBundleId,
  );
}
