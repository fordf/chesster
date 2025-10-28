import 'package:chesster/help/io.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

const atlasAsset = "assets/Chess_Pieces_Sprite.svg";
// final atlasWidget = svgWidget();
final pictureRecorder = ui.PictureRecorder();
final canvas = Canvas(pictureRecorder);

class Piece {}

class Chessboard extends StatefulWidget {
  const Chessboard({super.key});

  @override
  State<Chessboard> createState() => _ChessboardState();
}

class _ChessboardState extends State<Chessboard> {
  late final ui.Image atlas;

  @override
  Widget build(BuildContext context) {
    final atlasFuture = uiimage();
    return FutureBuilder(
      future: atlasFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Center(
          child: CustomPaint(
            painter: ChessPainter(
              snapshot.requireData,
            ),
          ),
        );
      },
    );
  }
}

class ChessPainter extends CustomPainter {
  ChessPainter(this.atlas);

  final ui.Image atlas;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawAtlas(
        atlas,
        <RSTransform>[
          for (var i = 0; i < 12; i++)
            RSTransform.fromComponents(
              rotation: 0,
              scale: 1,
              anchorX: 22.5,
              anchorY: 22.5,
              translateX: 0,
              translateY: 0,
            )
        ],
        <Rect>[
          for (var i = 0; i < 12; i++)
            Rect.fromLTWH(45.0 * i, i < 6 ? 0 : 45, 45, 45)
        ],
        null,
        null,
        null,
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
