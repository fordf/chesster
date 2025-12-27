import 'dart:math';

import 'package:chesster/models/chess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _firestore = FirebaseFirestore.instance;

class ColorChooser extends StatelessWidget {
  final int wantsBlack;
  final int wantsWhite;
  final int wantsCoinFlip;
  final Future<bool> Function(ChoosingChoice) onWantsChoosingChoice;

  const ColorChooser({
    super.key,
    required this.wantsBlack,
    required this.wantsWhite,
    required this.wantsCoinFlip,
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
              icon: wantsWhite > 0
                  ? Row(
                      children: List.filled(
                          wantsWhite,
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                          )),
                    )
                  : null,
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
              icon: wantsBlack > 0
                  ? Row(
                      children: List.filled(
                          wantsBlack,
                          const Icon(
                            Icons.check,
                            color: Colors.green,
                          )),
                    )
                  : null,
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
          icon: wantsCoinFlip > 0
              ? Row(
                  children: List.filled(
                      wantsCoinFlip,
                      const Icon(
                        Icons.check,
                        color: Colors.green,
                      )),
                )
              : null,
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
