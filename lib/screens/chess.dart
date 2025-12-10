import 'package:chesster/help/cache_query.dart';
import 'package:chesster/models/chess.dart';
import 'package:chesster/widgets/chessboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key, required this.gameRef});

  final DocumentReference<Map<String, Object?>> gameRef;

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  late final Future<DocumentSnapshot<Map<String, Object?>>> gameFuture;
  late final Stream<DocumentSnapshot> gameStream;
  late final ChessGame game;

  @override
  void initState() {
    super.initState();
    gameFuture = queryCache(widget.gameRef);
    // game = ChessGame.fromJson(g.data()!);
    // gameStream = widget.gameDoc.snapshots();
    // gameStream.listen((snapshot) {
    //   print(snapshot.data());
    // });
  }

  void chooseColors() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chesster"),
        // actions: [
        // ],
      ),
      body: FutureBuilder(
          future: gameFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                game = ChessGame.fromJson(snapshot.requireData.data()!);
                gameStream = widget.gameRef.snapshots();
                break;
            }
            return GestureDetector(
              child: StreamBuilder(
                  stream: gameStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    final gameData = snapshot.requireData.data()!;
                    print(gameData);
                    // if (game == null) {
                    //   game = ChessGame(creator)
                    // }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                Chessboard(game: game),
                                if (game.creatorIsWhite == null)
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: chooseColors,
                                      label: const Text('Flip the coin!'),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          const Spacer()
                        ],
                      ),
                    );
                  }),
            );
          }),
    );
  }
}
