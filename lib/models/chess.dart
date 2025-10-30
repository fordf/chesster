import 'dart:ui';

final startingPieces = [
  for (var rank in Rank.values)
    for (var column in rank.startingColumns)
      Piece(rank, (column, 0), ChessColor.white),
  for (var rank in Rank.values)
    for (var column in rank.startingColumns)
      Piece(rank, (column, 7), ChessColor.black),
  for (var i = 0; i < 8; i++) Piece.pawn((i, 1), ChessColor.white),
  for (var i = 0; i < 8; i++) Piece.pawn((i, 6), ChessColor.black),
];

class ChessGame {
  ChessGame() : pieces = startingPieces;

  List<Piece> pieces;
}

class Piece {
  Piece(this.rank, this.position, this.color);
  Piece.pawn(this.position, this.color) : rank = Rank.pawn;

  Rank rank;
  Position position;
  final ChessColor color;
}

class Sprite {
  Sprite(this.index, this.position);
  int index;
  Offset position;
}

typedef Position = (int x, int y);

enum ChessColor { black, white }

enum Rank {
  king(startingColumns: [4]),
  queen(startingColumns: [3]),
  rook(startingColumns: [0, 7]),
  bishop(startingColumns: [2, 5]),
  knight(startingColumns: [1, 6]),
  pawn(
    startingColumns: [],
  );

  const Rank({required this.startingColumns});

  final List<int> startingColumns;
}
