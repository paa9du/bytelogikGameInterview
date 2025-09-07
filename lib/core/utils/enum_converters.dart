// lib/core/utils/enum_converters.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/game_model.dart';

class GameStatusConverter implements JsonConverter<GameStatus, String> {
  const GameStatusConverter();

  @override
  GameStatus fromJson(String json) {
    switch (json) {
      case 'waiting':
        return GameStatus.waiting;
      case 'playing':
        return GameStatus.playing;
      case 'finished':
        return GameStatus.finished;
      case 'abandoned':
        return GameStatus.abandoned;
      default:
        return GameStatus.waiting;
    }
  }

  @override
  String toJson(GameStatus object) {
    return object.toString().split('.').last;
  }
}

class PlayerSymbolConverter implements JsonConverter<PlayerSymbol, String> {
  const PlayerSymbolConverter();

  @override
  PlayerSymbol fromJson(String json) {
    switch (json) {
      case 'x':
        return PlayerSymbol.x;
      case 'o':
        return PlayerSymbol.o;
      default:
        return PlayerSymbol.x;
    }
  }

  @override
  String toJson(PlayerSymbol object) {
    return object.toString().split('.').last;
  }
}