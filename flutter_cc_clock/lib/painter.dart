import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  Color shadow1;
  Color completeColor;
  double radians;
  double width;
  Painter({ this.completeColor, this.radians, this.width});

  @override
  void paint(Canvas canvas, Size size) {

    Paint complete = new Paint()
      ..color = completeColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill
      ..strokeWidth = width;
    Offset center = new Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    double arcAngle = radians;

    canvas.drawArc(new Rect.fromCircle(center: center, radius: radius), -pi / 2, arcAngle, true, complete);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
