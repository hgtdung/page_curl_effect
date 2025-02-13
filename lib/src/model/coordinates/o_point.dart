import 'dart:math';

import 'package:page_curl_effect/src/model/coordinates/f_point.dart';

/// Oxy coordinates point
class OPoint extends Point<double> {
  OPoint(super.x, super.y);

  FPoint toFPoint() {
    return FPoint(x, -y);
  }
}
