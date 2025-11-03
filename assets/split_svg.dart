// import 'dart:io';

// const String spriteAtlasPath = 'Chess_Pieces_Sprite.svg';
// const String svgScaffold = 'svg_scaffold.svg';
// const filenames = <String>[
//   'King_White.svg',
//   'Queen_White.svg',
//   'Bishop_White.svg',
//   'Knight_White.svg',
//   'Rook_White.svg',
//   'Pawn_White.svg',
//   'King_Black.svg',
//   'Queen_Black.svg',
//   'Bishop_Black.svg',
//   'Knight_Black.svg',
//   'Rook_Black.svg',
//   'Pawn_Black.svg',
// ];

// void main() async {
//   final str = await File(spriteAtlasPath).readAsString();
//   final scaffold = await File(svgScaffold).readAsLines();
//   int start = 0;
//   for (final filename in filenames) {
//     final begin = str.indexOf('-->', start);
//     final end = str.indexOf('<!--', begin);
//     final svg = [
//       ...scaffold.sublist(0, 3),
//       str.substring(begin, end),
//       scaffold[3]
//     ].join();
//     await File(filename).writeAsString(svg);
//   }
// }
