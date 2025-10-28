import 'package:chesster/chessboard.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const Chesster());
}

class Chesster extends StatelessWidget {
  const Chesster({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Chessboard(),
    );
  }
}
