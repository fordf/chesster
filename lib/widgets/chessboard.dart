import 'package:chesster/models/chess.dart';
import 'package:chesster/widgets/chesspiece.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class Chessboard extends StatefulWidget {
  const Chessboard({
    super.key,
    required this.game,
    required this.gameRef,
    required this.userDoc,
    required this.userColor,
    // required this.onMove,
    required this.turnColor,
    required this.piecesStream,
  });

  final ChessGame game;
  final ChessColor turnColor;
  // final void Function() onMove;
  final ChessColor userColor;
  final DocumentReference<Map<String, Object?>> gameRef;
  final DocumentSnapshot<Map<String, Object?>> userDoc;
  final Stream<QuerySnapshot<Map<String, dynamic>>> piecesStream;

  @override
  State<Chessboard> createState() => _ChessboardState();
}

// Map<String, (int, int)> sendMove(ChessColor color, startIndex, destIndex) {
//   return {color.name: (startIndex, destIndex)};
// }

// Map<String, dynamic> serializeGame(int id, ChessGame game) {
//   return {'id': id, 'moves': game.serializedMoves};
// }

class _ChessboardState extends State<Chessboard> {
  int? draggingIndex;
  Color dragColor = Colors.white;
  late final ChessGame game;
  final Map<int, Piece> piecesMap = {};

  @override
  void initState() {
    super.initState();
    game = widget.game;
  }

  void move(Piece piece, int newIndex) async {
    final gameUpdate = {
      'turn': FieldValue.increment(1),
      if (piecesMap.containsKey(newIndex) &&
          piecesMap[newIndex]!.rank == Rank.king)
        'complete': true,
    };
    final (int x, int y) = toCoords(piece.position);
    final pieceUpdate = {
      'pos': newIndex,
      if (piece.rank == Rank.pawn &&
          y == (piece.color == ChessColor.white ? 7 : 0))
        'rank': Rank.queen.index,
    };
    DocumentReference? removeDoc;
    if (piecesMap.containsKey(newIndex)) {
      removeDoc =
          widget.gameRef.collection('pieces').doc(piecesMap[newIndex]!.id);
    }
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(
          widget.gameRef.collection('pieces').doc(piece.id),
          pieceUpdate,
        );
        transaction.update(
          widget.gameRef,
          gameUpdate,
        );
        if (removeDoc != null) {
          transaction.delete(removeDoc);
        }
      });
    } on FirebaseException catch (e) {
      print(e.message);
      // setState(() {
      //   widget.game.move(piece, oldIndex);
      // });
    }
    // widget.onMove();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.piecesStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.done:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }
              final pieceDocs = snapshot.data!.docChanges;
              print('numchanges');
              print(pieceDocs.length);
              for (final pieceDoc in pieceDocs) {
                // print(pieceDoc.type);
                // print(pieceDoc.doc.id);
                // print(pieceDoc.doc.data());
                // if (pieceDoc.type == DocumentChangeType.modified) {

                // }
                piecesMap.removeWhere(
                  (key, pieceVal) => pieceVal.id == pieceDoc.doc.id,
                );
                final piece = Piece.fromJson(
                  pieceDoc.doc.data()!,
                  pieceDoc.doc.id,
                );
                piecesMap[piece.position] = piece;
              }
              return GridView.count(
                reverse: widget.userColor == ChessColor.white,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 8,
                children: List.generate(
                  64,
                  (i) => DragTarget(
                    // onMove: (DragTargetDetails<Piece> details) {
                    //   final piece = details.data;
                    //   setState(() {
                    //     draggingIndex = i;
                    //   });
                    // },
                    onWillAcceptWithDetails:
                        (DragTargetDetails<Piece> details) {
                      final piece = details.data;
                      final canMove =
                          widget.game.canMove(piece, i, piecesMap[i]);
                      setState(() {
                        dragColor = canMove ? Colors.white : Colors.red;
                        draggingIndex = i;
                      });
                      return canMove;
                    },
                    onAcceptWithDetails: (DragTargetDetails<Piece> details) {
                      setState(() {
                        move(details.data, i);
                      });
                    },
                    builder: (ctx, candidateData, rejectedData) {
                      final hasPiece = piecesMap.containsKey(i);
                      Widget? pieceWidget;
                      if (hasPiece) {
                        final piecePic = ChessPiecePic(piece: piecesMap[i]!);
                        pieceWidget = piecePic.piece.color == widget.userColor
                            ? Draggable(
                                maxSimultaneousDrags:
                                    widget.turnColor == widget.userColor
                                        ? 1
                                        : 0,
                                childWhenDragging: Container(),
                                data: piecePic.piece,
                                feedback: piecePic,
                                child: piecePic,
                              )
                            : piecePic;
                      }
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                draggingIndex == i ? dragColor : Colors.black,
                          ),
                          gradient: (i + i ~/ 8) % 2 == 0
                              ? const RadialGradient(
                                  colors: [
                                    Color.fromARGB(255, 236, 233, 209),
                                    Color.fromARGB(255, 194, 185, 153),
                                  ],
                                )
                              : const RadialGradient(colors: [
                                  Color.fromARGB(255, 127, 104, 96),
                                  Color.fromARGB(255, 86, 49, 34)
                                ]),
                        ),
                        child: pieceWidget,
                      );
                    },
                  ),
                ),
              );
          }
        });
  }
}
