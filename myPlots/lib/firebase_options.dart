import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Конфигурация Firebase для всех платформ.
///
/// ⚠️ ВНИМАНИЕ: Замените placeholder-значения ниже на реальные данные
/// из вашего проекта в консоли Firebase (Project settings → General → Your apps).
///
/// Также обязательно:
///  • Android: положите файл `google-services.json` в `android/app/`
///           (скачайте из консоли Firebase) и убедитесь, что google-services
///           плагин подключен в android/build.gradle + android/app/build.gradle.
///  • iOS:     положите файл `GoogleService-Info.plist` в `ios/Runner/`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;
    if (Platform.isMacOS) return macos;
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'ВАШ_WEB_API_KEY',
    authDomain: 'ВАШ_ПРОЕКТ.firebaseapp.com',
    projectId: 'ВАШ_ПРОЕКТ',
    storageBucket: 'ВАШ_ПРОЕКТ.appspot.com',
    messagingSenderId: 'ВАШ_MESSAGING_SENDER_ID',
    appId: 'ВАШ_APP_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ВАШ_ANDROID_API_KEY',
    appId: '1:ВАШ_ПРОЕКТ:android:ВАШ_APP_ID',
    messagingSenderId: 'ВАШ_MESSAGING_SENDER_ID',
    projectId: 'ВАШ_ПРОЕКТ',
    storageBucket: 'ВАШ_ПРОЕКТ.appspot.com',
    authDomain: 'ВАШ_ПРОЕКТ.firebaseapp.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'ВАШ_IOS_API_KEY',
    appId: '1:ВАШ_ПРОЕКТ:ios:ВАШ_APP_ID',
    messagingSenderId: 'ВАШ_MESSAGING_SENDER_ID',
    projectId: 'ВАШ_ПРОЕКТ',
    storageBucket: 'ВАШ_ПРОЕКТ.appspot.com',
    authDomain: 'ВАШ_ПРОЕКТ.firebaseapp.com',
    iosBundleId: 'com.myplotsapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'ВАШ_MACOS_API_KEY',
    appId: '1:ВАШ_ПРОЕКТ:macos:ВАШ_APP_ID',
    messagingSenderId: 'ВАШ_MESSAGING_SENDER_ID',
    projectId: 'ВАШ_ПРОЕКТ',
    storageBucket: 'ВАШ_ПРОЕКТ.appspot.com',
    authDomain: 'ВАШ_ПРОЕКТ.firebaseapp.com',
    iosBundleId: 'com.myplotsapp',
  );
}