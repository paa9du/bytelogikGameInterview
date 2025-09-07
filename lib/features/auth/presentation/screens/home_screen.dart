// // lib/features/game/presentation/screens/home_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
// import '../../../game/presentation/screens/game_screen.dart';
// import '../../../game/presentation/viewmodels/game_viewmodel.dart';
// import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
//
// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   bool _isMounted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _isMounted = true;
//   }
//
//   @override
//   void dispose() {
//     _isMounted = false;
//     super.dispose();
//   }
//
//   void _showSnackBar(String message, {bool isError = true}) {
//     if (_isMounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? Colors.red : Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   Future<void> _handleSignOut() async {
//     try {
//       await ref.read(authViewModelProvider.notifier).signOut();
//       ref.invalidate(authViewModelProvider);
//     } catch (e) {
//       if (_isMounted) {
//         _showSnackBar('Logout failed: $e');
//       }
//     }
//   }
//
//   // Replace your _navigateToGameLobby function with this:
//   Future<void> _navigateToGameLobby() async {
//     // Create a game first, then navigate to it
//     try {
//       // You'll need to access your game repository or service
//       final gameRepository = ref.read(gameRepositoryProvider);
//       final gameId = await gameRepository.createGame();
//
//       if (gameId != null) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
//         );
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to create game')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error creating game: $e')));
//     }
//   }
//
//   void _navigateToLeaderboard() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => LeaderboardScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final user = authState.user;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header with user info
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Hello,',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           user?.displayName ?? user?.email ?? 'Player',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         // if (user?.photoURL != null)
//                         //   CircleAvatar(
//                         //     backgroundImage: NetworkImage(user!.photoURL!),
//                         //     radius: 20,
//                         //     backgroundColor: Colors.white,
//                         //   ),
//                         const SizedBox(width: 10),
//                         IconButton(
//                           icon: const Icon(Icons.logout, color: Colors.white),
//                           onPressed: _handleSignOut,
//                           tooltip: 'Sign Out',
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Main content
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // App Logo/Title
//                       const Column(
//                         children: [
//                           Icon(
//                             Icons.gamepad_rounded,
//                             size: 80,
//                             color: Colors.white,
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             'Tic-Tac-Toe',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.5,
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             'Classic Game, Modern Experience',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 60),
//
//                       // Action Buttons
//                       Column(
//                         children: [
//                           // Play Game Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed: _navigateToGameLobby,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.white,
//                                 foregroundColor: const Color(0xFF6A11CB),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 elevation: 5,
//                                 shadowColor: Colors.black.withOpacity(0.3),
//                               ),
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.play_arrow_rounded),
//                                   SizedBox(width: 10),
//                                   Text(
//                                     'PLAY GAME',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           // Leaderboard Button
//                           SizedBox(
//                             width: double.infinity,
//                             child: OutlinedButton(
//                               onPressed: _navigateToLeaderboard,
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: Colors.white,
//                                 side: const BorderSide(
//                                   color: Colors.white,
//                                   width: 2,
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                               ),
//                               child: const Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.leaderboard_rounded),
//                                   SizedBox(width: 10),
//                                   Text(
//                                     'VIEW LEADERBOARD',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//
//                           const SizedBox(height: 30),
//
//                           // Additional Options
//                           Wrap(
//                             spacing: 20,
//                             children: [
//                               // Settings Button
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.settings,
//                                   color: Colors.white70,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, '/settings');
//                                 },
//                                 tooltip: 'Settings',
//                               ),
//
//                               // Profile Button
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.person,
//                                   color: Colors.white70,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, '/profile');
//                                 },
//                                 tooltip: 'Profile',
//                               ),
//
//                               // How to Play Button
//                               IconButton(
//                                 icon: const Icon(
//                                   Icons.help,
//                                   color: Colors.white70,
//                                 ),
//                                 onPressed: () {
//                                   Navigator.pushNamed(context, '/tutorial');
//                                 },
//                                 tooltip: 'How to Play',
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // Footer
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   '© 2024 Tic-Tac-Toe App',
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.6),
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//   // lib/features/game/presentation/screens/home_screen.dart
//   import 'package:flutter/material.dart';
//   import 'package:flutter_riverpod/flutter_riverpod.dart';
//   import 'package:firebase_auth/firebase_auth.dart';
//   import '../../../../core/models/game_model.dart';
//   import '../../../../core/models/user_model.dart';
//   import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
//   import '../../../game/data/repositories/game_repository_impl.dart';
//   import '../../../game/presentation/screens/game_screen.dart';
//   import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
//
//   class HomeScreen extends ConsumerStatefulWidget {
//     const HomeScreen({super.key});
//
//     @override
//     ConsumerState<HomeScreen> createState() => _HomeScreenState();
//   }
//
//   class _HomeScreenState extends ConsumerState<HomeScreen> {
//     bool _isMounted = false;
//
//     @override
//     void initState() {
//       super.initState();
//       _isMounted = true;
//     }
//
//     @override
//     void dispose() {
//       _isMounted = false;
//       super.dispose();
//     }
//
//     void _showSnackBar(String message, {bool isError = true}) {
//       if (_isMounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(message),
//             backgroundColor: isError ? Colors.red : Colors.green,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//
//     Future<void> _handleSignOut() async {
//       try {
//         await ref.read(authViewModelProvider.notifier).signOut();
//         ref.invalidate(authViewModelProvider);
//       } catch (e) {
//         if (_isMounted) {
//           _showSnackBar('Logout failed: $e');
//         }
//       }
//     }
//
//     // Fixed navigation function - now accepts ref as parameter
//     Future<void> _navigateToGameLobby(WidgetRef ref) async {
//       try {
//         final gameRepository = ref.read(gameRepositoryProvider);
//
//         // Get current user
//         final user = FirebaseAuth.instance.currentUser;
//         if (user == null) {
//           _showSnackBar('Please sign in first');
//           return;
//         }
//
//         // Create a new game
//         final game = GameModel(
//           id: '', // Will be generated by Firestore
//           player1: UserModel(
//             id: user.uid,
//             email: user.email ?? 'unknown@email.com',
//             photoUrl: user.photoURL,
//             wins: 0,
//             losses: 0,
//             draws: 0,
//           ),
//           player2: null,
//           board: List.filled(9, null),
//           currentPlayer: PlayerSymbol.x,
//           status: GameStatus.waiting,
//           createdAt: DateTime.now(),
//           winner: null,
//           roomId: '',
//         );
//
//         await gameRepository.createGame(game);
//
//         // Since createGame doesn't return the ID, we need to modify it
//         // For now, let's use a different approach
//         _showSnackBar('Game creation not fully implemented yet');
//       } catch (e) {
//         _showSnackBar('Error creating game: $e');
//       }
//     }
//
//     // Alternative approach - create a simple game directly
//     Future<void> _createAndNavigateToGame() async {
//       try {
//         final user = FirebaseAuth.instance.currentUser;
//         if (user == null) {
//           _showSnackBar('Please sign in first');
//           return;
//         }
//
//         final gameRepository = ref.read(gameRepositoryProvider);
//
//         // Create new game
//         final game = GameModel(
//           id: '', // Firestore will assign
//           roomId: '',
//           player1: UserModel(
//             id: user.uid,
//             email: user.email ?? 'unknown@email.com',
//             photoUrl: user.photoURL,
//             wins: 0,
//             losses: 0,
//             draws: 0,
//           ),
//           player2: null,
//           board: List.filled(9, null),
//           currentPlayer: PlayerSymbol.x,
//           status: GameStatus.waiting,
//           createdAt: DateTime.now(),
//           winner: null,
//         );
//
//         final gameId = await gameRepository.createGame(game); // get real id ✅
//
//         // Navigate to game
//         if (_isMounted) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
//           );
//         }
//       } catch (e) {
//         _showSnackBar('Error creating game: $e');
//       }
//     }
//
//     void _navigateToLeaderboard() {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => LeaderboardScreen()),
//       );
//     }
//
//     @override
//     Widget build(BuildContext context) {
//       final authState = ref.watch(authViewModelProvider);
//       final user = authState.user;
//
//       return Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             ),
//           ),
//           child: SafeArea(
//             child: Column(
//               children: [
//                 // Header with user info
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Hello,',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.8),
//                               fontSize: 16,
//                             ),
//                           ),
//                           Text(
//                             user?.displayName ?? user?.email ?? 'Player',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.logout, color: Colors.white),
//                             onPressed: _handleSignOut,
//                             tooltip: 'Sign Out',
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Main content
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(20),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         // App Logo/Title
//                         const Column(
//                           children: [
//                             Icon(
//                               Icons.gamepad_rounded,
//                               size: 80,
//                               color: Colors.white,
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               'Tic-Tac-Toe',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 32,
//                                 fontWeight: FontWeight.bold,
//                                 letterSpacing: 1.5,
//                               ),
//                             ),
//                             SizedBox(height: 5),
//                             Text(
//                               'Classic Game, Modern Experience',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 60),
//
//                         // Action Buttons
//                         Column(
//                           children: [
//                             // Play Game Button - Fixed to use the correct function
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton(
//                                 onPressed: () => _createAndNavigateToGame(),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.white,
//                                   foregroundColor: const Color(0xFF6A11CB),
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 16,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(25),
//                                   ),
//                                   elevation: 5,
//                                   shadowColor: Colors.black.withOpacity(0.3),
//                                 ),
//                                 child: const Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.play_arrow_rounded),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       'PLAY GAME',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//
//                             const SizedBox(height: 20),
//
//                             // Leaderboard Button
//                             SizedBox(
//                               width: double.infinity,
//                               child: OutlinedButton(
//                                 onPressed: _navigateToLeaderboard,
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   side: const BorderSide(
//                                     color: Colors.white,
//                                     width: 2,
//                                   ),
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 16,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(25),
//                                   ),
//                                 ),
//                                 child: const Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(Icons.leaderboard_rounded),
//                                     SizedBox(width: 10),
//                                     Text(
//                                       'VIEW LEADERBOARD',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
// //   }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
// import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
// import '../../../game/data/repositories/game_repository_impl.dart';
// import '../../../game/presentation/screens/game_screen.dart';
// import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
//
// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   bool _isMounted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _isMounted = true;
//   }
//
//   @override
//   void dispose() {
//     _isMounted = false;
//     super.dispose();
//   }
//
//   void _showSnackBar(String message, {bool isError = true}) {
//     if (_isMounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? Colors.red : Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   Future<void> _handleSignOut() async {
//     try {
//       await ref.read(authViewModelProvider.notifier).signOut();
//       ref.invalidate(authViewModelProvider);
//     } catch (e) {
//       if (_isMounted) {
//         _showSnackBar('Logout failed: $e');
//       }
//     }
//   }
//
//   Future<void> _joinOrCreateGame() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _showSnackBar('Please sign in first');
//         return;
//       }
//
//       final userModel = UserModel(
//         id: user.uid,
//         email: user.email ?? 'unknown@email.com',
//         photoUrl: user.photoURL,
//         wins: 0,
//         losses: 0,
//         draws: 0,
//       );
//
//       final gameRepository = ref.read(gameRepositoryProvider);
//       final gameId = await gameRepository.findOrCreateGame(
//         userModel,
//       ); // 🔥 fix here
//
//       if (_isMounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
//         );
//       }
//     } catch (e) {
//       _showSnackBar('Error joining/creating game: $e');
//     }
//   }
//
//   Future<void> _startOfflineGame() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _showSnackBar('Please sign in first');
//         return;
//       }
//
//       final player1 = UserModel(
//         id: '${user.uid}_offline1',
//         email: user.email ?? 'player1@offline.com',
//         photoUrl: user.photoURL,
//         wins: 0,
//         losses: 0,
//         draws: 0,
//       );
//
//       final player2 = UserModel(
//         id: '${user.uid}_offline2',
//         email: 'player2@offline.com',
//         photoUrl: null,
//         wins: 0,
//         losses: 0,
//         draws: 0,
//       );
//
//       final gameRepository = ref.read(gameRepositoryProvider);
//
//       final gameId = await gameRepository.createOfflineGame(player1, player2);
//
//       if (_isMounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
//         );
//       }
//     } catch (e) {
//       _showSnackBar('Error starting offline game: $e');
//     }
//   }
//
//   void _navigateToLeaderboard() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final user = authState.user;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Hello,',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           user?.displayName ?? user?.email ?? 'Player',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.logout, color: Colors.white),
//                       onPressed: _handleSignOut,
//                       tooltip: 'Sign Out',
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Main content
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Column(
//                         children: [
//                           Icon(
//                             Icons.gamepad_rounded,
//                             size: 80,
//                             color: Colors.white,
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             'Tic-Tac-Toe',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.5,
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             'Classic Game, Modern Experience',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 60),
//
//                       // Play Game Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _joinOrCreateGame,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: const Color(0xFF6A11CB),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             elevation: 5,
//                             shadowColor: Colors.black.withOpacity(0.3),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.play_arrow_rounded),
//                               SizedBox(width: 10),
//                               Text(
//                                 'PLAY GAME',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Offline / Local Game Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _startOfflineGame,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: Colors.deepPurple,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             elevation: 5,
//                             shadowColor: Colors.black.withOpacity(0.3),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.smart_toy_rounded),
//                               SizedBox(width: 10),
//                               Text(
//                                 'OFFLINE GAME',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       // Leaderboard Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton(
//                           onPressed: _navigateToLeaderboard,
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.white,
//                             side: const BorderSide(
//                               color: Colors.white,
//                               width: 2,
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.leaderboard_rounded),
//                               SizedBox(width: 10),
//                               Text(
//                                 'VIEW LEADERBOARD',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../../core/models/game_model.dart';
// import '../../../../core/models/user_model.dart';
// import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
// import '../../../game/data/repositories/game_repository_impl.dart';
// import '../../../game/presentation/screens/game_screen.dart';
// import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
//
// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   bool _isMounted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _isMounted = true;
//   }
//
//   @override
//   void dispose() {
//     _isMounted = false;
//     super.dispose();
//   }
//
//   void _showSnackBar(String message, {bool isError = true}) {
//     if (_isMounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? Colors.red : Colors.green,
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }
//
//   Future<void> _handleSignOut() async {
//     try {
//       await ref.read(authViewModelProvider.notifier).signOut();
//       ref.invalidate(authViewModelProvider);
//     } catch (e) {
//       if (_isMounted) {
//         _showSnackBar('Logout failed: $e');
//       }
//     }
//   }
//
//   /// Online Game
//   Future<void> _joinOrCreateGame() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _showSnackBar('Please sign in first');
//         return;
//       }
//
//       final userModel = UserModel(
//         id: user.uid,
//         email: user.email ?? 'unknown@email.com',
//         photoUrl: user.photoURL,
//         wins: 0,
//         losses: 0,
//         draws: 0,
//       );
//
//       final gameRepository = ref.read(gameRepositoryProvider);
//       final gameId = await gameRepository.findOrCreateGame(userModel);
//
//       if (_isMounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
//         );
//       }
//     } catch (e) {
//       _showSnackBar('Error joining/creating game: $e');
//     }
//   }
//
//   /// Offline Game
//   Future<void> _startOfflineGame() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _showSnackBar('Please sign in first');
//         return;
//       }
//
//       final player1 = UserModel(
//         id: '${user.uid}_offline1',
//         email: user.email ?? 'player1@offline.com',
//         photoUrl: user.photoURL,
//         wins: 0,
//         losses: 0,
//         draws: 0,
//       );
//
//       final player2 = UserModel(
//         id: '${user.uid}_offline2',
//         email: 'player2@offline.com',
//         photoUrl: null,
//         wins: 0,
//         losses: 0,
//         draws: 0,
//       );
//
//       final gameRepository = ref.read(gameRepositoryProvider);
//
//       final gameId = await gameRepository.createOfflineGame(player1, player2);
//
//       if (_isMounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
//         );
//       }
//     } catch (e) {
//       _showSnackBar('Error starting offline game: $e');
//     }
//   }
//
//   void _navigateToLeaderboard() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final user = authState.user;
//
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Hello,',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 16,
//                           ),
//                         ),
//                         Text(
//                           user?.displayName ?? user?.email ?? 'Player',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.logout, color: Colors.white),
//                       onPressed: _handleSignOut,
//                       tooltip: 'Sign Out',
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Main content
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Column(
//                         children: [
//                           Icon(
//                             Icons.gamepad_rounded,
//                             size: 80,
//                             color: Colors.white,
//                           ),
//                           SizedBox(height: 10),
//                           Text(
//                             'Tic-Tac-Toe',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.5,
//                             ),
//                           ),
//                           SizedBox(height: 5),
//                           Text(
//                             'Classic Game, Modern Experience',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 60),
//
//                       // Online Game Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _joinOrCreateGame,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: const Color(0xFF6A11CB),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             elevation: 5,
//                             shadowColor: Colors.black.withOpacity(0.3),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.play_arrow_rounded),
//                               SizedBox(width: 10),
//                               Text(
//                                 'PLAY GAME',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Offline Game Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _startOfflineGame,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.white,
//                             foregroundColor: Colors.deepPurple,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             elevation: 5,
//                             shadowColor: Colors.black.withOpacity(0.3),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.smart_toy_rounded),
//                               SizedBox(width: 10),
//                               Text(
//                                 'OFFLINE GAME',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//
//                       // Leaderboard Button
//                       SizedBox(
//                         width: double.infinity,
//                         child: OutlinedButton(
//                           onPressed: _navigateToLeaderboard,
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.white,
//                             side: const BorderSide(
//                               color: Colors.white,
//                               width: 2,
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.leaderboard_rounded),
//                               SizedBox(width: 10),
//                               Text(
//                                 'VIEW LEADERBOARD',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/models/game_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../game/data/repositories/game_repository_impl.dart';
import '../../../game/presentation/screens/game_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (_isMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await ref.read(authViewModelProvider.notifier).signOut();
      ref.invalidate(authViewModelProvider);
    } catch (e) {
      if (_isMounted) {
        _showSnackBar('Logout failed: $e');
      }
    }
  }

  /// Online Game
  Future<void> _joinOrCreateGame() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('Please sign in first');
        return;
      }

      final userModel = UserModel(
        id: user.uid,
        email: user.email ?? 'unknown@email.com',
        displayName: user.displayName,
        photoUrl: user.photoURL,
        // wins: 0,
        // losses: 0,
        // draws: 0,
      );

      final gameRepository = ref.read(gameRepositoryProvider);
      final gameId = await gameRepository.findOrCreateGame(userModel);

      if (_isMounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameScreen(gameId: gameId)),
        );
      }
    } catch (e) {
      _showSnackBar('Error joining/creating game: $e');
    }
  }

  /// Offline Game
  Future<void> _startOfflineGame() async {
    try {
      // For offline game, we don't need to create anything in Firebase
      // Just navigate to the game screen with a special flag
      if (_isMounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const GameScreen(gameId: 'offline', isOffline: true),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Error starting offline game: $e');
    }
  }

  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          user?.displayName ?? user?.email ?? 'OnLine Mode',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // adds "..."
                          maxLines: 1, // keeps it single line
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _handleSignOut,
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Column(
                        children: [
                          Icon(
                            Icons.gamepad_rounded,
                            size: 80,
                            color: Colors.white,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tic-Tac-Toe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Classic Game, Modern Experience',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),

                      // Online Game Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _joinOrCreateGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6A11CB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.online_prediction_rounded),
                              SizedBox(width: 10),
                              Text(
                                'PLAY ONLINE',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Offline Game Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startOfflineGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_alt_rounded),
                              SizedBox(width: 10),
                              Text(
                                'PLAY OFFLINE',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Leaderboard Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _navigateToLeaderboard,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.leaderboard_rounded),
                              SizedBox(width: 10),
                              Text(
                                'VIEW LEADERBOARD',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
