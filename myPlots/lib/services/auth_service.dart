import 'package:firebase_auth/firebase_auth.dart';

/// Сервис аутентификации Firebase (это логика из src/services/emailAuth.ts).
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Текущий авторизованный пользователь (или null).
  User? get currentUser => _auth.currentUser;

  /// Поток изменений состояния авторизации (аналог onAuthStateChanged).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Вход по email и паролю.
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Регистрация нового пользователя по email и паролю.
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Выход.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'user-disabled':
        return 'Пользователь заблокирован';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'email-already-in-use':
        return 'Этот email уже зарегистрирован';
      case 'weak-password':
        return 'Слишком слабый пароль';
      case 'invalid-email':
        return 'Некорректный email';
      case 'operation-not-allowed':
        return 'Вход по email/паролю отключён в консоли Firebase';
      default:
        return e.message ?? 'Ошибка авторизации Firebase';
    }
  }
}