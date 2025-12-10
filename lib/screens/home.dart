import 'package:chesster/help/cache_query.dart';
import 'package:chesster/widgets/games_list.dart';
import 'package:chesster/screens/new_game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class ChessHome extends StatelessWidget {
  const ChessHome({super.key});

  Future<QuerySnapshot<Map<String, Object?>>> getActiveGames() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userdoc = await queryCache(db.collection('users').doc(user.uid));
    final userdata = userdoc.data();
    if (userdata == null) throw ();
    final List<String> activeGameIds = List<String>.from(userdata['games']!);
    final activeGames = db
        .collection('games')
        .where(
          'id',
          whereIn: activeGameIds,
        )
        .get();
    return activeGames;
  }

  Future<QuerySnapshot<Map<String, Object?>>> getOpenGames() async {
    return db
        .collection('games')
        .where('opponent', isNull: true)
        .where(
          'creator',
          isNotEqualTo: FirebaseAuth.instance.currentUser!.displayName,
        )
        .get();
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
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Card(
                child: GamesList(
                  futureGetter: getActiveGames,
                  noGamesMessage: 'No active games! Make one!',
                ),
              ),
            ),
            const SizedBox(height: 18),
            Flexible(
              child: Card(
                child: GamesList(
                  futureGetter: getOpenGames,
                  noGamesMessage: 'No available games :(',
                ),
              ),
            ),
          ],
        ));
  }
}
