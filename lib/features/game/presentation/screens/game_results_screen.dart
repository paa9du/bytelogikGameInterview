// lib/features/game/presentation/screens/game_results_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../matchmacking/presentation/screens/matchmaking_screen.dart';

class GameResultsScreen extends StatelessWidget {
  final GameModel game;
  final String userId;

  const GameResultsScreen({
    super.key,
    required this.game,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = game.winner?.id == userId;
    final isDraw = game.winner == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Game Results')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result Icon
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

            // Result Text
            Text(
              isDraw
                  ? 'Draw!'
                  : isWinner
                  ? 'Victory!'
                  : 'Defeat!',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Score Summary
            Text(
              isDraw
                  ? 'Both players played well!'
                  : '${game.winner?.email.split('@')[0]} won the game!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Players Summary
            _buildPlayerSummary(game.player1, 'X', game.player1.id == userId),
            if (game.player2 != null)
              _buildPlayerSummary(
                game.player2!,
                'O',
                game.player2!.id == userId,
              ),
            const SizedBox(height: 40),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToMatchmaking(context),
                child: const Text('Play Again'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSummary(
    UserModel player,
    String symbol,
    bool isCurrentUser,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: player.photoUrl != null
            ? NetworkImage(player.photoUrl!)
            : null,
        child: player.photoUrl == null
            ? Text(player.email[0].toUpperCase())
            : null,
      ),
      title: Text(
        '${player.email.split('@')[0]} ${isCurrentUser ? '(You)' : ''}',
        style: TextStyle(
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text('Played as $symbol'),
      trailing: Text(
        player.id == game.winner?.id ? 'Winner' : '',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
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
