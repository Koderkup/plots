import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/plots_provider.dart';
import 'screens/create_plot_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/plot_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('✅ Firebase инициализирован');
  } catch (e, stack) {
    debugPrint('❌ Ошибка инициализации Firebase: $e');
    debugPrint(stack.toString());
    debugPrint('Настройте firebase_options.dart и файлы google-services.json / GoogleService-Info.plist');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlotsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPlotsApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const AuthWrapper(),
      routes: {
        '/home': (_) => const HomeScreen(),
        '/create-plot': (_) => const CreatePlotScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/plot') {
          final id = settings.arguments as String?;
          if (id != null && id.isNotEmpty) {
            return MaterialPageRoute(builder: (_) => PlotDetailScreen(plotId: id));
          }
        }
        return null;
      },
    );
  }
}

/// Показывает экран входа, пока пользователь не авторизован, иначе — главный экран.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, _) {
        if (auth.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
