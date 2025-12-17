import 'package:chesster/models/move.dart';
import 'package:chesster/widgets/chesspiece.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ChessColor { black, white }

enum Rank {
  king(startingColumns: [4]),
  queen(startingColumns: [3]),
  rook(startingColumns: [0, 7]),
  bishop(startingColumns: [2, 5]),
  knight(startingColumns: [1, 6]),
  pawn(startingColumns: []);

  const Rank({required this.startingColumns});

  final List<int> startingColumns;
}

typedef Position = (int x, int y);

class Piece {
  Piece(this.rank, this.position, this.color);
  Piece.pawn(this.position, this.color) : rank = Rank.pawn;
  Piece.fromIndexes({
    required int positionIndex,
    required int rankIndex,
    required int colorIndex,
  })  : rank = Rank.values[rankIndex],
        color = ChessColor.values[colorIndex],
        position = toPosition(positionIndex);

  Map<String, Object?> get toJson => {'rank': rank.index, 'color': color.index};

  Rank rank;
  Position position;
  final ChessColor color;

  int get positionIndex => toIndex(position);
}

class ChessGame {
  final List<Move> moves = [];
  final String creator;
  String? opponent;
  bool? creatorIsWhite;
  bool complete = false;
  final Map<int, ChessPiece> indexesMap;

  ChessGame(this.creator)
      : indexesMap = <int, ChessPiece>{
          for (final piece in startingPieces)
            piece.positionIndex: ChessPiece(piece: piece)
        };

  ChessGame.fromJson(Map<String, Object?> json)
      : creator = json['creator']! as String,
        complete = json['complete']! as bool,
        opponent = json['opponent'] as String?,
        creatorIsWhite = json['creatorIsWhite'] as bool?,
        indexesMap = <int, ChessPiece>{
          for (final (piecemap as Map<String, Object?>)
              in (json['pieces']! as List))
            piecemap['position'] as int: ChessPiece(
              piece: Piece.fromIndexes(
                positionIndex: piecemap['position']! as int,
                colorIndex: piecemap['color']! as int,
                rankIndex: piecemap['rank']! as int,
              ),
            ),
        };

  Map<String, Object?> get toJson => {
        'complete': complete,
        'creator': creator,
        'opponent': opponent,
        'creatorIsWhite': creatorIsWhite,
        // 'pieces': <Map<String, Object?>>[
        //   for (final chessPiece in indexesMap.values) chessPiece.piece.toJson
        // ],
      };

  void move(Piece piece, int endIndex) {
    if (indexesMap.containsKey(endIndex) &&
        indexesMap[endIndex]!.piece.rank == Rank.king) {
      complete = true;
    }
    final chessPiece = indexesMap[piece.positionIndex]!;
    indexesMap[endIndex] = chessPiece;
    indexesMap.remove(piece.positionIndex);
    moves.add(Move.withPiece(piece: piece, endIndex: endIndex));
    chessPiece.piece.position = toPosition(endIndex);
    if (chessPiece.piece.rank == Rank.pawn &&
        chessPiece.piece.position.$2 ==
            (chessPiece.piece.color == ChessColor.white ? 7 : 0)) {
      chessPiece.piece.rank = Rank.queen;
    }
  }

  // ChessColor get turn =>
  //     moves.length % 2 == 0 ? ChessColor.white : ChessColor.black;

  // List<Map> get serializedMoves => [for (final move in moves) move.serialize];

  // List<Piece> get serializedPieces => [
  //   for (final piece in indexesMap.values)
  //     piece.piece.serialized
  // ];

  bool canMove(Piece piece, int endIndex) {
    final positionTaken = indexesMap.containsKey(endIndex);
    if (positionTaken && indexesMap[endIndex]!.piece.color == piece.color) {
      return false;
    }
    final (x1, y1) = piece.position;
    final (x2, y2) = toPosition(endIndex);
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

// final chessGameCollection =
//     FirebaseFirestore.instance.collection('games').withConverter<ChessGame>(
//           fromFirestore: (snapshot, _) => ChessGame.fromJson(snapshot.data()!),
//           toFirestore: (game, _) => game.toJson,
//         );
