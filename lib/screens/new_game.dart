import 'package:chesster/help/cache_query.dart';
import 'package:chesster/models/chess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewGameScreen extends StatelessWidget {
  const NewGameScreen({super.key});

  Future<DocumentReference<Map<String, Object?>>> newGame() async {
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    final userDoc = await queryCache(userDocRef);
    final username = userDoc.get('username') as String;
    final newGame = ChessGame(username);
    final newGameRef = FirebaseFirestore.instance.collection('games').doc();
    final piecesRef = newGameRef.collection('pieces');
    final batch = FirebaseFirestore.instance.batch();
    batch.set(newGameRef, newGame.toJson);
    for (final piece in startingPieces) {
      final pieceRef = piecesRef.doc('${piece.position}');
      batch.set(pieceRef, piece.toJson);
    }
    batch.update(userDocRef, {
      'games': FieldValue.arrayUnion([newGameRef.id]),
    });
    await batch.commit();
    return newGameRef;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60.0),
        child: Center(
          child: Card(
            shape: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(80.0),
              child: ElevatedButton(
                  onPressed: () async {
                    final gameRef = await newGame();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Game created! Waiting for opponent...')),
                    );
                    Navigator.of(context).pop(gameRef);
                  },
                  child: const Text("New Game")),
            ),
          ),
        ),
      ),
    );
  }
}
