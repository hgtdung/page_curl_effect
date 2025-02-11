import 'package:page_curl_effect/src/model/coordinates/f_point.dart';

/// This curve would be drawn by Conic Bezier Curve
class MiddlePageCurve {
  /// Bezier start point
  FPoint startPoint;

  /// Bezier control point
  FPoint controlPoint;

  /// Bezier end point
  FPoint endPoint;

  /// Conic weigjt
  double weight;

  /// T [0,1] Using to draw part of curve
  double endT;

  MiddlePageCurve({
    required this.startPoint,
    required this.controlPoint,
    required this.endPoint,
    required this.weight,
    required this.endT
  });
}