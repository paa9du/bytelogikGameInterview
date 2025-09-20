// lib/features/auth/presentation/screens/login_screen.dart
import 'package:bytelogikgameinterview/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tic-Tac-Toe',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Multiplayer Game',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Email/Password Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .signInWithEmail(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                  }
                                },
                          child: authState.isLoading
                              ? const CircularProgressIndicator()
                              : const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sign Up Button
                      // In your LoginScreen, update the Sign Up button:
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                          child: const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ),

                // lib/features/auth/presentation/screens/login_screen.dart
                // DELETE the entire social login buttons section:

                // REMOVE THIS WHOLE SECTION:
                const SizedBox(height: 30),
                const Text('Or continue with'),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AuthButton(
                      icon: Icons.g_translate,
                      text: 'Google',
                      onPressed: authState.isLoading
                          ? null
                          : () => ref
                                .read(authViewModelProvider.notifier)
                                .signInWithGoogle(), // THIS METHOD NO LONGER EXISTS
                    ),
                    const SizedBox(width: 16),
                    // AuthButton(
                    //   icon: Icons.facebook,
                    //   text: 'Facebook',
                    //   onPressed: authState.isLoading
                    //       ? null
                    //       : () => ref
                    //             .read(authViewModelProvider.notifier)
                    //             .signInWithFacebook(), // THIS METHOD NO LONGER EXISTS
                    // ),
                    AuthButton(
                      icon: Icons.facebook,
                      text: 'Facebook',
                      onPressed: authState.isLoading
                          ? null
                          : () async {
                              // Call the notifier method instead of directly using 'state'
                              await ref
                                  .read(authViewModelProvider.notifier)
                                  .signInWithFacebook();
                            },
                    ),
                  ],
                ),

                // Error Message
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      authState.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
