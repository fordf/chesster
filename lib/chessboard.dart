import 'package:chesster/help/io.dart';
import 'package:chesster/models/chess.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

const atlasAsset = "assets/Chess_Pieces_Sprite.svg";
const atlasWidth = 270;
const atlasHeight = 90;
const atlasTile = 45;

final pictureRecorder = ui.PictureRecorder();
final canvas = Canvas(pictureRecorder);

class Chessboard extends StatefulWidget {
  const Chessboard({super.key});

  @override
  State<Chessboard> createState() => _ChessboardState();
}

class _ChessboardState extends State<Chessboard> {
  late final ui.Image atlas;
  final ChessGame game = ChessGame();

  @override
  void dispose() {
    atlas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileScale = screenWidth / 8;

    final atlasFuture = uiimage();

    return FutureBuilder(
      future: atlasFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Chesster"),
              // actions: [
              // ],
            ),
            body: GestureDetector(
              child: CustomPaint(
                foregroundPainter:
                    ChessPainter(snapshot.requireData, game, tileScale),
                size: Size.infinite,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 8,
                  children: List.generate(
                    64,
                    (i) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        gradient: (i + i ~/ 8) % 2 == 0
                            ? const RadialGradient(
                                colors: [
                                  Color.fromARGB(255, 236, 233, 209),
                                  Color.fromARGB(255, 194, 185, 153),
                                ],
                              )
                            : const RadialGradient(colors: [
                                Color.fromARGB(255, 211, 176, 164),
                                Color.fromARGB(255, 86, 49, 34)
                              ]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return const Center(
          child: Text('uh oh'),
        );
      },
    );
  }
}

class ChessPainter extends CustomPainter {
  ChessPainter(this.atlas, this.game, this.tileScale);

  final ui.Image atlas;
  final ChessGame game;
  final double tileScale;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawAtlas(
      atlas,
      // <RSTransform>[
      //   RSTransform.fromComponents(
      //     rotation: 0,
      //     scale: 1,
      //     anchorX: (atlasWidth / 2.0),
      //     anchorY: (atlasHeight / 2.0),
      //     translateX: atlasWidth / 2.0,
      //     translateY: atlasHeight / 2.0,
      //   )
      // ],
      // <Rect>[
      //   Rect.fromLTWH(
      //     0,
      //     0,
      //     atlasWidth.toDouble(),
      //     atlasHeight.toDouble(),
      //   )
      // ],
      <RSTransform>[
        for (final piece in game.pieces)
          RSTransform.fromComponents(
            rotation: 0,
            scale: 1,
            anchorX: atlasTile / 2.0,
            anchorY: atlasTile / 2.0,
            translateX: piece.position.$1 * tileScale + (tileScale / 2.0),
            translateY: piece.position.$2 * tileScale + (tileScale / 2.0),
          )
      ],
      <Rect>[
        for (final piece in game.pieces)
          Rect.fromLTWH(
            (atlasTile * piece.rank.index).toDouble(),
            (piece.color == ChessColor.white ? 0 : atlasTile).toDouble(),
            atlasTile.toDouble(),
            atlasTile.toDouble(),
          )
      ],
      null,
      null,
      null,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
