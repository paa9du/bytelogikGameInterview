// lib/core/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int wins;
  final int losses;
  final int draws;

  int get totalGames => wins + losses + draws;
  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    // this.totalGames = 0,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      // 'totalGames': totalGames,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      draws: json['draws'] ?? 0,
      // totalGames: json['totalGames'] ?? 0,
    );
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    int? wins,
    int? losses,
    int? draws,
    int? totalGames,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      // totalGames: totalGames ?? this.totalGames,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
