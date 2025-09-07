// lib/features/game/data/repositories/game_repository_impl.dart (updated)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../../../core/models/game_model.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(FirebaseFirestore.instance);
});

abstract class GameRepository {
  Stream<GameModel?> watchGame(String gameId);
  Future<void> createGame(GameModel game);
  Future<void> updateGame(GameModel game);
  Future<void> makeMove(String gameId, int index, String playerId);
  Future<void> joinGame(String gameId, String playerId);
}

class GameRepositoryImpl implements GameRepository {
  final FirebaseFirestore _firestore;

  GameRepositoryImpl(this._firestore);

  @override
  Stream<GameModel?> watchGame(String gameId) {
    return _firestore
        .collection('games')
        .doc(gameId)
        .snapshots()
        .map(
          (snapshot) => snapshot.data() != null
              ? GameModel.fromJson(snapshot.data()!)
              : null,
        );
  }

  @override
  Future<void> createGame(GameModel game) async {
    await _firestore.collection('games').doc(game.id).set(game.toJson());
  }

  @override
  Future<void> updateGame(GameModel game) async {
    await _firestore.collection('games').doc(game.id).update(game.toJson());
  }

  @override
  Future<void> makeMove(String gameId, int index, String playerId) async {
    final doc = _firestore.collection('games').doc(gameId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (!snapshot.exists) throw Exception('Game not found');

      final game = GameModel.fromJson(snapshot.data()!);
      if (game.board[index] != null) throw Exception('Invalid move');

      final newBoard = List<String?>.from(game.board);
      newBoard[index] = playerId;

      final isWinner = _checkWinner(newBoard);
      final isDraw = !isWinner && !newBoard.contains(null);

      final nextPlayer = game.currentPlayer == PlayerSymbol.x
          ? PlayerSymbol.o
          : PlayerSymbol.x;

      final newStatus = isWinner || isDraw ? GameStatus.finished : game.status;

      final updatedGame = game.copyWith(
        board: newBoard,
        currentPlayer: nextPlayer,
        status: newStatus,
        winner: isWinner
            ? game.player1.id == playerId
                  ? game.player1
                  : game.player2
            : null,
        finishedAt: isWinner || isDraw ? DateTime.now() : null,
      );

      transaction.update(doc, updatedGame.toJson());
    });
  }

  bool _checkWinner(List<String?> board) {
    const winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (final combination in winningCombinations) {
      if (board[combination[0]] != null &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> joinGame(String gameId, String playerId) async {
    // This will need to be updated based on how you handle player joining
    await _firestore.collection('games').doc(gameId).update({
      'player2Id': playerId,
      'status': GameStatus.playing.toString(),
    });
  }
}
