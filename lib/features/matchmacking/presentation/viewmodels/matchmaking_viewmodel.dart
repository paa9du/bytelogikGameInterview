// lib/features/matchmaking/presentation/viewmodels/matchmaking_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/game_model.dart';
import '../../data/repositories/matchmaking_repository_impl.dart';

final matchmakingViewModelProvider = StateNotifierProvider<MatchmakingViewModel, MatchmakingState>((ref) {
  return MatchmakingViewModel(ref.read(matchmakingRepositoryProvider));
});

class MatchmakingState {
  final bool isLoading;
  final String? error;
  final List<GameModel> availableGames;

  MatchmakingState({
    this.isLoading = false,
    this.error,
    this.availableGames = const [],
  });

  MatchmakingState copyWith({
    bool? isLoading,
    String? error,
    List<GameModel>? availableGames,
  }) {
    return MatchmakingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      availableGames: availableGames ?? this.availableGames,
    );
  }
}

class MatchmakingViewModel extends StateNotifier<MatchmakingState> {
  final MatchmakingRepository _repository;

  MatchmakingViewModel(this._repository) : super(MatchmakingState());

  Future<void> loadAvailableGames() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Implementation would watch available games stream
      // For now, we'll simulate loading
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false, availableGames: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> findQuickGame() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Implementation would create or join a game
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> joinGame(String gameId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Implementation would join the game
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}