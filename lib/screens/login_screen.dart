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
      backgroundColor: const Color(0xFF1A1B23),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1B23),
              Color(0xFF2D2E3F),
              Color(0xFF1A1B23),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.fingerprint_rounded,
                      size: 50,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Error Message
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2E3F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (value) => email = value!.trim(),
                      validator: (value) =>
                          value!.isEmpty ? 'Email is required' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2E3F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(20),
                      ),
                      obscureText: true,
                      onSaved: (value) => password = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Password is required' : null,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Login Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
