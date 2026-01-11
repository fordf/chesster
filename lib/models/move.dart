import 'package:chesster/models/chess.dart';

class Move {
  final Rank rank;
  final ChessColor color;
  final int startIndex;
  final int endIndex;

  const Move({
    required this.color,
    required this.rank,
    required this.startIndex,
    required this.endIndex,
  });

  Move.withPiece({required Piece piece, required this.endIndex})
      : rank = piece.rank,
        color = piece.color,
        startIndex = piece.position;

  Move.fromMap(Map<String, dynamic> map)
      : rank = map['rank'],
        color = map['color'],
        startIndex = map['start'],
        endIndex = map['end'];

  Map<String, dynamic> get serialize => {
        'rank': rank,
        'color': color,
        'start': startIndex,
        'end': endIndex,
      };
}
