import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game/logic/direction.dart';

class ArrowPainter extends CustomPainter {
  final Direction direction;
  final Color color;
  final double opacity;

  const ArrowPainter({
    required this.direction,
    required this.color,
    this.opacity = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    final arrowSize = size.width * 0.60;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    final angle = _angleFor(direction);
    canvas.rotate(angle);

    _drawArrow(canvas, paint, arrowSize);
    canvas.restore();
  }

  void _drawArrow(Canvas canvas, Paint paint, double size) {
    final halfW = size * 0.28;
    final tipY = -size * 0.42;
    final shaftTop = -size * 0.08;
    final shaftBot = size * 0.38;
    final shaftHalf = halfW * 0.55;
    final wingX = halfW * 1.0;
    final wingY = -size * 0.05;

    // Smooth chevron arrow
    final path = Path()
      ..moveTo(0, tipY)
      ..lineTo(wingX, wingY)
      ..lineTo(shaftHalf, shaftTop)
      ..lineTo(shaftHalf, shaftBot)
      ..lineTo(-shaftHalf, shaftBot)
      ..lineTo(-shaftHalf, shaftTop)
      ..lineTo(-wingX, wingY)
      ..close();

    canvas.drawPath(path, paint);

    // Rounded tip
    final tipPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, tipY), shaftHalf * 0.7, tipPaint);
  }

  double _angleFor(Direction dir) {
    switch (dir) {
      case Direction.up:
        return 0;
      case Direction.right:
        return math.pi / 2;
      case Direction.down:
        return math.pi;
      case Direction.left:
        return -math.pi / 2;
    }
  }

  @override
  bool shouldRepaint(ArrowPainter old) =>
      old.direction != direction || old.color != color || old.opacity != opacity;
}
