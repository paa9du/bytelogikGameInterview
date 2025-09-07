// // lib/features/game/presentation/screens/game_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
// import '../viewmodels/game_viewmodel.dart';
// import 'game_results_screen.dart';
//
// class GameScreen extends ConsumerStatefulWidget {
//   final String gameId;
//
//   const GameScreen({super.key, required this.gameId});
//
//   @override
//   ConsumerState<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends ConsumerState<GameScreen> {
//   GameModel? localGame;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(gameViewModelProvider(widget.gameId));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final gameState = ref.watch(gameViewModelProvider(widget.gameId));
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: gameState.when(
//             loading: () => const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             ),
//             error: (error, stack) => Center(
//               child: Text(
//                 'Error: $error',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             data: (game) {
//               if (game == null) {
//                 return const Center(
//                   child: Text(
//                     'Game not found',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 );
//               }
//
//               // Initialize local game state
//               localGame ??= game;
//
//               // Navigate to results if game finished
//               if (game.status == GameStatus.finished ||
//                   game.status == GameStatus.abandoned) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => GameResultsScreen(
//                         game: game,
//                         userId: currentUser!.uid,
//                       ),
//                     ),
//                   );
//                 });
//               }
//
//               return Column(
//                 children: [
//                   _buildHeader(currentUser),
//                   Expanded(
//                     child: _buildGameBoard(
//                       context,
//                       localGame!,
//                       currentUser!.uid,
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(User? currentUser) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               // CircleAvatar(
//               //   radius: 25,
//               //   backgroundImage: currentUser?.photoURL != null
//               //       ? NetworkImage(currentUser!.photoURL!)
//               //       : null,
//               //   child: currentUser?.photoURL == null
//               //       ? Text(
//               //           currentUser?.email?[0].toUpperCase() ?? 'P',
//               //           style: const TextStyle(
//               //             fontSize: 20,
//               //             color: Colors.white,
//               //           ),
//               //         )
//               //       : null,
//               // ),
//               // const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Welcome',
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                   Text(
//                     currentUser?.displayName ?? currentUser?.email ?? 'Player',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app, color: Colors.white),
//             onPressed: () => _showExitDialog(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGameBoard(BuildContext context, GameModel game, String userId) {
//     final isCurrentPlayer =
//         (game.currentPlayer == PlayerSymbol.x && game.player1.id == userId) ||
//         (game.currentPlayer == PlayerSymbol.o && game.player2?.id == userId);
//
//     return Column(
//       children: [
//         // Players
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildPlayerCard(game.player1, PlayerSymbol.x, game, userId),
//             if (game.player2 != null)
//               _buildPlayerCard(game.player2!, PlayerSymbol.o, game, userId),
//           ],
//         ),
//         const SizedBox(height: 20),
//
//         // Turn indicator
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white24,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _getGameStatusText(game, userId, isCurrentPlayer),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // Board
//         Expanded(
//           child: AspectRatio(
//             aspectRatio: 1,
//             child: GridView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: 9,
//               itemBuilder: (context, index) {
//                 return _buildGridCell(game, index, isCurrentPlayer);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPlayerCard(
//     UserModel player,
//     PlayerSymbol symbol,
//     GameModel game,
//     String userId,
//   ) {
//     final isCurrent =
//         (symbol == PlayerSymbol.x && game.player1.id == userId) ||
//         (symbol == PlayerSymbol.o && game.player2?.id == userId);
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isCurrent ? Colors.white.withOpacity(0.2) : Colors.white12,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: isCurrent ? Colors.white : Colors.white38,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: player.photoUrl != null
//                 ? NetworkImage(player.photoUrl!)
//                 : null,
//             child: player.photoUrl == null
//                 ? Text(
//                     player.email[0].toUpperCase(),
//                     style: const TextStyle(color: Colors.white),
//                   )
//                 : null,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             player.email.split('@')[0],
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             symbol == PlayerSymbol.x ? 'X' : 'O',
//             style: TextStyle(
//               color: symbol == PlayerSymbol.x
//                   ? Colors.blue[200]
//                   : Colors.red[200],
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGridCell(GameModel game, int index, bool isCurrentPlayer) {
//     final cellValue = game.board[index];
//     final canMakeMove =
//         isCurrentPlayer &&
//         cellValue == null &&
//         game.status == GameStatus.playing;
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//               setState(() {
//                 localGame = localGame!.copyWith(
//                   board: List<String?>.from(localGame!.board)
//                     ..[index] =
//                         (localGame!.player1.id ==
//                             FirebaseAuth.instance.currentUser!.uid)
//                         ? 'X'
//                         : 'O',
//                   currentPlayer: localGame!.currentPlayer == PlayerSymbol.x
//                       ? PlayerSymbol.o
//                       : PlayerSymbol.x,
//                 );
//               });
//
//               ref
//                   .read(gameViewModelProvider(widget.gameId).notifier)
//                   .makeMove(index, FirebaseAuth.instance.currentUser!.uid);
//             }
//           : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: canMakeMove ? Colors.white70 : Colors.white24,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             cellValue ?? '',
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: cellValue == 'X' ? Colors.blue[200] : Colors.red[200],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getGameStatusText(
//     GameModel game,
//     String userId,
//     bool isCurrentPlayer,
//   ) {
//     switch (game.status) {
//       case GameStatus.waiting:
//         return 'Waiting for opponent...';
//       case GameStatus.playing:
//         return isCurrentPlayer ? 'Your turn!' : 'Opponent\'s turn';
//       case GameStatus.finished:
//         if (game.winner == null) return 'Draw!';
//         return game.winner!.id == userId ? 'You won!' : 'You lost!';
//       case GameStatus.abandoned:
//         return 'Game abandoned';
//     }
//   }
//
//   void _showExitDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Leave Game'),
//         content: const Text('Are you sure you want to leave this game?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Leave'),
//           ),
//         ],
//       ),
//     );
//   }
// // }
// // lib/features/game/presentation/screens/game_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
// import '../viewmodels/game_viewmodel.dart';
// import 'game_results_screen.dart';
//
// class GameScreen extends ConsumerStatefulWidget {
//   final String gameId;
//
//   const GameScreen({super.key, required this.gameId});
//
//   @override
//   ConsumerState<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends ConsumerState<GameScreen> {
//   GameModel? localGame;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(gameViewModelProvider(widget.gameId));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final gameState = ref.watch(gameViewModelProvider(widget.gameId));
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: gameState.when(
//             loading: () => const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             ),
//             error: (error, stack) => Center(
//               child: Text(
//                 'Error: $error',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             data: (game) {
//               if (game == null) {
//                 return const Center(
//                   child: Text(
//                     'Game not found',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 );
//               }
//
//               // Initialize local game state once
//               localGame ??= game;
//
//               // Navigate to results if game finished
//               if (localGame!.status == GameStatus.finished ||
//                   localGame!.status == GameStatus.abandoned) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => GameResultsScreen(
//                         game: localGame!,
//                         userId: currentUser!.uid,
//                       ),
//                     ),
//                   );
//                 });
//               }
//
//               return Column(
//                 children: [
//                   _buildHeader(currentUser),
//                   Expanded(child: _buildGameBoard(context, currentUser!.uid)),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(User? currentUser) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Welcome',
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//               Text(
//                 currentUser?.displayName ?? currentUser?.email ?? 'Player',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app, color: Colors.white),
//             onPressed: () => _showExitDialog(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGameBoard(BuildContext context, String userId) {
//     final isCurrentPlayer =
//         (localGame!.currentPlayer == PlayerSymbol.x &&
//             localGame!.player1.id == userId) ||
//         (localGame!.currentPlayer == PlayerSymbol.o &&
//             localGame!.player2?.id == userId);
//     print('currentPlayer: ${localGame!.currentPlayer}, your id: $userId');
//     print(
//       'player1.id: ${localGame!.player1.id}, player2.id: ${localGame!.player2?.id}',
//     );
//     print('isCurrentPlayer: $isCurrentPlayer');
//
//     return Column(
//       children: [
//         // Players
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildPlayerCard(localGame!.player1, PlayerSymbol.x, userId),
//             if (localGame!.player2 != null)
//               _buildPlayerCard(localGame!.player2!, PlayerSymbol.o, userId),
//           ],
//         ),
//         const SizedBox(height: 20),
//
//         // Turn indicator
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white24,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _getGameStatusText(userId, isCurrentPlayer),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // Board
//         Expanded(
//           child: AspectRatio(
//             aspectRatio: 1,
//             child: GridView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: 9,
//               itemBuilder: (context, index) {
//                 return _buildGridCell(index, isCurrentPlayer, userId);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPlayerCard(
//     UserModel player,
//     PlayerSymbol symbol,
//     String userId,
//   ) {
//     final isCurrent =
//         (symbol == PlayerSymbol.x && localGame!.player1.id == userId) ||
//         (symbol == PlayerSymbol.o && localGame!.player2?.id == userId);
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isCurrent ? Colors.white.withOpacity(0.2) : Colors.white12,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: isCurrent ? Colors.white : Colors.white38,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: player.photoUrl != null
//                 ? NetworkImage(player.photoUrl!)
//                 : null,
//             child: player.photoUrl == null
//                 ? Text(
//                     player.email[0].toUpperCase(),
//                     style: const TextStyle(color: Colors.white),
//                   )
//                 : null,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             player.email.split('@')[0],
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             symbol == PlayerSymbol.x ? 'X' : 'O',
//             style: TextStyle(
//               color: symbol == PlayerSymbol.x
//                   ? Colors.blue[200]
//                   : Colors.red[200],
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGridCell(int index, bool isCurrentPlayer, String userId) {
//     final cellValue = localGame!.board[index];
//     final canMakeMove =
//         isCurrentPlayer &&
//         cellValue == null &&
//         localGame!.status == GameStatus.playing;
//     print('index $index, cellValue: $cellValue, canMakeMove: $canMakeMove');
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//               setState(() {
//                 final newBoard = List<String?>.from(localGame!.board);
//                 newBoard[index] = (localGame!.player1.id == userId) ? 'X' : 'O';
//                 localGame = localGame!.copyWith(
//                   board: newBoard,
//                   currentPlayer: localGame!.currentPlayer == PlayerSymbol.x
//                       ? PlayerSymbol.o
//                       : PlayerSymbol.x,
//                 );
//               });
//               print(localGame!.board);
//               // If offline game
//               if (localGame!.id.contains('_offline')) {
//                 _checkOfflineWinner();
//                 return;
//               }
//
//               // Online game move
//               ref
//                   .read(gameViewModelProvider(widget.gameId).notifier)
//                   .makeMove(index, userId);
//             }
//           : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: canMakeMove ? Colors.white70 : Colors.white24,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             cellValue ?? '',
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: cellValue == 'X' ? Colors.blue[200] : Colors.red[200],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getGameStatusText(String userId, bool isCurrentPlayer) {
//     switch (localGame!.status) {
//       case GameStatus.waiting:
//         return 'Waiting for opponent...';
//       case GameStatus.playing:
//         return isCurrentPlayer ? 'Your turn!' : 'Opponent\'s turn';
//       case GameStatus.finished:
//         if (localGame!.winner == null) return 'Draw!';
//         return localGame!.winner!.id == userId ? 'You won!' : 'You lost!';
//       case GameStatus.abandoned:
//         return 'Game abandoned';
//     }
//   }
//
//   void _checkOfflineWinner() {
//     final b = localGame!.board;
//     const combos = [
//       [0, 1, 2],
//       [3, 4, 5],
//       [6, 7, 8],
//       [0, 3, 6],
//       [1, 4, 7],
//       [2, 5, 8],
//       [0, 4, 8],
//       [2, 4, 6],
//     ];
//
//     UserModel? winner;
//
//     for (var c in combos) {
//       if (b[c[0]] != null && b[c[0]] == b[c[1]] && b[c[1]] == b[c[2]]) {
//         winner = b[c[0]] == 'X' ? localGame!.player1 : localGame!.player2;
//         break;
//       }
//     }
//
//     if (winner != null || !b.contains(null)) {
//       setState(() {
//         localGame = localGame!.copyWith(
//           status: GameStatus.finished,
//           winner: winner,
//           finishedAt: DateTime.now(),
//         );
//       });
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => GameResultsScreen(
//               game: localGame!,
//               userId: FirebaseAuth.instance.currentUser!.uid,
//             ),
//           ),
//         );
//       });
//     }
//   }
//
//   void _showExitDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Leave Game'),
//         content: const Text('Are you sure you want to leave this game?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Leave'),
//           ),
//         ],
//       ),
//     );
//   }
// }
// // lib/features/game/presentation/screens/game_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
// import '../viewmodels/game_viewmodel.dart';
// import 'game_results_screen.dart';
//
// class GameScreen extends ConsumerStatefulWidget {
//   final String gameId;
//
//   const GameScreen({super.key, required this.gameId});
//
//   @override
//   ConsumerState<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends ConsumerState<GameScreen> {
//   GameModel? localGame;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(gameViewModelProvider(widget.gameId));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final gameState = ref.watch(gameViewModelProvider(widget.gameId));
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: gameState.when(
//             loading: () => const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             ),
//             error: (error, stack) => Center(
//               child: Text(
//                 'Error: $error',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             data: (game) {
//               if (game == null) {
//                 return const Center(
//                   child: Text(
//                     'Game not found',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 );
//               }
//
//               // Initialize local game state once
//               localGame ??= game;
//
//               // Navigate to results if game finished
//               if (localGame!.status == GameStatus.finished ||
//                   localGame!.status == GameStatus.abandoned) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => GameResultsScreen(
//                         game: localGame!,
//                         userId: currentUser!.uid,
//                       ),
//                     ),
//                   );
//                 });
//               }
//
//               return Column(
//                 children: [
//                   _buildHeader(currentUser),
//                   Expanded(child: _buildGameBoard(currentUser!.uid)),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(User? currentUser) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Welcome',
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//               Text(
//                 currentUser?.displayName ?? currentUser?.email ?? 'Player',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app, color: Colors.white),
//             onPressed: () => _showExitDialog(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGameBoard(String userId) {
//     return Column(
//       children: [
//         // Players
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildPlayerCard(localGame!.player1, PlayerSymbol.x, ""),
//             _buildPlayerCard(localGame!.player2!, PlayerSymbol.o, ""),
//           ],
//         ),
//         const SizedBox(height: 20),
//
//         // Turn indicator
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white24,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _getOfflineStatusText(),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // Board
//         Expanded(
//           child: AspectRatio(
//             aspectRatio: 1,
//             child: GridView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: 9,
//               itemBuilder: (context, index) {
//                 return _buildOfflineGridCell(index);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _getOfflineStatusText() {
//     if (localGame!.status != GameStatus.playing) {
//       if (localGame!.winner == null) return 'Draw!';
//       return localGame!.winner == localGame!.player1
//           ? 'Player 1 won!'
//           : 'Player 2 won!';
//     }
//
//     return localGame!.currentPlayer == PlayerSymbol.x
//         ? "Player 1's turn"
//         : "Player 2's turn";
//   }
//
//   Widget _buildOfflineGridCell(int index) {
//     final cellValue = localGame!.board[index];
//     final canMakeMove =
//         cellValue == null && localGame!.status == GameStatus.playing;
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//               setState(() {
//                 final newBoard = List<String?>.from(localGame!.board);
//                 // Fill current player's symbol
//                 newBoard[index] = localGame!.currentPlayer == PlayerSymbol.x
//                     ? 'X'
//                     : 'O';
//
//                 // Switch turn
//                 final nextPlayer = localGame!.currentPlayer == PlayerSymbol.x
//                     ? PlayerSymbol.o
//                     : PlayerSymbol.x;
//
//                 localGame = localGame!.copyWith(
//                   board: newBoard,
//                   currentPlayer: nextPlayer,
//                 );
//
//                 // Check winner
//                 _checkOfflineWinner();
//               });
//             }
//           : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: canMakeMove ? Colors.white70 : Colors.white24,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             cellValue ?? '',
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: cellValue == 'X' ? Colors.blue[200] : Colors.red[200],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlayerCard(
//     UserModel player,
//     PlayerSymbol symbol,
//     String userId,
//   ) {
//     final isCurrent =
//         (symbol == PlayerSymbol.x && localGame!.player1.id == userId) ||
//         (symbol == PlayerSymbol.o && localGame!.player2?.id == userId);
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isCurrent ? Colors.white.withOpacity(0.2) : Colors.white12,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: isCurrent ? Colors.white : Colors.white38,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: player.photoUrl != null
//                 ? NetworkImage(player.photoUrl!)
//                 : null,
//             child: player.photoUrl == null
//                 ? Text(
//                     player.email[0].toUpperCase(),
//                     style: const TextStyle(color: Colors.white),
//                   )
//                 : null,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             player.email.split('@')[0],
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             symbol == PlayerSymbol.x ? 'X' : 'O',
//             style: TextStyle(
//               color: symbol == PlayerSymbol.x
//                   ? Colors.blue[200]
//                   : Colors.red[200],
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGridCell(int index, bool isCurrentPlayer, String userId) {
//     final cellValue = localGame!.board[index];
//     final canMakeMove =
//         isCurrentPlayer &&
//         cellValue == null &&
//         localGame!.status == GameStatus.playing;
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//               setState(() {
//                 final newBoard = List<String?>.from(localGame!.board);
//                 if (localGame!.id.contains('_offline')) {
//                   // Alternate moves for offline players
//                   newBoard[index] = localGame!.currentPlayer == PlayerSymbol.x
//                       ? 'X'
//                       : 'O';
//                   localGame = localGame!.copyWith(
//                     board: newBoard,
//                     currentPlayer: localGame!.currentPlayer == PlayerSymbol.x
//                         ? PlayerSymbol.o
//                         : PlayerSymbol.x,
//                   );
//                   _checkOfflineWinner();
//                 } else {
//                   // Online move
//                   newBoard[index] = (localGame!.player1.id == userId)
//                       ? 'X'
//                       : 'O';
//                   localGame = localGame!.copyWith(
//                     board: newBoard,
//                     currentPlayer: localGame!.currentPlayer == PlayerSymbol.x
//                         ? PlayerSymbol.o
//                         : PlayerSymbol.x,
//                   );
//                   ref
//                       .read(gameViewModelProvider(widget.gameId).notifier)
//                       .makeMove(index, userId);
//                 }
//               });
//             }
//           : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: canMakeMove ? Colors.white70 : Colors.white24,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             cellValue ?? '',
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: cellValue == 'X' ? Colors.blue[200] : Colors.red[200],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getGameStatusText(String userId, bool isCurrentPlayer) {
//     switch (localGame!.status) {
//       case GameStatus.waiting:
//         return 'Waiting for opponent...';
//       case GameStatus.playing:
//         return isCurrentPlayer ? 'Your turn!' : 'Opponent\'s turn';
//       case GameStatus.finished:
//         if (localGame!.winner == null) return 'Draw!';
//         return localGame!.winner!.id == userId ? 'You won!' : 'You lost!';
//       case GameStatus.abandoned:
//         return 'Game abandoned';
//     }
//   }
//
//   void _checkOfflineWinner() {
//     final b = localGame!.board;
//     const combos = [
//       [0, 1, 2],
//       [3, 4, 5],
//       [6, 7, 8],
//       [0, 3, 6],
//       [1, 4, 7],
//       [2, 5, 8],
//       [0, 4, 8],
//       [2, 4, 6],
//     ];
//
//     UserModel? winner;
//
//     for (var c in combos) {
//       if (b[c[0]] != null && b[c[0]] == b[c[1]] && b[c[1]] == b[c[2]]) {
//         winner = b[c[0]] == 'X' ? localGame!.player1 : localGame!.player2;
//         break;
//       }
//     }
//
//     if (winner != null || !b.contains(null)) {
//       setState(() {
//         localGame = localGame!.copyWith(
//           status: GameStatus.finished,
//           winner: winner,
//           finishedAt: DateTime.now(),
//         );
//       });
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => GameResultsScreen(
//               game: localGame!,
//               userId: FirebaseAuth.instance.currentUser!.uid,
//             ),
//           ),
//         );
//       });
//     }
//   }
//
//   void _showExitDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Leave Game'),
//         content: const Text('Are you sure you want to leave this game?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Leave'),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
// import '../viewmodels/game_viewmodel.dart';
// import 'game_results_screen.dart';
//
// class GameScreen extends ConsumerStatefulWidget {
//   final String gameId;
//   final bool isOffline;
//
//   const GameScreen({super.key, required this.gameId, this.isOffline = false});
//
//   @override
//   ConsumerState<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends ConsumerState<GameScreen> {
//   GameModel? localGame;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // For offline games, initialize the game state immediately
//     if (widget.isOffline) {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser != null) {
//         final player1 = UserModel(
//           id: '${currentUser.uid}_offline1',
//           email: currentUser.email ?? 'player1@offline.com',
//           displayName: 'Player 1 (You)',
//           photoUrl: currentUser.photoURL,
//           wins: 0,
//           losses: 0,
//           draws: 0,
//         );
//
//         final player2 = UserModel(
//           id: '${currentUser.uid}_offline2',
//           email: 'player2@offline.com',
//           displayName: 'Player 2',
//           photoUrl: null,
//           wins: 0,
//           losses: 0,
//           draws: 0,
//         );
//
//         setState(() {
//           localGame = GameModel(
//             id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
//             roomId: 'offline',
//             player1: player1,
//             player2: player2,
//             board: List.filled(9, null),
//             currentPlayer: PlayerSymbol.x,
//             status: GameStatus.playing,
//             createdAt: DateTime.now(),
//             winner: null,
//             finishedAt: null,
//           );
//         });
//       }
//     } else {
//       // For online games, start watching the game state
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref.read(gameViewModelProvider(widget.gameId));
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     // For offline games, use the local state
//     if (widget.isOffline) {
//       if (localGame == null) {
//         return const Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         );
//       }
//
//       return _buildOfflineGameUI(currentUser!);
//     }
//
//     // For online games, use the Riverpod state
//     final gameState = ref.watch(gameViewModelProvider(widget.gameId));
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: gameState.when(
//             loading: () => const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             ),
//             error: (error, stack) => Center(
//               child: Text(
//                 'Error: $error',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             data: (game) {
//               if (game == null) {
//                 return const Center(
//                   child: Text(
//                     'Game not found',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 );
//               }
//
//               // Navigate to results if game finished
//               if (game.status == GameStatus.finished ||
//                   game.status == GameStatus.abandoned) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => GameResultsScreen(
//                         game: game,
//                         userId: currentUser!.uid,
//                       ),
//                     ),
//                   );
//                 });
//               }
//
//               return Column(
//                 children: [
//                   _buildHeader(currentUser),
//                   Expanded(child: _buildOnlineGameBoard(game, currentUser!.uid)),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOfflineGameUI(User currentUser) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(currentUser),
//               Expanded(child: _buildOfflineGameBoard(currentUser.uid)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(User? currentUser) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Welcome',
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//               Text(
//                 widget.isOffline ? 'Offline Mode' : currentUser?.displayName ?? currentUser?.email ?? 'Player',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app, color: Colors.white),
//             onPressed: () => _showExitDialog(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOnlineGameBoard(GameModel game, String userId) {
//     final isCurrentPlayer = (game.currentPlayer == PlayerSymbol.x &&
//         game.player1.id == userId) ||
//         (game.currentPlayer == PlayerSymbol.o && game.player2?.id == userId);
//
//     return Column(
//       children: [
//         // Players
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildPlayerCard(game.player1, PlayerSymbol.x, userId, game),
//             if (game.player2 != null)
//               _buildPlayerCard(game.player2!, PlayerSymbol.o, userId, game),
//           ],
//         ),
//         const SizedBox(height: 20),
//
//         // Turn indicator
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white24,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _getGameStatusText(game, userId, isCurrentPlayer),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // Board
//         Expanded(
//           child: AspectRatio(
//             aspectRatio: 1,
//             child: GridView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: 9,
//               itemBuilder: (context, index) {
//                 return _buildOnlineGridCell(index, isCurrentPlayer, userId, game);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildOfflineGameBoard(String userId) {
//     final isCurrentPlayer = localGame!.currentPlayer == PlayerSymbol.x;
//
//     return Column(
//       children: [
//         // Players
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildPlayerCard(localGame!.player1, PlayerSymbol.x, userId, localGame!),
//             _buildPlayerCard(localGame!.player2!, PlayerSymbol.o, userId, localGame!),
//           ],
//         ),
//         const SizedBox(height: 20),
//
//         // Turn indicator
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white24,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _getGameStatusText(localGame!, userId, isCurrentPlayer),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//
//         // Board
//         Expanded(
//           child: AspectRatio(
//             aspectRatio: 1,
//             child: GridView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: 9,
//               itemBuilder: (context, index) {
//                 return _buildOfflineGridCell(index);
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPlayerCard(
//       UserModel player, PlayerSymbol symbol, String userId, GameModel game) {
//     final isCurrentPlayer = (symbol == PlayerSymbol.x && game.player1.id == userId) ||
//         (symbol == PlayerSymbol.o && game.player2?.id == userId);
//
//     final isCurrentTurn = game.currentPlayer == symbol;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isCurrentTurn ? Colors.white.withOpacity(0.2) : Colors.white12,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: isCurrentTurn ? Colors.white : Colors.white38,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: player.photoUrl != null
//                 ? NetworkImage(player.photoUrl!)
//                 : null,
//             child: player.photoUrl == null
//                 ? Text(
//               player.email[0].toUpperCase(),
//               style: const TextStyle(color: Colors.white),
//             )
//                 : null,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             player.displayName ?? player.email.split('@')[0],
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             symbol == PlayerSymbol.x ? 'X' : 'O',
//             style: TextStyle(
//               color: symbol == PlayerSymbol.x
//                   ? Colors.blue[200]
//                   : Colors.red[200],
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOnlineGridCell(int index, bool isCurrentPlayer, String userId, GameModel game) {
//     final cellValue = game.board[index];
//     final canMakeMove = isCurrentPlayer &&
//         cellValue == null &&
//         game.status == GameStatus.playing;
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//         ref
//             .read(gameViewModelProvider(widget.gameId).notifier)
//             .makeMove(index, userId);
//       }
//           : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: canMakeMove ? Colors.white70 : Colors.white24,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             cellValue ?? '',
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: cellValue == 'x' ? Colors.blue[200] :
//               cellValue == 'o' ? Colors.red[200] : Colors.transparent,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOfflineGridCell(int index) {
//     final cellValue = localGame!.board[index];
//     final canMakeMove = cellValue == null &&
//         localGame!.status == GameStatus.playing;
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//         setState(() {
//           final newBoard = List<String?>.from(localGame!.board);
//           newBoard[index] = localGame!.currentPlayer == PlayerSymbol.x ? 'x' : 'o';
//
//           localGame = localGame!.copyWith(
//             board: newBoard,
//             currentPlayer: localGame!.currentPlayer == PlayerSymbol.x
//                 ? PlayerSymbol.o
//                 : PlayerSymbol.x,
//           );
//
//           _checkOfflineWinner();
//         });
//       }
//           : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.all(4),
//         decoration: BoxDecoration(
//           color: canMakeMove ? Colors.white70 : Colors.white24,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 4,
//               offset: const Offset(2, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             cellValue ?? '',
//             style: TextStyle(
//               fontSize: 48,
//               fontWeight: FontWeight.bold,
//               color: cellValue == 'x' ? Colors.blue[200] :
//               cellValue == 'o' ? Colors.red[200] : Colors.transparent,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getGameStatusText(GameModel game, String userId, bool isCurrentPlayer) {
//     switch (game.status) {
//       case GameStatus.waiting:
//         return 'Waiting for opponent...';
//       case GameStatus.playing:
//         return isCurrentPlayer ? 'Your turn!' : 'Opponent\'s turn';
//       case GameStatus.finished:
//         if (game.winner == null) return 'Draw!';
//         return game.winner!.id == userId ? 'You won!' : 'You lost!';
//       case GameStatus.abandoned:
//         return 'Game abandoned';
//     }
//   }
//
//   void _checkOfflineWinner() {
//     final b = localGame!.board;
//     const combos = [
//       [0, 1, 2],
//       [3, 4, 5],
//       [6, 7, 8],
//       [0, 3, 6],
//       [1, 4, 7],
//       [2, 5, 8],
//       [0, 4, 8],
//       [2, 4, 6],
//     ];
//
//     UserModel? winner;
//
//     for (var c in combos) {
//       if (b[c[0]] != null && b[c[0]] == b[c[1]] && b[c[1]] == b[c[2]]) {
//         winner = b[c[0]] == 'x' ? localGame!.player1 : localGame!.player2;
//         break;
//       }
//     }
//
//     final isDraw = !b.contains(null) && winner == null;
//
//     if (winner != null || isDraw) {
//       setState(() {
//         localGame = localGame!.copyWith(
//           status: GameStatus.finished,
//           winner: winner,
//           finishedAt: DateTime.now(),
//         );
//       });
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => GameResultsScreen(
//               game: localGame!,
//               userId: FirebaseAuth.instance.currentUser!.uid,
//             ),
//           ),
//         );
//       });
//     }
//   }
//
//   void _showExitDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Leave Game'),
//         content: const Text('Are you sure you want to leave this game?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Leave'),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
// import '../viewmodels/game_viewmodel.dart';
// import 'game_results_screen.dart';
//
// class GameScreen extends ConsumerStatefulWidget {
//   final String gameId;
//   final bool isOffline;
//
//   const GameScreen({super.key, required this.gameId, this.isOffline = false});
//
//   @override
//   ConsumerState<GameScreen> createState() => _GameScreenState();
// }
//
// class _GameScreenState extends ConsumerState<GameScreen> {
//   GameModel? localGame;
//
//   @override
//   void initState() {
//     super.initState();
//
//     if (widget.isOffline) {
//       final currentUser = FirebaseAuth.instance.currentUser;
//       if (currentUser != null) {
//         final player1 = UserModel(
//           id: '${currentUser.uid}_offline1',
//           email: currentUser.email ?? 'player1@offline.com',
//           displayName: 'Player 1 (You)',
//           photoUrl: currentUser.photoURL,
//           wins: 0,
//           losses: 0,
//           draws: 0,
//         );
//
//         final player2 = UserModel(
//           id: '${currentUser.uid}_offline2',
//           email: 'player2@offline.com',
//           displayName: 'Player 2',
//           photoUrl: null,
//           wins: 0,
//           losses: 0,
//           draws: 0,
//         );
//
//         setState(() {
//           localGame = GameModel(
//             id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
//             roomId: 'offline',
//             player1: player1,
//             player2: player2,
//             board: List.filled(9, null),
//             currentPlayer: PlayerSymbol.x,
//             status: GameStatus.playing,
//             createdAt: DateTime.now(),
//             winner: null,
//             finishedAt: null,
//           );
//         });
//       }
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref.read(gameViewModelProvider(widget.gameId));
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser;
//
//     if (widget.isOffline) {
//       if (localGame == null) {
//         return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       }
//
//       return _buildGameUI(currentUser!, localGame!, isOffline: true);
//     }
//
//     final gameState = ref.watch(gameViewModelProvider(widget.gameId));
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: gameState.when(
//             loading: () => const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             ),
//             error: (error, stack) => Center(
//               child: Text(
//                 'Error: $error',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             data: (game) {
//               if (game == null) {
//                 return const Center(
//                   child: Text(
//                     'Game not found',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 );
//               }
//
//               if (game.status == GameStatus.finished ||
//                   game.status == GameStatus.abandoned) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => GameResultsScreen(
//                         game: game,
//                         userId: currentUser!.uid,
//                       ),
//                     ),
//                   );
//                 });
//               }
//
//               return _buildGameUI(currentUser!, game);
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGameUI(
//     User currentUser,
//     GameModel game, {
//     bool isOffline = false,
//   }) {
//     final userId = currentUser.uid;
//     final isCurrentPlayer = isOffline
//         ? game.currentPlayer == PlayerSymbol.x
//         : (game.currentPlayer == PlayerSymbol.x && game.player1.id == userId) ||
//               (game.currentPlayer == PlayerSymbol.o &&
//                   game.player2?.id == userId);
//
//     return Column(
//       children: [
//         _buildHeader(currentUser),
//         const SizedBox(height: 10),
//         // Players row (offline & online same layout)
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Expanded(
//                 child: _buildPlayerCard(
//                   game.player1,
//                   PlayerSymbol.x,
//                   userId,
//                   game,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               if (game.player2 != null)
//                 Expanded(
//                   child: _buildPlayerCard(
//                     game.player2!,
//                     PlayerSymbol.o,
//                     userId,
//                     game,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         // Turn indicator
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white24,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _getGameStatusText(game, userId, isCurrentPlayer),
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 16,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         // Game board
//         Expanded(
//           child: AspectRatio(
//             aspectRatio: 1,
//             child: GridView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//               ),
//               itemCount: 9,
//               itemBuilder: (context, index) {
//                 return isOffline
//                     ? _buildOfflineGridCell(index)
//                     : _buildOnlineGridCell(
//                         index,
//                         isCurrentPlayer,
//                         userId,
//                         game,
//                       );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildHeader(User? currentUser) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Welcome',
//                 style: TextStyle(color: Colors.white70, fontSize: 14),
//               ),
//               Text(
//                 widget.isOffline
//                     ? 'Offline Mode'
//                     : currentUser?.displayName ??
//                           currentUser?.email ??
//                           'Player',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 overflow: TextOverflow.ellipsis, // adds "..."
//                 maxLines: 1, // keeps it single line
//               ),
//             ],
//           ),
//           IconButton(
//             icon: const Icon(Icons.exit_to_app, color: Colors.white),
//             onPressed: () => _showExitDialog(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPlayerCard(
//     UserModel player,
//     PlayerSymbol symbol,
//     String userId,
//     GameModel game,
//   ) {
//     final isCurrentPlayer =
//         (symbol == PlayerSymbol.x && game.player1.id == userId) ||
//         (symbol == PlayerSymbol.o && game.player2?.id == userId);
//     final isCurrentTurn = game.currentPlayer == symbol;
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isCurrentTurn ? Colors.white.withOpacity(0.2) : Colors.white12,
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: isCurrentTurn ? Colors.white : Colors.white38,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         children: [
//           CircleAvatar(
//             radius: 25,
//             backgroundImage: player.photoUrl != null
//                 ? NetworkImage(player.photoUrl!)
//                 : null,
//             child: player.photoUrl == null
//                 ? Text(
//                     player.email[0].toUpperCase(),
//                     style: const TextStyle(color: Colors.white),
//                   )
//                 : null,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             player.displayName ?? player.email.split('@')[0],
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
//             ),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           Text(
//             symbol == PlayerSymbol.x ? 'X' : 'O',
//             style: TextStyle(
//               color: symbol == PlayerSymbol.x
//                   ? Colors.blue[200]
//                   : Colors.red[200],
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOnlineGridCell(
//     int index,
//     bool isCurrentPlayer,
//     String userId,
//     GameModel game,
//   ) {
//     final cellValue = game.board[index];
//     final canMakeMove =
//         isCurrentPlayer &&
//         cellValue == null &&
//         game.status == GameStatus.playing;
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//               ref
//                   .read(gameViewModelProvider(widget.gameId).notifier)
//                   .makeMove(index, userId);
//             }
//           : null,
//       child: _buildGridCell(cellValue, canMakeMove),
//     );
//   }
//
//   Widget _buildOfflineGridCell(int index) {
//     final cellValue = localGame!.board[index];
//     final canMakeMove =
//         cellValue == null && localGame!.status == GameStatus.playing;
//
//     return GestureDetector(
//       onTap: canMakeMove
//           ? () {
//               setState(() {
//                 final newBoard = List<String?>.from(localGame!.board);
//                 newBoard[index] = localGame!.currentPlayer == PlayerSymbol.x
//                     ? 'x'
//                     : 'o';
//
//                 localGame = localGame!.copyWith(
//                   board: newBoard,
//                   currentPlayer: localGame!.currentPlayer == PlayerSymbol.x
//                       ? PlayerSymbol.o
//                       : PlayerSymbol.x,
//                 );
//
//                 _checkOfflineWinner();
//               });
//             }
//           : null,
//       child: _buildGridCell(cellValue, canMakeMove),
//     );
//   }
//
//   Widget _buildGridCell(String? cellValue, bool canMakeMove) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: canMakeMove ? Colors.white70 : Colors.white24,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 4,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: Center(
//         child: Text(
//           cellValue ?? '',
//           style: TextStyle(
//             fontSize: 48,
//             fontWeight: FontWeight.bold,
//             color: cellValue == 'x'
//                 ? Colors.blue[200]
//                 : cellValue == 'o'
//                 ? Colors.red[200]
//                 : Colors.transparent,
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _getGameStatusText(
//     GameModel game,
//     String userId,
//     bool isCurrentPlayer,
//   ) {
//     switch (game.status) {
//       case GameStatus.waiting:
//         return 'Waiting for opponent...';
//       case GameStatus.playing:
//         return isCurrentPlayer ? 'Your turn!' : 'Opponent\'s turn';
//       case GameStatus.finished:
//         if (game.winner == null) return 'Draw!';
//         return game.winner!.id == userId ? 'You won!' : 'You lost!';
//       case GameStatus.abandoned:
//         return 'Game abandoned';
//     }
//   }
//
//   void _checkOfflineWinner() {
//     final b = localGame!.board;
//     const combos = [
//       [0, 1, 2],
//       [3, 4, 5],
//       [6, 7, 8],
//       [0, 3, 6],
//       [1, 4, 7],
//       [2, 5, 8],
//       [0, 4, 8],
//       [2, 4, 6],
//     ];
//
//     UserModel? winner;
//
//     for (var c in combos) {
//       if (b[c[0]] != null && b[c[0]] == b[c[1]] && b[c[1]] == b[c[2]]) {
//         winner = b[c[0]] == 'x' ? localGame!.player1 : localGame!.player2;
//         break;
//       }
//     }
//
//     final isDraw = !b.contains(null) && winner == null;
//
//     if (winner != null || isDraw) {
//       setState(() {
//         localGame = localGame!.copyWith(
//           status: GameStatus.finished,
//           winner: winner,
//           finishedAt: DateTime.now(),
//         );
//       });
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => GameResultsScreen(
//               game: localGame!,
//               userId: FirebaseAuth.instance.currentUser!.uid,
//             ),
//           ),
//         );
//       });
//     }
//   }
//
//   void _showExitDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Leave Game'),
//         content: const Text('Are you sure you want to leave this game?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text('Leave'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';
import '../viewmodels/game_viewmodel.dart';
import 'game_results_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String gameId;
  final bool isOffline;

  const GameScreen({super.key, required this.gameId, this.isOffline = false});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  GameModel? localGame;

  @override
  void initState() {
    super.initState();

    if (widget.isOffline) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final player1 = UserModel(
          id: '${currentUser.uid}_offline1',
          email: currentUser.email ?? 'player1@offline.com',
          displayName: 'Player 1 (You)',
          photoUrl: currentUser.photoURL,
          wins: 0,
          losses: 0,
          draws: 0,
        );

        final player2 = UserModel(
          id: '${currentUser.uid}_offline2',
          email: 'player2@offline.com',
          displayName: 'Player 2',
          photoUrl: null,
          wins: 0,
          losses: 0,
          draws: 0,
        );

        setState(() {
          localGame = GameModel(
            id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
            roomId: 'offline',
            player1: player1,
            player2: player2,
            board: List.filled(9, null),
            currentPlayer: PlayerSymbol.x,
            status: GameStatus.playing,
            createdAt: DateTime.now(),
            winner: null,
            finishedAt: null,
          );
        });
      }
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gameViewModelProvider(widget.gameId));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Apply the same gradient background to both online and offline modes
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
          child: widget.isOffline
              ? _buildOfflineContent(currentUser)
              : _buildOnlineContent(currentUser),
        ),
      ),
    );
  }

  Widget _buildOfflineContent(User? currentUser) {
    if (localGame == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (localGame!.status == GameStatus.finished ||
        localGame!.status == GameStatus.abandoned) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                GameResultsScreen(game: localGame!, userId: currentUser!.uid),
          ),
        );
      });
      return const Center(
        child: Text('Game finished', style: TextStyle(color: Colors.white)),
      );
    }

    return _buildGameUI(currentUser!, localGame!, isOffline: true);
  }

  Widget _buildOnlineContent(User? currentUser) {
    final gameState = ref.watch(gameViewModelProvider(widget.gameId));

    return gameState.when(
      loading: () =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
      error: (error, stack) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      data: (game) {
        if (game == null) {
          return const Center(
            child: Text(
              'Game not found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (game.status == GameStatus.finished ||
            game.status == GameStatus.abandoned) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    GameResultsScreen(game: game, userId: currentUser!.uid),
              ),
            );
          });
        }

        return _buildGameUI(currentUser!, game);
      },
    );
  }

  Widget _buildGameUI(
    User currentUser,
    GameModel game, {
    bool isOffline = false,
  }) {
    final userId = currentUser.uid;
    final isCurrentPlayer = isOffline
        ? game.currentPlayer == PlayerSymbol.x
        : (game.currentPlayer == PlayerSymbol.x && game.player1.id == userId) ||
              (game.currentPlayer == PlayerSymbol.o &&
                  game.player2?.id == userId);

    return Column(
      children: [
        _buildHeader(currentUser, isOffline),
        const SizedBox(height: 10),
        // Players row (offline & online same layout)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildPlayerCard(
                  game.player1,
                  PlayerSymbol.x,
                  userId,
                  game,
                ),
              ),
              const SizedBox(width: 16),
              if (game.player2 != null)
                Expanded(
                  child: _buildPlayerCard(
                    game.player2!,
                    PlayerSymbol.o,
                    userId,
                    game,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Turn indicator
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getGameStatusText(game, userId, isCurrentPlayer, isOffline),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Game board
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return isOffline
                      ? _buildOfflineGridCell(index)
                      : _buildOnlineGridCell(
                          index,
                          isCurrentPlayer,
                          userId,
                          game,
                        );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeader(User? currentUser, bool isOffline) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                isOffline
                    ? 'Offline Mode'
                    : currentUser?.displayName ??
                          currentUser?.email ??
                          'Player',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () => _showExitDialog(context, isOffline),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
    UserModel player,
    PlayerSymbol symbol,
    String userId,
    GameModel game,
  ) {
    final isCurrentPlayer =
        (symbol == PlayerSymbol.x && game.player1.id == userId) ||
        (symbol == PlayerSymbol.o && game.player2?.id == userId);
    final isCurrentTurn = game.currentPlayer == symbol;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn ? Colors.white.withOpacity(0.2) : Colors.white12,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentTurn ? Colors.white : Colors.white38,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: player.photoUrl != null
                ? NetworkImage(player.photoUrl!)
                : null,
            child: player.photoUrl == null
                ? Text(
                    player.email[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            player.displayName ?? player.email.split('@')[0],
            style: TextStyle(
              color: Colors.white,
              fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            symbol == PlayerSymbol.x ? 'X' : 'O',
            style: TextStyle(
              color: symbol == PlayerSymbol.x
                  ? Colors.blue[200]
                  : Colors.red[200],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineGridCell(
    int index,
    bool isCurrentPlayer,
    String userId,
    GameModel game,
  ) {
    final cellValue = game.board[index];
    final canMakeMove =
        isCurrentPlayer &&
        cellValue == null &&
        game.status == GameStatus.playing;

    return GestureDetector(
      onTap: canMakeMove
          ? () {
              ref
                  .read(gameViewModelProvider(widget.gameId).notifier)
                  .makeMove(index, userId);
            }
          : null,
      child: _buildGridCell(cellValue, canMakeMove),
    );
  }

  Widget _buildOfflineGridCell(int index) {
    final cellValue = localGame!.board[index];
    final canMakeMove =
        cellValue == null && localGame!.status == GameStatus.playing;

    return GestureDetector(
      onTap: canMakeMove
          ? () {
              setState(() {
                final newBoard = List<String?>.from(localGame!.board);
                newBoard[index] = localGame!.currentPlayer == PlayerSymbol.x
                    ? 'x'
                    : 'o';

                localGame = localGame!.copyWith(
                  board: newBoard,
                  currentPlayer: localGame!.currentPlayer == PlayerSymbol.x
                      ? PlayerSymbol.o
                      : PlayerSymbol.x,
                );

                _checkOfflineWinner();
              });
            }
          : null,
      child: _buildGridCell(cellValue, canMakeMove),
    );
  }

  Widget _buildGridCell(String? cellValue, bool canMakeMove) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: canMakeMove ? Colors.white70 : Colors.white24,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            cellValue ?? '',
            key: ValueKey(cellValue ?? 'empty'),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: cellValue == 'x'
                  ? Colors.blue[200]
                  : cellValue == 'o'
                  ? Colors.red[200]
                  : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  String _getGameStatusText(
    GameModel game,
    String userId,
    bool isCurrentPlayer,
    bool isOffline,
  ) {
    switch (game.status) {
      case GameStatus.waiting:
        return 'Waiting for opponent...';
      case GameStatus.playing:
        if (isOffline) {
          return 'Player ${game.currentPlayer == PlayerSymbol.x ? '1' : '2'}\'s turn';
        }
        return isCurrentPlayer ? 'Your turn!' : 'Opponent\'s turn';
      case GameStatus.finished:
        if (game.winner == null) return 'Draw!';
        return game.winner!.id == userId ? 'You won!' : 'You lost!';
      case GameStatus.abandoned:
        return 'Game abandoned';
    }
  }

  void _checkOfflineWinner() {
    final b = localGame!.board;
    const combos = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    UserModel? winner;

    for (var c in combos) {
      if (b[c[0]] != null && b[c[0]] == b[c[1]] && b[c[1]] == b[c[2]]) {
        winner = b[c[0]] == 'x' ? localGame!.player1 : localGame!.player2;
        break;
      }
    }

    final isDraw = !b.contains(null) && winner == null;

    if (winner != null || isDraw) {
      setState(() {
        localGame = localGame!.copyWith(
          status: GameStatus.finished,
          winner: winner,
          finishedAt: DateTime.now(),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameResultsScreen(
              game: localGame!,
              userId: FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
        );
      });
    }
  }

  void _showExitDialog(BuildContext context, bool isOffline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Game'),
        content: Text(
          isOffline
              ? 'Are you sure you want to exit this offline game?'
              : 'Are you sure you want to leave this game?',
        ),
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
