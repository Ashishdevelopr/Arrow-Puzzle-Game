import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../game/logic/direction.dart';

class ArrowPainter extends CustomPainter {
  final Direction direction;
  final Color color;
  final double opacity;
  /// When true, draws a slimmer arrow suited for dense/crowded boards.
  final bool compact;

  const ArrowPainter({
    required this.direction,
    required this.color,
    this.opacity = 1.0,
    this.compact = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width / 2, size.height / 2);
    // Compact arrows are drawn at 52% of cell; normal at 60%.
    final arrowSize = size.width * (compact ? 0.52 : 0.60);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_angleFor(direction));
    _drawArrow(canvas, paint, arrowSize);
    canvas.restore();
  }

  void _drawArrow(Canvas canvas, Paint paint, double size) {
    // Compact: narrower shaft (0.16 vs 0.26), tighter head (0.20 vs 0.26).
    final shaftHalfW = size * (compact ? 0.16 : 0.26);
    final headHalfW  = size * (compact ? 0.30 : 0.44);
    final tipY       = -size * 0.44;
    final headBaseY  = -size * 0.08;
    final shaftBotY  =  size * 0.42;

    final path = Path()
      ..moveTo(0, tipY)                        // tip
      ..lineTo(headHalfW, headBaseY)           // right wing
      ..lineTo(shaftHalfW, headBaseY)          // right shoulder
      ..lineTo(shaftHalfW, shaftBotY)          // right shaft bottom
      ..lineTo(-shaftHalfW, shaftBotY)         // left shaft bottom
      ..lineTo(-shaftHalfW, headBaseY)         // left shoulder
      ..lineTo(-headHalfW, headBaseY)          // left wing
      ..close();

    canvas.drawPath(path, paint);

    // Rounded cap at tip for polish.
    canvas.drawCircle(
      Offset(0, tipY),
      shaftHalfW * 0.7,
      paint,
    );
  }

  double _angleFor(Direction dir) {
    switch (dir) {
      case Direction.up:    return 0;
      case Direction.right: return math.pi / 2;
      case Direction.down:  return math.pi;
      case Direction.left:  return -math.pi / 2;
    }
  }

  @override
  bool shouldRepaint(ArrowPainter old) =>
      old.direction != direction ||
      old.color != color ||
      old.opacity != opacity ||
      old.compact != compact;
}
