import 'dart:ui';

import 'package:page_curl_effect/src/model/coordinates/f_point.dart';
import 'package:page_curl_effect/src/model/coordinates/o_point.dart';
import 'package:page_curl_effect/src/page_curl_math/page_curl_math.dart';

/// The movement of the animation will be represented by a Cylinder
/// In two dimension it will be a rectangular
class Cylinder {
  /// The size of the page that applies page curl animation
  final Size paperSize;

  /// The top left of the rectangular
  final FPoint topLeft;

  /// The top right of the rectangular
  final FPoint topRight;

  /// The top center of the rectangular
  final FPoint topCenter;

  /// The bottom left of the rectangular
  final FPoint bottomLeft;

  /// The bottom right of the rectangular
  final FPoint bottomRight;

  /// The bottom center of the rectangular
  final FPoint bottomCenter;

  /// The center of the rectangular
  final FPoint center;

  /// The width of the rectangular
  final double range;

  /// The rotation angle of the rectangular
  final double angle;

  /// null: default pivot is the center
  /// A new pivot
  final OPoint? pivot;
  Cylinder(
      {required this.paperSize,
      required this.topLeft,
      required this.topRight,
      required this.bottomLeft,
      required this.bottomRight,
      required this.center,
      required this.topCenter,
      required this.bottomCenter,
      required this.range,
      required this.angle,
      this.pivot});

  factory Cylinder.from(
      Offset localPosition, double cylinderRadius, Size paperSize) {
    var distanceFromRight = paperSize.width - localPosition.dx;
    var chopstickRange = (distanceFromRight / 2) - cylinderRadius;

    var topLeft = FPoint(localPosition.dx, 0);
    var topRight = FPoint(localPosition.dx + chopstickRange, 0);
    var bottomLeft = FPoint(localPosition.dx, topLeft.y + paperSize.height);
    var bottomRight = FPoint(
        localPosition.dx + chopstickRange, topRight.y + paperSize.height);

    FPoint center =
        FPoint(localPosition.dx + chopstickRange / 2, paperSize.height / 2);
    FPoint centerTop = FPoint(topLeft.x + chopstickRange / 2, 0);
    FPoint centerBottom =
        FPoint(topLeft.x + chopstickRange / 2, paperSize.height);

    return Cylinder(
        paperSize: paperSize,
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        center: center,
        topCenter: centerTop,
        bottomCenter: centerBottom,
        range: chopstickRange,
        angle: 0);
  }

  Cylinder rotateBy(double newAngle, {FPoint? newPivot}) {
    late OPoint centerOxy;
    if (newPivot != null) {
      centerOxy = newPivot.toOrigin();
    } else {
      centerOxy = center.toOrigin();
    }

    /// Transform to origin coordinates
    var topLeftOxy = topLeft.toOrigin();
    var topRightOxy = topRight.toOrigin();
    var bottomLeftOxy = bottomLeft.toOrigin();
    var bottomRightOxy = bottomRight.toOrigin();
    var centerTopOxy = topCenter.toOrigin();
    var centerBottomOxy = bottomCenter.toOrigin();

    /// Rotate
    topLeftOxy = PCMath.rotateAround(topLeftOxy, centerOxy, newAngle);
    topRightOxy = PCMath.rotateAround(topRightOxy, centerOxy, newAngle);
    bottomLeftOxy = PCMath.rotateAround(bottomLeftOxy, centerOxy, newAngle);
    bottomRightOxy = PCMath.rotateAround(bottomRightOxy, centerOxy, newAngle);
    centerTopOxy = OPoint(topLeftOxy.x + (topRightOxy.x - topLeftOxy.x) / 2,
        topRightOxy.y + (topLeftOxy.y - topRightOxy.y) / 2);
    centerBottomOxy = OPoint(
        bottomLeftOxy.x + (bottomRightOxy.x - bottomLeftOxy.x) / 2,
        bottomLeftOxy.y - (bottomLeftOxy.y - bottomRightOxy.y) / 2);

    /// Limit the coordinates only in the size of the screen.
    /// If the Point is outside of the screen,
    /// then find cross with top, bottom, left, right of the screen.
    /// Find top coordinates of the rectangular
    var topLeadingIntersection =
        PCMath.findIntersectionWithOX(bottomLeftOxy, topLeftOxy);
    var topTrailingIntersection =
        PCMath.findIntersectionWithOX(bottomRightOxy, topRightOxy);
    var topCenterIntersection =
        PCMath.findIntersectionWithOX(centerBottomOxy, centerTopOxy);

    /// Reach out of width of the screen
    if (topLeadingIntersection!.x > paperSize.width) {
      topLeadingIntersection = PCMath.findIntersectionWithVerticalLine(
          bottomLeftOxy, topLeftOxy, paperSize.width);
    }
    if (topTrailingIntersection!.x > paperSize.width) {
      topTrailingIntersection = PCMath.findIntersectionWithVerticalLine(
          bottomRightOxy, topRightOxy, paperSize.width);
    }
    if (topCenterIntersection!.x > paperSize.width) {
      topCenterIntersection = PCMath.findIntersectionWithVerticalLine(
          centerTopOxy, centerBottomOxy, paperSize.width);
    }

    /// Find bottom coordinates of the rectangular
    var bottomLeadingIntersection = PCMath.findIntersectionWithHorizontalLine(
        bottomLeftOxy, topLeftOxy, -paperSize.height);
    var bottomTrailingIntersection = PCMath.findIntersectionWithHorizontalLine(
        bottomRightOxy, topRightOxy, -paperSize.height);
    var bottomCenterIntersection = PCMath.findIntersectionWithHorizontalLine(
        centerTopOxy, centerBottomOxy, -paperSize.height);

    if (bottomLeadingIntersection!.x > paperSize.width) {
      bottomLeadingIntersection = PCMath.findIntersectionWithVerticalLine(
          bottomLeftOxy, topLeftOxy, paperSize.width);
    }

    if (bottomTrailingIntersection!.x > paperSize.width) {
      bottomTrailingIntersection = PCMath.findIntersectionWithVerticalLine(
          bottomRightOxy, topRightOxy, paperSize.width);
    }

    if (bottomCenterIntersection!.x > paperSize.width) {
      bottomCenterIntersection = PCMath.findIntersectionWithVerticalLine(
          centerTopOxy, centerBottomOxy, paperSize.width);
    }

    return Cylinder(
        paperSize: paperSize,
        topLeft: topLeadingIntersection!.toFPoint(),
        topRight: topTrailingIntersection!.toFPoint(),
        topCenter: topCenterIntersection!.toFPoint(),
        bottomLeft: bottomLeadingIntersection!.toFPoint(),
        bottomRight: bottomTrailingIntersection!.toFPoint(),
        bottomCenter: bottomCenterIntersection!.toFPoint(),
        angle: newAngle,
        center: centerOxy.toFPoint(),
        range: range,
        pivot: newPivot?.toOrigin());
  }

