import 'package:chesster/help/cache_query.dart';
import 'package:chesster/models/chess.dart';
import 'package:chesster/screens/chess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GamesList extends StatefulWidget {
  const GamesList(
      {super.key, required this.futureGetter, required this.noGamesMessage});

  final Future<QuerySnapshot<Map<String, Object?>>> Function() futureGetter;
  final String noGamesMessage;

  @override
  State<GamesList> createState() => _GamesListState();
}

class _GamesListState extends State<GamesList> {
  late final Future<QuerySnapshot<Map<String, Object?>>> future;

  Future<DocumentReference<Map<String, dynamic>>> joinGame(
      QueryDocumentSnapshot<Map<String, dynamic>> game) async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await queryCache(userDocRef);
    final username = userDoc.get('username') as String;
    final batch = FirebaseFirestore.instance.batch();
    batch.update(game.reference, {'opponent': username});
    batch.update(userDocRef, {
      'games': FieldValue.arrayUnion([game.id]),
    });
    await batch.commit();
    return game.reference;
  }

  @override
  void initState() {
    super.initState();
    future = widget.futureGetter();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        return Future(() {
          setState(() {
            future = widget.futureGetter();
          });
        });
      },
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('error ${snapshot.error}');
          }
          final games = snapshot.requireData.docs;
          if (games.isEmpty) {
            return Center(
              child: Text(widget.noGamesMessage),
            );
          }
          return ListView.builder(
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
                        builder: (context) => ChessScreen(gameRef: gameRef),
                      ));
                    },
                  ),
                );
              });
        },
      ),
    );
  }
}
