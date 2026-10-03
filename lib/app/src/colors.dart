import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AppColors {
  // Tebyan identity (olive greens)
  static Color primaryColor = HexColor("#273526");
  static Color color1 = HexColor("#45624e");
  static Color color2 = HexColor("#6c8776");
  static Color color3 = HexColor("#c0cfb2");
  static Color color4 = HexColor("#e4e6d9");

  // Supporting colors
  static Color background = HexColor("#f6f7f1");
  static Color accent = HexColor("#c9963f"); // warm sand / gold
  static Color success = HexColor("#2e7d4f");
  static Color danger = HexColor("#b3261e");
  static Color warning = HexColor("#c77700");

  static LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [HexColor("#1d291c"), HexColor("#2f4532"), HexColor("#45624e")],
  );

  /// A palette used to give every course its own colour.
  static List<Color> coursePalette = [
    HexColor("#45624e"),
    HexColor("#8a6d3b"),
    HexColor("#4f6d7a"),
    HexColor("#7a5c61"),
    HexColor("#5f7a3a"),
    HexColor("#3d5a6c"),
  ];

  static Color courseColor(String seed) {
    if (seed.isEmpty) return coursePalette.first;
    final sum = seed.codeUnits.fold<int>(0, (a, b) => a + b);
    return coursePalette[sum % coursePalette.length];
  }
}
