import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class Background extends StatelessWidget {
  final Widget child;
  final double height;
  const Background({Key? key, required this.child, required this.height})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: SizedBox(
          height: size.height,
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: Size(size.width, height),
                painter: BGCustomPainter(),
              ),
              child,
            ],
          )),
    );
  }
}

class BGCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.9998692, 0);
    path.cubicTo(
        size.width * 0.9998692,
        0,
        size.width * 1.0000167,
        size.height * 0.4160673,
        size.width * 0.9998692,
        size.height * 0.4170404);

    path.cubicTo(
        size.width * 0.9537214,
        size.height * 0.4932735,
        size.width * 0.938388,
        size.height * 0.5448430,
        size.width * 0.8127142,
        size.height * 0.6143498);

    path.cubicTo(
        size.width * 0.68700896,
        size.height * 0.6838565,
        size.width * 0.4542483,
        size.height * 0.6337220,
        size.width * 0.30400372,
        size.height * 0.688341);
    path.cubicTo(size.width * 0.0000260, size.height * 0.7439462, 0,//0.0438260,0.8439462
        size.height, 0, size.height);
    path.close();
    Paint paint = Paint()..style = PaintingStyle.fill;
    paint.shader = ui.Gradient.linear(
        Offset(size.width * 0.0500000, size.height * 0.05400000),
        Offset(size.width * 0.05460000, size.height * 0.93900000), [
      const Color(0xB758F10B).withOpacity(1),
      const Color.fromARGB(255, 226, 176, 156).withOpacity(1),
    ], [
      0,
      1
    ]);
    canvas.drawPath(path, paint);
    canvas.drawShadow(path, Colors.white, 6.0, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
