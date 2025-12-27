import 'package:chesster/screens/username_form.dart';
import 'package:chesster/widgets/games_list.dart';
import 'package:chesster/screens/new_game.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class ChessHome extends StatelessWidget {
  const ChessHome({
    super.key,
    // this.userImageUrl,
  });

  // final String? userImageUrl;

  void addNewGameToActive(gameRef) {}

  Stream<DocumentSnapshot<Map<String, Object?>>> getUserDoc() {
    final user = FirebaseAuth.instance.currentUser!;
    return db.collection('users').doc(user.uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, Object?>>>? getActiveGames(
      DocumentSnapshot<Map<String, dynamic>> userdoc) {
    final userdata = userdoc.data()!;
    final List<String> activeGameIds = List<String>.from(userdata['games']!);
    if (activeGameIds.isEmpty) return null;
    return db
        .collection('games')
        .orderBy('creatorIsWhite', descending: true)
        .where(
          FieldPath.documentId,
          whereIn: activeGameIds.isEmpty ? null : activeGameIds,
        )
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, Object?>>> getOpenGames(
      DocumentSnapshot<Map<String, dynamic>> userdoc) {
    final userdata = userdoc.data()!;
    final username = userdata['username'] as String;
    return db
        .collection('games')
        .where('opponent', isNull: true)
        .where(
          'creator',
          isNotEqualTo: username,
        )
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Chesster',
            style: theme.textTheme.headlineSmall,
          ),
          backgroundColor: theme.colorScheme.surfaceContainer,
          actions: [
            IconButton(
              onPressed: () async {
                final newGameRef =
                    await Navigator.of(context).push<DocumentReference>(
                  MaterialPageRoute(
                    builder: (context) => const NewGameScreen(),
                  ),
                );
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
        body: StreamBuilder(
            stream: getUserDoc(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return const Center(
                    child: Text('uh oh'),
                  );
                case ConnectionState.none:
                case ConnectionState.waiting:
                  print(snapshot.connectionState);
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('uh oh, something broke'),
                    );
                  }
                  if (!snapshot.data!.exists && context.mounted) {
                    return const UsernameForm();
                  }
                  final userDoc = snapshot.requireData;
                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GamesList(
                          stream: () => getActiveGames(userDoc),
                          noGamesMessage: 'No active games! Make one!',
                          tileColor: theme.colorScheme.onSecondary,
                          labelText: 'Active',
                          userDoc: userDoc,
                        ),
                        const SizedBox(height: 8),
                        GamesList(
                          stream: () => getOpenGames(userDoc),
                          noGamesMessage: 'No available games :(',
                          tileColor: theme.colorScheme.onPrimary,
                          labelText: 'Available',
                          userDoc: userDoc,
                        ),
                      ],
                    ),
                  );
              }
            }));
  }
}
