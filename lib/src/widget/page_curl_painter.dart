import 'package:flutter/material.dart';
import 'package:page_curl_effect/src/constants.dart';
import 'package:page_curl_effect/src/model/coordinates/f_point.dart';
import 'package:page_curl_effect/src/model/cylinder.dart';
import 'package:page_curl_effect/src/page_curl_math/page_curl_math.dart';
import 'package:page_curl_effect/src/state_management/state/horizontal_page_curl.dart';
import 'package:page_curl_effect/src/state_management/state/middle_paper_curl.dart';


/// Paint the page curl effect by two curves
class PageCurlPainter extends CustomPainter {
  Cylinder? nullableCylinder;
  HorizontalPageCurve? nullableHorizontalPageCurve;
  MiddlePageCurve? nullableMiddlePageCurve;

  PageCurlPainter(
      {this.nullableCylinder,
      this.nullableHorizontalPageCurve,
      this.nullableMiddlePageCurve});
  @override
  void paint(Canvas canvas, Size size) {
    if (nullableCylinder == null) {
      return;
    }

    var cylinder = nullableCylinder!;

    drawShadow(cylinder, nullableHorizontalPageCurve, nullableMiddlePageCurve,
        canvas, size);

    drawTurnPagePart(cylinder, nullableHorizontalPageCurve,
        nullableMiddlePageCurve, canvas, size);
  }

  void drawShadow(
      Cylinder cylinder,
      HorizontalPageCurve? nullableHorizontalPageCurve,
      MiddlePageCurve? nullableMiddlePageCurve,
      Canvas canvas,
      Size size) {
    var shadowPath = Path();

    if (cylinder.angle == 0) {
      shadowPath.moveTo(cylinder.topLeft.x, cylinder.topLeft.y);
      shadowPath.lineTo(cylinder.topRight.x, cylinder.topRight.y);
      shadowPath.lineTo(cylinder.bottomRight.x, cylinder.bottomRight.y);
      shadowPath.lineTo(cylinder.bottomLeft.x, cylinder.bottomLeft.y);
      shadowPath.lineTo(cylinder.topLeft.x, cylinder.topLeft.y);
    } else {
      var horizontalPageCurve = nullableHorizontalPageCurve!;
      var middlePageCurve = nullableMiddlePageCurve!;
      var conicWeight = middlePageCurve.weight;
      var conicT = middlePageCurve.endT;
      shadowPath.moveTo(
          horizontalPageCurve.endPoint.x, horizontalPageCurve.endPoint.y);
      if ((middlePageCurve.endPoint.x <= cylinder.topRight.x &&
              cylinder.topRight.x < size.width &&
              cylinder.angle > 0) ||
          (middlePageCurve.endPoint.x <= cylinder.bottomRight.x &&
              cylinder.bottomRight.x < size.width &&
              cylinder.angle < 0)) {
        var crossPoint = conicToCross(
            middlePageCurve.startPoint,
            middlePageCurve.controlPoint,
            middlePageCurve.endPoint,
            conicWeight,
            cylinder.topRight,
            cylinder.bottomRight,
            shadowPath);
        if (crossPoint == null) {
          cylinder.angle > 0
              ? shadowPath.lineTo(cylinder.topRight.x, cylinder.topRight.y)
              : shadowPath.lineTo(
                  cylinder.bottomRight.x, cylinder.bottomRight.y);
        }
      } else {
        for (double t = 0.0; t <= conicT; t += 0.01) {
          final point = PCMath.getPointOnConicCurve(
              t,
              middlePageCurve.startPoint,
              middlePageCurve.controlPoint,
              middlePageCurve.endPoint,
              conicWeight);
          shadowPath.lineTo(point.x, point.y);
        }
      }
      shadowPath.lineTo(
          horizontalPageCurve.foldPoint.x, horizontalPageCurve.foldPoint.y);

      /// Calculate t of the bezier curve by angle [angle, maximumAgle] => [0.5, 0.25]
      double tc =
          0.5 - ((cylinder.angle.abs() / PCConstants.maximumAngle) * 0.25);
      if (cylinder.angle.abs() > PCConstants.maximumAngle / 2) {
        tc = 0.5;
      }
      FPoint horizontalControlPoint = PCMath.calculateControlPoint(
          horizontalPageCurve.startPoint,
          horizontalPageCurve.endPoint,
          horizontalPageCurve.foldPoint,
          tc);
      for (double t = tc; t <= 1; t += 0.01) {
        final point = PCMath.getPointOnQuadraticCurve(
            t,
            horizontalPageCurve.startPoint,
            horizontalControlPoint,
            horizontalPageCurve.endPoint);
        shadowPath.lineTo(point.x, point.y);
      }
      shadowPath.lineTo(
          horizontalPageCurve.endPoint.x, horizontalPageCurve.endPoint.y);
    }

    /// Offset matrix for shadow
    Offset shadowOffset = Offset(-10, -10); // Move left (-10) and up (-10)
    shadowPath = shadowPath.shift(shadowOffset);

    canvas.drawShadow(
      shadowPath,
      Colors.black45,
      10.0,
      true,
    );
  }

