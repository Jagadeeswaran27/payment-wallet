import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String _getEnv(String key) {
    return dotenv.env[key]!;
  }

  //web based Keys
  static String get firebaseWebApiKey => _getEnv('FIREBASE_WEB_API_KEY');
  static String get firebaseWebAppId => _getEnv('FIREBASE_WEB_APP_ID');
  static String get firebaseWebMessagingSenderId =>
      _getEnv('FIREBASE_WEB_MESSAGING_SENDER_ID');
  static String get firebaseWebProjectId => _getEnv('FIREBASE_WEB_PROJECT_ID');
  static String get firebaseWebStorageBucket =>
      _getEnv('FIREBASE_WEB_STORAGE_BUCKET');
  static String get firebaseWebMeasurementId =>
      _getEnv('FIREBASE_WEB_MEASUREMENT_ID');
  static String get firebaseWebAuthDomain =>
      _getEnv('FIREBASE_WEB_AUTH_DOMAIN');

  //android based Keys

  static String get firebaseAndroidApiKey =>
      _getEnv('FIREBASE_ANDROID_API_KEY');
  static String get firebaseAndroidAppId => _getEnv('FIREBASE_ANDROID_APP_ID');
  static String get firebaseAndroidMessagingSenderId =>
      _getEnv('FIREBASE_ANDROID_MESSAGING_SENDER_ID');
  static String get firebaseAndroidProjectId =>
      _getEnv('FIREBASE_ANDROID_PROJECT_ID');
  static String get firebaseAndroidStorageBucket =>
      _getEnv('FIREBASE_ANDROID_STORAGE_BUCKET');

  //ios based Keys

  static String get firebaseIosApiKey => _getEnv('FIREBASE_IOS_API_KEY');
  static String get firebaseIosAppId => _getEnv('FIREBASE_IOS_APP_ID');
  static String get firebaseIosMessagingSenderId =>
      _getEnv('FIREBASE_IOS_MESSAGING_SENDER_ID');
  static String get firebaseIosProjectId => _getEnv('FIREBASE_IOS_PROJECT_ID');
  static String get firebaseIosStorageBucket =>
      _getEnv('FIREBASE_IOS_STORAGE_BUCKET');
  static String get firebaseIosBundleId => _getEnv('FIREBASE_IOS_BUNDLE_ID');

  static String get appName => _getEnv('APP_NAME');
  static String get appDescription => _getEnv('APP_DESCRIPTION');
  static String get appVersion => _getEnv('APP_VERSION');
  static String get appBuildNumber => _getEnv('APP_BUILD_NUMBER');
  static String get appPackageName => _getEnv('APP_PACKAGE_NAME');
  static String get appBundleId => _getEnv('APP_BUNDLE_ID');
  static String get appDeveloperName => _getEnv('APP_DEVELOPER_NAME');
  static String get appDeveloperEmail => _getEnv('APP_DEVELOPER_EMAIL');
  static String get appDeveloperWebsite => _getEnv('APP_DEVELOPER_WEBSITE');
}
