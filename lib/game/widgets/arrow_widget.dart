import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/logic/direction.dart';
import 'arrow_painter.dart';

class ArrowWidget extends StatefulWidget {
  final Direction direction;
  final bool isRemovable;
  final bool isBlocked;
  final bool isHinted;
  final bool isNew;
  final VoidCallback onTap;
  final double tileSize;
  final bool isDark;
  final bool compact;

  const ArrowWidget({
    super.key,
    required this.direction,
    required this.isRemovable,
    required this.isBlocked,
    required this.isHinted,
    required this.isNew,
    required this.onTap,
    required this.tileSize,
    required this.isDark,
    this.compact = false,
  });

  @override
  State<ArrowWidget> createState() => _ArrowWidgetState();
}

class _ArrowWidgetState extends State<ArrowWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late AnimationController _hintCtrl;
  late AnimationController _entranceCtrl;
  late Animation<double> _shakeAnim;
  late Animation<double> _hintGlow;
  late Animation<double> _entranceScale;
  late Animation<double> _entranceFade;

  bool _wasBlocked = false;
  bool _wasHinted = false;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut));

    _hintCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _hintGlow = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _hintCtrl, curve: Curves.easeInOut),
    );

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _entranceScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutBack),
    );
    _entranceFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );

    if (widget.isNew) {
      _entranceCtrl.forward();
    } else {
      _entranceCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ArrowWidget old) {
    super.didUpdateWidget(old);

    if (widget.isBlocked && !_wasBlocked) {
      _shakeCtrl.forward(from: 0);
    }
    _wasBlocked = widget.isBlocked;

    if (widget.isHinted && !_wasHinted) {
      _hintCtrl.repeat(reverse: true);
    } else if (!widget.isHinted && _wasHinted) {
      _hintCtrl.stop();
      _hintCtrl.value = 0;
    }
    _wasHinted = widget.isHinted;
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _hintCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Color get _arrowColor {
    if (widget.isBlocked) return AppColors.errorRed;
    return widget.isDark ? AppColors.arrowDark : AppColors.arrowLight;
  }

  Color get _tileColor {
    if (widget.isBlocked) return AppColors.errorRedLight;
    if (widget.isDark) return AppColors.tileFillDark;
    return AppColors.tileFillLight;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceFade,
      child: ScaleTransition(
        scale: _entranceScale,
        child: AnimatedBuilder(
          animation: _shakeAnim,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeAnim.value, 0),
            child: child,
          ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _hintGlow,
              builder: (context, child) {
                return Container(
                  width: widget.tileSize,
                  height: widget.tileSize,
                  decoration: BoxDecoration(
                    color: _tileColor,
                    borderRadius: BorderRadius.circular(AppRadii.tile),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isHinted
                            ? AppColors.accent.withValues(alpha: _hintGlow.value * 0.6)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: widget.isHinted ? 12 : 4,
                        spreadRadius: widget.isHinted ? 2 : 0,
                      ),
                    ],
                    border: widget.isHinted
                        ? Border.all(
                            color: AppColors.accent.withValues(alpha: _hintGlow.value),
                            width: 2,
                          )
                        : null,
                  ),
                  child: child,
                );
              },
              child: CustomPaint(
                painter: ArrowPainter(
                  direction: widget.direction,
                  color: _arrowColor,
                  compact: widget.compact,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