  void drawTurnPagePart(
      Cylinder cylinder,
      HorizontalPageCurve? nullableHorizontalPageCurve,
      MiddlePageCurve? nullablemiddlePageCurve,
      Canvas canvas,
      Size size) {
    /// Turn page area
    var paint = Paint()
      ..color = const Color(0xffF6F6F6)
      // ..color = Colors.blue
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    /// Border
    var borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (cylinder.angle == 0) {
      path.moveTo(cylinder.topLeft.x, cylinder.topLeft.y);
      path.lineTo(cylinder.topRight.x, cylinder.topRight.y);
      path.lineTo(cylinder.bottomRight.x, cylinder.bottomRight.y);
      path.lineTo(cylinder.bottomLeft.x, cylinder.bottomLeft.y);
      path.lineTo(cylinder.topLeft.x, cylinder.topLeft.y);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    } else {
      var horizontalPageCurve = nullableHorizontalPageCurve!;
      var middlePageCurve = nullablemiddlePageCurve!;
      var conicWeight = middlePageCurve.weight;
      var conicT = middlePageCurve.endT;
      path.moveTo(horizontalPageCurve.endPoint.x, horizontalPageCurve.endPoint.y);

      /// Draw conic curve
      if ((middlePageCurve.endPoint.x <= cylinder.topRight.x &&
              cylinder.topRight.x < size.width &&
              cylinder.angle > 0) ||
          (middlePageCurve.endPoint.x <= cylinder.bottomRight.x &&
              cylinder.bottomRight.x < size.width &&
              cylinder.angle < 0)) {
        var crossPoint = conicToCross(
            middlePageCurve.startPoint,
            middlePageCurve.controlPoint,
            middlePageCurve.endPoint,
            conicWeight,
            cylinder.topRight,
            cylinder.bottomRight,
            path);
        if (crossPoint == null) {
          cylinder.angle > 0
              ? path.lineTo(cylinder.topRight.x, cylinder.topRight.y)
              : path.lineTo(cylinder.bottomRight.x, cylinder.bottomRight.y);
        }
      } else {
        FPoint? crossOffset;
        bool wasCrossing = false;

        for (double t = 0.0; t <= conicT; t += 0.01) {
          final point = PCMath.getPointOnConicCurve(
              t,
              middlePageCurve.startPoint,
              middlePageCurve.controlPoint,
              middlePageCurve.endPoint,
              conicWeight);
          path.lineTo(point.x, point.y);

          if (crossOffset == null &&
              PCMath.isCrossingLine(point.x, point.y, cylinder.topRight,
                  cylinder.bottomRight, wasCrossing)) {
            crossOffset = point;
          }
          if (crossOffset != null && cylinder.angle.abs() < 10) {
            break;
          }
        }

        /// Fix the last t not draw to
        if (conicT == 1) {
          path.lineTo(middlePageCurve.endPoint.x, middlePageCurve.endPoint.y);
        }
      }

      path.lineTo(
          horizontalPageCurve.foldPoint.x, horizontalPageCurve.foldPoint.y);

      /// Fix t_c of Quadratic Bezier curve
      double tc = 0.3;
      FPoint horizontalControlPoint = PCMath.calculateControlPoint(
          horizontalPageCurve.startPoint,
          horizontalPageCurve.endPoint,
          horizontalPageCurve.foldPoint,
          tc);
      for (double t = tc; t <= 1; t += 0.01) {
        final point = PCMath.getPointOnQuadraticCurve(
            t,
            horizontalPageCurve.startPoint,
            horizontalControlPoint,
            horizontalPageCurve.endPoint);
        path.lineTo(point.x, point.y);
      }
      path.lineTo(horizontalPageCurve.endPoint.x, horizontalPageCurve.endPoint.y);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    }
  }

  FPoint? conicToCross(FPoint start, FPoint control, FPoint end,
      double conicWeight, FPoint lineStart, FPoint lineEnd, Path? path) {
    bool wasCrossing = false;

    /// Draw Conic curve manually
    for (double t = 0; t <= 1; t += 0.01) {
      var point =
          PCMath.getPointOnConicCurve(t, start, control, end, conicWeight);
      path?.lineTo(point.x, point.y);
      if (PCMath.isCrossingLine(
          point.x, point.y, lineStart, lineEnd, wasCrossing)) {
        return point;
      }
    }
    path?.lineTo(end.x, end.y);
    return null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
