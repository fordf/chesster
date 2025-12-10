import 'package:chesster/models/chess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chessboard extends StatefulWidget {
  const Chessboard({super.key, required this.game});

  final ChessGame game;

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

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // reverse: true,
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
          onWillAcceptWithDetails: (DragTargetDetails<Piece> details) {
            final piece = details.data;
            final canMove = widget.game.canMove(piece, i);
            setState(() {
              dragColor = canMove ? Colors.white : Colors.red;
              draggingIndex = i;
            });
            return canMove;
          },
          onAcceptWithDetails: (DragTargetDetails<Piece> details) {
            setState(() {
              widget.game.move(details.data, i);
            });
          },
          builder: (ctx, candidateData, rejectedData) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: draggingIndex == i ? dragColor : Colors.black,
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
              child: widget.game.indexesMap.containsKey(i)
                  ? widget.game.indexesMap[i]
                  : null,
            );
          },
        ),
      ),
    );
  }
}
