// lib/features/leaderboard/presentation/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/user_model.dart';
import '../viewmodels/leaderboard_viewmodel.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load leaderboard when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardViewModelProvider.notifier).loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardViewModelProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        ref
                            .read(leaderboardViewModelProvider.notifier)
                            .refreshLeaderboard();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: leaderboardState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _buildLeaderboardContent(
                        leaderboardState,
                        user?.uid ?? '',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardContent(LeaderboardState state, String userId) {
    if (state.error != null) {
      return Center(
        child: Text(
          'Error: ${state.error}',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (state.players.isEmpty) {
      return const Center(
        child: Text('No players found', style: TextStyle(color: Colors.white)),
      );
    }

    // Find current user's position
    final userIndex = state.players.indexWhere((player) => player.id == userId);
    final userRank = userIndex >= 0 ? userIndex + 1 : 0;

    return Column(
      children: [
        // User's current rank card
        if (userIndex >= 0)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      state.players[userIndex].photoUrl != null &&
                          state.players[userIndex].photoUrl!.isNotEmpty
                      ? NetworkImage(state.players[userIndex].photoUrl!)
                      : null,
                  child:
                      state.players[userIndex].photoUrl == null ||
                          state.players[userIndex].photoUrl!.isEmpty
                      ? Text(
                          state.players[userIndex].email[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Rank: #$userRank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'W: ${state.players[userIndex].wins} | '
                        'L: ${state.players[userIndex].losses} | '
                        'D: ${state.players[userIndex].draws}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_calculateWinRate(state.players[userIndex])}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else if (userId.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.person, color: Colors.white70),
                SizedBox(width: 16),
                Text(
                  'Your Rank: Not ranked yet',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

        // Leaderboard list
        Expanded(
          child: ListView.builder(
            itemCount: state.players.length,
            itemBuilder: (context, index) {
              final player = state.players[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: player.id == userId
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getRankColor(index + 1),
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    player.displayName ?? player.email.split('@')[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: player.id == userId
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    'W:${player.wins} L:${player.losses} D:${player.draws}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    '${_calculateWinRate(player)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  String _calculateWinRate(UserModel player) {
    if (player.totalGames == 0) return '0';
    final winRate = (player.wins / player.totalGames * 100);
    return winRate.toStringAsFixed(1);
  }
}
