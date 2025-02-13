import 'package:flutter/material.dart';
import 'package:page_curl_effect/src/model/coordinates/f_point.dart';
import 'package:page_curl_effect/src/model/cylinder.dart';
import 'package:page_curl_effect/src/page_curl_math/page_curl_math.dart';
import 'package:page_curl_effect/src/state_management/state/horizontal_page_curl.dart';
import 'package:page_curl_effect/src/state_management/state/middle_paper_curl.dart';

class PageCurlClipper extends CustomClipper<Path> {
  Cylinder? nullableCylinder;
  HorizontalPageCurve? nullableHorizontalPageCurve;
  MiddlePageCurve? nullableMiddlePageCurve;

  PageCurlClipper(
      {this.nullableCylinder,
      this.nullableHorizontalPageCurve,
      this.nullableMiddlePageCurve});
  @override
  Path getClip(Size size) {
    final path = Path();

    if (nullableCylinder == null) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
      return path;
    }
    var cylinder = nullableCylinder!;

    if (cylinder.angle == 0) {
      path.moveTo(0, size.height);
      path.lineTo(cylinder.bottomRight.x, cylinder.bottomRight.y);
      path.lineTo(cylinder.topRight.x, cylinder.topRight.y);
      path.lineTo(0, 0);
    } else {
      var horizontalPageCurve = nullableHorizontalPageCurve!;
      var middlePageCurve = nullableMiddlePageCurve!;

      if (cylinder.angle > 0) {
        path.moveTo(0, size.height);
      } else {
        path.moveTo(0, 0);
      }

      /// Draw the Bezier curve to the fold point
      var horizontalEndPoint = horizontalPageCurve.endPoint;
      var horizontalStartPoint = horizontalPageCurve.startPoint;
      var horizontalFoldPoint = horizontalPageCurve.foldPoint;

      /// Fix t_c of Quadratic Bezier curve
      double tc = 0.3;
      FPoint horizontalControlPoint = PCMath.calculateControlPoint(
          horizontalStartPoint, horizontalEndPoint, horizontalFoldPoint, tc);

      for (double t = 0; t <= tc; t += 0.01) {
        final point = PCMath.getPointOnQuadraticCurve(t, horizontalStartPoint,
            horizontalControlPoint, horizontalEndPoint);
        path.lineTo(point.x, point.y);
      }
      path.lineTo(horizontalFoldPoint.x, horizontalFoldPoint.y);

      if ((middlePageCurve.endPoint.x <= cylinder.topRight.x &&
              cylinder.topRight.x < size.width &&
              cylinder.angle > 0) ||
          (middlePageCurve.endPoint.x <= cylinder.bottomRight.x &&
              cylinder.bottomRight.x < size.width &&
              cylinder.angle < 0)) {
        double? crossT = PCMath.findTAtConicCrossLine(
            horizontalEndPoint,
            middlePageCurve.controlPoint,
            middlePageCurve.endPoint,
            middlePageCurve.weight,
            cylinder.topRight,
            cylinder.bottomRight);
        late double t;
        if (crossT != null && cylinder.angle < 10) {
          t = crossT;
          FPoint point = PCMath.getPointOnConicCurve(
              t,
              horizontalEndPoint,
              middlePageCurve.controlPoint,
              middlePageCurve.endPoint,
              middlePageCurve.weight);
          path.lineTo(point.x, point.y);
          for (t; t <= 1; t += 0.01) {
            final point = PCMath.getPointOnConicCurve(
                t,
                horizontalEndPoint,
                middlePageCurve.controlPoint,
                middlePageCurve.endPoint,
                middlePageCurve.weight);
            path.lineTo(point.x, point.y);
          }
        } else {
          t = middlePageCurve.endT;
        }
        cylinder.angle > 0
            ? path.lineTo(cylinder.topRight.x, cylinder.topRight.y)
            : path.lineTo(cylinder.bottomRight.x, cylinder.bottomRight.y);
      } else {
        /// draw from fold point to conic inflection point
        FPoint conicInflectionPoint = PCMath.getPointOnConicCurve(
            middlePageCurve.endT,
            horizontalEndPoint,
            middlePageCurve.controlPoint,
            middlePageCurve.endPoint,
            middlePageCurve.weight);

        double? crossT = PCMath.findTAtConicCrossLine(
            horizontalEndPoint,
            middlePageCurve.controlPoint,
            middlePageCurve.endPoint,
            middlePageCurve.weight,
            cylinder.topRight,
            cylinder.bottomRight);
        FPoint? crossPoint;

        double t = middlePageCurve.endT;

        if (crossT != null && cylinder.angle < 10) {
          crossPoint = PCMath.getPointOnConicCurve(
              crossT,
              horizontalEndPoint,
              middlePageCurve.controlPoint,
              middlePageCurve.endPoint,
              middlePageCurve.weight);
          path.lineTo(crossPoint.x, crossPoint.y);
          t = crossT;
        } else {
          path.lineTo(conicInflectionPoint.x, conicInflectionPoint.y);
        }

        /// draw conic curve to end point
        for (t; t <= 1; t += 0.01) {
          final point = PCMath.getPointOnConicCurve(
              t,
              horizontalEndPoint,
              middlePageCurve.controlPoint,
              middlePageCurve.endPoint,
              middlePageCurve.weight);
          path.lineTo(point.x, point.y);
        }
        path.lineTo(middlePageCurve.endPoint.x, middlePageCurve.endPoint.y);
      }

      /// Draw to finish the boundary
      if (cylinder.angle > 0) {
        cylinder.topRight.x == size.width ? path.lineTo(size.width, 0) : ();
        path.lineTo(0, 0);
        path.lineTo(0, size.height);
      } else if (cylinder.angle < 0) {
        cylinder.bottomRight.x == size.width
            ? path.lineTo(size.width, size.height)
            : ();
        path.lineTo(0, size.height);
        path.lineTo(0, 0);
      }
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
