import 'package:flutter/material.dart';
import 'dart:math' show min;

class ScreenSize {
  static double width(BuildContext context, {double percentage = 1.0}) {
    return percentage * MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context, {double percentage = 1.0}) {
    return percentage * MediaQuery.of(context).size.height;
  }

  static double shorterSide(BuildContext context, {double percentage = 1.0}) {
    return percentage *
        min(ScreenSize.width(context), ScreenSize.height(context));
  }
}
