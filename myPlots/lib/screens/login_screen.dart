import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Экран входа (перенос app/login.tsx).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _showPassword = false;
  bool _registerMode = false;

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final ok = _registerMode
        ? await auth.signUp(_email.text.trim(), _password.text)
        : await auth.signIn(_email.text.trim(), _password.text);
    if (ok && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final navigator = Navigator.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.4), width: 2),
                    borderRadius: BorderRadius.circular(55),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.home, size: 56, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                const Text('Мои участки',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Управляйте своими участками легко и удобно',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _password,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(auth.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.loading ? null : _submit,
                    child: auth.loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_registerMode ? 'Зарегистрироваться' : 'Войти',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: auth.loading ? null : () => setState(() => _registerMode = !_registerMode),
                  child: Text(_registerMode
                      ? 'Есть аккаунт? Войти'
                      : 'Нет аккаунта? Зарегистрироваться'),
                ),
                TextButton(
                  onPressed: auth.loading || !auth.isAuthenticated ? null : () async {
                    await auth.signOut();
                    if (mounted) navigator.pushReplacementNamed('/');
                  },
                  child: const Text('Выйти', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
