import 'package:chesster/help/cache_query.dart';
import 'package:chesster/models/chess.dart';
import 'package:chesster/screens/chess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class GamesList extends StatefulWidget {
  const GamesList(
      {super.key, required this.futureGetter, required this.noGamesMessage});

  final Future<List<QueryDocumentSnapshot<Map<String, Object?>>>> Function()
      futureGetter;
  final String noGamesMessage;

  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  late Future<List<QueryDocumentSnapshot<Map<String, Object?>>>> future;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<DocumentReference<Map<String, dynamic>>> joinGame(
      QueryDocumentSnapshot<Map<String, dynamic>> game) async {
    if (game.data()['opponent'] != null) {
      return game.reference;
    }
    final userDocRef = _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await queryCache(userDocRef);
    final username = userDoc.get('username') as String;
    final transactionResult = _firestore.runTransaction((transaction) async {
      final gameDoc = await transaction.get(game.reference);
      if (gameDoc.data()!['opponent'] == null) {
        return transaction
            .update(game.reference, {'opponent': username}).update(userDocRef, {
          'games': FieldValue.arrayUnion([game.id]),
        });
      } else {
        return transaction;
      }
    });
    print(transactionResult);
    // final batch = _firestore.batch();
    // batch.update(game.reference, {'opponent': username});
    // batch.update(userDocRef, {
    //   'games': FieldValue.arrayUnion([game.id]),
    // });
    // await batch.commit();
    return game.reference;
  }

  @override
  void initState() {
    super.initState();
    future = widget.futureGetter();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('error ${snapshot.error}');
              }
              final games = snapshot.requireData;
              if (games.isEmpty) {
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: () async {
                    return Future(() {
                      setState(() {
                        future = widget.futureGetter();
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
                      future = widget.futureGetter();
                    });
                  });
                },
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: games.length,
                    itemBuilder: (ctx, index) {
                      final game = ChessGame.fromJson(games[index].data());
                      return Card.filled(
                        child: ListTile(
                          key: ValueKey(index),
                          title: Text(game.creator),
                          onTap: () async {
                            // print(games[index].get('creator'));
                            // print(FirebaseAuth.instance.currentUser!.email);
                            final gameRef = await joinGame(games[index]);
                            if (!context.mounted) return;
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ChessScreen(gameRef: gameRef),
                            ));
                          },
                        ),
                      );
                    }),
              );
            },
          ),
        ),
      ),
    );
  }
}
