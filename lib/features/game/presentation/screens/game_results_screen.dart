// lib/features/game/presentation/screens/game_results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../leaderboard/presentation/viewmodels/leaderboard_viewmodel.dart';
import '../../../matchmacking/presentation/screens/matchmaking_screen.dart';

class GameResultsScreen extends ConsumerStatefulWidget {
  final GameModel game;
  final String userId;

  const GameResultsScreen({
    super.key,
    required this.game,
    required this.userId,
  });

  @override
  ConsumerState<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends ConsumerState<GameResultsScreen> {
  bool _updatedLeaderboard = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateLeaderboard();
  }

  Future<void> _updateLeaderboard() async {
    if (_updatedLeaderboard) return;
    _updatedLeaderboard = true;

    final viewModel = ref.read(leaderboardViewModelProvider.notifier);
    final isCurrentUserWinner = widget.game.winner?.id == widget.userId;
    final isDraw = widget.game.winner == null;

    // Update stats for player 1
    await viewModel.updateUserStatsAfterGame(
      userId: widget.game.player1.id,
      isWin: widget.game.player1.id == widget.game.winner?.id,
      isDraw: isDraw,
    );

    // Update stats for player 2 if exists
    if (widget.game.player2 != null) {
      await viewModel.updateUserStatsAfterGame(
        userId: widget.game.player2!.id,
        isWin: widget.game.player2!.id == widget.game.winner?.id,
        isDraw: isDraw,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = widget.game.winner?.id == widget.userId;
    final isDraw = widget.game.winner == null;

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDraw
                      ? Icons.emoji_events_outlined
                      : isWinner
                      ? Icons.emoji_events
                      : Icons.sentiment_dissatisfied,
                  size: 80,
                  color: isDraw
                      ? Colors.amber
                      : isWinner
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(height: 20),
                Text(
                  isDraw
                      ? 'Draw!'
                      : isWinner
                      ? 'Victory!'
                      : 'Defeat!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isDraw
                      ? 'Both players played well!'
                      : '${widget.game.winner?.displayName ?? widget.game.winner?.email.split('@')[0] ?? 'Opponent'} won the game!',
                  style: const TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildPlayerSummary(
                  widget.game.player1,
                  'X',
                  widget.game.player1.id == widget.userId,
                ),
                if (widget.game.player2 != null)
                  _buildPlayerSummary(
                    widget.game.player2!,
                    'O',
                    widget.game.player2!.id == widget.userId,
                  ),
                const SizedBox(height: 40),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     onPressed: () => _navigateToMatchmaking(context),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       foregroundColor: const Color(0xFF6A11CB),
                //       padding: const EdgeInsets.symmetric(vertical: 16),
                //     ),
                //     child: const Text(
                //       'Play Again',
                //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (route) => route.isFirst),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSummary(
      UserModel player,
      String symbol,
      bool isCurrentUser,
      ) {
    final isWinner = player.id == widget.game.winner?.id;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: player.photoUrl != null
                ? NetworkImage(player.photoUrl!)
                : null,
            child: player.photoUrl == null
                ? Text(player.email[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${player.displayName ?? player.email.split('@')[0]} ${isCurrentUser ? '(You)' : ''}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  'Played as $symbol',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          if (isWinner)
            const Icon(Icons.emoji_events, color: Colors.green),
        ],
      ),
    );
  }

  void _navigateToMatchmaking(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MatchmakingScreen()),
          (route) => route.isFirst,
    );
  }
}