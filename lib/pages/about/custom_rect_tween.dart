import 'dart:ui';

import 'package:flutter/widgets.dart';

/// {@template custom_rect_tween}
/// Linear RectTween with a [Curves.easeOut] curve.
///
/// Less dramatic that the regular [RectTween] used in [Hero] animations.
/// {@endtemplate}
class CustomRectTween extends RectTween {
  /// {@macro custom_rect_tween}
  CustomRectTween({
    required Rect begin,
    required Rect end,
  }) : super(begin: begin, end: end);

  @override
  Rect lerp(double t) {
    final elasticCurveValue = Curves.easeOut.transform(t);
    double? xleft = begin!.left;
    double? yleft = end!.left;
    double? xRight = begin!.right;
    double? yRight = end!.right;
    double? xtop = begin!.top;
    double? ytop = end!.top;
    double? xBottom = begin!.bottom;
    double? yBottom = end!.bottom;
    return Rect.fromLTRB(
      lerpDouble(xleft, yleft, elasticCurveValue)!,
      lerpDouble(xtop, ytop, elasticCurveValue)!,
      lerpDouble(xRight, yRight, elasticCurveValue)!,
      lerpDouble(xBottom, yBottom, elasticCurveValue)!,
    );

   
  }
}
