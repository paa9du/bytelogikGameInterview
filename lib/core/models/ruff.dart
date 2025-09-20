// // lib/core/models/game_model.dart
// import 'user_model.dart';
//
// enum GameStatus { waiting, playing, finished, abandoned }
//
// enum PlayerSymbol { x, o }
//
// class GameModel {
//   final String id;
//   final String roomId;
//   final UserModel player1;
//   final UserModel? player2;
//   final List<String?> board;
//   final PlayerSymbol currentPlayer;
//   final GameStatus status;
//   final UserModel? winner;
//   final DateTime? createdAt;
//   final DateTime? finishedAt;
//
//   GameModel({
//     required this.id,
//     required this.roomId,
//     required this.player1,
//     this.player2,
//     required this.board,
//     required this.currentPlayer,
//     required this.status,
//     this.winner,
//     this.createdAt,
//     this.finishedAt,
//   });
//
//   // Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'roomId': roomId,
//       'player1': player1.toJson(),
//       'player2': player2?.toJson(),
//       'board': board,
//       'currentPlayer': _playerSymbolToString(currentPlayer),
//       'status': _gameStatusToString(status),
//       'winner': winner?.toJson(),
//       'createdAt': createdAt?.toIso8601String(),
//       'finishedAt': finishedAt?.toIso8601String(),
//     };
//   }
//
//   // Create from JSON
//   factory GameModel.fromJson(Map<String, dynamic> json) {
//     return GameModel(
//       id: json['id'],
//       roomId: json['roomId'],
//       player1: UserModel.fromJson(json['player1']),
//       player2: json['player2'] != null
//           ? UserModel.fromJson(json['player2'])
//           : null,
//       board: List<String?>.from(json['board']),
//       currentPlayer: _stringToPlayerSymbol(json['currentPlayer']),
//       status: _stringToGameStatus(json['status']),
//       winner: json['winner'] != null
//           ? UserModel.fromJson(json['winner'])
//           : null,
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : null,
//       finishedAt: json['finishedAt'] != null
//           ? DateTime.parse(json['finishedAt'])
//           : null,
//     );
//   }
//
//   // Helper methods for enum conversion
//   static String _playerSymbolToString(PlayerSymbol symbol) {
//     return symbol.toString().split('.').last;
//   }
//
//   static PlayerSymbol _stringToPlayerSymbol(String value) {
//     switch (value) {
//       case 'x':
//         return PlayerSymbol.x;
//       case 'o':
//         return PlayerSymbol.o;
//       default:
//         return PlayerSymbol.x;
//     }
//   }
//
//   static String _gameStatusToString(GameStatus status) {
//     return status.toString().split('.').last;
//   }
//
//   static GameStatus _stringToGameStatus(String value) {
//     switch (value) {
//       case 'waiting':
//         return GameStatus.waiting;
//       case 'playing':
//         return GameStatus.playing;
//       case 'finished':
//         return GameStatus.finished;
//       case 'abandoned':
//         return GameStatus.abandoned;
//       default:
//         return GameStatus.waiting;
//     }
//   }
//
//   // Copy with method
//   GameModel copyWith({
//     String? id,
//     String? roomId,
//     UserModel? player1,
//     UserModel? player2,
//     List<String?>? board,
//     PlayerSymbol? currentPlayer,
//     GameStatus? status,
//     UserModel? winner,
//     DateTime? createdAt,
//     DateTime? finishedAt,
//   }) {
//     return GameModel(
//       id: id ?? this.id,
//       roomId: roomId ?? this.roomId,
//       player1: player1 ?? this.player1,
//       player2: player2 ?? this.player2,
//       board: board ?? this.board,
//       currentPlayer: currentPlayer ?? this.currentPlayer,
//       status: status ?? this.status,
//       winner: winner ?? this.winner,
//       createdAt: createdAt ?? this.createdAt,
//       finishedAt: finishedAt ?? this.finishedAt,
//     );
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is GameModel && other.id == id;
//   }
//
//   @override
//   int get hashCode => id.hashCode;
// }