// lib/features/game/data/repositories/game_repository_impl.dart (updated)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(FirebaseFirestore.instance);
});

// abstract class GameRepository {
//   Stream<GameModel?> watchGame(String gameId);
//   Future<void> createGame(GameModel game);
//   Future<void> updateGame(GameModel game);
//   Future<void> makeMove(String gameId, int index, String playerId);
//   Future<void> joinGame(String gameId, String playerId);
// }
//
// class GameRepositoryImpl implements GameRepository {
//   final FirebaseFirestore _firestore;
//
//   GameRepositoryImpl(this._firestore);
//
//   @override
//   Stream<GameModel?> watchGame(String gameId) {
//     return _firestore
//         .collection('games')
//         .doc(gameId)
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.data() != null
//               ? GameModel.fromJson(snapshot.data()!)
//               : null,
//         );
//   }
//
//   // @override
//   // Future<void> createGame(GameModel game) async {
//   //   await _firestore.collection('games').doc(game.id).set(game.toJson());
//   // }
//   @override
//   Future<String> createGame(GameModel game) async {
//     final doc = _firestore.collection('games').doc(); // auto-ID
//     final newGame = game.copyWith(id: doc.id);
//
//     await doc.set(newGame.toJson());
//     return doc.id;
//   }
//
//   @override
//   Future<void> updateGame(GameModel game) async {
//     await _firestore.collection('games').doc(game.id).update(game.toJson());
//   }
//
//   @override
//   Future<void> makeMove(String gameId, int index, String playerId) async {
//     final doc = _firestore.collection('games').doc(gameId);
//     await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(doc);
//       if (!snapshot.exists) throw Exception('Game not found');
//
//       final game = GameModel.fromJson(snapshot.data()!);
//       if (game.board[index] != null) throw Exception('Invalid move');
//
//       final newBoard = List<String?>.from(game.board);
//       newBoard[index] = playerId;
//
//       final isWinner = _checkWinner(newBoard);
//       final isDraw = !isWinner && !newBoard.contains(null);
//
//       final nextPlayer = game.currentPlayer == PlayerSymbol.x
//           ? PlayerSymbol.o
//           : PlayerSymbol.x;
//
//       final newStatus = isWinner || isDraw ? GameStatus.finished : game.status;
//
//       final updatedGame = game.copyWith(
//         board: newBoard,
//         currentPlayer: nextPlayer,
//         status: newStatus,
//         winner: isWinner
//             ? game.player1.id == playerId
//                   ? game.player1
//                   : game.player2
//             : null,
//         finishedAt: isWinner || isDraw ? DateTime.now() : null,
//       );
//
//       transaction.update(doc, updatedGame.toJson());
//     });
//   }
//
//   bool _checkWinner(List<String?> board) {
//     const winningCombinations = [
//       [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
//       [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
//       [0, 4, 8], [2, 4, 6], // diagonals
//     ];
//
//     for (final combination in winningCombinations) {
//       if (board[combination[0]] != null &&
//           board[combination[0]] == board[combination[1]] &&
//           board[combination[1]] == board[combination[2]]) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   @override
//   Future<void> joinGame(String gameId, String playerId) async {
//     // This will need to be updated based on how you handle player joining
//     await _firestore.collection('games').doc(gameId).update({
//       'player2Id': playerId,
//       'status': GameStatus.playing.toString(),
//     });
//   }
// }

