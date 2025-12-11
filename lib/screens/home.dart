import 'package:chesster/help/cache_query.dart';
import 'package:chesster/widgets/games_list.dart';
import 'package:chesster/screens/new_game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class ChessHome extends StatelessWidget {
  const ChessHome({super.key});

  Future<DocumentSnapshot<Map<String, Object?>>> getUserDoc() async {
    final user = FirebaseAuth.instance.currentUser!;
    return db.collection('users').doc(user.uid).get();
    // return queryCache(db.collection('users').doc(user.uid));
  }

  Future<List<QueryDocumentSnapshot<Map<String, Object?>>>> getActiveGames(
      DocumentSnapshot<Map<String, dynamic>> userdoc) async {
    final userdata = userdoc.data()!;
    final List<String> activeGameIds = List<String>.from(userdata['games']!);
    if (activeGameIds.isEmpty) return [];
    final activeGames = await db
        .collection('games')
        .where(
          FieldPath.documentId,
          whereIn: activeGameIds,
        )
        .get();
    return activeGames.docs;
  }

  Future<List<QueryDocumentSnapshot<Map<String, Object?>>>> getOpenGames(
      DocumentSnapshot<Map<String, dynamic>> userdoc) async {
    final userdata = userdoc.data()!;
    final username = userdata['username'] as String;
    final openGames = await db
        .collection('games')
        .where('opponent', isNull: true)
        .where(
          'creator',
          isNotEqualTo: username,
        )
        .get();
    return openGames.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('chesster'),
          actions: [
            IconButton(
              onPressed: () {
                final newGameRef =
                    Navigator.of(context).push<DocumentReference>(
                  MaterialPageRoute(
                    builder: (context) => const NewGameScreen(),
                  ),
                );
                print(newGameRef);
              },
              icon: const Icon(Icons.add),
            ),
          ],
          leading: IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ),
        body: FutureBuilder(
            future: getUserDoc(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.done:
                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GamesList(
                          futureGetter: () async =>
                              getActiveGames(snapshot.requireData),
                          noGamesMessage: 'No active games! Make one!',
                        ),
                        const SizedBox(height: 18),
                        GamesList(
                          futureGetter: () async =>
                              getOpenGames(snapshot.requireData),
                          noGamesMessage: 'No available games :(',
                        ),
                      ],
                    ),
                  );
              }
            }));
  }
}
