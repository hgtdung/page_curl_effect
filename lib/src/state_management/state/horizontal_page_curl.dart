import 'package:page_curl_effect/src/model/coordinates/f_point.dart';

/// Horizontal page curve would be drawn by Quadratic Bezier Curve
class HorizontalPageCurve {
  /// Bezier start point
  FPoint startPoint;

  /// Bezier end point
  FPoint endPoint;

  /// The point that would be used to calculate Beizer control point
  FPoint foldPoint;
  HorizontalPageCurve({
    required this.startPoint,
    required this.foldPoint,
    required this.endPoint,
  });
}