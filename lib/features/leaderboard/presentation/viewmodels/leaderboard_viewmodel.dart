// lib/features/leaderboard/presentation/viewmodels/leaderboard_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../data/repositories/leaderboard_repository_impl.dart';

final leaderboardViewModelProvider = StateNotifierProvider<LeaderboardViewModel, LeaderboardState>((ref) {
  return LeaderboardViewModel(ref.read(leaderboardRepositoryProvider));
});

class LeaderboardState {
  final bool isLoading;
  final String? error;
  final List<UserModel> players;

  LeaderboardState({
    this.isLoading = false,
    this.error,
    this.players = const [],
  });

  LeaderboardState copyWith({
    bool? isLoading,
    String? error,
    List<UserModel>? players,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      players: players ?? this.players,
    );
  }
}

class LeaderboardViewModel extends StateNotifier<LeaderboardState> {
  final LeaderboardRepository _repository;

  LeaderboardViewModel(this._repository) : super(LeaderboardState());

  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Implementation would load leaderboard data
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false, players: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}