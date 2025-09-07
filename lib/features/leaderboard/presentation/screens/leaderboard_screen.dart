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
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: leaderboardState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildLeaderboardContent(leaderboardState, user!.uid),
    );
  }

  Widget _buildLeaderboardContent(LeaderboardState state, String userId) {
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    if (state.players.isEmpty) {
      return const Center(child: Text('No players found'));
    }

    // Find current user's position
    final userIndex = state.players.indexWhere((player) => player.id == userId);
    final userRank = userIndex + 1;

    return Column(
      children: [
        // User's current rank card
        if (userIndex >= 0)
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: state.players[userIndex].photoUrl != null
                    ? NetworkImage(state.players[userIndex].photoUrl!)
                    : null,
                child: state.players[userIndex].photoUrl == null
                    ? Text(state.players[userIndex].email[0].toUpperCase())
                    : null,
              ),
              title: Text(
                'Your Rank: #$userRank',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Wins: ${state.players[userIndex].wins} | '
                    'Losses: ${state.players[userIndex].losses} | '
                    'Draws: ${state.players[userIndex].draws}',
              ),
            ),
          ),

        // Leaderboard list
        Expanded(
          child: ListView.builder(
            itemCount: state.players.length,
            itemBuilder: (context, index) {
              final player = state.players[index];
              return ListTile(
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
                  player.email.split('@')[0],
                  style: TextStyle(
                    fontWeight: player.id == userId ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'W: ${player.wins} | L: ${player.losses} | D: ${player.draws}',
                ),
                trailing: Text(
                  '${_calculateWinRate(player)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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