//
// final gameRepositoryProvider = Provider<GameRepository>((ref) {
//   return GameRepositoryImpl(FirebaseFirestore.instance);
// });
//
// abstract class GameRepository {
//   Stream<GameModel?> watchGame(String gameId);
//   Future<String> createGame(GameModel game); // return the id ✅
//   Future<void> updateGame(GameModel game);
//   Future<void> makeMove(String gameId, int index, String playerId);
//   Future<void> joinGame(String gameId, String playerId);
// }
//
// class GameRepositoryImpl implements GameRepository {
//   final FirebaseFirestore _firestore;
//
//   GameRepositoryImpl(this._firestore);
//
//   @override
//   Stream<GameModel?> watchGame(String gameId) {
//     return _firestore
//         .collection('games')
//         .doc(gameId)
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.data() != null
//               ? GameModel.fromJson(snapshot.data()!)
//               : null,
//         );
//   }
//
//   @override
//   Future<String> createGame(GameModel game) async {
//     final doc = _firestore.collection('games').doc(); // 🔥 new game each time
//     final newGame = game.copyWith(
//       id: doc.id,
//       board: List.filled(9, null), // empty board
//       status: GameStatus.waiting,
//       currentPlayer: PlayerSymbol.x,
//       player2: null,
//       winner: null,
//       finishedAt: null,
//     );
//
//     await doc.set(newGame.toJson());
//     return doc.id;
//   }
//
//   @override
//   Future<void> updateGame(GameModel game) async {
//     await _firestore.collection('games').doc(game.id).update(game.toJson());
//   }
//
//   @override
//   Future<void> makeMove(String gameId, int index, String playerId) async {
//     final doc = _firestore.collection('games').doc(gameId);
//
//     await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(doc);
//       if (!snapshot.exists) throw Exception('Game not found');
//
//       final game = GameModel.fromJson(snapshot.data()!);
//
//       if (game.board[index] != null) throw Exception('Invalid move');
//
//       // Determine symbol for the current player
//       final symbol = (game.player1.id == playerId)
//           ? PlayerSymbol.x
//           : PlayerSymbol.o;
//
//       final newBoard = List<String?>.from(game.board);
//       newBoard[index] = symbol.name; // ✅ store "x" or "o"
//
//       final isWinner = _checkWinner(newBoard);
//       final isDraw = !isWinner && !newBoard.contains(null);
//
//       final nextPlayer = game.currentPlayer == PlayerSymbol.x
//           ? PlayerSymbol.o
//           : PlayerSymbol.x;
//
//       final newStatus = isWinner || isDraw ? GameStatus.finished : game.status;
//
//       final updatedGame = game.copyWith(
//         board: newBoard,
//         currentPlayer: nextPlayer,
//         status: newStatus,
//         winner: isWinner
//             ? (symbol == PlayerSymbol.x ? game.player1 : game.player2)
//             : null,
//         finishedAt: isWinner || isDraw ? DateTime.now() : null,
//       );
//
//       transaction.update(doc, updatedGame.toJson());
//     });
//   }
//
//   bool _checkWinner(List<String?> board) {
//     const winningCombinations = [
//       [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
//       [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
//       [0, 4, 8], [2, 4, 6], // diagonals
//     ];
//
//     for (final combo in winningCombinations) {
//       if (board[combo[0]] != null &&
//           board[combo[0]] == board[combo[1]] &&
//           board[combo[1]] == board[combo[2]]) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   @override
//   Future<void> joinGame(String gameId, String playerId) async {
//     final doc = _firestore.collection('games').doc(gameId);
//     final snapshot = await doc.get();
//     if (!snapshot.exists) throw Exception('Game not found');
//
//     final game = GameModel.fromJson(snapshot.data()!);
//
//     if (game.player1.id == playerId) {
//       throw Exception("You can't join your own game");
//     }
//
//     if (game.player2 != null) {
//       throw Exception("Game already has 2 players");
//     }
//
//     final player2 = UserModel(
//       id: playerId,
//       email: '', // fetch from FirebaseAuth if needed
//       photoUrl: null,
//       wins: 0,
//       losses: 0,
//       draws: 0,
//     );
//
//     final updatedGame = game.copyWith(
//       player2: player2,
//       status: GameStatus.playing,
//     );
//
//     await doc.update(updatedGame.toJson());
//   }
// }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
//
// abstract class GameRepository {
//   Stream<GameModel?> watchGame(String gameId);
//   Future<String> findOrCreateGame(UserModel user); // 🔥 new
//   Future<String> createGame(GameModel game);
//   Future<void> updateGame(GameModel game);
//   Future<void> makeMove(String gameId, int index, String playerId);
//   Future<void> joinGame(String gameId, String playerId);
// }
//
// class GameRepositoryImpl implements GameRepository {
//   final FirebaseFirestore _firestore;
//
//   GameRepositoryImpl(this._firestore);
//
//   @override
//   Stream<GameModel?> watchGame(String gameId) {
//     return _firestore
//         .collection('games')
//         .doc(gameId)
//         .snapshots()
//         .map(
//           (snapshot) => snapshot.data() != null
//               ? GameModel.fromJson(snapshot.data()!)
//               : null,
//         );
//   }
//
//   /// 🔥 Find a waiting game or create a new one
//   @override
//   Future<String> findOrCreateGame(UserModel user) async {
//     final waitingGames = await _firestore
//         .collection('games')
//         .where('status', isEqualTo: GameStatus.waiting.name)
//         .limit(1)
//         .get();
//
//     if (waitingGames.docs.isNotEmpty) {
//       // Join existing game
//       final doc = waitingGames.docs.first;
//       final game = GameModel.fromJson(doc.data());
//
//       if (game.player1.id != user.id && game.player2 == null) {
//         final updatedGame = game.copyWith(
//           player2: user,
//           status: GameStatus.playing,
//         );
//         await doc.reference.update(updatedGame.toJson());
//         return doc.id;
//       }
//     }
//
//     // Otherwise create a new game
//     final doc = _firestore.collection('games').doc();
//
//     final newGame = GameModel(
//       id: doc.id,
//       player1: user,
//       player2: null,
//       board: List.filled(9, null),
//       currentPlayer: PlayerSymbol.x,
//       status: GameStatus.waiting,
//       createdAt: DateTime.now(),
//       winner: null,
//       finishedAt: null,
//       roomId: '',
//     );
//
//     await doc.set(newGame.toJson());
//     return doc.id;
//   }
//
//   @override
//   Future<String> createGame(GameModel game) async {
//     final doc = _firestore.collection('games').doc();
//     final newGame = game.copyWith(
//       id: doc.id,
//       board: List.filled(9, null),
//       status: GameStatus.waiting,
//       currentPlayer: PlayerSymbol.x,
//       player2: null,
//       winner: null,
//       finishedAt: null,
//     );
//
//     await doc.set(newGame.toJson());
//     return doc.id;
//   }
//
//   @override
//   Future<void> updateGame(GameModel game) async {
//     await _firestore.collection('games').doc(game.id).update(game.toJson());
//   }
//
//   @override
//   Future<void> makeMove(String gameId, int index, String playerId) async {
//     final doc = _firestore.collection('games').doc(gameId);
//
//     await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(doc);
//       if (!snapshot.exists) throw Exception('Game not found');
//
//       final game = GameModel.fromJson(snapshot.data()!);
//
//       if (game.board[index] != null) throw Exception('Invalid move');
//
//       // Determine symbol for the current player
//       final symbol = (game.player1.id == playerId)
//           ? PlayerSymbol.x
//           : PlayerSymbol.o;
//
//       final newBoard = List<String?>.from(game.board);
//       newBoard[index] = symbol.name;
//
//       final isWinner = _checkWinner(newBoard);
//       final isDraw = !isWinner && !newBoard.contains(null);
//
//       final nextPlayer = game.currentPlayer == PlayerSymbol.x
//           ? PlayerSymbol.o
//           : PlayerSymbol.x;
//
//       final newStatus = isWinner || isDraw ? GameStatus.finished : game.status;
//
//       final updatedGame = game.copyWith(
//         board: newBoard,
//         currentPlayer: nextPlayer,
//         status: newStatus,
//         winner: isWinner
//             ? (symbol == PlayerSymbol.x ? game.player1 : game.player2)
//             : null,
//         finishedAt: isWinner || isDraw ? DateTime.now() : null,
//       );
//
//       transaction.update(doc, updatedGame.toJson());
//     });
//   }
//
//   bool _checkWinner(List<String?> board) {
//     const winningCombinations = [
//       [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
//       [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
//       [0, 4, 8], [2, 4, 6], // diagonals
//     ];
//
//     for (final combo in winningCombinations) {
//       if (board[combo[0]] != null &&
//           board[combo[0]] == board[combo[1]] &&
//           board[combo[1]] == board[combo[2]]) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   @override
//   Future<void> joinGame(String gameId, String playerId) async {
//     final doc = _firestore.collection('games').doc(gameId);
//     final snapshot = await doc.get();
//     if (!snapshot.exists) throw Exception('Game not found');
//
//     final game = GameModel.fromJson(snapshot.data()!);
//
//     if (game.player1.id == playerId) {
//       throw Exception("You can't join your own game");
//     }
//
//     if (game.player2 != null) {
//       throw Exception("Game already has 2 players");
//     }
//
//     final player2 = UserModel(
//       id: playerId,
//       email: '',
//       photoUrl: null,
//       wins: 0,
//       losses: 0,
//       draws: 0,
//     );
//
//     final updatedGame = game.copyWith(
//       player2: player2,
//       status: GameStatus.playing,
//     );
//
//     await doc.update(updatedGame.toJson());
//   }
//
//   @override
//   Future<String> createOfflineGame(UserModel player1, UserModel player2) async {
//     final gameDoc = _firestore.collection('games').doc();
//     final gameData = {
//       'id': gameDoc.id,
//       'player1': player1.toJson(),
//       'player2': player2.toJson(),
//       'board': List.filled(9, null),
//       'currentPlayer': 'X',
//       'status': 'playing',
//       'winner': null,
//     };
//     await gameDoc.set(gameData);
//     return gameDoc.id;
//   }
// }
abstract class GameRepository {
  Stream<GameModel?> watchGame(String gameId);
  Future<String> findOrCreateGame(UserModel user);
  Future<String> createGame(GameModel game);
  Future<void> updateGame(GameModel game);
  Future<void> makeMove(String gameId, int index, String playerId);
  Future<void> joinGame(String gameId, String playerId);
  Future<String> createOfflineGame(UserModel player1, UserModel player2);
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
  Future<String> findOrCreateGame(UserModel user) async {
    final waitingGames = await _firestore
        .collection('games')
        .where('status', isEqualTo: GameStatus.waiting.name)
        .limit(1)
        .get();

    if (waitingGames.docs.isNotEmpty) {
      final doc = waitingGames.docs.first;
      final game = GameModel.fromJson(doc.data());

      if (game.player1.id != user.id && game.player2 == null) {
        final updatedGame = game.copyWith(
          player2: user,
          status: GameStatus.playing,
        );
        await doc.reference.update(updatedGame.toJson());
        return doc.id;
      }
    }

    final doc = _firestore.collection('games').doc();
    final newGame = GameModel(
      id: doc.id,
      player1: user,
      player2: null,
      board: List.filled(9, null),
      currentPlayer: PlayerSymbol.x,
      status: GameStatus.waiting,
      createdAt: DateTime.now(),
      winner: null,
      finishedAt: null,
      roomId: '',
    );
    await doc.set(newGame.toJson());
    return doc.id;
  }

