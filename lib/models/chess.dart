import 'dart:ui';
import 'dart:math';

import 'package:chesster/widgets/chesspiece.dart';

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
  ChessGame()
      : indexesMap = <int, ChessPiece>{
          for (final piece in startingPieces)
            piece.positionIndex: ChessPiece(piece: piece)
        };

  final Map<int, ChessPiece> indexesMap;

  void move(Piece piece, int destinationIndex) {
    // final positionTaken = indexesMap.containsKey(destinationIndex);
    final chessPiece = indexesMap[piece.positionIndex]!;
    indexesMap[destinationIndex] = chessPiece;
    indexesMap.remove(chessPiece.piece.positionIndex);
    chessPiece.piece.position = toPosition(destinationIndex);
  }

  bool canMove(Piece piece, int destinationIndex) {
    final positionTaken = indexesMap.containsKey(destinationIndex);
    if (positionTaken &&
        indexesMap[destinationIndex]!.piece.color == piece.color) return false;
    final (x1, y1) = piece.position;
    final (x2, y2) = toPosition(destinationIndex);
    final isForward = piece.color == ChessColor.white ? y2 > y1 : y2 < y1;
    final dx = (x2 - x1).abs();
    final dy = (y2 - y1).abs();
    switch (piece.rank) {
      case Rank.king:
        return dx < 2 && dy < 2;
      case Rank.queen:
        return isDiagonal(dx, dy) || isStraight(dx, dy);
      case Rank.rook:
        return isStraight(dx, dy);
      case Rank.bishop:
        return isDiagonal(dx, dy);
      case Rank.knight:
        return isLShape(dx, dy);
      case Rank.pawn:
        if (!isForward) return false;
        if (positionTaken) {
          return dx == 1 && dy == 1;
        }
        if (dx != 0) return false;
        if (y1 == 1 || y1 == 6) {
          return dy < 3;
        }
        return dy < 2;
    }
  }
}

class Piece {
  Piece(this.rank, this.position, this.color);
  Piece.pawn(this.position, this.color) : rank = Rank.pawn;

  Rank rank;
  Position position;
  final ChessColor color;

  int get positionIndex => toIndex(position);
}

class Sprite {
  Sprite(this.index, this.position);
  int index;
  Offset position;
}

typedef Position = (int x, int y);

enum ChessColor { black, white }

enum Rank {
  king(startingColumns: [4], canMove: pawnCanMove),
  queen(startingColumns: [3], canMove: pawnCanMove),
  rook(startingColumns: [0, 7], canMove: pawnCanMove),
  bishop(startingColumns: [2, 5], canMove: pawnCanMove),
  knight(startingColumns: [1, 6], canMove: pawnCanMove),
  pawn(startingColumns: [], canMove: pawnCanMove);

  const Rank({required this.startingColumns, required this.canMove});

  final List<int> startingColumns;
  final Function(Position, Position, ChessGame) canMove;
}

bool pawnCanMove(Position a, Position b, ChessGame game) {
  final (x1, y1) = a;
  final (x2, y2) = b;

  return true;
}

int toIndex(Position position) {
  final (x, y) = position;
  return x + (8 * y);
}

Position toPosition(int index) {
  final y = index ~/ 8;
  final x = index % 8;
  return (x, y);
}

bool isDiagonal(int dx, int dy) => dx == dy;
bool isStraight(int dx, int dy) => dx == 0 || dy == 0;
bool isLShape(int dx, int dy) => (dx, dy) == (1, 2) || (dx, dy) == (2, 1);
