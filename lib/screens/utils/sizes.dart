import 'package:flutter/material.dart';

extension SizeBoxInt on int {
  SizedBox get w => SizedBox(width: toDouble());

  SizedBox get h => SizedBox(height: toDouble());

  SizedBox get wh => SizedBox(width: toDouble(), height: toDouble());

  Widget get horizontalSpace => SizedBox(width: toDouble());

  Widget get verticalSpace => SizedBox(height: toDouble());
}
