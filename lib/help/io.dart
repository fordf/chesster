import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;

const String spriteAtlasPath = 'assets/Chess_Pieces_Sprite.svg';

Widget svgWidget() {
  return SvgPicture.asset(spriteAtlasPath, semanticsLabel: "Atlas");
}

Future<ui.Image> uiimage({width = 270, height = 90}) async {
  final rawSvg = await rootBundle.loadString(spriteAtlasPath);
  final pictureInfo = await vg.loadPicture(
    SvgStringLoader(rawSvg),
    null,
  );
  return pictureInfo.picture.toImage(width, height);
}

Future<ui.Image> loadImageFromAsset(String assetName) async {
  var buffer = await ui.ImmutableBuffer.fromAsset(assetName);
  var codec = await ui.instantiateImageCodecFromBuffer(buffer);
  var frame = await codec.getNextFrame();
  return frame.image;
}
