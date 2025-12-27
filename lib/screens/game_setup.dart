import 'package:chesster/help/cache_query.dart';
import 'package:chesster/models/chess.dart';
import 'package:chesster/widgets/chess_color_chooser.dart';
import 'package:chesster/widgets/chessboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late ChessGame game;
  late final bool userIsCreator;
  bool setupComplete = false;

  Future<void> getGame() async {
    final gameDoc = await widget.gameRef.get();
    final piecesCollection = await widget.gameRef.collection('pieces').get();
    final pieces = {
      for (final x in piecesCollection.docs) int.parse(x.id): x.data()
    };
    game = ChessGame.fromJson(gameDoc.data()!);
    userIsCreator = game.creator == (widget.userDoc.get('username') as String);
    game.setIndexesMap(pieces);
    if (game.creatorIsWhite != null) {
      setState(() {
        setupComplete = true;
      });
    }
  }

  Future<bool> wantsChoosingChoice(ChoosingChoice choice) async {
    try {
      final choiceField = userIsCreator ? 'creatorChoice' : 'opponentChoice';
      await _firestore.runTransaction((transaction) async {
        final gameDoc = await transaction.get(widget.gameRef);
        final Map<String, Object?> update = {};
        if (gameDoc.get('creatorIsWhite') == null) {
          final prevChoiceIndex = gameDoc.get(choiceField);
          final newChoiceIndex = ChoosingChoice.values.indexOf(choice);
          if (prevChoiceIndex == newChoiceIndex) return;
          update[choiceField] = newChoiceIndex;
          if (prevChoiceIndex != null) {
            final prevChoice = ChoosingChoice.values[prevChoiceIndex as int];
            update[prevChoice.name] = FieldValue.increment(-1);
          }
          update[choice.name] = FieldValue.increment(1);
          transaction.update(widget.gameRef, update);
        }
      });
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
              gameStream = widget.gameRef.snapshots();
          }
          return StreamBuilder(
            stream: gameStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.hasData) {
                game = ChessGame.fromJson(
                    snapshot.requireData.data() as Map<String, Object?>);
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
                            child: setupComplete
                                ? Chessboard(game: game)
                                : ColorChooser(
                                    wantsBlack: game.wantsBlack,
                                    wantsWhite: game.wantsWhite,
                                    wantsCoinFlip: game.wantsCoinFlip,
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
