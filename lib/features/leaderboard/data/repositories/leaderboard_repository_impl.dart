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
}

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final FirebaseFirestore _firestore;

  LeaderboardRepositoryImpl(this._firestore);

  @override
  Stream<List<UserModel>> getTopPlayers(int limit) {
    return _firestore
        .collection('users')
        .orderBy('wins', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList());
  }

  @override
  Stream<List<UserModel>> getPlayersByScore() {
    return _firestore
        .collection('users')
        .orderBy('wins', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList());
  }
}