import 'dart:math';

import 'package:page_curl_effect/src/model/coordinates/f_point.dart';
import 'package:page_curl_effect/src/model/coordinates/o_point.dart';

//// Page curl math
class PCMath {
  //// Rotate a point around new pivot
  static OPoint rotateAround(OPoint pointA, OPoint pivotB, double angle) {
    double angleRadian = -angle * (pi / 180);
    //// Translate A relative to B
    final double translatedX = pointA.x - pivotB.x;
    final double translatedY = pointA.y - pivotB.y;

    //// Perform rotation
    final double rotatedX =
        translatedX * cos(angleRadian) - translatedY * sin(angleRadian);

    final double rotatedY =
        translatedX * sin(angleRadian) + translatedY * cos(angleRadian);

    //// Translate back to the original position relative to B
    final double finalX = rotatedX + pivotB.x;
    final double finalY = rotatedY + pivotB.y;

    var finalResult = OPoint(finalX, finalY);
    return finalResult;
  }

  static OPoint? findIntersectionWithOX(OPoint p1, OPoint p2) {
    /// Check if the line is vertical
    if (p1.x == p2.x) {
      /// The vertical line intersects the x-axis at (p1.dx, 0)
      return OPoint(p1.x, 0);
    }

    /// Calculate slope and y-intercept
    final double m = (p2.y - p1.y) / (p2.x - p1.x);
    final double c = p1.y - m * p1.x;

    /// Calculate the intersection with the x-axis
    final double x = -c / m;

    return OPoint(x, 0);
  }

  static OPoint? findIntersectionWithVerticalLine(OPoint p1, OPoint p2, double V) {
    /// Check if the line is vertical (parallel to the y-axis)
    if (p1.x == p2.x) {
      return null; /// No intersection with vertical line, because the line is vertical
    }

    /// Calculate the slope (m) of the line
    final double m = (p2.y - p1.y) / (p2.x - p1.x);

    /// Calculate the y-intercept (c) using one of the points
    final double c = p1.y - m * p1.x;

    /// Find the y-coordinate where the line intersects the vertical line x = V
    final double y = m * V + c;

    /// Return the intersection point as an Offset (V, y)
    return OPoint(V, y);
  }

  static OPoint? findIntersectionWithHorizontalLine(OPoint p1, OPoint p2, double M) {
    /// Check if the line is vertical (parallel to the y-axis)
    if (p1.x == p2.x) {
      return OPoint(p1.x, M);
    }

    /// Calculate the slope (m) of the line
    final double m = (p2.y - p1.y) / (p2.x - p1.x);

    /// Calculate the y-intercept (c) using one of the points
    final double c = p1.y - m * p1.x;

    /// Find the x-coordinate where the line intersects the horizontal line y = M
    final double x = (M - c) / m;

    /// Return the intersection point as an Offset (x, M)
    return OPoint(x, M);
  }

  /// Function to find the symmetric point of [point]
  /// across the line defined by [linePoint1] and [linePoint2].
  static OPoint findSymmetricPoint(
      OPoint point, OPoint linePoint1, OPoint linePoint2) {
    /// Coordinates of the line
    double x1 = linePoint1.x, y1 = linePoint1.y;
    double x2 = linePoint2.x, y2 = linePoint2.y;
    double px = point.x, py = point.y;

    /// Calculate the coefficients A, B, C of the line equation Ax + By + C = 0
    double A = y2 - y1;
    double B = x1 - x2;
    double C = x2 * y1 - x1 * y2;

    /// Calculate the symmetric point
    double denominator = A * A + B * B;
    double xSymmetric = px - 2 * A * (A * px + B * py + C) / denominator;
    double ySymmetric = py - 2 * B * (A * px + B * py + C) / denominator;

    return OPoint(xSymmetric, ySymmetric);
  }


  static OPoint? twoLineIntersection(OPoint p1, OPoint p2, OPoint p3, OPoint p4) {
    double denominator = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x);

    /// If denominator is zero, the lines are parallel or coincident
    if (denominator == 0) {
      return null; /// No intersection
    }

    double t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / denominator;
    double u = ((p1.x - p3.x) * (p1.y - p2.y) - (p1.y - p3.y) * (p1.x - p2.x)) / denominator;

