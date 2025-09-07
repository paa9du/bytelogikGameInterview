// lib/features/game/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authViewModelProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user?.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoURL!),
                radius: 40,
              ),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${user?.displayName ?? user?.email ?? 'Player'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to game lobby
              },
              child: const Text('Play Game'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Navigate to leaderboard
              },
              child: const Text('View Leaderboard'),
            ),
          ],
        ),
      ),
    );
  }
}