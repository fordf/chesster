import 'package:flutter/material.dart';

class ChessAppBar extends StatelessWidget {
  const ChessAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Chesster',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
