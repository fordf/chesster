import 'package:chesster/models/move.dart';
import 'package:chesster/widgets/chesspiece.dart';

enum ChessColor { black, white }

enum ChoosingChoice {
  black,
  white,
  coinflip,
}

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
  Rank rank;
  int position;
  final String id;
  final ChessColor color;

  Piece(this.rank, this.position, this.color) : id = position.toString();
  Piece.pawn(this.position, this.color)
      : rank = Rank.pawn,
        id = position.toString();
  Piece.fromIndexes({
    required int positionIndex,
    required int rankIndex,
    required int colorIndex,
  })  : rank = Rank.values[rankIndex],
        color = ChessColor.values[colorIndex],
        position = positionIndex,
        id = positionIndex.toString();

  Piece.fromJson(Map<String, Object?> json, this.id)
      : rank = Rank.values[json['rank'] as int],
        color = ChessColor.values[json['color'] as int],
        position = json['pos'] as int;

  Map<String, Object?> get toJson => {
        'rank': rank.index,
        'color': color.index,
        'pos': position,
      };

  // int get positionIndex => toIndex(position);
}

class ChessGame {
  final List<Move> moves = [];
  int turn = 0;
  final String creator;
  String? opponent;
  ChoosingChoice? creatorChoice;
  ChoosingChoice? opponentChoice;
  bool? creatorIsWhite;
  bool complete = false;
  // late final Map<int, ChessPiecePic> piecesMap;

  ChessGame(this.creator);
  // : piecesMap = <int, ChessPiecePic>{
  //     for (final piece in startingPieces)
  //       piece.position: ChessPiecePic(piece: piece)
  //   };

  ChessGame.fromJson(Map<String, Object?> json)
      : creator = json['creator']! as String,
        complete = json['complete']! as bool,
        opponent = json['opponent'] as String?,
        turn = json['turn'] as int,
        creatorChoice = json['creatorChoice'] == null
            ? null
            : ChoosingChoice.values[json['creatorChoice'] as int],
        opponentChoice = json['opponentChoice'] == null
            ? null
            : ChoosingChoice.values[json['opponentChoice'] as int],
        creatorIsWhite = json['creatorIsWhite'] as bool?;

  // void setInitialPieces() {
  //   piecesMap = <int, ChessPiecePic>{
  //     for (final piece in startingPieces)
  //       piece.position: ChessPiecePic(piece: piece)
  //   };
  // }

  // void setPiecesMap(Map<int, Map<String, dynamic>> json) {
  //   piecesMap = {
  //     for (final MapEntry(key: index, value: piecemap) in json.entries)
  //       index: ChessPiecePic(
  //         piece: Piece.fromIndexes(
  //           positionIndex: index,
  //           rankIndex: piecemap['rank']!,
  //           colorIndex: piecemap['color']!,
  //         ),
  //       )
  //   };
  // }

  // void setPiece(Piece piece) {
  //   piecesMap[int.parse(piece.id)] = ChessPiecePic(piece: piece);
  // }

  Map<String, Object?> get toJson => {
        'complete': complete,
        'creator': creator,
        'opponent': opponent,
        'turn': turn,
        'creatorIsWhite': creatorIsWhite,
        'creatorChoice': creatorChoice == null
            ? null
            : ChoosingChoice.values.indexOf(creatorChoice!),
        'opponentChoice': opponentChoice == null
            ? null
            : ChoosingChoice.values.indexOf(opponentChoice!),
      };

  // void move(Piece piece, int endIndex) {
  //   if (piecesMap.containsKey(endIndex) &&
  //       piecesMap[endIndex]!.piece.rank == Rank.king) {
  //     complete = true;
  //   }
  //   final chessPiece = piecesMap[piece.position]!;
  //   chessPiece.piece.position = endIndex;
  //   piecesMap[endIndex] = chessPiece;
  //   piecesMap.remove(piece.position);
  //   moves.add(Move.withPiece(piece: piece, endIndex: endIndex));
  //   turn += 1;
  //   final (int x, int y) = toPosition(chessPiece.piece.position);
  //   if (chessPiece.piece.rank == Rank.pawn &&
  //       y == (chessPiece.piece.color == ChessColor.white ? 7 : 0)) {
  //     chessPiece.piece.rank = Rank.queen;
  //   }
  // }

  // ChessColor get turns =>
  //     moves.length % 2 == 0 ? ChessColor.white : ChessColor.black;

  // List<Map> get serializedMoves => [for (final move in moves) move.serialize];

  // List<Piece> get serializedPieces => [
  //   for (final piece in piecesMap.values)
  //     piece.piece.serialized
  // ];

  ChessColor get turnColor =>
      turn % 2 == 0 ? ChessColor.white : ChessColor.black;

  bool canMove(Piece piece, int endIndex, Piece? takenPiece) {
    print('turn $turn');
    if (turn % 2 == 0 && piece.color == ChessColor.black) return false;
    if (takenPiece != null && takenPiece.color == piece.color) {
      return false;
    }
    final (x1, y1) = toCoords(piece.position);
    final (x2, y2) = toCoords(endIndex);
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
        if (takenPiece != null) {
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

Position toCoords(int index) {
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
      Piece(rank, toIndex((column, 0)), ChessColor.white),
  for (var rank in Rank.values)
    for (var column in rank.startingColumns)
      Piece(rank, toIndex((column, 7)), ChessColor.black),
  for (var i = 0; i < 8; i++) Piece.pawn(toIndex((i, 1)), ChessColor.white),
  for (var i = 0; i < 8; i++) Piece.pawn(toIndex((i, 6)), ChessColor.black),
];

// final chessGameCollection =
//     FirebaseFirestore.instance.collection('games').withConverter<ChessGame>(
//           fromFirestore: (snapshot, _) => ChessGame.fromJson(snapshot.data()!),
//           toFirestore: (game, _) => game.toJson,
//         );
