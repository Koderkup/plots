# MyPlotsApp (Flutter)

Порт приложения **MyPlotsApp** с **React Native (Expo)** на **Flutter / Dart**.
Работает на Android, iOS и Web. Соединение с **Firebase** (Authentication email/пароль + Cloud Firestore) реализовано.

## Структура проекта (порт с `myPlotsApp`)

```text
lib/
  main.dart                 # точка входа, инициализация Firebase, навигация, провайдеры
  firebase_options.dart     # конфигурация Firebase (здесь вписать свои ключи)
  models/
    plot.dart               # Apartment, Floor, Entrance, PlotParams, Plot (как в src/types)
  providers/
    auth_provider.dart      # авторизация (аналог AuthContext)
    plots_provider.dart     # участки + слушатель Firestore (аналог PlotsContext)
  screens/
    login_screen.dart       # вход / регистрация (app/login.tsx)
    home_screen.dart        # список участков, выход (app/index.tsx)
    create_plot_screen.dart # создание участка (app/create-plot.tsx)
    plot_detail_screen.dart # детали участка, редактирование квартиры (app/plot/[id].tsx)
  services/
    auth_service.dart       # Firebase Auth (signIn/signUp/logout)
    plot_service.dart       # Firestore: снимок списка, add/update/delete
android/                    # нативный Android (ApplicationId com.myplotsapp.my_plots_app_flutter)
ios/                        # нативный iOS
assets/images/              # иконки и картинки (скопированы из myPlotsApp/assets/images)
```

## Что перенесено из React Native

| Экран React Native | Экран Flutter |
| :--- | :--- |
| `app/login.tsx` | `lib/screens/login_screen.dart` |
| `app/index.tsx` (список участков) | `lib/screens/home_screen.dart` |
| `app/create-plot.tsx` | `lib/screens/create_plot_screen.dart` |
| `app/plot/[id].tsx` | `lib/screens/plot_detail_screen.dart` |
| `src/context/AuthContext.tsx` | `lib/providers/auth_provider.dart` |
| `src/context/PlotsContext.tsx` | `lib/providers/plots_provider.dart` |
| `src/services/emailAuth.ts` + `firebase.ts` | `lib/services/auth_service.dart` + `plot_service.dart` |
| `src/types/index.ts` | `lib/models/plot.dart` |

Логика генерации подъездов/этажей/квартир, нумерации (`sequential` / `byEntrance`), создания/обновления/удаления участков в Firestore — полностью перенесена.

## Настройка Firebase (обязательно)

Приложение инициализирует Firebase вручную через `lib/firebase_options.dart` (работает без файла `google-services.json`).

1. Создайте проект в [Firebase Console](https://console.firebase.google.com) → **Add project**.
2. Включите **Authentication → Sign-in method → Email/Password → Enable**.
3. Создайте базу **Firestore Database → Create database** (для разработки можно «test mode», но см. правила ниже).
4. Откройте `lib/firebase_options.dart` и замените placeholder-значения (`ВАШ_...`) на реальные из **Project settings → General → Your apps → Config**:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'ВАШ_API_KEY',
  authDomain: 'ВАШ_ПРОЕКТ.firebaseapp.com',
  projectId: 'ВАШ_ПРОЕКТ',
  storageBucket: 'ВАШ_ПРОЕКТ.appspot.com',
  messagingSenderId: 'ВАШ_MESSAGING_SENDER_ID',
  appId: 'ВАШ_APP_ID',
);
```

Аналогично заполните блоки `web`, `ios`, `macos`.

1. Настройте правила доступа Firestore (콘соль Firebase → **Firestore Database → Rules**):

```firebase
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /plots/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

Без правил чтения/записи запросы к Firestore будут отклоняться.

2. (Опционально, только Android) Стандартная интеграция через `google-services.json`:
   - Скачайте `google-services.json` для Android-приложения в консоли Firebase и положите в `android/app/google-services.json`.
   - В `android/build.gradle.kts` добавьте в `buildscript { dependencies { classpath("com.google.gms:google-services:4.4.2") } }` и репозиторий `google()`.
   - В `android/app/build.gradle.kts` в конце добавьте `apply(plugin = "com.google.gms.google-services")`.
   - Приложение `com.myplotsapp.my_plots_app_flutter` должно быть зарегистрировано в проекте Firebase с таким же пакетом.

## Как запустить

Установите [Flutter SDK](https://docs.flutter.dev/get-started/install) (в этой среде он уже в `~/flutter`).

```bash
# перейдите в папку проекта
cd "/home/koderkup/Документы/plots/myPlotsAppFlutter"

# установите зависимости (firebase_core, firebase_auth, cloud_firestore, provider)
flutter pub get

# запустите на эмуляторе/устройстве или в Chrome
flutter run                 # устройство / эмулятор
flutter run -d chrome       # веб-браузер

# сборка Android APK
flutter build apk --debug
```

## Проверить код

```bash
flutter pub get
dart analyze lib/     # должно быть 0 ошибок
flutter build apk --debug
```

## Различия от оригинала

- Навигация: вместо `expo-router` (file-based) используется навигация Flutter (`MaterialApp` с именованными маршрутами: `/`, `/home`, `/create-plot`, `/plot`).
- Состояние: вместо React Context используется `provider` (`ChangeNotifierProvider`).
- Картинки: подключены через `pubspec.yaml` → `assets: - assets/images/`.
- iOS: `ios/Runner/AppDelegate.swift` вызывает `FirebaseApp.configure()`.
