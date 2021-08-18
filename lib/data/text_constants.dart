import 'package:flutter/material.dart';

class TextConstants {
  /// font-size used when no size is specified
  static const double defaultFontSize = 16;

  /// color used if no color is specified
  static const Color defaultColor = Colors.black;

  /// available header tags
  static const List<String> headers = const ["h1", "h2", "h3"];

  /// corresponding header-sizes
  static const Map<String, double> headerSizes = const {
    "h1": 30,
    "h2": 25,
    "h3": 20,
  };

  /// default style of labels
  static const TextStyle labelStyle = TextStyle(
    color: Colors.black,
  );

  /// available list of colors
  static const List<String> colors = [
    "#ff0000",
    "#cc0000",
    "#00ff00",
    "#6aa84f",
    "#0000ff",
    "#ffff00",
    "#ff00ff",
    "#9900ff",
    "#bf9001",
    "#666666"
  ];
}