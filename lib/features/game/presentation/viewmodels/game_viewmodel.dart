// lib/features/game/presentation/viewmodels/game_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/game_model.dart';
import '../../data/repositories/game_repository_impl.dart';


final gameViewModelProvider = StateNotifierProvider.autoDispose
    .family<GameViewModel, AsyncValue<GameModel?>, String>((ref, gameId) {
  return GameViewModel(ref.read(gameRepositoryProvider), gameId);
});

class GameViewModel extends StateNotifier<AsyncValue<GameModel?>> {
  final GameRepository _repository;
  final String _gameId;

  GameViewModel(this._repository, this._gameId) : super(const AsyncLoading()) {
    _watchGame();
  }

  void _watchGame() {
    _repository.watchGame(_gameId).listen((game) {
      state = AsyncData(game);
    }, onError: (error, stack) {
      state = AsyncError(error, stack);
    });
  }

  Future<void> makeMove(int index, String playerId) async {
    try {
      await _repository.makeMove(_gameId, index, playerId);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}