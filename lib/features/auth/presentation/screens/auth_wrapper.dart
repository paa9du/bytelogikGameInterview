// lib/features/auth/presentation/screens/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/auth_viewmodel.dart';
import './login_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = FirebaseAuth.instance.currentUser;

    // Show loading indicator while checking auth state
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If user is authenticated, show home screen
    if (user != null || authState.isAuthenticated) {
      return const HomeScreen();
    }

    // Otherwise show login screen
    return const LoginScreen();
  }
}