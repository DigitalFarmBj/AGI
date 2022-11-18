import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BubbleMessage extends SingleChildRenderObjectWidget {
  const BubbleMessage({
    Key? key,
    required this.painter,
    required Widget child,
  }) : super(key: key, child: child);

  final CustomPainter painter;

  @override
  RenderCustomPaint createRenderObject(BuildContext context) {
    return RenderCustomPaint(
      painter: painter,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCustomPaint renderObject) {
    renderObject..painter = painter;
  }
}
