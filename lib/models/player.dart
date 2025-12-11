class Player {
  int gamesPlayed;
  int gamesWon;
  String username;
  final List<String> games;
  final List<String> invites;
  String? imageUrl;
  final String email;

  Player({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    required this.username,
    required this.email,
    this.imageUrl,
  })  : games = <String>[],
        invites = <String>[];

  Player.fromJson(Map<String, Object?> json)
      : gamesPlayed = json['gamesPlayed']! as int,
        gamesWon = json['gamesWon']! as int,
        username = json['username']! as String,
        imageUrl = json['imageUrl'] as String?,
        email = json['email']! as String,
        games = json['games']! as List<String>,
        invites = json['invites']! as List<String>;

  Map<String, Object?> get toJson => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'username': username,
        'games': games,
        'invites': invites,
        'email': email,
        'imageUrl': imageUrl,
      };
}
