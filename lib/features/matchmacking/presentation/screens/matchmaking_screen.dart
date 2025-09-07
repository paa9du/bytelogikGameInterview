// lib/features/matchmaking/presentation/screens/matchmaking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../viewmodels/matchmaking_viewmodel.dart';

class MatchmakingScreen extends ConsumerStatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  ConsumerState<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends ConsumerState<MatchmakingScreen> {
  @override
  void initState() {
    super.initState();
    // Start looking for games when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchmakingViewModelProvider.notifier).loadAvailableGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchmakingState = ref.watch(matchmakingViewModelProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Opponent'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Quick Play Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: matchmakingState.isLoading
                    ? null
                    : () => ref
                          .read(matchmakingViewModelProvider.notifier)
                          .findQuickGame(),
                child: matchmakingState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Quick Play', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // Available Games List
            Expanded(
              child: matchmakingState.availableGames.isEmpty
                  ? const Center(child: Text('No available games found'))
                  : ListView.builder(
                      itemCount: matchmakingState.availableGames.length,
                      itemBuilder: (context, index) {
                        final game = matchmakingState.availableGames[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.gamepad),
                            title: Text('Game by ${game.player1.email}'),
                            subtitle: Text(
                              'Waiting for opponent...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => ref
                                  .read(matchmakingViewModelProvider.notifier)
                                  .joinGame(game.id),
                              child: const Text('Join'),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Status Indicators
            if (matchmakingState.isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            if (matchmakingState.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  matchmakingState.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
