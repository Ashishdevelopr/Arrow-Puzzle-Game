import 'package:flutter/material.dart';
import '../../game/logic/direction.dart';
import '../../core/theme/app_colors.dart';
import 'arrow_painter.dart';

class FlyingArrowData {
  final int id;
  final int row, col;
  final Direction direction;
  final double startX, startY, tileSize;

  FlyingArrowData({
    required this.id,
    required this.row,
    required this.col,
    required this.direction,
    required this.startX,
    required this.startY,
    required this.tileSize,
  });
}

class FlyingArrow extends StatefulWidget {
  final FlyingArrowData data;
  final bool isDark;
  final int rows, cols;
  final double tileSize, gap;
  final bool compact;

  const FlyingArrow({
    super.key,
    required this.data,
    required this.isDark,
    required this.rows,
    required this.cols,
    required this.tileSize,
    required this.gap,
    this.compact = false,
  });

  @override
  State<FlyingArrow> createState() => _FlyingArrowState();
}

class _FlyingArrowState extends State<FlyingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _posAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    final dir = widget.data.direction;
    final tileSize = widget.tileSize;
    final gap = widget.gap;
    final boardW = widget.cols * (tileSize + gap);
    final boardH = widget.rows * (tileSize + gap);

    double endDx = 0, endDy = 0;
    switch (dir) {
      case Direction.up:
        endDy = -(widget.data.startY + tileSize + 40);
        break;
      case Direction.down:
        endDy = boardH - widget.data.startY + 40;
        break;
      case Direction.left:
        endDx = -(widget.data.startX + tileSize + 40);
        break;
      case Direction.right:
        endDx = boardW - widget.data.startX + 40;
        break;
    }

    _posAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(endDx, endDy),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0)),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tileSize = widget.data.tileSize;
    final color = widget.isDark ? AppColors.arrowDark : AppColors.arrowLight;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Positioned(
        left: widget.data.startX + _posAnim.value.dx,
        top: widget.data.startY + _posAnim.value.dy,
        child: Opacity(
          opacity: _fadeAnim.value,
          child: SizedBox(
            width: tileSize,
            height: tileSize,
            child: CustomPaint(
              painter: ArrowPainter(
                direction: widget.data.direction,
                color: color,
                compact: widget.compact,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
