// lib/features/game/presentation/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';
import '../viewmodels/game_viewmodel.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameScreen({super.key, required this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Start watching the game when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameViewModelProvider(widget.gameId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameViewModelProvider(widget.gameId));
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic-Tac-Toe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _showExitDialog(context),
          ),
        ],
      ),
      body: gameState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (game) {
          if (game == null) {
            return const Center(child: Text('Game not found'));
          }
          return _buildGameBoard(context, game, user!.uid);
        },
      ),
    );
  }

  Widget _buildGameBoard(BuildContext context, GameModel game, String userId) {
    final isCurrentPlayer =
        (game.currentPlayer == PlayerSymbol.x && game.player1.id == userId) ||
        (game.currentPlayer == PlayerSymbol.o && game.player2?.id == userId);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Player info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPlayerInfo(game.player1, PlayerSymbol.x, game, userId),
              if (game.player2 != null)
                _buildPlayerInfo(game.player2!, PlayerSymbol.o, game, userId),
            ],
          ),
          const SizedBox(height: 20),

          // Game status
          Text(
            _getGameStatusText(game, userId, isCurrentPlayer),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Game board
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return _buildGridCell(
                      context,
                      game,
                      index,
                      isCurrentPlayer,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(
    UserModel player,
    PlayerSymbol symbol,
    GameModel game,
    String userId,
  ) {
    final isCurrent =
        (symbol == PlayerSymbol.x && game.player1.id == userId) ||
        (symbol == PlayerSymbol.o && game.player2?.id == userId);

    return Column(
      children: [
        CircleAvatar(
          backgroundImage: player.photoUrl != null
              ? NetworkImage(player.photoUrl!)
              : null,
          child: player.photoUrl == null
              ? Text(player.email[0].toUpperCase())
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          player.email.split('@')[0],
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(symbol == PlayerSymbol.x ? 'X' : 'O'),
      ],
    );
  }

  Widget _buildGridCell(
    BuildContext context,
    GameModel game,
    int index,
    bool isCurrentPlayer,
  ) {
    final cellValue = game.board[index];
    final canMakeMove =
        isCurrentPlayer &&
        cellValue == null &&
        game.status == GameStatus.playing;

    return GestureDetector(
      onTap: canMakeMove
          ? () => ref
                .read(gameViewModelProvider(widget.gameId).notifier)
                .makeMove(index, FirebaseAuth.instance.currentUser!.uid)
          : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: canMakeMove ? Colors.grey[100] : Colors.white,
        ),
        child: Center(
          child: Text(
            cellValue != null ? (cellValue == game.player1.id ? 'X' : 'O') : '',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _getGameStatusText(
    GameModel game,
    String userId,
    bool isCurrentPlayer,
  ) {
    switch (game.status) {
      case GameStatus.waiting:
        return 'Waiting for opponent...';
      case GameStatus.playing:
        return isCurrentPlayer ? 'Your turn!' : 'Opponent\'s turn';
      case GameStatus.finished:
        if (game.winner == null) return 'Draw!';
        return game.winner!.id == userId ? 'You won!' : 'You lost!';
      case GameStatus.abandoned:
        return 'Game abandoned';
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Game'),
        content: const Text('Are you sure you want to leave this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
