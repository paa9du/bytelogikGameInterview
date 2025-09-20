import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../game/data/repositories/game_repository_impl.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (_isMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await ref.read(authViewModelProvider.notifier).signOut();
      ref.invalidate(authViewModelProvider);
    } catch (e) {
      if (_isMounted) {
        _showSnackBar('Logout failed: $e');
      }
    }
  }

  /// Online Game
  Future<void> _joinOrCreateGame() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Please sign in first');
        return;
      }

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? 'unknown@email.com',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        // wins: 0,
        // losses: 0,
        // draws: 0,
      );

      final gameRepository = ref.read(gameRepositoryProvider);
      final gameId = await gameRepository.findOrCreateGame(userModel);

      if (_isMounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
        );
      }
    } catch (e) {
      _showSnackBar('Error joining/creating game: $e');
    }
  }

  /// Offline Game
  Future<void> _startOfflineGame() async {
    try {
      // For offline game, we don't need to create anything in Firebase
      // Just navigate to the game screen with a special flag
      if (_isMounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const GameScreen(gameId: 'offline', isOffline: true),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Error starting offline game: $e');
    }
  }

  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user?.displayName ?? user?.email ?? 'OnLine Mode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // adds "..."
                          maxLines: 1, // keeps it single line
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _handleSignOut,
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Column(
                        children: [
                          Icon(
                            Icons.gamepad_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tic-Tac-Toe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Classic Game, Modern Experience',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),

                      // Online Game Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _joinOrCreateGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6A11CB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.online_prediction_rounded),
                              SizedBox(width: 10),
                              Text(
                                'PLAY ONLINE',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Offline Game Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startOfflineGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_alt_rounded),
                              SizedBox(width: 10),
                              Text(
                                'PLAY OFFLINE',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Leaderboard Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _navigateToLeaderboard,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.leaderboard_rounded),
                              SizedBox(width: 10),
                              Text(
                                'VIEW LEADERBOARD',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
