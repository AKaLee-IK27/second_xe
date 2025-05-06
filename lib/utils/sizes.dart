import 'package:flutter/material.dart';

/// Extension on [int] to create SizedBox widgets with specified dimensions.
extension SizeBoxInt on int {
  /// Returns a SizedBox with this integer as width.
  SizedBox get w => SizedBox(width: toDouble());

  /// Returns a SizedBox with this integer as height.
  SizedBox get h => SizedBox(height: toDouble());

  /// Returns a SizedBox with this integer as both width and height.
  SizedBox get wh => SizedBox(width: toDouble(), height: toDouble());

  /// Returns a SizedBox with this integer as horizontal padding (width).
  Widget get horizontalSpace => SizedBox(width: toDouble());

  /// Returns a SizedBox with this integer as vertical padding (height).
  Widget get verticalSpace => SizedBox(height: toDouble());
}
