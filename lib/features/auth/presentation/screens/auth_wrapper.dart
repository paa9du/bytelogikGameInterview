// lib/features/auth/presentation/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/auth_viewmodel.dart';
import './login_screen.dart';
import 'home_screen.dart';

// lib/features/auth/presentation/screens/auth_wrapper.dart
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    // Debug prints
    print('=== AUTH WRAPPER BUILD ===');
    print('isLoading: ${authState.isLoading}');
    print('isAuthenticated: ${authState.isAuthenticated}');
    print('user: ${authState.user?.email}');
    print('error: ${authState.error}');

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.isAuthenticated) {
      print('Navigating to HomeScreen');
      return const HomeScreen();
    }

    print('Navigating to LoginScreen');
    return const LoginScreen();
  }
}
