// lib/features/score/data/repositories/score_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../../../core/models/user_model.dart';

final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepositoryImpl(FirebaseFirestore.instance);
});

abstract class ScoreRepository {
  Future<void> updateScores(String winnerId, String loserId, bool isDraw);
  Future<UserModel> getUserStats(String userId);
  Stream<UserModel> watchUserStats(String userId);
}

class ScoreRepositoryImpl implements ScoreRepository {
  final FirebaseFirestore _firestore;

  ScoreRepositoryImpl(this._firestore);

  @override
  Future<void> updateScores(
    String winnerId,
    String loserId,
    bool isDraw,
  ) async {
    final batch = _firestore.batch();

    final winnerRef = _firestore.collection('users').doc(winnerId);
    final loserRef = _firestore.collection('users').doc(loserId);

    if (isDraw) {
      batch.update(winnerRef, {
        'draws': FieldValue.increment(1),
        'totalGames': FieldValue.increment(1),
      });
      batch.update(loserRef, {
        'draws': FieldValue.increment(1),
        'totalGames': FieldValue.increment(1),
      });
    } else {
      batch.update(winnerRef, {
        'wins': FieldValue.increment(1),
        'totalGames': FieldValue.increment(1),
      });
      batch.update(loserRef, {
        'losses': FieldValue.increment(1),
        'totalGames': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  @override
  Future<UserModel> getUserStats(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return UserModel.fromJson(doc.data()!);
  }

  @override
  Stream<UserModel> watchUserStats(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => UserModel.fromJson(snapshot.data()!));
  }
}
