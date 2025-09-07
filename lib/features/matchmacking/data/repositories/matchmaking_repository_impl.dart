// lib/features/matchmaking/data/repositories/matchmaking_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';

final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
  return MatchmakingRepositoryImpl(FirebaseFirestore.instance);
});

abstract class MatchmakingRepository {
  Stream<List<GameModel>> watchAvailableGames();
  Future<String> createGameRoom(String playerId);
  Future<void> joinGameRoom(String gameId, String playerId);
  Future<void> leaveGameRoom(String gameId, String playerId);
}

class MatchmakingRepositoryImpl implements MatchmakingRepository {
  final FirebaseFirestore _firestore;

  MatchmakingRepositoryImpl(this._firestore);

  @override
  Stream<List<GameModel>> watchAvailableGames() {
    return _firestore
        .collection('games')
        .where('status', isEqualTo: GameStatus.waiting.toString())
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => GameModel.fromJson(doc.data()))
              .toList(),
        );
  }

  @override
  Future<String> createGameRoom(String playerId) async {
    final docRef = _firestore.collection('games').doc();
    final game = GameModel(
      id: docRef.id,
      roomId: docRef.id,
      player1: UserModel(id: playerId, email: ''),
      player2: null,
      board: List.filled(9, null),
      currentPlayer: PlayerSymbol.x,
      status: GameStatus.waiting,
      createdAt: DateTime.now(),
    );

    await docRef.set(game.toJson());
    return docRef.id;
  }

  @override
  Future<void> joinGameRoom(String gameId, String playerId) async {
    await _firestore.collection('games').doc(gameId).update({
      'player2Id': playerId,
      'status': GameStatus.playing.toString(),
    });
  }

  @override
  Future<void> leaveGameRoom(String gameId, String playerId) async {
    final doc = _firestore.collection('games').doc(gameId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doc);
      if (!snapshot.exists) return;

      final game = GameModel.fromJson(snapshot.data()!);
      if (game.player1.id == playerId) {
        transaction.update(doc, {
          'status': GameStatus.abandoned.toString(),
          'finishedAt': FieldValue.serverTimestamp(),
        });
      } else if (game.player2?.id == playerId) {
        transaction.update(doc, {
          'player2Id': null,
          'status': GameStatus.waiting.toString(),
        });
      }
    });
  }
}
