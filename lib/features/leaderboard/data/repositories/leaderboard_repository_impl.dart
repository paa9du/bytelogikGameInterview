// lib/features/leaderboard/data/repositories/leaderboard_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../../../core/models/user_model.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepositoryImpl(FirebaseFirestore.instance);
});

abstract class LeaderboardRepository {
  Stream<List<UserModel>> getTopPlayers(int limit);
  Stream<List<UserModel>> getPlayersByScore();
  Future<List<UserModel>> getAllPlayers();
  Future<void> addOrUpdateUser(UserModel user);
  Future<void> incrementWin(String userId);
  Future<void> incrementLoss(String userId);
  Future<void> incrementDraw(String userId);
  Future<UserModel?> getUser(String userId);
}

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final FirebaseFirestore _firestore;
  final String collection = 'users';

  LeaderboardRepositoryImpl(this._firestore);

  @override
  Stream<List<UserModel>> getTopPlayers(int limit) {
    return _firestore
        .collection(collection)
        .orderBy('wins', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Stream<List<UserModel>> getPlayersByScore() {
    return _firestore
        .collection(collection)
        .orderBy('wins', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Future<List<UserModel>> getAllPlayers() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .orderBy('wins', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load players: $e');
    }
  }

  @override
  Future<void> addOrUpdateUser(UserModel user) async {
    try {
      await _firestore
          .collection(collection)
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to add/update user: $e');
    }
  }

  @override
  Future<void> incrementWin(String userId) async {
    try {
      final userDoc = _firestore.collection(collection).doc(userId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final wins = (data['wins'] ?? 0) + 1;
          final totalGames = (data['totalGames'] ?? 0) + 1;

          transaction.update(userDoc, {
            'wins': wins,
            'totalGames': totalGames,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to increment win: $e');
    }
  }

  @override
  Future<void> incrementLoss(String userId) async {
    try {
      final userDoc = _firestore.collection(collection).doc(userId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final losses = (data['losses'] ?? 0) + 1;
          final totalGames = (data['totalGames'] ?? 0) + 1;

          transaction.update(userDoc, {
            'losses': losses,
            'totalGames': totalGames,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to increment loss: $e');
    }
  }

  @override
  Future<void> incrementDraw(String userId) async {
    try {
      final userDoc = _firestore.collection(collection).doc(userId);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final draws = (data['draws'] ?? 0) + 1;
          final totalGames = (data['totalGames'] ?? 0) + 1;

          transaction.update(userDoc, {
            'draws': draws,
            'totalGames': totalGames,
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to increment draw: $e');
    }
  }

  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      final snapshot = await _firestore.collection(collection).doc(userId).get();
      if (snapshot.exists) {
        return UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }
}