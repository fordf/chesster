import 'dart:math';

import 'package:chesster/models/chess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

const creatorCheck = Icon(
  Icons.check,
  color: Colors.green,
);
const opponentCheck = Icon(
  Icons.check,
  color: Colors.purpleAccent,
);

class ColorChooser extends StatelessWidget {
  final ChoosingChoice? creatorChoice;
  final ChoosingChoice? opponentChoice;
  final Future<bool> Function(ChoosingChoice) onWantsChoosingChoice;

  const ColorChooser({
    super.key,
    required this.creatorChoice,
    required this.opponentChoice,
    required this.onWantsChoosingChoice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: Row(children: [
                if (creatorChoice == ChoosingChoice.white) creatorCheck,
                if (opponentChoice == ChoosingChoice.white) opponentCheck,
              ]),
              onPressed: () async {
                final success = await onWantsChoosingChoice(
                  ChoosingChoice.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shadowColor: Colors.black,
              ),
              label: const Text('White'),
            ),
            const SizedBox(
              width: 40,
            ),
            ElevatedButton.icon(
              icon: Row(children: [
                if (creatorChoice == ChoosingChoice.black) creatorCheck,
                if (opponentChoice == ChoosingChoice.black) opponentCheck,
              ]),
              onPressed: () async {
                final success = await onWantsChoosingChoice(
                  ChoosingChoice.black,
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.white),
              label: const Text('Black'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Choose a color or flip a coin',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        ElevatedButton.icon(
          icon: Row(children: [
            if (creatorChoice == ChoosingChoice.coinflip) creatorCheck,
            if (opponentChoice == ChoosingChoice.coinflip) opponentCheck,
          ]),
          onPressed: () async {
            final success = await onWantsChoosingChoice(
              ChoosingChoice.coinflip,
            );
          },
          label: const Text('Flip a coin!'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary),
        ),
      ],
    );
  }
}
