import 'package:attendance_app/screens/splash_sreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:attendance_app/services/auth_user.dart';
import 'package:attendance_app/models/user_model.dart';
import 'package:attendance_app/database/user_db.dart';
import 'package:attendance_app/providers/app_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  bool isLoading = false;
  String? errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await AuthService.login(email, password);

      final token = response['token'];
      // final user = UserModel.fromJson(response['user']);
      final user = UserModel.fromJson(response['user']);

      // Save token and login state
      await ref.read(appStateProvider.notifier).setLogin(token, user.userId);

      // Save user to local DB
      final userDb = UserDb();
      print('🧪 Inserting user to DB...');
      await userDb.insertUser(user);

print('✅ Insert done. Navigating...');
      if (!mounted) return;
      // Navigator.pop(context, true); // Login succeeded
      Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const SplashScreen()),
);

    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // @override
  // void dispose() {
  //   _emailController.dispose();
  //   _passwordController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (errorMessage != null) ...[
                Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              TextFormField(
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value!.trim(),
                validator: (value) =>
                    value!.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (value) => password = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        child: const Text('Login'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
