import 'package:chesster/models/chess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

String getAssetPath(Rank rank, ChessColor color) =>
    'assets/chess_pieces/${rank.name}_${color.name}.svg';

class ChessPiece extends StatelessWidget {
  const ChessPiece({
    super.key,
    required this.piece,
  });
  final Piece piece;

  @override
  Widget build(BuildContext context) => Draggable(
        childWhenDragging: Container(),
        data: piece,
        feedback: this,
        child: SvgPicture.asset(
          getAssetPath(piece.rank, piece.color),
          semanticsLabel: piece.rank.name,
        ),
      );
}
