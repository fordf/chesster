import 'package:chesster/help/cache_query.dart';
import 'package:chesster/models/chess.dart';
import 'package:chesster/screens/game_setup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class GamesList extends StatefulWidget {
  const GamesList({
    super.key,
    required this.stream,
    required this.noGamesMessage,
    required this.tileColor,
    required this.labelText,
    required this.userDoc,
  });

  final Stream<QuerySnapshot<Map<String, Object?>>>? Function() stream;
  final String noGamesMessage;
  final Color tileColor;
  final String labelText;
  final DocumentSnapshot<Map<String, Object?>> userDoc;

  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  Stream<QuerySnapshot<Map<String, Object?>>>? stream;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<DocumentReference<Map<String, dynamic>>> joinGame(
      QueryDocumentSnapshot<Map<String, dynamic>> game) async {
    final gameData = game.data();
    if (gameData['opponent'] != null) {
      return game.reference;
    }
    // final userDocRef = _firestore
    //     .collection('users')
    //     .doc(FirebaseAuth.instance.currentUser!.uid);
    // final userDoc = await queryCache(userDocRef);
    final username = widget.userDoc.get('username') as String;
    if (gameData['creator'] == username) {
      return game.reference;
    }
    final transactionResult = _firestore.runTransaction((transaction) async {
      final gameDoc = await transaction.get(game.reference);
      if (gameDoc.data()!['opponent'] == null) {
        return transaction
            .update(game.reference, {'opponent': username}).update(
                widget.userDoc.reference, {
          'games': FieldValue.arrayUnion([game.id]),
        });
      } else {
        return transaction;
      }
    });
    return game.reference;
  }

  @override
  void initState() {
    super.initState();
    stream = widget.stream();
  }

  @override
  Widget build(BuildContext context) {
    stream ??= widget.stream();
    final theme = Theme.of(context);

    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10),
                  child: Text(
                    widget.labelText,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('error ${snapshot.error}');
                    }
                    final List<QueryDocumentSnapshot<Map<String, Object?>>>
                        games =
                        snapshot.hasData ? snapshot.requireData.docs : [];
                    if (games.isEmpty) {
                      return RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: () async {
                          return Future(() {
                            setState(() {
                              stream = widget.stream();
                            });
                          });
                        },
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Text(widget.noGamesMessage),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: () async {
                        return Future(() {
                          setState(() {
                            stream = widget.stream();
                          });
                        });
                      },
                      child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: games.length,
                          itemBuilder: (ctx, index) {
                            final game =
                                ChessGame.fromJson(games[index].data());
                            return Card.filled(
                              color: game.creatorIsWhite == null
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onTertiary,
                              child: ListTile(
                                key: ValueKey(index),
                                title: Text(game.creator),
                                onTap: () async {
                                  final gameRef = await joinGame(games[index]);
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChessSetupScreen(
                                      gameRef: gameRef,
                                      userDoc: widget.userDoc,
                                    ),
                                  ));
                                },
                              ),
                            );
                          }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