    /// If 0 <= t <= 1 and 0 <= u <= 1, the intersection point is on both line segments
    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      double x = p1.x + t * (p2.x - p1.x);
      double y = p1.y + t * (p2.y - p1.y);
      return OPoint(x, y);
    }

    return null; /// The intersection is outside the line segments
  }

  static OPoint? findPointOnPerpendicularBisector(OPoint a, OPoint b, double distance, bool below) {
    /// Calculate the midpoint M of AB
    double midX = (a.x + b.x) / 2;
    double midY = (a.y + b.y) / 2;
    OPoint midPoint = OPoint(midX, midY);

    /// Calculate the perpendicular vector to AB (AB is perpendicular to -dy, dx)
    double dx = b.x - a.x;
    double dy = b.y - a.y;

    /// Perpendicular vector (dx, dy) -> (-dy, dx)
    double perpX = -dy;
    double perpY = dx;

    /// Length of the perpendicular vector
    double perpLength = sqrt(perpX * perpX + perpY * perpY);

    /// Normalize the perpendicular vector
    double unitPerpX = perpX / perpLength;
    double unitPerpY = perpY / perpLength;

    /// Calculate two points on the perpendicular bisector at a distance of `distance` from M
    OPoint p1 = OPoint(midPoint.x + unitPerpX * distance, midPoint.y + unitPerpY * distance);
    OPoint p2 = OPoint(midPoint.x - unitPerpX * distance, midPoint.y - unitPerpY * distance);

    /// Only return the point below the line AB (y < midY)
    if (below) {
      return p1;
    } else {
      return p2;
    }
  }

  static FPoint calculateControlPoint(FPoint a, FPoint b, FPoint c, double tc) {
    double x1 = (c.x - (1 - tc) * (1 - tc) * a.x - tc * tc * b.x) / (2 * tc * (1 - tc));
    double y1 = (c.y - (1 - tc) * (1 - tc) * a.y - tc * tc * b.y) / (2 * tc * (1 - tc));
    return FPoint(x1, y1);
  }

  static FPoint getPointOnQuadraticCurve(double t, FPoint start, FPoint control, FPoint end) {
    double x = (1 - t) * (1 - t) * start.x +
        2 * (1 - t) * t * control.x +
        t * t * end.x;

    double y = (1 - t) * (1 - t) * start.y +
        2 * (1 - t) * t * control.y +
        t * t * end.y;

    return FPoint(x, y);
  }

  /// Function to calculate the point on the conic curve for parameter t
  static FPoint getPointOnConicCurve(double t, FPoint start, FPoint control, FPoint end, double weight) {
    double numeratorX = (1 - t) * (1 - t) * start.x +
        2 * (1 - t) * t * control.x * weight +
        t * t * end.x;

    double numeratorY = (1 - t) * (1 - t) * start.y +
        2 * (1 - t) * t * control.y * weight +
        t * t * end.y;

    double denominator = (1 - t) * (1 - t) + 2 * (1 - t) * t * weight + t * t;

    double x = numeratorX / denominator;
    double y = numeratorY / denominator;

    return FPoint(x, y);
  }


  static double? findTAtConicCrossLine(FPoint start, FPoint control, FPoint end, double conicWeight, FPoint lineStart, FPoint lineEnd) {
    bool wasCrossing = false;
    for (double t = 0; t <= 1; t += 0.01) {
      FPoint point = getPointOnConicCurve(t, start, control, end, conicWeight);
      if (isCrossingLine(point.x, point.y, lineStart, lineEnd, wasCrossing)) {
        return t;
      }
    }
    return null;
  }


  static bool isCrossingLine(double x, double y, FPoint lineStart, FPoint lineEnd, bool wasCrossing) {
    /// Cross product to determine the side of the line the point lies on
    double crossProduct = (lineEnd.x - lineStart.x) * (y - lineStart.y) -
        (lineEnd.y - lineStart.y) * (x - lineStart.x);

    bool isCrossing = crossProduct < 0;

    /// Detect change in side (crossing)
    return wasCrossing != isCrossing;
  }

  /// Map a value from range [oldMin, oldMax] to [newMin, newMax]
  static double mapRange2Range({
    required double value,
    required double oldMin,
    required double oldMax,
    required double newMin,
    required double newMax,
  }) {
    return newMin + (value - oldMin) / (oldMax - oldMin) * (newMax - newMin);
  }
  static double mapValue(double value, double fromLow, double fromHigh, double toLow, double toHigh) {
    return toLow + (value - fromLow) * (toHigh - toLow) / (fromHigh - fromLow);
  }
}