  Cylinder translateXby(double offset) {
    return copyWith(
        topRight: FPoint(topRight.x - offset, topRight.y),
        topLeft: FPoint(topLeft.x - offset, topLeft.y),
        bottomRight: FPoint(bottomRight.x - offset, bottomRight.y),
        bottomLeft: FPoint(bottomLeft.x - offset, bottomLeft.y));
  }

  Cylinder revertRotation() {
    assert(pivot != null, "pivot should not be null");
    var topLeftOxy = this.topLeft.toOrigin();
    var topRightOxy = this.topRight.toOrigin();
    var bottomLeftOxy = this.bottomLeft.toOrigin();
    var bottomRightOxy = this.bottomRight.toOrigin();

    /// Rotate back an amount of -angle
    topLeftOxy = PCMath.rotateAround(topLeftOxy, pivot!, -this.angle);
    topRightOxy = PCMath.rotateAround(topRightOxy, pivot!, -this.angle);
    bottomLeftOxy = PCMath.rotateAround(bottomLeftOxy, pivot!, -this.angle);
    bottomRightOxy = PCMath.rotateAround(bottomRightOxy, pivot!, -this.angle);

    var topLeadingIntersection =
        PCMath.findIntersectionWithOX(bottomLeftOxy, topLeftOxy);
    var topTrailingIntersection =
        PCMath.findIntersectionWithOX(bottomRightOxy, topRightOxy);
    var bottomLeadingIntersection = PCMath.findIntersectionWithHorizontalLine(
        bottomLeftOxy, topLeftOxy, -paperSize.height);

    var bottomTrailingIntersection = PCMath.findIntersectionWithHorizontalLine(
        bottomRightOxy, topRightOxy, -paperSize.height);

    var topLeft = topLeadingIntersection!.toFPoint();
    var topRight = topTrailingIntersection!.toFPoint();
    var bottomLeft = bottomLeadingIntersection!.toFPoint();
    var bottomRight = bottomTrailingIntersection!.toFPoint();
    var angle = 0.0;
    var center = FPoint(topLeft.x + range / 2, paperSize.height / 2);
    var centerTop = FPoint(topLeft.x + (range / 2), 0);
    var centerBottom = FPoint(topLeft.x + (range / 2), paperSize.height);

    return copyWith(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        angle: angle,
        pivot: null,
        center: center,
        topCenter: centerTop,
        bottomCenter: centerBottom)
      ..rotateBy(-angle, newPivot: this.center);
  }

  Cylinder updateRange(FPoint touchPoint, double range) {
    var chopstickLeading = touchPoint.x;

    var topLeft = FPoint(chopstickLeading, 0);
    var topRight = FPoint(chopstickLeading + range, 0);
    var bottomLeft = FPoint(chopstickLeading, topLeft.y + paperSize.height);
    var bottomRight =
        FPoint(chopstickLeading + range, topRight.y + paperSize.height);
    var center = FPoint(chopstickLeading + range / 2, paperSize.height / 2);

    var centerTop = FPoint(chopstickLeading + (range / 2), 0);
    var centerBottom = FPoint(chopstickLeading + (range / 2), paperSize.height);

    return copyWith(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
        center: center,
        topCenter: centerTop,
        bottomCenter: centerBottom,
        range: range);
  }

  Cylinder copyWith(
      {Size? paperSize,
      FPoint? topLeft,
      FPoint? topRight,
      FPoint? bottomLeft,
      FPoint? bottomRight,
      FPoint? center,
      FPoint? topCenter,
      FPoint? bottomCenter,
      double? range,
      double? angle,
      OPoint? pivot}) {
    return Cylinder(
        paperSize: paperSize ?? this.paperSize,
        topLeft: topLeft ?? this.topLeft,
        topRight: topRight ?? this.topRight,
        bottomLeft: bottomLeft ?? this.bottomLeft,
        bottomRight: bottomRight ?? this.bottomRight,
        center: center ?? this.center,
        topCenter: topCenter ?? this.topCenter,
        bottomCenter: bottomCenter ?? this.bottomCenter,
        range: range ?? this.range,
        angle: angle ?? this.angle,
        pivot: pivot ?? this.pivot);
  }
}