  @override
  Future<String> createGame(GameModel game) async {
    final doc = _firestore.collection('games').doc();
    final newGame = game.copyWith(
      id: doc.id,
      board: List.filled(9, null),
      status: GameStatus.waiting,
      currentPlayer: PlayerSymbol.x,
      player2: null,
      winner: null,
      finishedAt: null,
    );
    await doc.set(newGame.toJson());
    return doc.id;
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

      final symbol = (game.player1.id == playerId)
          ? PlayerSymbol.x
          : PlayerSymbol.o;

      final newBoard = List<String?>.from(game.board);
      newBoard[index] = symbol.name;

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
            ? (symbol == PlayerSymbol.x ? game.player1 : game.player2)
            : null,
        finishedAt: isWinner || isDraw ? DateTime.now() : null,
      );

      transaction.update(doc, updatedGame.toJson());
    });
  }

  bool _checkWinner(List<String?> board) {
    const winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final combo in winningCombinations) {
      if (board[combo[0]] != null &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> joinGame(String gameId, String playerId) async {
    final doc = _firestore.collection('games').doc(gameId);
    final snapshot = await doc.get();
    if (!snapshot.exists) throw Exception('Game not found');

    final game = GameModel.fromJson(snapshot.data()!);

    if (game.player1.id == playerId) {
      throw Exception("You can't join your own game");
    }

    if (game.player2 != null) {
      throw Exception("Game already has 2 players");
    }

    final player2 = UserModel(
      id: playerId,
      email: '',
      photoUrl: null,
      wins: 0,
      losses: 0,
      draws: 0,
    );

    final updatedGame = game.copyWith(
      player2: player2,
      status: GameStatus.playing,
    );

    await doc.update(updatedGame.toJson());
  }

  /// Offline game creation
  @override
  Future<String> createOfflineGame(UserModel player1, UserModel player2) async {
    final gameDoc = _firestore.collection('games').doc();
    final gameData = {
      'id': gameDoc.id,
      'player1': player1.toJson(),
      'player2': player2.toJson(),
      'board': List.filled(9, null),
      'currentPlayer': 'X',
      'status': 'playing',
      'winner': null,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'finishedAt': null,
      'roomId': 'offline_${gameDoc.id}',
    };
    await gameDoc.set(gameData);
    return gameDoc.id;
  }
}
