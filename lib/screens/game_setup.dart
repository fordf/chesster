import 'dart:math';

import 'package:chesster/models/chess.dart';
import 'package:chesster/widgets/chess_color_chooser.dart';
import 'package:chesster/widgets/chessboard.dart';
import 'package:chesster/widgets/chesspiece.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class ChessSetupScreen extends StatefulWidget {
  const ChessSetupScreen({
    super.key,
    required this.gameRef,
    required this.userDoc,
  });

  final DocumentReference<Map<String, Object?>> gameRef;
  final DocumentSnapshot<Map<String, Object?>> userDoc;

  @override
  State<ChessSetupScreen> createState() => _ChessSetupScreenState();
}

class _ChessSetupScreenState extends State<ChessSetupScreen> {
  late final Future<void> gameFuture;
  late final Stream<DocumentSnapshot> gameStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> piecesStream;
  late ChessGame game;
  late final bool userIsCreator;
  // late final Map<int, ChessPiecePic> piecesMap;
  ChessColor turnColor = ChessColor.white;
  late final ChessColor userColor;

  // void move() {
  //   setState(() {
  //     turnColor =
  //         turnColor == ChessColor.white ? ChessColor.black : ChessColor.white;
  //   });
  // }

  Future<void> getGame() async {
    final gameDoc = await widget.gameRef.get();
    // final piecesCollection = await widget.gameRef.collection('pieces').get();
    // piecesMap = {
    //   for (final x in piecesCollection.docs)
    //     int.parse(x.id): ChessPiecePic(
    //       piece: Piece.fromJson(x.data(), x.id),
    //     )
    // };
    final data = gameDoc.data();
    game = ChessGame.fromJson(gameDoc.data()!);
    userIsCreator = game.creator == (widget.userDoc.get('username') as String);
  }

  Future<bool> wantsChoosingChoice(ChoosingChoice? choice) async {
    if ((userIsCreator ? game.creatorChoice : game.opponentChoice) == choice) {
      choice = null;
    }
    final (cChoice, oChoice) = userIsCreator
        ? (choice, game.opponentChoice)
        : (game.creatorChoice, choice);
    final update = <String, Object?>{};
    if ({cChoice, oChoice}
        .containsAll([ChoosingChoice.white, ChoosingChoice.black])) {
      update['creatorIsWhite'] = cChoice == ChoosingChoice.white;
    } else if (cChoice == ChoosingChoice.coinflip &&
        oChoice == ChoosingChoice.coinflip) {
      final creatorIsWhite = Random().nextBool();
      update['creatorIsWhite'] = creatorIsWhite;
    }
    final choiceField = userIsCreator ? 'creatorChoice' : 'opponentChoice';
    final newChoiceIndex =
        choice == null ? null : ChoosingChoice.values.indexOf(choice);
    try {
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(widget.gameRef);
        if (gameDoc.get('creatorIsWhite') == null) {
          transaction.update(
            widget.gameRef,
            {choiceField: newChoiceIndex, ...update},
          );
        }
      });
      // game.setInitialPieces();
    } on FirebaseException catch (error) {
      print(error);
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    gameFuture = getGame();
    gameStream = widget.gameRef.snapshots();
    piecesStream = widget.gameRef.collection('pieces').snapshots();
  }

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
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
            // print(snapshot.requireData);
          }
          if (game.creatorIsWhite != null) {
            userColor = userIsCreator
                ? (game.creatorIsWhite! ? ChessColor.white : ChessColor.black)
                : (game.creatorIsWhite! ? ChessColor.black : ChessColor.white);
          }
          return StreamBuilder(
            stream: gameStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.hasData) {
                final json =
                    snapshot.requireData.data() as Map<String, Object?>;
                game = ChessGame.fromJson(json);
                turnColor =
                    game.turn % 2 == 0 ? ChessColor.white : ChessColor.black;
              }
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return const Center(
                    child: Text('none??'),
                  );
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  return const Center(
                    child: Text('Guess it\'s over?'),
                  );
                case ConnectionState.active:
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: game.creatorIsWhite != null
                                ? Column(
                                    children: [
                                      Text('Turn: ${game.turnColor.name}'),
                                      Expanded(
                                        child: Chessboard(
                                          game: game,
                                          // onMove: move,
                                          turnColor: turnColor,
                                          // piecesMap: piecesMap,
                                          gameRef: widget.gameRef,
                                          userDoc: widget.userDoc,
                                          userColor: userColor,
                                          piecesStream: piecesStream,
                                        ),
                                      ),
                                      Text('Your color: ${userColor.name}')
                                    ],
                                  )
                                : ColorChooser(
                                    creatorChoice: game.creatorChoice,
                                    opponentChoice: game.opponentChoice,
                                    onWantsChoosingChoice: wantsChoosingChoice,
                                  ),
                          ),
                        ),
                        const Spacer()
                      ],
                    ),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
