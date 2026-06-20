import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LivesBar extends StatelessWidget {
  final int lives;
  final int maxLives;

  const LivesBar({super.key, required this.lives, required this.maxLives});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < maxLives; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _HeartIcon(filled: i < lives),
          ),
      ],
    );
  }
}

class _HeartIcon extends StatefulWidget {
  final bool filled;
  const _HeartIcon({required this.filled});

  @override
  State<_HeartIcon> createState() => _HeartIconState();
}

class _HeartIconState extends State<_HeartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _prevFilled = true;

  @override
  void initState() {
    super.initState();
    _prevFilled = widget.filled;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.4), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_HeartIcon old) {
    super.didUpdateWidget(old);
    if (!widget.filled && _prevFilled) {
      _ctrl.forward(from: 0);
    }
    _prevFilled = widget.filled;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(
        widget.filled ? Icons.favorite : Icons.favorite_border,
        color: widget.filled ? AppColors.heartActive : AppColors.heartEmpty,
        size: 24,
      ),
    );
  }
}
